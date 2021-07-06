using System;
using Beef_Net.Connection;

namespace Beef_Net
{
	public enum SocketState
	{
		ServerSocket = 0x00,
		Blocking = 0x01,
		ReuseAddress = 0x02,
		CanSend = 0x04,
		CanReceive = 0x08,
		SSLActive = 0x10,
		NoDelay = 0x20
	}

	public enum SocketConnectionStatus
	{
		None = 0x0,
		Connecting = 0x1,
		Connected = 0x2,
		Disconnecting = 0x4
	}

	public enum SocketOperation
	{
		Send,
		Receive
	}

	// Callback Event procedure for errors
	public function void SocketErrorEvent(StringView aMsg,  Socket aSocket);

	// Callback Event procedure for others
	public function void SocketEvent(Socket aSocket);

	// Callback Event procedure for progress reports
	public function void SocketProgressEvent(Socket aSocket, int aBytes);

	class Socket : Handle
	{
		protected SocketAddress _address;
		protected SocketAddress _peerAddress;
		protected bool _reuseAddress;
		protected SocketConnectionStatus _connectionStatus;
		protected Socket _nextSock;
		protected Socket _prevSock;
		protected SocketState _socketState;
		protected SocketEvent _onFree;
		protected bool _blocking;
		protected int32 _listenBacklog;
		protected int32 _protocol;
		protected int32 _socketType;
		protected int32 _socketNet;
		protected Component _creator;
		protected Session _session;
		protected BaseConnection _connection;
    
    	protected int32 SocketType // inherit and publicize if you need to set this outside
		{
			get { return _socketType; }
			set { _socketType = value; }
		}

		public bool Connected
		{
			get { return _connectionStatus == .Connected; }
		}

		public bool Connecting
		{
			get { return _connectionStatus == .Connecting; }
		}

		public SocketConnectionStatus ConnectionStatus
		{
			get { return _connectionStatus; }
		}

		public int32 ListenBacklog
		{
			get { return _listenBacklog; }
			set { _listenBacklog = value; }
		}

		public int32 Protocol
		{
			get { return _protocol; }
			set { _protocol = value; }
		}

		public int32 SocketNet
		{
			get { return _socketNet; }
			set { _socketNet = value; }
		}

		public uint16 PeerPort
		{
			get {
				return _socketType == SOCK_STREAM
					? Common.ntohs(_address.u.IPv4.sin_port)
					: Common.ntohs(_peerAddress.u.IPv4.sin_port);
			}
		}

		public uint16 LocalPort
		{
			get { return Common.ntohs(_address.u.IPv4.sin_port); }
		}

		public Socket NextSock
		{
			get { return _nextSock; }
			set { _nextSock = value; }
		}

		public Socket PrevSock
		{
			get { return _prevSock; }
			set { _prevSock = value; }
		}

		public SocketState SocketState
		{
			get { return _socketState; }
		}

		public Component Creator
		{
			get { return _creator; }
		}

		public Session Session
		{
			get { return _session; }
		}
		
		protected SockAddr* GetIPAddressPointer()
		{
			switch (_socketNet)
			{
			case AF_INET: return (SockAddr*)&_address.u.IPv4;
			case AF_INET6: return (SockAddr*)&_address.u.IPv6;
			default: Runtime.FatalError("Unknown socket network type (not IPv4 or IPv6)");
			}
		}

		protected int32 GetIPAddressLength()
		{
			switch (_socketNet)
			{
			case AF_INET: return sizeof(sockaddr_in);
			case AF_INET6: return sizeof(sockaddr_in6);
			default: Runtime.FatalError("Unknown socket network type (not IPv4 or IPv6)");
			}
		}
		
		protected virtual bool SetupSocket(uint16 aPort, StringView aAddress)
		{
			/*
var
  Done: Boolean;
  Arg, Opt: Integer;
begin
  Result := false;
  if FConnectionStatus = scNone then begin
    Done := true;
    FHandle := fpSocket(FSocketNet, FSocketType, FProtocol);
    if FHandle = INVALID_SOCKET then
      Exit(Bail('Socket error', LSocketError));
    SetOptions;

    if FSocketType = SOCK_DGRAM then begin
      Arg := 1;
      if fpsetsockopt(FHandle, SOL_SOCKET, SO_BROADCAST, @Arg, Sizeof(Arg)) = SOCKET_ERROR then
        Exit(Bail('SetSockOpt error', LSocketError));
    end;

    if FReuseAddress then begin
      Arg := 1;
      Opt := SO_REUSEADDR;
      {$ifdef WIN32} // I expect 64 has it oddly, so screw them for now
      if (Win32Platform = 2) and (Win32MajorVersion >= 5) then
        Opt := Integer(not Opt);
      {$endif}
      if fpsetsockopt(FHandle, SOL_SOCKET, Opt, @Arg, Sizeof(Arg)) = SOCKET_ERROR then
        Exit(Bail('SetSockOpt error', LSocketError));
    end;

    {$ifdef darwin}
    Arg := 1;
    if fpsetsockopt(FHandle, SOL_SOCKET, SO_NOSIGPIPE, @Arg, Sizeof(Arg)) = SOCKET_ERROR then
      Exit(Bail('SetSockOpt error', LSocketError));
    {$endif}

    FillAddressInfo(FAddress, FSocketNet, Address, aPort);
    FillAddressInfo(FPeerAddress, FSocketNet, LADDR_BR, aPort);

    Result  :=  Done;
  end;
			*/
		}

		protected virtual int DoSend(char8* aData, int aSize)
		{
			/*
var
  AddressLength: Longint = SizeOf(FPeerAddress);
begin
  if FSocketType = SOCK_STREAM then
    Result := Sockets.fpSend(FHandle, @aData, aSize, LMSG)
  else begin
    case FAddress.IPv4.sin_family of
      LAF_INET  :
        begin
          AddressLength := SizeOf(FPeerAddress.IPv4);
          Result := sockets.fpsendto(FHandle, @aData, aSize, LMSG, @FPeerAddress.IPv4, AddressLength);
        end;
      LAF_INET6 :
        begin
          AddressLength := SizeOf(FPeerAddress.IPv6);
          Result := sockets.fpsendto(FHandle, @aData, aSize, LMSG, @FPeerAddress.IPv6, AddressLength);
        end;
    end;
  end;
			*/
		}

		protected virtual int DoGet(char8* aData, int aSize)
		{
			/*
var
  AddressLength: Longint = SizeOf(FPeerAddress);
begin
  if FSocketType = SOCK_STREAM then
    Result := sockets.fpRecv(FHandle, @aData, aSize, LMSG)
  else begin
    case FAddress.IPv4.sin_family of
      LAF_INET  :
        begin
          AddressLength := SizeOf(FPeerAddress.IPv4);
          Result := sockets.fpRecvfrom(FHandle, @aData, aSize, LMSG, @FPeerAddress.IPv4, @AddressLength);
        end;
      LAF_INET6 :
        begin
          AddressLength := SizeOf(FPeerAddress.IPv6);
          Result := sockets.fpRecvfrom(FHandle, @aData, aSize, LMSG, @FPeerAddress.IPv6, @AddressLength);
        end;
    end;
  end;
			*/
		}

		protected virtual int HandleResult(int aResult, SocketOperation aOp)
		{
			/*
const
  GSStr: array[TLSocketOperation] of string = ('Send', 'Get');
var
  LastError: Longint;
begin
  Result := aResult;
  if Result = SOCKET_ERROR then begin
    LastError := LSocketError;
    if IsBlockError(LastError) then case aOp of
      soSend:
         begin
           FSocketState := FSocketState - [ssCanSend];
           IgnoreWrite := False;
         end;
      soReceive:
         begin
           FSocketState := FSocketState - [ssCanReceive];
           IgnoreRead := False;
         end;
    end else if IsNonFatalError(LastError) then
      LogError(GSStr[aOp] + ' error', LastError) // non fatals don't cause disconnect
    else if (aOp = soSend) and IsPipeError(LastError) then begin
      LogError(GSStr[aOp] + ' error', LastError);
      HardDisconnect(True); {$warning check if we need aOp = soSend in the IF, perhaps bad recv is possible?}
    end else
      Bail(GSStr[aOp] + ' error', LastError);

    Result := 0;
  end;
			*/
		}

		public void GetPeerAddress(String aOutStr)
		{
			aOutStr.Clear();
			Common.NetAddrToStr(
				_socketType == SOCK_STREAM
					? _address.u.IPv4.sin_addr
					: _peerAddress.u.IPv4.sin_addr,
				aOutStr
			);
		}

		public void GetLocalAddress(String aOutStr)
		{
			aOutStr.Clear();
			sockaddr_in a = .();
			int32 l = sizeof(sockaddr_in);

			if (Common.GetSockName(_handle, (SockAddr*)&a, &l) > 0)
				Common.NetAddrToStr(a.sin_addr, aOutStr);
		}

		[Inline]
		protected bool SendPossible()
		{
			if (_connectionStatus != .Connected)
				return LogError("Unable to send when not connected", -1);

			if (!_socketState.HasFlag(.CanSend))
			{
				if (_connection == null || _connection.[Friend]_onCanSend == null)
					return LogError("Send buffer full, try again later", -1);

				return false;
			}

			if (_socketState.HasFlag(.ServerSocket))
				return LogError("Unable to send on server a socket", -1);

			return true;
		}

		[Inline]
		protected bool ReceivePossible() =>
			(SocketConnectionStatus.Connected | SocketConnectionStatus.Disconnecting).HasFlag(_connectionStatus) &&
			_socketState.HasFlag(.CanReceive) && !_socketState.HasFlag(.ServerSocket);

		protected virtual void SetOptions()
		{
			SetBlocking(_blocking);
		}

		protected void SetBlocking(bool aValue)
		{
			if (_handle != INVALID_SOCKET) // we already have a socket
			{
				if (!Common.SetBlocking(_handle, aValue))
				{
					Bail("Error on SetNoDelay", Common.SocketError());
				}
				else
				{
					_blocking = true;

					if (aValue)
					{
						_socketState |= .Blocking;
					}
					else
					{
						_socketState &= ~.Blocking;
					}
				}
			}
		}

		protected void SetReuseAddress(bool aValue)
		{
			if (_connectionStatus == .None)
			{
				_reuseAddress = true;

				if (aValue)
				{
					_socketState |= .ReuseAddress;
				}
				else
				{
					_socketState &= ~.ReuseAddress;
				}
			}
		}

		protected void SetNoDelay(bool aValue)
		{
			if (_handle != INVALID_SOCKET) // we already have a socket
			{
				if (!Common.SetNoDelay(_handle, aValue))
				{
					Bail("Error on SetNoDelay", Common.SocketError());
				}
				else
				{
					if (aValue)
					{
						_socketState |= .NoDelay;
					}
					else
					{
						_socketState &= ~.NoDelay;
					}
				}
			}
		}

		protected void HardDisconnect(bool aIndNoShutdown = false)
		{
			bool needShut = _connectionStatus == .Connected && _socketType == SOCK_STREAM && !_socketState.HasFlag(.ServerSocket);

			if (aIndNoShutdown)
				needShut = false;

			_dispose = true;
			_socketState |= .CanSend;
			_socketState |= .CanReceive;
			_ignoreWrite = true;

			if ((SocketConnectionStatus.Connected | SocketConnectionStatus.Connecting | SocketConnectionStatus.Disconnecting).HasFlag(_connectionStatus))
			{
				_connectionStatus = .None;

				if (needShut && Common.Shutdown(_handle, SHUT_RDWR) != 0)
					LogError("Shutdown error", Common.SocketError());

				if (_eventer != null)
					_eventer.UnregisterHandle(this);

				if (Common.CloseSocket(_handle) != 0)
					LogError("Closesocket error", Common.SocketError());

				_handle = INVALID_SOCKET;
			}
		}

		protected void SoftDisconnect()
		{
			if ((SocketConnectionStatus.Connected | SocketConnectionStatus.Connecting).HasFlag(_connectionStatus))
			{
				if (_connectionStatus == .Connected && _socketType == SOCK_STREAM && !_socketState.HasFlag(.ServerSocket))
				{
					_connectionStatus = .Disconnecting;

					if (Common.Shutdown(_handle, SHUT_WR) != 0)
						LogError("Shutdown error", Common.SocketError());
				}
				else
				{
					HardDisconnect(); // UDP or ServerSocket
				}
			}
		}

		protected bool Bail(StringView aMsg, int32 aErrNum)
		{
			if (!_dispose)
			{
				Disconnect(true);
				LogError(aMsg, aErrNum);
			}

			return false;
		}

		protected virtual bool LogError(StringView aMsg, int32 aErrNum)
		{
			if (_onError != null)
			{
				String tmp = scope .(aMsg);

				if (aErrNum > 0)
				{
					Common.StrError(aErrNum, tmp);
				}

				_onError(this, tmp);
			}

			return false;
		}

		public this() : base()
		{
			_handle = INVALID_SOCKET;
			_listenBacklog = DEFAULT_BACKLOG;
			_prevSock = null;
			_nextSock = null;
			_socketState = .CanSend;
			_connectionStatus = .None;
			_socketType = SOCK_STREAM;
			_socketNet = AF_INET;
			_protocol = PROTO_TCP;
		}

		public ~this()
		{
			if (_onFree != null)
				_onFree(this);

			if (_eventer != null)
				_eventer.[Friend]InternalUnplugHandle(this);

			Disconnect(true);
		}

		public virtual bool SetState(SocketState aState, bool aIndTurnOn = true)
		{
			switch (aState)
			{
			case .ServerSocket:
				{
					if (aIndTurnOn)
					{
						_socketState |= aState;
					}
					else
					{
						Runtime.FatalError("Can not turn off server socket feature");
					}
				}
			case .Blocking:
				{
					SetBlocking(aIndTurnOn);
					break;
				}
			case .ReuseAddress: 
				{
					SetReuseAddress(aIndTurnOn);
					break;
				}
			case .CanSend:
			case .CanReceive: 
				{
					if (aIndTurnOn)
					{
						_socketState |= aState;
					}
					else
					{
						_socketState &= ~aState;
					}
				}
			case .SSLActive: 
				{
					Runtime.FatalError("Can not turn SSL/TLS on in TLSocket instance");
				}
			case .NoDelay: 
				{
					SetNoDelay(aIndTurnOn);
					break;
				}
			}

			return true;
		}

		public bool Listen(uint16 aPort, StringView aIntf = ADDR_ANY)
		{
			bool result = false;

			if (_connectionStatus != .None)
				Disconnect(true);

			SetupSocket(aPort, aIntf);

			if (Common.Bind(_handle, GetIPAddressPointer(), GetIPAddressLength()) == SOCKET_ERROR)
			{
				Bail("Error on bind", Common.SocketError());
			}
			else
			{
				result = true;
			}

			if (_socketType == SOCK_STREAM && result)
				if (Common.Listen(_handle, _listenBacklog) == SOCKET_ERROR)
					result = Bail("Error on Listen", Common.SocketError());

			return result;
		}

		public bool Accept(fd_handle aSerSock)
		{
			int32 addrLen = GetIPAddressLength();

			if (_connectionStatus != .None)
				Disconnect(true);

			_handle = Common.Accept(aSerSock, GetIPAddressPointer(), &addrLen);

			if (_handle != INVALID_SOCKET)
			{
				SetOptions();
				_isAcceptor = true;
				return true;
			}
			else
			{
				Bail("Error on accept", Common.SocketError());
			}

			return false;
		}

		public bool Connect(StringView aAddress, uint16 aPort)
		{
			if (_connectionStatus != .None)
				Disconnect(true);

			if (SetupSocket(aPort, aAddress))
			{
				Common.Connect(_handle, GetIPAddressPointer(), GetIPAddressLength());
				_connectionStatus = .Connecting;
				return true;
			}

			return false;
		}

		public virtual int Send(char8* aData, int aSize)
		{
			int result = 0;
			Runtime.Assert(aSize != 0);

			if (SendPossible())
			{
				if (aSize <= 0)
				{
					LogError("Send error: Size <= 0", -1);
					return 0;
				}

				return HandleResult(DoSend(aData, aSize), .Send);
			}

			return result;
		}

		public int SendMessage(StringView aMsg) =>
			Send(aMsg.Ptr, aMsg.Length);

		public virtual int Get(char8* aData, int aSize)
		{
			int result = 0;
			Runtime.Assert(aSize > 0);

			if (ReceivePossible())
			{
				result = DoGet(aData, aSize);

				if (result == 0)
				{
					if (_socketType == SOCK_STREAM)
					{
						Disconnect();
					}
					else
					{
						Bail("Receive Error [0 on recvfrom with UDP]", 0);
						return 0;
					}
				}

				return HandleResult(result, .Receive);
			}

			return result;
		}

		public int GetMessage(String aOutStr)
		{
			aOutStr.Clear();
			char8* tmpPtr = scope char8[BUFFER_SIZE]*;
			int len = Get(tmpPtr, BUFFER_SIZE);
			aOutStr.Append(tmpPtr, len);
			return aOutStr.Length;
		}

		public virtual void Disconnect(bool aIndForced = false)
		{
			// don't do anything when already invalid
			if (_dispose && _handle == INVALID_SOCKET && _connectionStatus == .None)
				return;

			if (aIndForced)
			{
				HardDisconnect();
			}
			else
			{
				SoftDisconnect();
			}
		}
	}
}
