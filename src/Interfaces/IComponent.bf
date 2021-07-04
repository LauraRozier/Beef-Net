using System;

namespace Beef_Net.Interfaces
{
	interface IComponent
	{
	    void Disconnect(bool aIndForced = false);
	    void CallAction();

	    Type SocketClass { get; set; };
	    StringView Host { get; set; };
	    uint16 Port { get; set; };
	}
}
