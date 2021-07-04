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
				aSocket.[Friend]SocketType = Common.SOCK_DGRAM;
				aSocket.Protocol   = Common.PROTO_UDP;
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
			{
				_session.ReceiveEvent(aSocket);
			}
			else
			{
				ReceiveEvent(aSocket);
			}
		}

		protected override void ErrorAction(Handle aSocket, StringView aMsg)
		{
			if (aSocket == _rootSock)
			{
				Bail(aMsg);
				return;
			}

			if (_session != null)
			{
				_session.ErrorEvent(aSocket, aMsg);
			}
			else
			{
				ErrorEvent(aSocket, aMsg);
			}
		}

		protected bool Bail(StringView aMsg)
		{
			Disconnect(true);

			if (_session != null)
			{
				_session.ErrorEvent(null, aMsg);
			}
			else
			{
				ErrorEvent(_rootSock, aMsg);
			}

			return false;
		}

		protected void SetAddress(StringView aAddress)
		{
			int n = (_socketNet != Common.AF_INET6)
				? aAddress.IndexOf(':')       // IPv4
				: aAddress.IndexOf("]:") + 1; // IPv6
			
			if (n > 1)
			{
				StringView s = aAddress.Substring(0, n - 1);
				uint16 p = UInt32.Parse(aAddress.Substring(n + 1)); // Word(StrToInt(Copy(Address, n+1, Length(aAddress))));
				
				Common.FillAddressInfo(ref _rootSock.[Friend]_peerAddress, (sa_family_t)_rootSock.[Friend]_socketNet, s, p);
			}
			else
				Common.FillAddressInfo(ref _rootSock.[Friend]_peerAddress, (sa_family_t)_rootSock.[Friend]_socketNet, aAddress, _rootSock.PeerPort);
		}

		public this(): base()
		{
		}

		public override bool Connect(StringView aAddress, uint16 aPort)
		{
		}

		public override bool Listen(uint16 aPort, StringView aIntf = Common.ADDR_ANY)
		{
		}

		public override int Get(char8* aData, int aSize, Socket aSocket = null)
		{
		}

		public override int GetMessage(String aOutMsg, Socket aSocket = null)
		{
		}

		public override int SendMessage(StringView aMsg, Socket aSocket = null)
		{
		}

		public int SendMessage(StringView aMsg, StringView aAddress)
		{
		}

		public override int Send(char8* aData, int aSize, Socket aSocket = null)
		{
		}

		public int Send(char8* aData, int aSize, StringView aAddress)
		{
		}

		public override bool IterNext()
		{
		}

		public override void IterReset()
		{
		}

		public override void Disconnect(bool aIndForced = false)
		{
		}

		public override void CallAction()
		{
		}
	}
}
