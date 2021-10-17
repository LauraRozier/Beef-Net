using System;
using System.Collections;
using System.IO;
using System.Threading;
using Beef_Net;
using Beef_Net_Common;
using Beef_OpenSSL;

namespace FtpClient
{
	class Program
	{
		protected const int32 BufferSize = 65536; // Usual maximal recv. size defined by OS, no problem if it's more or less really.

		/*
		These are the events which will get called when something happens on a socket.
		OnConnect will get called when the client connection finished connecting successfuly.
		OnReceive will get called when any data is received on the data stream (the one for files).
		OnControl will get called when any data/info is received on the command stream (the one with command/responses for server.
		OnSent will get called after sending big pieces of data to the other side, it'll report the progress indicated by "Bytes".
		OnError will get called when any network error occurs, like ECONNRESET
		*/
		protected SocketEvent _onConnect = new => OnConnect ~ delete _;
		protected SocketErrorEvent _onError = new => OnError ~ delete _;
		protected SocketEvent _onReceive = new => OnReceive ~ delete _;
		protected SocketEvent _onControl = new => OnControl ~ delete _;
		protected SocketProgressEvent _onSent = new => OnSent ~ delete _;

		protected static readonly String _appExe = new .() ~ delete _;
		protected static readonly String _appExeDir = new .() ~ delete _;
		protected FtpClient _client;       // The FTP connection itself
		protected bool _connected = false;
		protected bool _quit = false;      // Used as controller of the main loop
		protected FileStream _file = null; // File stream to save "GET" files into

		public static int Main(String[] aArgs)
		{
			Environment.GetExecutableFilePath(_appExe);
			Path.GetDirectoryPath(_appExe, _appExeDir);

			if (aArgs.Count > 0)
			{
				String host = new .(aArgs[0]);
				uint16 port = 21;

				if (aArgs.Count > 1)
				{
					if (uint32.Parse(aArgs[1]) case .Ok(let val))
					{
						port = (uint16)val;
					}
					else
					{
						Console.WriteLine("Error parsing the port (\"{0}\"), please provide a valid port.", aArgs[1]);
						delete host;
						return -1;
					}
				}

				Self app = new .();
				app.Run(host, port);
				delete host;
				delete app;
			}
			else
			{
				String tmp = scope .();
				Path.GetFileName(_appExe, tmp);
				Console.WriteLine("Usage: {0} IP [PORT]", tmp);
			}

			return 0;
		}

		public this()
		{
			Beef_Net_Init();
			ConsoleExt.PrepHandles();

			_client = new FtpClient();
			_client.Timeout = 50; // 50 milliseconds is nice to save CPU but fast enough to be responsive to humans
			// assign all events
			_client.OnConnect = _onConnect;
			_client.OnError = _onError;
			_client.OnReceive = _onReceive;
			_client.OnControl = _onControl;
			_client.OnSent = _onSent;
		}

		public ~this()
		{
			delete _client;
			Beef_Net_Cleanup();
		}

		// This is where the main loop is
		public void Run(StringView aHost, uint16 aPort)
		{
			_file = null; // Set "GET" file to nothing for now
			String envUser;
			String command = scope .();
			String name = scope .();
			Dictionary<String, String> envVars = new .();
			Environment.GetEnvironmentVariables(envVars);

			envVars.TryGetValue(UserString, out envUser);
			command.AppendF("USER [{0}]", envUser); // Get info about username and pass from console
			GetAnswer(command, name, false);

			if (name.Length == 0) // If username wasn't set, presume it's the same as environment var for USER
			{
				envVars.TryGetValue("USER", out envUser);

				if (envUser != null)
					name.Set(envUser);
			}

			String pass = scope .();
			GetAnswer("PASS", pass, true); // Get password from user console

			if (_client.Connect(aHost, aPort)) // If initial connect call worked
			{
				Console.WriteLine("Connecting... press escape to cancel"); // Write info about status

				repeat
				{
					_client.CallAction(); // Repeat this until we either get connected, fail or user decides to quit manually

					if (ConsoleExt.IsKeyPressed() && ConsoleExt.ReadKey(true).KeyChar == (char8)27)
						return;
				}
				while (!_connected);
			}
			else
			{
				return;
			}

			String str = scope .();

			if (_client.Authenticate(name, pass)) // If authentication with server passed
			{
				_client.Binary = true; // Set binary mode, others are useless anyhow
				Console.WriteLine("Press \"?\" for help"); // Just info
				String tmp = scope .();
				ConsoleKeyInfo cki = ?;

				while (!_quit) // Main loop is here, for events and user interaction
				{
					if (ConsoleExt.IsKeyPressed()) // This is all user interaction stuff
					{
						cki = ConsoleExt.ReadKey(true);

						switch (cki.KeyChar)
						{
						case (char8)27: _quit = true; // Escape quits the client
						case '?':       PrintHelp();
						case 'g', 'G': // "GET" file, this means:
							{
								GetAnswer("Filename", str); // We need to find out which file from user

								if (str.Length > 0) // Then if it was valid info
								{
									String tmpFullFile = scope .(_appExeDir);
									Path.GetFileName(str, tmp);
									tmpFullFile.Append(tmp);

									if (File.Exists(tmpFullFile)) // See if the file exists already on local disk/dir
										File.Delete(tmpFullFile); // If so, delete it (I know it's not the best idea, but it's a simple client)

									DeleteAndNullify!(_file); // Ensure any old file/data is not used
									_file = new .();
									_file.Create(tmpFullFile, .ReadWrite); // Create new file for the incomming one
									_client.Retrieve(str); // Send request for the file over FTP control connnection
								}
							}
						case 'l':       _client.List(); // And send request for file listing
						case 'L':       _client.Nlst(); // Send request for new type of file listing
						case 'p', 'P':
							{
								GetAnswer("Filename", str); // See which file the user wants to PUT on the server
								tmp.Set(_appExeDir);
								tmp.Append(str);

								if (File.Exists(tmp)) // If it exits locally
									_client.Put(tmp); // Then send it over
								else
									Console.WriteLine("No such file \"{0}\"", str); // Otherwise inform user of their error
							}
						case 'b', 'B': _client.Binary = !_client.Binary; // Set or unset binary
						case 's', 'S': _client.SystemInfo(); // Request systeminfo from server
						case 'h', 'H':
							{
								GetAnswer("Help verb", tmp);
								_client.Help(tmp); // Request help from server, argument input from console
							}
						case 'x', 'X': _client.PresentWorkingDirectory(); // Get current working directory info from server
						case 'c', 'C':
							{
								GetAnswer("New dir", tmp);
								_client.ChangeDirectory(tmp); // Change directory, new dir is read from user console
							}
						case 'm', 'M':
							{
								GetAnswer("New dir", tmp);
								_client.MakeDirectory(tmp); // Make a new directory on server, dirname is read from user console
							}
						case 'n', 'N':
							{
								String tmp2 = scope .();
								GetAnswer("From", tmp);
								GetAnswer("To", tmp2);
								_client.Rename(tmp, tmp2); // Rename a file, old and new names read from user console
							}
						case 'r', 'R':
							{
								GetAnswer("Dirname", tmp);
								_client.RemoveDirectory(tmp); // Delete a directory on server, name read from user console
							}
						case 'd', 'D':
							{
								GetAnswer("Filename", tmp);
								_client.DeleteFile(tmp); // Delete a file on server, name read from user console
							}
						case 'e', 'E': _client.Echo = !_client.Echo; // Set echo mode on/off
						case 'f', 'F': _client.ListFeatures(); // Get all FTP features from server
						}
					}

					_client.CallAction(); // This needs to be called ASAP, in a loop.  It's the magic function which makes all the events work :)
				}
			}
			else
			{
				_client.GetMessage(str); // If the authentication failed, get reason from server
			}

			if (str.Length > 0) // If reason was given, write it
				Console.Write(str);

			DeleteDictionaryAndKeysAndValues!(envVars);
			DeleteAndNullify!(_file); // Make sure not to leak memory
		}

		protected String UserString
		{
			get
			{
#if BF_PLATFORM_WINDOWS
				return "USERNAME";
#else
				return "USER";
#endif
			}
		}

		protected void GetAnswer(StringView aStr, String aOutStr, bool aIndNoEcho = false)
		{
			aOutStr.Clear();
			Console.Write("{0} : ", aStr);
			String tmp = scope .();

			while (true)
			{
				_client.CallAction();

				if (ConsoleExt.IsKeyPressed())
				{
					tmp.Clear();
					ConsoleKeyInfo cki = ConsoleExt.ReadKey(true);

					switch (cki.Key)
					{
					case .Enter,
						 .Escape:
						{
							Console.WriteLine();
							return;
						}
					case .Backspace:
						{
							if (aOutStr.Length > 0)
							{
								aOutStr.RemoveFromEnd(1);

								if (!aIndNoEcho)
								{
									tmp.Append(cki.KeyChar);
									Console.Write(tmp);
								}
							}
						}
					default:
						{
							aOutStr.Append(cki.KeyChar);

							if (!aIndNoEcho)
							{
								tmp.Append(cki.KeyChar);
								Console.Write(tmp);
							}
						}
					}
				}
			}
		}

		protected void PrintHelp()
		{
			Console.WriteLine("""
Beef-Net example FTP client ; Original by Ales Katona for FPC, Ported by Thimo Braker
Commands:
  ?   - Print this help
  ESC - Quit
  l   - List remote directory
  L   - Nlst remote directory (lists only files sometimes)
  g/G - Get remote file
  p/P - Put local file
  b/B - Change mode (binary on/off)
  s/S - Get server system info
  h/H - Print server help
  x/X - Print current working directory
  c/C - Change remote directory
  m/M - Create new remote directory
  r/R - Remove remote directory
  n/N - Rename remote file/directory
  d/D - Delete remote file
  e/E - Echo on/off
  f/F - Feature list
""");
		}

		private void OnConnect(Socket aSocket)
		{
			_connected = true;
			Console.WriteLine("Connected successfully");
		}
		
		private void OnError(StringView aMsg,  Socket aSocket) =>
			Console.WriteLine(aMsg); // Just write the error out

		private void OnReceive(Socket aSocket)
		{
			uint8* buf = scope .[BufferSize]*();

			if (_client.CurrentStatus == .Retr) // If we're in getting mode..
			{
				Console.Write("."); // Inform of progress.
				int len = _client.GetData(buf, BufferSize); // Get data, `len` is set to the amount.

				if (len == 0 && !_client.DataConnection.Connected) // If we got disconnected then..
					DeleteAndNullify!(_file); // Close the file.
				else if (_file.TryWrite(.(buf, len)) case .Err) // Otherwise, write the data to file.
					Console.WriteLine("Error writing to file.");
			}
			else
			{
				// If we got data and we weren't in getting mode, write it on the screen as FTP info.
				String tmp = scope .();
				_client.GetDataMessage(tmp);
				Console.Write(tmp);
			}
		}

		private void OnControl(Socket aSocket)
		{
			String tmp = scope .();

			// If we got some new message about FTP status, write it.
			if (_client.GetMessage(tmp) > 0)
				Console.WriteLine(tmp);
		}

		private void OnSent(Socket aSocket, int aBytes) =>
			Console.Write("."); // Inform on progress, very basic.
	}
}
