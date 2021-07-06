using System;

namespace Beef_Net.Interfaces
{
	interface IServer
	{
		bool Listen(uint16 aPort, StringView aIntf = ADDR_ANY);
	}
}
