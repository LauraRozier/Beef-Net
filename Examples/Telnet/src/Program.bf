using System;
using System.IO;
using System.Threading;
using Beef_Net;
using Beef_Net_Common;
using Beef_OpenSSL;

/*
	This is a full TeleHack Telnet client.
	See file Beef-Net/Telnet.bf if you want to know how it works.
*/
namespace Telnet
{
	class Program
	{
		private static SocketEvent _onConnect = new => OnConnect ~ delete _;
		private static SocketEvent _onDisconnect = new => OnDisconnect ~ delete _;
		private static SocketErrorEvent _onError = new => OnError ~ delete _;
		private static SocketEvent _onReceive = new => OnReceive ~ delete _;
		private static TelnetClient _client;
		private static Thread _bgWorker = null;
		private static bool _needsCleanup = false;

		static int Main()
		{
			Beef_Net_Init();

			_client = new .();
			_client.OnConnect = _onConnect;
			_client.OnDisconnect = _onDisconnect;
			_client.OnError = _onError;
			_client.OnReceive = _onReceive;
			_client.RegisterOption(Telnet.OPT_LINEMODE, true);

			if (_client.Connect("telehack.com", 23))
			{
				_client.CallAction();

				_bgWorker = new .(new => ThreadStart);
				_bgWorker.IsBackground = true;
				_bgWorker.SetName("Networking_Thread");
				_bgWorker.Start(false);
				String strBuff = new .();
				ConsoleKeyInfo cki = ?;
				char8 charBuff = ?;
				_client.SetOption(Telnet.OPT_LINEMODE);

				ConsoleExt.PrepHandles();

				repeat
				{
					if (_client.Connected)
					{
						if (_client.OptionIsSet(Telnet.OPT_LINEMODE))
						{
							strBuff.Clear();
							Console.ReadLine(strBuff);
			
							if (String.IsNullOrWhiteSpace(strBuff) || _client.Connected)
								continue;

							strBuff.EnsureNullTerminator();
							_client.SendMessage(strBuff);
						}
						else
						{
							cki = ConsoleExt.ReadKey(true);
							
							if (cki.KeyChar == 0x0 || !_client.Connected)
								continue;
	
							charBuff = cki.KeyChar;
							_client.Send((uint8*)&charBuff, 1);
						}
					}
				} while ((_client.Connected || _client.Connection.Connecting) && !_needsCleanup);

				delete strBuff;
			}

			if (_client.Connected)
				_client.Disconnect();

			_needsCleanup = true; // Better safe then sorry

			if (_bgWorker != null)
			{
				_bgWorker.Join();
				delete _bgWorker;
			}

			delete _client;
			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			Beef_Net_Cleanup();
			return 0;
		}

		private static void OnConnect(Socket aSocket)
		{
			aSocket.SetState(.NoDelay, true); // Send packets ASAP (disables Nagle's algorithm)
			Console.WriteLine("\r\nConnected to Telnet server {0}:{1}", aSocket.Creator.Host, aSocket.Creator.Port);
		}

		private static void OnDisconnect(Socket aSocket)
		{
			if (aSocket != null)
				Console.WriteLine("\r\nDisconnected from Telnet server {0}:{1}", aSocket.Creator.Host, aSocket.Creator.Port);

			_needsCleanup = true;
			Console.WriteLine("\r\nPress any key to continue...");
		}
		
		private static void OnError(StringView aMsg,  Socket aSocket)
		{
			if (aSocket != null)
				Console.WriteLine("\r\nError for Telnet server {0}:{1}\r\n  {2}", aSocket.Creator.Host, aSocket.Creator.Port, aMsg);
		}

		private static void OnReceive(Socket aSocket)
		{
			String tmp = new .();
			int readCnt = 0;

			repeat
			{
				readCnt = _client.GetMessage(tmp, aSocket);

				if (readCnt > 0)
					Console.Write(tmp);
			}
			while (readCnt > 0);

			delete tmp;
		}

		private static void ThreadStart()
		{
			while ((!_needsCleanup) && _client != null)
				_client.CallAction();
		}
	}
}
