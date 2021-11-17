using Beef_Net.Connection;
using Beef_OpenSSL;
using System;
using System.IO;
using System.Reflection;

namespace Beef_Net
{
	public enum SSLMethod
	{
		// [Obsolete("Please rethink your decisions..", true)]
		// SSLv3,
		TLS,
		TLSv1,
		TLSv1_1,
		TLSv1_2
	}

	public enum SSLStatus
	{
		None        = 0x0,
		Connect     = 0x1,
		ActivateTLS = 0x2,
		Shutdown    = 0x4
	}

	[AlwaysInclude(IncludeAllMethods=true), Reflect(.All)]
	public class SSLSocket : Socket
	{
		protected SSL.ssl_st* _SSL = null ~ { if (_ != null) SSL.free(_); };
		protected SSL.CTX* _SSLContext = null;
		protected SSLStatus _SSLStatus = .None;

		public new bool Connected
		{
			get
			{
				return _socketState.HasFlag(.SSLActive)
					? _SSL != null && _SSLStatus != .None
					: _connectionStatus == .Connected;
			}
		}
		public new SocketConnectionStatus ConnectionStatus
		{
			get
			{
				if (!_socketState.HasFlag(.SSLActive))
				{
					switch (_SSLStatus)
					{
					case .None:        return _SSL != null ? .Connected : .None;
					case .Connect,
						 .ActivateTLS: return .Connecting;
					case .Shutdown:    return .Disconnecting;
					}
				}

				return base.ConnectionStatus;
			}
		}
		public SSLStatus SSLState { get { return _SSLStatus; } }
		
		protected override int32 DoSend(uint8* aData, int32 aSize)
		{
			if (_socketState.HasFlag(.SSLActive))
			{
				/*
				if (_SSLSendSize == 0)
				{
				  	_SSLSendSize = Math.Min(aSize, _SSLSendBuffer.Count);
				  	Internal.MemMove(_SSLSendBuffer[0], aData, _SSLSendSize);
				}

				int32 result = SSL.write(&_SSLSendBuffer[0], _SSL, _SSLSendSize);

				if (result > 0)
				  	_SSLSendSize = 0;

				return result;
				*/

				return (int32)SSL.write(_SSL, aData, aSize);
			}

			return base.DoSend(aData, aSize);
		}

		protected override int32 DoGet(uint8* aData, int32 aSize) =>
			_socketState.HasFlag(.SSLActive)
				? (int32)SSL.read(_SSL, aData, aSize)
				: base.DoGet(aData, aSize);

		protected override int32 HandleResult(int32 aResult, SocketOperation aOp)
		{
			if (!_socketState.HasFlag(.SSLActive))
				return base.HandleResult(aResult, aOp);

			if (aResult > 0)
				return aResult;
			
			int32 result = aResult;
			int32 lastErr = (int32)SSL.get_error(_SSL, result);

			if (IsSSLBlockError(lastErr))
			{
				switch (aOp)
				{
				case .Send:
					{
						_socketState &= ~.CanSend;
						IgnoreWrite = false;
					}
				case .Receive:
					{
						_socketState &= ~.CanReceive;
						IgnoreRead = false;
					}
				}
			}
			else if (IsSSLNonFatalError(lastErr, result))
			{
				String tmp = scope .(aOp.SSLStringValue);
				tmp.Append(" error");
		      	LogError(tmp, lastErr);
		    }
			else if (aOp == .Send && Common.IsPipeError(lastErr))
			{
		      	HardDisconnect(true);
		    }
			else
			{
				String tmp = scope .(aOp.SSLStringValue);
				tmp.Append(" error");
		      	Bail(tmp, lastErr);
			}

		    return 0;
		}

		public bool SetActiveSSL(bool aValue)
		{
			if (_socketState.HasFlag(.SSLActive) == aValue)
				return true;

			if (aValue)
				_socketState |= .SSLActive;
			else
				_socketState &= ~.SSLActive;

			if (aValue && _connectionStatus == .Connected)
				ActivateTLSEvent();

			if (!aValue)
			{
				if (ConnectionStatus == .Connected)
					ShutdownSSL();
				else if ((SSLStatus.Connect | SSLStatus.ActivateTLS).HasFlag(_SSLStatus))
					Runtime.FatalError("Switching SSL mode on socket during SSL handshake is not supported");
			}

			return true;
		}

		protected void SetupSSLSocket()
		{
			if (_SSL != null)
				SSL.free(_SSL);

			_SSL = SSL.new_(_SSLContext);

			if (_SSL == null)
			{
				Bail("SSL_new error", -1);
				return;
			}

			if (SSL.set_fd(_SSL, (int)_handle) == 0)
			{
				_SSL = null;
				Bail("SSL_set_fd error", -1);
				return;
			}
		}

		protected void ActivateTLSEvent()
		{
			SetupSSLSocket();
			_SSLStatus = .ActivateTLS;

			if (_isAcceptor)
				AcceptSSL();
			else
				ConnectSSL();
		}

		protected void ConnectEvent()
		{
			SetupSSLSocket();
			_SSLStatus = .Connect;
			ConnectSSL();
		}

		protected void AcceptEvent()
		{
			SetupSSLSocket();
			_SSLStatus = .Connect;
			AcceptSSL();
		}

		protected void ConnectSSL()
		{
			int c = SSL.connect(_SSL);

			if (c <= 0)
			{
				int e = SSL.get_error(_SSL, c);

				switch (e)
				{
				case SSL.ERROR_WANT_READ:
					{ // make sure we're watching for reads and flag status
						_socketState &= ~.CanReceive;
						IgnoreRead = false;
					}
				case SSL.ERROR_WANT_WRITE:
					{ // make sure we're watching for writes and flag status
						_socketState &= ~.CanSend;
						IgnoreWrite = false;
					}
				default:
					{
						String tmp = scope .("SSL connect errors: ");
						String tmp2 = scope .();
						GetSSLErrorStr(e, tmp2);
						tmp.Append(Environment.NewLine, tmp2);
						Bail(tmp, -1);
					}
				}
			}
			else
			{
				_SSLStatus = .None;
				((SSLSession)_session).[Friend]CallOnSSLConnect(this);
			}
		}

		protected void AcceptSSL()
		{
			int c = SSL.accept(_SSL);

			if (c <= 0)
			{
				int e = SSL.get_error(_SSL, c);

				switch (e)
				{
				case SSL.ERROR_WANT_READ:
					{ // make sure we're watching for reads and flag status
						_socketState &= ~.CanReceive;
						IgnoreRead = false;
					}
				case SSL.ERROR_WANT_WRITE:
					{ // make sure we're watching for writes and flag status
						_socketState &= ~.CanSend;
						IgnoreWrite = false;
					}
				default:
					{
						String tmp = scope .("SSL accept errors: ");
						String tmp2 = scope .();
						GetSSLErrorStr(e, tmp2);
						tmp.Append(Environment.NewLine, tmp2);
						Bail(tmp, -1);
					}
				}
			}
			else
			{
				_SSLStatus = .None;
				((SSLSession)_session).[Friend]CallOnSSLAccept(this);
			}
		}

		protected void ShutdownSSL()
		{
			if (_SSL != null)
			{
				_SSLStatus = .None; // for now
				int n = SSL.shutdown(_SSL); // don't care for now, unless it fails badly

				if (n <= 0)
				{
					n = SSL.get_error(_SSL, n);

					switch (n)
					{
					case SSL.ERROR_WANT_READ,
						 SSL.ERROR_WANT_WRITE,
						 SSL.ERROR_SYSCALL:    break; // ignore
					default:
						{
							String tmp = scope .("SSL shutdown errors: ");
							String tmp2 = scope .();
							GetSSLErrorStr(n, tmp2);
							tmp.Append(Environment.NewLine, tmp2);
							Bail(tmp, -1);
						}
					}
				}
				else
				{
					_SSLStatus = .None; // success from our end
				}
			}
		}

		protected override bool LogError(StringView aMsg, int32 aErrNum)
		{
			if (!_socketState.HasFlag(.SSLActive))
				return base.LogError(aMsg, aErrNum);

			if (_onError != null)
			{
				if (aErrNum > 0)
				{
					char8* s = scope char8[1024]*;
					Error.error_string_n((uint)aErrNum, s, 1024 * sizeof(char8));
					String tmp = scope .(aMsg);
					tmp.Append(": ");
					tmp.Append(s);
					_onError(this, tmp);
				}
				else
				{
					_onError(this, aMsg);
				}
			}

			return false;
		}

		public override bool SetState(SocketState aState, bool aIndTurnOn = true) =>
			aState == .SSLActive
				? SetActiveSSL(aIndTurnOn)
				: base.SetState(aState, aIndTurnOn);

		public override void Disconnect(bool aIndForced = false)
		{
			if (_dispose && _connectionStatus == .None && !_socketState.HasFlag(.SSLActive)) // don't do anything when already invalid
				return;

			if (_socketState.HasFlag(.SSLActive))
			{
				if (ConnectionStatus == .Connected) // don't make SSL inactive just yet, we might get a shutdown response
					ShutdownSSL();

				_SSLStatus = .Shutdown;
			}

			if (aIndForced || _SSLStatus == .None) // if this is forced or we successfuly sent the shutdown
			{
				SetActiveSSL(false); // make sure to update status
				base.Disconnect(aIndForced); // then proceed with TCP disconnect
			}
		}
	}

	public class SSLSession : Session
	{
		protected SocketEvent _onSSLConnect;
		protected SocketEvent _onSSLAccept;
		protected bool _SSLActive;
		protected SSL.CTX* _SSLContext;
		protected String _password = new .() ~ delete _;
		protected String _CAFile = new .() ~ delete _;
		protected String _keyFile = new .() ~ delete _;
		protected SSLMethod _method;
		protected PEM.password_cb _passwordCallback;

		public StringView Password
		{
			get { return _password; }
			set
			{
				if (value.Equals(_password, false))
					return;

				_password.Set(value);
				CreateSSLContext();
			}
		}
		public StringView CAFile
		{
			get { return _CAFile; }
			set
			{
				String tmp = scope .(value);
				// Ensure we have the correct dir sep chars
				tmp.Replace('/', Path.DirectorySeparatorChar);
				tmp.Replace('\\', Path.DirectorySeparatorChar);

				if (tmp.Equals(_CAFile, .InvariantCulture))
					return;

				_CAFile.Set(tmp);
				CreateSSLContext();
			}
		}
		public StringView KeyFile
		{
			get { return _keyFile; }
			set
			{
				String tmp = scope .(value);
				// Ensure we have the correct dir sep chars
				tmp.Replace('/', Path.DirectorySeparatorChar);
				tmp.Replace('\\', Path.DirectorySeparatorChar);

				if (tmp.Equals(_keyFile, .InvariantCulture))
					return;

				_keyFile.Set(tmp);
				CreateSSLContext();
			}
		}
		public SSLMethod Method
		{
			get { return _method; }
			set
			{
				if (value == _method)
					return;

				_method = value;
				CreateSSLContext();
			}
		}
		public ref PEM.password_cb PasswordCallback
		{
			get { return ref _passwordCallback; }
			set
			{
				if (value == _passwordCallback)
					return;

				_passwordCallback = value;
				CreateSSLContext();
			}
		}
		public void* SSLContext { get { return _SSLContext; } }
		public bool SSLActive
		{
			get { return _SSLActive; }
			set
			{
				if (value == _SSLActive)
					return;

				_SSLActive = value;

				if (value)
				  CreateSSLContext();
			}
		}
		public ref SocketEvent OnSSLConnect
		{
			get { return ref _onSSLConnect; }
			set { _onSSLConnect = value; }
		}
		public ref SocketEvent OnSSLAccept
		{
			get { return ref _onSSLAccept; }
			set { _onSSLAccept = value; }
		}

		protected static int PasswordCB(char8* buf, int num, int rwFlag, void* userData)
		{
			SSLSession s = *(SSLSession*)userData;

			if (num < s.Password.Length + 1)
				return 0;

			Internal.MemMove(&buf[0], s.Password.Ptr, s.Password.Length);
			return s.Password.Length;
		}
		
		protected void CallOnSSLConnect(Socket aSocket)
		{
			if (_onSSLConnect != null)
				_onSSLConnect(aSocket);
		}

		protected void CallOnSSLAccept(Socket aSocket)
		{
			if (_onSSLAccept != null)
				_onSSLAccept(aSocket);
		}

		protected virtual void CreateSSLContext()
		{
			if (_SSLContext != null)
				SSL.CTX_free(_SSLContext);

			if (!_SSLActive)
				return;

			SSL.METHOD* method;

			switch (_method)
			{
			case .TLS:     method = TLS.method();
			case .TLSv1:   method = TLS1.method();
			case .TLSv1_1: method = TLS1_1.method();
			case .TLSv1_2: method = TLS1_2.method();
			default:       method = null;
			}

			if (method == null)
				Runtime.FatalError("Unsupported SSL method");

			_SSLContext = SSL.CTX_new(method);

			if (_SSLContext == null)
				Runtime.FatalError("Error creating SSL CTX: SSL_CTX_new");

			if (SSL.CTX_set_mode(_SSLContext, SSL.MODE_ENABLE_PARTIAL_WRITE) & SSL.MODE_ENABLE_PARTIAL_WRITE != SSL.MODE_ENABLE_PARTIAL_WRITE)
			  	Runtime.FatalError("Error setting partial write mode on CTX");

			if (SSL.CTX_set_mode(_SSLContext, SSL.MODE_ACCEPT_MOVING_WRITE_BUFFER) & SSL.MODE_ACCEPT_MOVING_WRITE_BUFFER != SSL.MODE_ACCEPT_MOVING_WRITE_BUFFER)
			  	Runtime.FatalError("Error setting accept moving buffer mode on CTX");

			if (_CAFile.Length > 0)
			  	if (SSL.CTX_use_certificate_chain_file(_SSLContext, _CAFile) == 0)
			    	Runtime.FatalError("Error creating SSL CTX: SSLCTXLoadVerifyLocations");

			if (_keyFile.Length > 0)
			{
				Self refThis = this;
				SSL.CTX_set_default_passwd_cb(_SSLContext, _passwordCallback);
				SSL.CTX_set_default_passwd_cb_userdata(_SSLContext, &refThis);

				if (SSL.CTX_use_PrivateKey_file(_SSLContext, _keyFile, SSL.FILETYPE_PEM) == 0)
					Runtime.FatalError("Error creating SSL CTX: SSLCTXUsePrivateKeyFile");
			}

			OpenSSL.add_all_algorithms();
		}

		public this(Component aOwner) : base()
		{
			_passwordCallback = => PasswordCB;
			_SSLActive = true;
			CreateSSLContext();
		}

		public override void RegisterWithComponent(BaseConnection aConnection)
		{
			base.RegisterWithComponent(aConnection);
			Type type = typeof(SSLSocket);

			if (aConnection.SocketClass != type && !aConnection.SocketClass.IsSubtypeOf(type))
				aConnection.SocketClass = type;
		}

		public override void InitHandle(Handle aHandle)
		{
			base.InitHandle(aHandle);

			((SSLSocket)aHandle).[Friend]_SSLContext = _SSLContext;
			((SSLSocket)aHandle).SetState(.SSLActive, _SSLActive);
		}

		public override void ConnectEvent(Handle aHandle)
		{
			if (!((SSLSocket)aHandle).SocketState.HasFlag(.SSLActive))
				base.ConnectEvent(aHandle);
			else if (HandleSSLConnection((SSLSocket)aHandle))
				CallConnectEvent(aHandle);
		}

		public override void ReceiveEvent(Handle aHandle)
		{
			if (!((SSLSocket)aHandle).SocketState.HasFlag(.SSLActive))
			{
				base.ReceiveEvent(aHandle);
			}
			else
			{
				switch (((SSLSocket)aHandle).SSLState)
				{
				case .Connect:
					{
						if (HandleSSLConnection((SSLSocket)aHandle))
						{
							if (((SSLSocket)aHandle).SocketState.HasFlag(.ServerSocket))
								CallAcceptEvent(aHandle);
						    else
								CallConnectEvent(aHandle);
						}
					}
				case .ActivateTLS: HandleSSLConnection((SSLSocket)aHandle);
				default:           CallReceiveEvent(aHandle);
				}
			}
		}

		public override void AcceptEvent(Handle aHandle)
		{
			if (!((SSLSocket)aHandle).SocketState.HasFlag(.SSLActive))
				base.AcceptEvent(aHandle);
			else if (HandleSSLConnection((SSLSocket)aHandle))
				CallAcceptEvent(aHandle);
		}

		public bool HandleSSLConnection(SSLSocket aSocket)
		{
			if (_SSLContext == null)
				Runtime.FatalError("Context not created during SSL connect/accept");

			switch (aSocket.[Friend]_SSLStatus)
			{
			case .None:
				{
					if (aSocket.[Friend]_isAcceptor)
					  	aSocket.[Friend]AcceptEvent();
					else
					  	aSocket.[Friend]ConnectEvent();
				}
			case .ActivateTLS,
				 .Connect:
				{
					if (aSocket.[Friend]_isAcceptor)
					  	aSocket.[Friend]AcceptSSL();
					else
					  	aSocket.[Friend]ConnectSSL();
				}
			case .Shutdown: Runtime.FatalError("Got ConnectEvent or AcceptEvent on socket with ssShutdown status");
			}

			return aSocket.SSLState == .None;
		}
	}
}
