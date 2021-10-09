using System;
using System.IO;
using System.Threading;
using Beef_Net;
using Beef_Net_Common;
using Beef_OpenSSL;

namespace FtpClient
{
	class Program
	{
		private static SocketEvent _onConnect = new => OnConnect ~ delete _;
		private static SocketEvent _onDisconnect = new => OnDisconnect ~ delete _;
		private static SocketErrorEvent _onError = new => OnError ~ delete _;
		private static SocketEvent _onReceive = new => OnReceive ~ delete _;
		private static FtpClient _client;
		private static Thread _bgWorker = null;
		private static bool _needsCleanup = false;

		static int Main()
		{
			Beef_Net_Init();

			_client = new FtpClient();
			_client.OnConnect = _onConnect;
			_client.OnDisconnect = _onDisconnect;
			_client.OnError = _onError;
			_client.OnReceive = _onReceive;

			if (_client.Connected)
				_client.Disconnect();

			_needsCleanup = true; // Better safe then sorry
			/*_bgWorker.Join();
			delete _bgWorker;*/
			delete _client;

			Beef_Net_Cleanup();
			return 0;
		}

		private static void OnConnect(Socket aSocket)
		{
			aSocket.SetState(.NoDelay, true); // Send packets ASAP (disables Nagle's algorithm)
			Console.WriteLine("\r\nConnected to FTP server {0}:{1}", aSocket.Creator.Host, aSocket.Creator.Port);
		}

		private static void OnDisconnect(Socket aSocket)
		{
			if (aSocket != null)
				Console.WriteLine("\r\nDisconnected from FTP server {0}:{1}", aSocket.Creator.Host, aSocket.Creator.Port);

			_needsCleanup = true;
			Console.WriteLine("\r\nPress any key to continue...");
		}
		
		private static void OnError(StringView aMsg,  Socket aSocket)
		{
			if (aSocket != null)
				Console.WriteLine("\r\nError for FTP server {0}:{1}\r\n  {2}", aSocket.Creator.Host, aSocket.Creator.Port, aMsg);
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
			{
				Thread.Sleep(10);
				_client.CallAction();
			}
		}
	}
}
