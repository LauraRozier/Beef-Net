using System;

namespace Beef_Net.Connection
{
	class TcpConnection : BaseConnection
	{
		protected int _count;

		public bool Connecting
		{
			get { return GetConnecting(); }
		}

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
		}

		protected override bool GetConnected()
		{
		}

		protected bool GetConnecting()
		{
		}

		protected override int GetCount()
		{
		}

		protected Socket GetValidSocket()
		{
		}

		protected override void ConnectAction(Handle aSocket)
		{
		}

		protected override void AcceptAction(Handle aSocket)
		{
		}

		protected override void ReceiveAction(Handle aSocket)
		{
		}

		protected override void SendAction(Handle aSocket)
		{
		}

		protected override void ErrorAction(Handle aSocket, StringView aMsg)
		{
		}

		protected bool Bail(StringView aMsg, Socket aSocket)
		{
		}

		protected void SocketDisconnect(Socket aSocket)
		{
		}

		public this(): base()
		{
		}

		public override bool Connect(StringView aAddress, uint16 aPort)
		{
		}

		public override bool Listen(uint16 aPort, StringView aIntf = ADDR_ANY)
		{
		}

		public override int32 Get(char8* aData, int32 aSize, Socket aSocket = null)
		{
		}

		public override int32 GetMessage(String aOutMsg, Socket aSocket = null)
		{
		}

		public override int32 Send(char8* aData, int32 aSize, Socket aSocket = null)
		{
		}

		public override int32 SendMessage(StringView aMsg, Socket aSocket = null)
		{
		}

		public override bool IterNext()
		{
		}

		public override void IterReset()
		{
		}

		public override void CallAction()
		{
		}

		public override void Disconnect(bool aIndForced = false)
		{
		}
	}
}
