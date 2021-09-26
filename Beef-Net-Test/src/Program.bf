using System;
using System.IO;
using System.Threading;
using Beef_Net;
using Beef_OpenSSL;

namespace Beef_Net_Test
{
	class Program
	{
		private static SocketEvent _onConnect = new => OnConnect ~ delete _;
		private static SocketEvent _onDisconnect = new => OnDisconnect ~ delete _;
		private static SocketErrorEvent _onError = new => OnError ~ delete _;
		private static SocketEvent _onReceive = new => OnReceive ~ delete _;
		private static TelnetClient _telnetClient;
		private static Thread _bgWorker = null;
		private static bool _needsCleanup = false;

		static int Main()
		{
			Beef_Net_Init();
			/*
			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			String tmp = scope:: .(AES.options());
			tmp.Append("\n\nOpenSSL.VERSION     = ");
			tmp.Append(OpenSSL.version(OpenSSL.VERSION));
			tmp.Append("\nOpenSSL.CFLAGS      = ");
			tmp.Append(OpenSSL.version(OpenSSL.CFLAGS));
			tmp.Append("\nOpenSSL.BUILT_ON    = ");
			tmp.Append(OpenSSL.version(OpenSSL.BUILT_ON));
			tmp.Append("\nOpenSSL.PLATFORM    = ");
			tmp.Append(OpenSSL.version(OpenSSL.PLATFORM));
			tmp.Append("\nOpenSSL.DIR         = ");
			tmp.Append(OpenSSL.version(OpenSSL.DIR));
			tmp.Append("\nOpenSSL.ENGINES_DIR = ");
			tmp.Append(OpenSSL.version(OpenSSL.ENGINES_DIR));
			Console.WriteLine(tmp);
			*/

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			_telnetClient = new TelnetClient();
			_telnetClient.OnConnect = _onConnect;
			_telnetClient.OnDisconnect = _onDisconnect;
			_telnetClient.OnError = _onError;
			_telnetClient.OnReceive = _onReceive;
			_telnetClient.RegisterOption(Telnet.OPT_LINEMODE, true);

			if (_telnetClient.Connect("telehack.com", 23))
			{
				_telnetClient.CallAction();

				_bgWorker = new Thread(new => ThreadStart);
				_bgWorker.IsBackground = true;
				_bgWorker.SetName("Networking_Thread");
				_bgWorker.Start(false);
				String strBuff = new String();
				ConsoleKeyInfo cki = ?;
				char8 charBuff = ?;
				_telnetClient.SetOption(Telnet.OPT_LINEMODE);

				ConsoleExt.PrepHandles();

				repeat
				{
					if (_telnetClient.Connected)
					{
						if (_telnetClient.OptionIsSet(Telnet.OPT_LINEMODE))
						{
							strBuff.Clear();
							Console.ReadLine(strBuff);
			
							if (String.IsNullOrWhiteSpace(strBuff) || _telnetClient.Connected)
								continue;

							strBuff.EnsureNullTerminator();
							_telnetClient.SendMessage(strBuff);
						}
						else
						{
							cki = ConsoleExt.ReadKey(true);
							
							if (cki.KeyChar == 0x0 || !_telnetClient.Connected)
								continue;
	
							charBuff = cki.KeyChar;
							_telnetClient.Send(&charBuff, 1);
						}
					}
				} while ((_telnetClient.Connected || _telnetClient.Connection.Connecting) && !_needsCleanup);

				delete strBuff;
			}

			if (_telnetClient.Connected)
				_telnetClient.Disconnect();

			_needsCleanup = true; // Better safe then sorry
			_bgWorker.Join();
			delete _bgWorker;
			delete _telnetClient;
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
				readCnt = _telnetClient.GetMessage(tmp, aSocket);

				if (readCnt > 0)
					Console.Write(tmp);
			}
			while (readCnt > 0);

			delete tmp;
		}

		private static void ThreadStart()
		{
			while ((!_needsCleanup) && _telnetClient != null)
			{
				Thread.Sleep(10);
				_telnetClient.CallAction();
			}
		}
	}
}
