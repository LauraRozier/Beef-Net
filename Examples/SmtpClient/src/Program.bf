using Beef_Net;
using Beef_Net_Common;
using System;
using System.IO;

namespace SmtpClient
{
	class Program
	{
		protected SocketEvent _onConnect = new => OnConnect ~ delete _;
		protected SocketEvent _onDisconnect = new => OnDisconnect ~ delete _;
		protected SocketErrorEvent _onError = new => OnError ~ delete _;
		protected SocketEvent _onReceive = new => OnReceive ~ delete _;
		protected SocketEvent _onSSLConnect = new => OnSSLConnect ~ delete _;

		protected static readonly String _appExe = new .() ~ delete _;
		protected static readonly String _appExeDir = new .() ~ delete _;
		protected SmtpClient _client; // This is THE smtp connection
		protected SSLSession _ssl = null;
		protected bool _quit = false; // Helper for main loop
		
		public static int Main(String[] aArgs)
		{
			Environment.GetExecutableFilePath(_appExe);
			Path.GetDirectoryPath(_appExe, _appExeDir);

			Self app = new .();
			app.Run(aArgs);
			delete app;

			return 0;
		}

		protected void GetAnswer(StringView aStr, String aOutStr, bool aIndMaskInput = false)
		{
			aOutStr.Clear();
			Console.Write("{0}: ", aStr);
			ConsoleKeyInfo cki = ?;

			while (true)
			{
				_client.CallAction();

				if (ConsoleExt.IsKeyPressed())
				{
					cki = ConsoleExt.ReadKey(true);

					switch (cki.KeyChar)
					{
					case (char8)27:
						{
							_client.Quit();
							aOutStr.Clear();
							return;
						}
					case (char8)13:
						{
							Console.WriteLine();
							return;
						}
					case (char8)8:
						{
							if (aOutStr.Length > 0)
							{
								aOutStr.RemoveFromEnd(1);
								Console.Write(cki.KeyChar);
							}
						}
					default:
						{
							aOutStr.Append(cki.KeyChar);

							if (aIndMaskInput)
								Console.Write("*");
							else
								Console.Write("{0}", cki.KeyChar);
						}
					}
				}
			}
		}

		protected void PrintUsage(StringView aStr)
		{
			String tmp = scope .();
			Path.GetFileName(_appExe, tmp);
			Console.WriteLine("""
Usage: {0} {1}
       -s is used to specify that an implicit SSL connection is required
""", tmp, aStr);
		}

		/*
		 * These events are used to see what happens on the SMTP connection. They are used via "CallAction".
		 * - OnConnect will get fired when connecting to server ended with success.
		 * - OnDisconnect will get fired when the other side closed connection gracefully.
		 * - OnError will get called when any kind of net error occurs on the connection.
		 * - OnReceive will get fired whenever new data is received from the SMTP server.
		 */
		protected void OnConnect(Socket aSocket) =>
			Console.WriteLine("Connected"); // Inform user of successful connect

		protected void OnDisconnect(Socket aSocket)
		{
			Console.WriteLine("Lost connection"); // Inform user about lost connection
			_quit = true; // Since SMTP shouldn't do this unless we issued a QUIT, consider it to be end of session and quit program
		}

		protected void OnError(StringView aMsg, Socket aSocket) =>
			Console.WriteLine(aMsg); // Inform about error

		protected void OnReceive(Socket aSocket)
		{
			String tmp = scope .();

			if (_client.GetMessage(tmp) > 0) // If we actually received something from SMTP server, write it for the user
				Console.Write(tmp);
		}

		// This event is used to monitor TLS handshake. If SSL or TLS is used we will know if the handshake went ok if this event is fired on the session
		protected void OnSSLConnect(Socket aSocket) =>
			Console.WriteLine("SSL handshake was successful");

		public this()
		{
			Beef_Net_Init();
			ConsoleExt.PrepHandles();

			_ssl = new .(null);
			_ssl.SSLActive = false;            // Turn it "off" by default
			_ssl.OnSSLConnect = _onSSLConnect; // Let's watch if TLS/SSL handshake is ok

			_client = new .();
			_client.Session = _ssl; // Set the SSL session, so if it's a SSL/TLS SMTP we can use it
			_client.Timeout = 100;  // Responsive enough, but won't hog CPU
			// Assign all events
			_client.OnConnect = _onConnect;
			_client.OnDisconnect = _onDisconnect;
			_client.OnError = _onError;
			_client.OnReceive = _onReceive;
		}

		public ~this()
		{
			delete _client;
			delete _ssl;
			Beef_Net_Cleanup();
		}

		// This is where the main loop is
		public void Run(String[] aArgs)
		{
			String addr = scope .();
			uint16 port = 25;

			if (aArgs.Count > 0)
			{
				addr.Append(aArgs[0]); // Get address and port from commandline args

				if (aArgs.Count > 1)
				{
					if (uint32.Parse(aArgs[1]) case .Ok(let val))
					{
						port = (uint16)val;
					}
					else
					{
						if (aArgs.Count > 2 && aArgs[2].Equals("-s", .OrdinalIgnoreCase))
						{
							port = 25;
							_ssl.SSLActive = true;
						}
						else
						{
							Console.WriteLine("Wrong argument #2");
							return;
						}
					}
				}

				if (aArgs.Count > 2 && aArgs[2].Equals("-s", .OrdinalIgnoreCase))
					_ssl.SSLActive = true;

				Console.Write("Connecting to {0}:{1}...", addr, port);

				if (_client.Connect(addr, port))
				{
					repeat // Try to connect 
					{
						_client.CallAction(); // If inital connect went ok, wait for "acknowlidgment" or otherwise

						if (ConsoleExt.IsKeyPressed())
							if (ConsoleExt.ReadKey(true).KeyChar == (char8)27)
								_quit = true; // If user doesn't wish to wait, quit
					}
					while (!(_quit || _client.Connected)); // If user quit, or we connected, then continue
				}

				if (!_quit) // If we connected send HELO
				{
					_client.Ehlo();
					Console.WriteLine("""
Press escape to quit
Press "a" to authenticate (AUTH LOGIN)
Press "e" to issue additional EHLO
Press "t" to STARTTLS
Press "return" to compose an email
""");
				}

				ConsoleKeyInfo cki = ?;
				String user = scope .();
				String pass = scope .();
				String sender = scope .();
				String recipients = scope .();
				String subject = scope .();
				String message = scope .();

				while (!_quit) // If we connected, do main loop
				{
					_client.CallAction(); // Main event mechanism, make sure to call periodicly and ASAP, or specify high timeout

					if (ConsoleExt.IsKeyPressed())
					{
						cki = ConsoleExt.ReadKey(true);

						switch (cki.KeyChar) // Let's see what the user wants
						{
						case (char8)27: // And we're connected, then do a graceful QUIT, waiting for server to disconnect
							{
								if (_client.Connected)
									_client.Quit();
								else
									_quit = true; // Otherwise just quit from this end
							}
						case 'a': // User wants to authenticate
							{
								GetAnswer("Username", user);       // First get username
								GetAnswer("Password", pass, true);
								_client.AuthLogin(user, pass);     // Then get password (mask it) and pass to auth
							}
						case 't': _client.StartTLS(); // Technically we should now "wait" for TLS handshake to finish, but aaaaw skip it, we'll see if it succeeded via OnSSLConnect event
						case 'e': _client.Ehlo();
						default: // Otherwise, user wants to compose email
							{
								 GetAnswer("From", sender); // Get info about email from console input
								 GetAnswer("Recipients", recipients);
								 GetAnswer("Subject", subject);
								 GetAnswer("Data", message);
								_client.SendMail(sender, recipients, subject, message); // Send the mail given user data
							}
						}
					}
				}
			}
			else
			{
				PrintUsage("<SMTP server hostname/IP> [port] [-s]");
			}
		}
	}
}
