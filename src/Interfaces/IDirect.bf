using System;

namespace Beef_Net.Interfaces
{
	interface IDirect
	{
		int Get(char8* aData, int aSize, Socket aSocket = null);
		int GetMessage(String aOutMsg, Socket aSocket = null);

		int Send(char8* aData, int aSize, Socket aSocket = null);
		int SendMessage(StringView aMsg, Socket aSocket = null);
	}
}
