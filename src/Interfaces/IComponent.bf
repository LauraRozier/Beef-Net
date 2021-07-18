using System;
using System.Reflection;

namespace Beef_Net.Interfaces
{
	interface IComponent
	{
	    void Disconnect(bool aIndForced = false);
	    void CallAction();

	    bool IsSSLSocket { get; set; };
	    StringView Host { get; set; };
	    uint16 Port { get; set; };
	}
}
