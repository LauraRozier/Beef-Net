using System;
using System.Reflection;

namespace Beef_Net.Interfaces
{
	interface IComponent
	{
	    StringView Host { get; set; };
	    uint16 Port { get; set; };
		Type SocketClass { get; set; }

	    void Disconnect(bool aIndForced = false);
	    void CallAction();
	}
}
