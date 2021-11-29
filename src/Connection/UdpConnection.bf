using System;

namespace Beef_Net.Connection
{
	class UdpConnection : BaseConnection
	{
		protected override Socket InitSocket(Socket aSocket)
		{
			Socket result = _rootSock;

			if (_rootSock == null)
			{
				aSocket.[Friend]SocketType = SOCK_DGRAM;
				aSocket.Protocol = PROTO_UDP;
				result = base.InitSocket(aSocket); // call last, to make sure sessions get their turn in overriding
			}

			return result;
		}

		protected override bool GetConnected()
		{
			if (_rootSock != null)
				return _rootSock.ConnectionStatus == .Connected;

			return false;
		}

		protected override void ReceiveAction(Handle aSocket)
		{
			((Socket)aSocket).SetState(.CanReceive);
	
			if (_session != null)
				_session.ReceiveEvent(aSocket);
			else
				ReceiveEvent(aSocket);
		}

		protected override void ErrorAction(Handle aSocket, StringView aMsg)
		{
			if (aSocket == _rootSock)
			{
				Bail(aMsg);
				return;
			}

			if (_session != null)
				_session.ErrorEvent(aSocket, aMsg);
			else
				ErrorEvent(aSocket, aMsg);
		}

		protected bool Bail(StringView aMsg)
		{
			Disconnect(true);

			if (_session != null)
				_session.ErrorEvent(null, aMsg);
			else
				ErrorEvent(_rootSock, aMsg);

			return false;
		}

		protected void SetAddress(StringView aAddress)
		{
			int n = (_socketNet != AF_INET6)
				? aAddress.IndexOf(':')       // IPv4
				: aAddress.IndexOf("]:") + 1; // IPv6
			
			if (n > 1)
			{
				StringView s = aAddress.Substring(0, n - 1);
				uint16 p = (uint16)UInt32.Parse(aAddress.Substring(n + 1)); // Word(StrToInt(Copy(Address, n+1, Length(aAddress))));
				
				Common.FillAddressInfo(ref _rootSock.[Friend]_peerAddress, (sa_family_t)_rootSock.[Friend]_socketNet, s, p);
			}
			else
			{
				Common.FillAddressInfo(ref _rootSock.[Friend]_peerAddress, (sa_family_t)_rootSock.[Friend]_socketNet, aAddress, _rootSock.PeerPort);
			}
		}

		public this(): base()
		{
			_timeVal.tv_usec = 0;
			_timeVal.tv_sec = 0;
		}

		public override bool Connect(StringView aAddress, uint16 aPort)
		{
			bool result = base.Connect(aAddress, aPort);

			if (_rootSock != null && _rootSock.[Friend]_connectionStatus != .None)
				Disconnect(true);

			_rootSock = InitSocket((Socket)TrySilent!(_socketClass.CreateObject()));
			_iterator =  _rootSock;
			result = _rootSock.[Friend]SetupSocket(aPort, ADDR6_ANY);

			if (result)
			{
				Common.FillAddressInfo(ref _rootSock.[Friend]_peerAddress, (uint16)_rootSock.[Friend]_socketNet, aAddress, aPort);
				_rootSock.[Friend]_connectionStatus = .Connected;
				RegisterWithEventer();
			}

			return result;
		}

		public override bool Listen(uint16 aPort, StringView aIntf = ADDR_ANY)
		{
			if (_rootSock != null && _rootSock.[Friend]_connectionStatus != .None)
				Disconnect(true);

			_rootSock = InitSocket((Socket)TrySilent!(_socketClass.CreateObject()));
			_rootSock.[Friend]SetReuseAddress(_reuseAddress);
			_iterator = _rootSock;

			if (_rootSock.Listen(aPort, aIntf))
			{
				Common.FillAddressInfo(ref _rootSock.[Friend]_peerAddress, (uint16)_rootSock.[Friend]_socketNet, ADDR_BR, aPort);
				_rootSock.[Friend]_connectionStatus = .Connected;
				RegisterWithEventer();
				return true;
			}

			return false;
		}

		public override int32 Get(uint8* aData, int32 aSize, Socket aSocket = null)
		{
			if (_rootSock != null)
				return _rootSock.Get(aData, aSize);

			return 0;
		}

		public override int32 GetMessage(String aOutMsg, Socket aSocket = null)
		{
			if (_rootSock != null)
				return _rootSock.GetMessage(aOutMsg);

			return 0;
		}

		public override int32 SendMessage(StringView aMsg, Socket aSocket = null)
		{
			if (_rootSock != null)
				return _rootSock.SendMessage(aMsg);

			return 0;
		}

		public int32 SendMessage(StringView aMsg, StringView aAddress)
		{
			if (_rootSock != null)
			{
				SetAddress(aAddress);
				return _rootSock.SendMessage(aMsg);
			}

			return 0;
		}

		public override int32 Send(uint8* aData, int32 aSize, Socket aSocket = null)
		{
			if (_rootSock != null)
				return _rootSock.Send(aData, aSize);

			return 0;
		}

		public int32 Send(uint8* aData, int32 aSize, StringView aAddress)
		{
			if (_rootSock != null)
			{
				SetAddress(aAddress);
				return _rootSock.Send(aData, aSize);
			}

			return 0;
		}

		public override bool IterNext() =>
			false;

		public override void IterReset()
		{
		}

		public override void Disconnect(bool aIndForced = false)
		{
			if (_rootSock != null)
			{
				_rootSock.Disconnect(true); // true on UDP it always goes there anyways 
				_rootSock = null; // even if the old one exists, eventer takes care of deleting it
			}
		}

		public override void CallAction()
		{
			if (_eventer != null)
				_eventer.CallAction();
		}
	}
}
