using System;

namespace Beef_Net.Socket
{
	[CRepr]
	struct TcpKeepAlive
	{
		public int64 OnOff;
		public int64 KeepAliveTime;
		public int64 KeepAliveInterval;
	}

	class TcpSocket : BaseSocket
	{

	}
}
