using Beef_Net;
using Beef_Net_Common;
using System;
using System.IO;

namespace HttpClient
{
	class Program
	{
		private static bool _done = false;
		private static FileStream _outFile = null ~ if (_ != null) DeleteAndNullify!(_);

		private static SocketEvent _onCd = new => ClientDisconnect ~ delete _;
		private static HttpClientEvent _onCdi = new => ClientDoneInput ~ delete _;
		private static SocketErrorEvent _onCe = new => ClientError ~ delete _;
		private static InputEvent _onCi = new => ClientInput ~ delete _;
		private static HttpClientEvent _onCph = new => ClientProcessHeaders ~ delete _;

		public static int Main(String[] aArgs)
		{
			Beef_Net_Init();
			ConsoleExt.PrepHandles();

			if (aArgs.Count == 0)
			{
				Console.Out.WriteLine("Specify URL (and optionally, filename).");
				Console.WriteLine("Press any key to continue...");
				ConsoleExt.ReadKey(true);
				return 0;
			}

			/* Parse URL */
			String url = scope .(aArgs[0]);
			String host = scope .();
			String uri = scope .();
			uint16 port = 0;
			bool useSSL = HttpUtil.DecomposeUrl(url, host, uri, out port);
			Console.Out.WriteLine("Host: {0}, URI: {1}, Port: {2}", host, uri, port);

			String filename = scope .();
			String altFilename = scope .();

			if (aArgs.Count >=2)
			{
				filename.Append(aArgs[1]);
			}
			else
			{
				int idx = uri.LastIndexOf('/');

				if (idx >= 0)
					filename.Append(uri.Substring(idx + 1));

				if (filename.Length == 0)
					filename.Append("index.html");
			}

			if (File.Exists(filename))
			{
				int idx = 1;

				repeat
				{
					altFilename.Set(filename);
					altFilename.AppendF(".{0}", idx++);
				}
				while (File.Exists(altFilename));

				Console.WriteLine("\"{0}\" exists, writing to \"{1}\"", filename, altFilename);
				filename.Set(altFilename);
			}

			_outFile = new .();
			_outFile.Open(filename, .Create, .ReadWrite, .Read);

			HttpClient client = new .();
			client.Session = new SSLSession(client);
			client.OwnsSession = true;
			((SSLSession)client.Session).SSLActive = useSSL;
			client.Host = host;
			client.Method = .Get;
			client.Port = port;
			client.Uri = uri;
			client.Timeout = -1;
			client.OnDisconnect = _onCd;
			client.OnDoneInput = _onCdi;
			client.OnError = _onCe;
			client.OnInput = _onCi;
			client.OnProcessHeaders = _onCph;

			client.SendRequest();
			_done = false;

			while (!_done)
				client.CallAction();

			delete client;
			Console.WriteLine("Press any key to continue...");
			ConsoleExt.ReadKey(true);
			Beef_Net_Cleanup();
			return 0;
		}

		public static void ClientDisconnect(Socket aSocket)
		{
			Console.Out.WriteLine("Disconnected.");
			_done = true;
		}

		public static void ClientDoneInput(HttpClientSocket aSocket)
		{
			Console.Out.WriteLine("Done.");
			_outFile.Close();
			aSocket.Disconnect();
		}

		public static void ClientError(StringView aMsg, Socket aSocket)
		{
			Console.Out.WriteLine("Error: {0}", aMsg);

			if (!aSocket.Connected)
				_done = true;
		}

		public static int32 ClientInput(HttpClientSocket aSocket, uint8* aBuffer, int32 aSize)
		{
			int32 result = (int32)TrySilent!(_outFile.TryWrite(.(aBuffer, aSize)));
			Console.Out.WriteLine("{0}...", aSize);
			result = aSize;
			return result;
		}

		public static void ClientProcessHeaders(HttpClientSocket aSocket)
		{
			String tmp = scope .();
			aSocket.GetResponseReason(tmp);
			Console.Out.WriteLine("Response: {0} {1}, data...", aSocket.ResponseStatus.Underlying, tmp);
		}
	}
}
