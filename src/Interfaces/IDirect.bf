using System;

namespace Beef_Net.Interfaces
{
	interface IDirect
	{
		int32 Get(char8* aData, int32 aSize, Socket aSocket = null);
		int32 GetMessage(String aOutMsg, Socket aSocket = null);

		int32 Send(char8* aData, int32 aSize, Socket aSocket = null);
		int32 SendMessage(StringView aMsg, Socket aSocket = null);
	}
}
