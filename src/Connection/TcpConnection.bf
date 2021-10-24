using System;

namespace Beef_Net.Connection
{
	class TcpConnection : BaseConnection
	{
		protected int _count;
		protected SocketEvent _onFreeDelegate = new => SocketDisconnect ~ delete _;

		public bool Connecting { get { return GetConnecting(); } }
		public SocketEvent OnAccept
		{
			get { return _onAccept; }
			set { _onAccept = value; }
		}
		public SocketEvent OnConnect
		{
			get { return _onConnect; }
			set { _onConnect = value; }
		}

		protected override Socket InitSocket(Socket aSocket)
		{
			aSocket.[Friend]SocketType = SOCK_STREAM;
			aSocket.Protocol = PROTO_TCP;
			aSocket.SocketNet = _socketNet;
			aSocket.[Friend]_onFree = _onFreeDelegate;

			return base.InitSocket(aSocket); // call last to make sure session can override options
		}

		protected override bool GetConnected()
		{
			Socket tmp = _rootSock;

			while (tmp != null)
			{
				if (tmp.ConnectionStatus == .Connected && !tmp.SocketState.HasFlag(.ServerSocket))
					return true;

				tmp = tmp.NextSock;
			}

			return false;
		}

		protected bool GetConnecting() =>
			_rootSock != null ? _rootSock.ConnectionStatus == .Connecting : false;

		protected override int GetCount() =>
			_count;

		protected Socket GetValidSocket() =>
			((_iterator != null && !_iterator.SocketState.HasFlag(.ServerSocket))
				? _iterator
				: ((_rootSock != null && _rootSock.NextSock != null)
					? _rootSock.NextSock
					: null
				)
			);

		protected override void ConnectAction(Handle aSocket)
		{
			Socket sock = (Socket)aSocket;
			int32 l = 0, n = 0;
			sockaddr_in addr4 = .();
			sockaddr_in6 addr6 = .();

			switch (sock.SocketNet)
			{
			case AF_INET:
				{
					l = sizeof(sockaddr_in);
					n = Common.GetPeerName(sock.[Friend]_handle, (SockAddr*)&addr4, &l);
				}
			case AF_INET6:
				{
					l = sizeof(sockaddr_in6);
					n = Common.GetPeerName(sock.[Friend]_handle, (SockAddr*)&addr6, &l);
				}
			default: Runtime.FatalError("Unknown SocketNet in ConnectAction");
			}

			if (n != 0)
			{
				Bail("Error on connect: connection refused", sock);
			}
			else
			{
				sock.[Friend]_connectionStatus = .Connected;
				sock.IgnoreWrite = true;

				if (sock.Session != null)
					sock.Session.ConnectEvent(aSocket);
				else
					ConnectEvent(aSocket);
			}
		}

		protected override void AcceptAction(Handle aSocket)
		{
			Socket tmp = InitSocket((Socket)TrySilent!(_socketClass.CreateObject()));

			if (tmp.Accept(_rootSock.[Friend]_handle))
			{
				if (_rootSock.NextSock != null)
				{
					tmp.NextSock = _rootSock.NextSock;
					_rootSock.NextSock.PrevSock = tmp;
				}

				_rootSock.NextSock = tmp;
				tmp.PrevSock = _rootSock;

				// if we don't have (bug?) an iterator yet or if it's the first socket accepted
				if (_iterator == null || _iterator.SocketState.HasFlag(.ServerSocket))
					_iterator = tmp; // assign it as iterator (don't assign later acceptees)

				_count++;
				_eventer.AddHandle(tmp);

				tmp.[Friend]_connectionStatus = .Connected;
				tmp.IgnoreWrite = true;

				if (_session != null)
					_session.AcceptEvent(tmp);
				else
					AcceptEvent(tmp);
			}
			else
			{
				tmp.Dispose();
			}
		}

		protected override void ReceiveAction(Handle aSocket)
		{
			Socket sock = (Socket)aSocket;

			if (sock == _rootSock && sock.SocketState.HasFlag(.ServerSocket))
			{
				AcceptAction(aSocket);
			}
			else
			{
				if ((SocketConnectionStatus.Connected | SocketConnectionStatus.Disconnecting).HasFlag(sock.ConnectionStatus))
				{
					sock.SetState(.CanReceive);

					if (sock.[Friend]_session != null)
						sock.[Friend]_session.ReceiveEvent(aSocket);
					else
						ReceiveEvent(aSocket);

					if (sock.ConnectionStatus != .Connected)
					{
						DisconnectEvent(aSocket);
						aSocket.Dispose();
					}
				}
			}
		}

		protected override void SendAction(Handle aSocket)
		{
			if (((Socket)aSocket).ConnectionStatus == .Connecting)
				ConnectAction(aSocket);
			else
				base.SendAction(aSocket);
		}

		protected override void ErrorAction(Handle aSocket, StringView aMsg)
		{
			if (((Socket)aSocket).ConnectionStatus == .Connecting)
			{
				Bail("Error on connect: connection refused", (Socket)aSocket);
				return;
			}

			if (_session != null)
				_session.ErrorEvent(aSocket, aMsg);
			else
				ErrorEvent(aSocket, aMsg);
		}

		protected bool Bail(StringView aMsg, Socket aSocket)
		{
			if (_session != null)
				_session.ErrorEvent(aSocket, aMsg);
			else
				ErrorEvent(aSocket, aMsg);

			if (aSocket != null)
				aSocket.Disconnect(true);
			else
				Disconnect(true);

			return false;
		}

		protected void SocketDisconnect(Socket aSocket)
		{
			if (aSocket == _iterator)
			{
				_iterator = (_iterator.NextSock != null
					? _iterator.NextSock
					: (_iterator.PrevSock != null
						? _iterator.PrevSock
						: null // Do not call IterReset, not reorganized yet
					)
				);

				if (_iterator != null && _iterator.SocketState.HasFlag(.ServerSocket))
					_iterator = null;
			}

			if (aSocket == _rootSock)
				_rootSock = aSocket.NextSock;

			if (aSocket.PrevSock != null)
				aSocket.PrevSock.NextSock = aSocket.NextSock;

			if (aSocket.NextSock != null)
				aSocket.NextSock.PrevSock = aSocket.PrevSock;

			_count--;
		}

		public this(): base()
		{
			_socketNet = AF_INET; // default to IPv4
			_iterator  = null;
			_count     = 0;
			_rootSock  = null;
		}

		public override bool Connect(StringView aAddress, uint16 aPort)
		{
			bool result = base.Connect(aAddress, aPort);

			if (_rootSock != null)
				Disconnect(true);

			_rootSock = InitSocket((Socket)TrySilent!(_socketClass.CreateObject()));
			result = _rootSock.Connect(aAddress, aPort);

			if (result)
			{
				_count++;
				_iterator = _rootSock;
				RegisterWithEventer();
			}
			else
			{
				DeleteAndNullify!(_rootSock); // one possible use, since we're not in eventer yet
				_iterator = null;
			}

			return result;
		}

		public override bool Listen(uint16 aPort, StringView aIntf = ADDR_ANY)
		{
			if (_rootSock != null)
				Disconnect(true);

			_rootSock = InitSocket((Socket)TrySilent!(_socketClass.CreateObject()));
			_rootSock.[Friend]SetReuseAddress(_reuseAddress);

			if (_rootSock.Listen(aPort, aIntf))
			{
				_rootSock.SetState(.ServerSocket);
				_rootSock.[Friend]_connectionStatus = .Connected;
				_iterator = _rootSock;
				_count++;
				RegisterWithEventer();
				return true;
			}

			return false;
		}

		public override int32 Get(uint8* aData, int32 aSize, Socket aSocket = null)
		{
			var aSocket;
			int32 result = 0;

			if (aSocket == null)
				aSocket = GetValidSocket();

			if (aSocket != null)
				result = aSocket.Get(aData, aSize);
			else
				Bail("No connected socket to get through", null);

			return result;
		}

		public override int32 GetMessage(String aOutMsg, Socket aSocket = null)
		{
			var aSocket;
			int32 result = 0;

			if (aSocket == null)
				aSocket = GetValidSocket();

			if (aSocket != null)
				result = aSocket.GetMessage(aOutMsg);
			else
				Bail("No connected socket to get through", null);

			return result;
		}

		public override int32 Send(uint8* aData, int32 aSize, Socket aSocket = null)
		{
			var aSocket;
			int32 result = 0;

			if (aSocket == null)
				aSocket = GetValidSocket();

			if (aSocket != null)
				result = aSocket.Send(aData, aSize);
			else
				Bail("No connected socket to send through", null);

			return result;
		}

		public override int32 SendMessage(StringView aMsg, Socket aSocket = null) =>
			Send((uint8*)aMsg.Ptr, (int32)aMsg.Length, aSocket);

		public override bool IterNext()
		{
			if (_iterator == null)
			  	return false;

			if (_iterator.NextSock != null)
			{
				_iterator = _iterator.NextSock;
				return true;
			}
			else
			{
				IterReset();
				return false;
			}
		}

		public override void IterReset() =>
			_iterator = _rootSock;

		public override void CallAction()
		{
			if (_eventer != null)
				_eventer.CallAction();
		}

		public override void Disconnect(bool aIndForced = false)
		{
			FreeSocks(aIndForced);

			if (aIndForced) // only unlink for forced, we still need to wait otherwise!
			{
				_rootSock = null;
				_iterator = null;
				_count = 0;
			}
		}
	}
}
