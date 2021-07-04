using System;

namespace Beef_Net.Interfaces
{
	interface IClient
	{
		bool Connect(StringView aAddress, uint16 aPort);
		bool Connect();
	}
}
