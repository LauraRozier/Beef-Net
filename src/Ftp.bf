using Beef_Net.Connection;
using Beef_Net.Interfaces;
using System;
using System.Collections;
using System.Diagnostics;
using System.IO;

namespace Beef_Net
{
	public enum FtpStatus
	{
		case None = 0x000000;
		case Con  = 0x000001;
		case User = 0x000002;
		case Pass = 0x000004;
		case Pasv = 0x000008;
		case Port = 0x000010;
		case List = 0x000020;
		case Retr = 0x000040;
		case Stor = 0x000080;
		case Type = 0x000100;
		case CWD  = 0x000200;
		case MKD  = 0x000400;
		case RMD  = 0x000800;
		case DEL  = 0x001000;
		case RNFR = 0x002000;
		case RNTO = 0x004000;
		case SYS  = 0x008000;
		case Feat = 0x010000;
		case PWD  = 0x020000;
		case Help = 0x040000;
		case Quit = 0x080000;
		case Last = 0x100000;

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .None: return "None";
				case .Con:  return "Connect";
				case .User: return "Authenticate";
				case .Pass: return "Password";
				case .Pasv: return "Passive";
				case .Port: return "Active";
				case .List: return "List";
				case .Retr: return "Retrieve";
				case .Stor: return "Store";
				case .Type: return "Type";
				case .CWD:  return "CWD";
				case .MKD:  return "MKDIR";
				case .RMD:  return "RMDIR";
				case .DEL:  return "Delete";
				case .RNFR: return "RenameFrom";
				case .RNTO: return "RenameTo";
				case .SYS:  return "System";
				case .Feat: return "Features";
				case .PWD:  return "PWD";
				case .Help: return "HELP";
				case .Quit: return "QUIT";
				case .Last: return "LAST";
				}
			}
		}
	}

	public enum FtpTransferMethod
	{
		Active,
		Passive
	}

	public struct FtpStatusRec
	{
		public FtpStatus Status;
		public String[] Args = new .[2](new .(), new .());
	}

	public delegate void FtpClientStatusEvent(Socket aSocket, FtpStatus aStatus);

	public class FtpStatusFront
	{
		public const int MAX_FRONT_ITEMS = 10;

		protected FtpStatusRec _emptyItem;
		protected FtpStatusRec[] _items = new .[MAX_FRONT_ITEMS] ~ { for (FtpStatusRec item in _) { DeleteContainerAndItems!(item.Args); } delete _; };
		protected int _top = 0;
		protected int _bottom = 0;
		protected int _count = 0;

		public int Count { get { return _count; } }
		public bool Empty { get { return _count == 0; } }

		public this(FtpStatusRec aDefaultItem)
		{
			_emptyItem = aDefaultItem;
			Clear();
		}

		public FtpStatusRec First()
		{
			if (_count > 0)
				return _items[_bottom];

			return _emptyItem;
		}

		public FtpStatusRec Remove()
		{
			FtpStatusRec result = First();

			if (_count > 0)
			{
				_count--;
				_bottom++;

				if (_bottom >= MAX_FRONT_ITEMS)
					_bottom = 0;
			}

			return result;
		}

		public bool Insert(FtpStatusRec aValue)
		{
			if (_count < MAX_FRONT_ITEMS)
			{
				if (_top >= MAX_FRONT_ITEMS)
					_top = 0;

				_items[_top] = aValue;
				_count++;
				_top++;
				return true;
			}

			return false;
		}

		public bool Insert(FtpStatus aStatus, StringView aArg1 = "", StringView aArg2 = "")
		{
			if (_count < MAX_FRONT_ITEMS)
			{
				if (_top >= MAX_FRONT_ITEMS)
					_top = 0;

				_items[_top].Status = aStatus;
				_items[_top].Args[0].Set(aArg1);
				_items[_top].Args[1].Set(aArg2);
				_count++;
				_top++;
				return true;
			}

			return false;
		}

		public void Clear()
		{
			for (int i = 0; i < _items.Count; i++)
			{
				if (_items[i].Args == null)
				{
					_items[i] = .();
				}
				else
				{
					_items[i].Status = .None;
					_items[i].Args[0].Clear();
					_items[i].Args[1].Clear();
				}
			}

			_count = 0;
			_bottom = 0;
			_top = 0;
		}
	}

	public abstract class Ftp : Component, IDirect
	{
		public const uint16 DEFAULT_FTP_PORT = 1025;

		protected FtpTelnetClient _control = new .() ~ delete _;
		protected TcpConnection _data = new .() ~ delete _; // TcpList;
		protected bool _sending = false;
		protected FtpTransferMethod _transferMethod = .Passive; // Let's be modern
		protected StringList _featureList = new .() ~ DeleteContainerAndItems!(_);
		protected String _featureString = new .() ~ delete _;
		
		public bool Connected { get { return GetConnected(); } }
		public int64 Timeout
		{
			get { return _control.Timeout; }
			set
			{
				_control.Timeout = value;
				_data.Timeout = value;
			}
		}
		public FtpTelnetClient ControlConnection { get { return _control; } }
		public TcpConnection DataConnection { get { return _data; } }
		public FtpTransferMethod TransferMethod
		{
			get { return _transferMethod; }
			set { _transferMethod = value; }
		}
		public Session Session
		{
			get { return _control.Session; }
			set
			{
				_control.Session = value;
				_data.Session = value;
			}
		}
		public List<String> FeatureList { get { return _featureList; } }

		public this() : base()
		{
			_port = 21;
			_control.Creator = this;
			_data.Creator = this;
			_data.SocketClass = typeof(Socket);
		}

		protected override void SetCreator(Component aValue)
		{
			base.SetCreator(aValue);
			_control.Creator = aValue;
			_data.Creator = aValue;
		}

		protected virtual bool GetConnected() =>
			_control.Connected;

		public abstract int32 Get(uint8* aData, int32 aSize, Socket aSocket = null);
		public abstract int32 GetMessage(String aOutMsg, Socket aSocket = null);

		public abstract int32 Send(uint8* aData, int32 aSize, Socket aSocket = null);
		public abstract int32 SendMessage(StringView aMsg, Socket aSocket = null);
	}

	public class FtpTelnetClient : TelnetClient
	{
		// Don't do anything since they broke Telnet in FTP as per-usual
		protected override void React(char8 aOperation, char8 aCommand) { }
	}

	public class FtpClient : Ftp, IClient
	{
		private const uint16 DEFAULT_CHUNK = 8192;
		private readonly static FtpStatusRec EMPTY_REC = .() ~ DeleteContainerAndItems!(_.Args);
		private readonly static char8[] NumericAndComma = new char8[11] (
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ','
		) ~ delete _;
		private readonly static char8[] SmallNumeric = new .[5]('1', '2', '3', '4', '5') ~ delete _;

		protected FtpStatus _statusFlags = .None;
		protected FtpStatus _statusSet = .None | .Con | .User | .Pass | .Pasv | .Port | .List | .Retr | .Stor |
			.Type | .CWD | .MKD | .RMD | .DEL | .RNFR | .RNTO | .SYS | .Feat | .PWD | .Help | .Quit | .Last;
		protected FtpStatusFront _status = new .(EMPTY_REC) ~ delete _;
		protected FtpStatusFront _commandFront = new .(EMPTY_REC) ~ delete _;
		protected FileStream _storeFile = null ~ if (_ != null) delete _;

		protected bool _expectedBIN = false;
		protected bool _pipeline = false;

		protected uint16 _chunkSize = DEFAULT_CHUNK;
		protected uint16 _startPort = DEFAULT_FTP_PORT;
		protected uint16 _lastPort = _startPort;

		protected String _pwd = new .() ~ delete _;
		protected String _password = new .() ~ delete _;
		protected StringList _fsl = new .() ~ DeleteContainerAndItems!(_);

		protected SocketEvent _onConnect = null;
		protected SocketEvent _onDisconnect = null;
		protected SocketErrorEvent _onError = null;
		protected SocketEvent _onReceive = null;
		protected SocketProgressEvent _onSent = null;
		protected SocketEvent _onControl = null;
		protected FtpClientStatusEvent _onSuccess = null;
		protected FtpClientStatusEvent _onFailure = null;

		protected SocketEvent _onDs = new => OnDs ~ delete _;
		protected SocketErrorEvent _onEr = new => OnEr ~ delete _;
		protected SocketEvent _onSe = new => OnSe ~ delete _;
		protected SocketEvent _onRe = new => OnRe ~ delete _;

		protected SocketEvent _onControlCo = new => OnControlCo ~ delete _;
		protected SocketEvent _onControlDs = new => OnControlDs ~ delete _;
		protected SocketErrorEvent _onControlEr = new => OnControlEr ~ delete _;
		protected SocketEvent _onControlRe = new => OnControlRe ~ delete _;

		public FtpStatus StatusSet
		{
			get { return _statusSet; }
			set { _statusSet = value; }
		}
		public FtpStatus StatusFlags
		{
			get { return _statusFlags; }
			set { _statusFlags = value; }
		}
		public uint16 ChunkSize
		{
			get { return _chunkSize; }
			set { _chunkSize = value; }
		}
		public bool Binary
		{
			get { return _statusFlags.HasFlag(.Type); }
			set
			{
				if (CanContinue(.Type, value ? "TRUE" : "FALSE"))
				{
					_expectedBIN = value;
					_status.Insert(.Type);
					String tmp = scope .();
					tmp.AppendF("TYPE {0}\r\n", value ? "I" : "A");
					_control.SendMessage(tmp);
				}
			}
		}
		public bool PipeLine
		{
			get { return _pipeline; }
			set { _pipeline = value; }
		}
		public bool Echo
		{
			get { return _control.OptionIsSet(FtpTelnetClient.OPT_ECHO); }
			set
			{
				if (value)
					_control.SetOption(FtpTelnetClient.OPT_ECHO);
				else
					_control.UnSetOption(FtpTelnetClient.OPT_ECHO);
			}
		}
		public uint16 StartPort
		{
			get { return _startPort; }
			set { _startPort = value; }
		}
		public bool Transfer { get { return _data.Connected; } }
		public FtpStatus CurrentStatus { get { return _status.First().Status; } }
		public StringView PresentWorkingDirectoryString { get { return _pwd; }  }
		public ref SocketEvent OnConnect
		{
			get { return ref _onConnect; }
			set { _onConnect = value; }
		}
		public ref SocketEvent OnDisconnect
		{
			get { return ref _onDisconnect; }
			set { _onDisconnect = value; }
		}
		public ref SocketErrorEvent OnError
		{
			get { return ref _onError; }
			set { _onError = value; }
		}
		public ref SocketProgressEvent OnSent
		{
			get { return ref _onSent; }
			set { _onSent = value; }
		}
		public ref SocketEvent OnReceive
		{
			get { return ref _onReceive; }
			set { _onReceive = value; }
		}
		public ref SocketEvent OnControl
		{
			get { return ref _onControl; }
			set { _onControl = value; }
		}
		public ref FtpClientStatusEvent OnSuccess
		{
			get { return ref _onSuccess; }
			set { _onSuccess = value; }
		}
		public ref FtpClientStatusEvent OnFailure
		{
			get { return ref _onFailure; }
			set { _onFailure = value; }
		}

		public this() : base()
		{
			_control.OnConnect = _onControlCo;
			_control.OnDisconnect = _onControlDs;
			_control.OnError = _onControlEr;
			_control.OnReceive = _onControlRe;

			_data.OnDisconnect = _onDs;
			_data.OnError = _onEr;
			_data.OnReceive = _onRe;
			_data.OnCanSend = _onSe;

			ClearStatusFlags();
		}

		public ~this()
		{
			Disconnect(true);
		}

		protected void OnDs(Socket aSocket)
		{
			StopSending();
			Debug.WriteLine("Disconnected");
		}

		protected void OnEr(StringView aMsg, Socket aSocket)
		{
			StopSending();

			if (_onError != null)
				_onError(aMsg, aSocket);
		}

		protected void OnSe(Socket aSocket)
		{
			if (Connected && _sending)
				SendChunk(true);
		}

		protected void OnRe(Socket aSocket)
		{
			if (_onReceive != null)
				_onReceive(aSocket);
		}

		protected void OnControlCo(Socket aSocket)
		{
			if (_onConnect != null)
				_onConnect(aSocket);
		}

		protected void OnControlDs(Socket aSocket)
		{
			StopSending();

			if (_onError != null)
				_onError("Connection lost", aSocket);
		}

		protected void OnControlEr(StringView aMsg, Socket aSocket)
		{
			StopSending();
			FtpStatusRec rec;

			if (_onFailure != null)
			{
				while (!_status.Empty)
				{
					rec = _status.Remove();
					_onFailure(aSocket, rec.Status);
				}
			}
			else
			{
				_status.Clear();
			}

			ClearStatusFlags();

			if (_onError != null)
				_onError(aMsg, aSocket);
		}

		protected void OnControlRe(Socket aSocket)
		{
			if (_onControl != null)
				_onControl(aSocket);
		}

		protected void SetStartPort(uint16 aValue)
		{
			_startPort = aValue;

			if (aValue > _lastPort)
				_lastPort = aValue;
		}

		protected void PasvPort()
		{
			mixin StringPair(uint16 aPort)
			{
				String result = scope .();
				result.AppendF("{0},{1}", aPort / 256, aPort % 256);
				result
			}

			mixin IPStr()
			{
				String result = scope .();
				_control.Connection.Iterator.GetLocalAddress(result);
				result.Replace('.', ',');
				result.Append(',');
				result
			}


			if (_transferMethod == .Active)
			{
				Debug.WriteLine("Send PORT");
				_data.Disconnect(true);
				_data.Listen(_lastPort);
				_status.Insert(.Port);

				String command = scope .();
				command.AppendF("PORT {0}{1}\r\n", IPStr!(), StringPair!(_lastPort));
				_control.SendMessage(command);

				if (_lastPort < uint16.MaxValue)
					_lastPort++;
				else
					_lastPort = _startPort;
			}
			else
			{
				Debug.WriteLine("Send PASV");
				_status.Insert(.Pasv);
				_control.SendMessage("PASV\r\n");
			}
		}

		protected bool CanContinue(FtpStatus aStatus, StringView aArg1 = "", StringView aArg2 = "")
		{
			bool result = _pipeline || _status.Empty;

			if (!result)
				_commandFront.Insert(aStatus, aArg1, aArg2);

			return result;
		}

		protected void StopSending()
		{
			_sending = false;

			if (_storeFile != null)
				DeleteAndNullify!(_storeFile);
		}

		protected void ClearStatusFlags() =>
			_statusFlags = .None;

		protected int32 CleanInput(String aStr)
		{
			_fsl.SetText(aStr);

			for (int i = 0; i < _fsl.Count; i++)
				if (_fsl[i].Length > 0)
					EvaluateAnswer(_fsl[i]);

			aStr.Replace("\r\n", Environment.NewLine);
			int idx = aStr.IndexOf("PASS");

			if (idx > -1)
			{
				aStr.RemoveToEnd(idx);
				aStr.Append("PASS");
			}

			return (int32)aStr.Length;
		}

		protected void ParsePWD(StringView aStr)
		{
			bool isIn = false;
			_pwd.Clear();

			for (int i = 0; i < aStr.Length; i++)
			{
				if (aStr[i] == '"')
				{
					isIn = !isIn;
					continue;
				}

				if (isIn)
					_pwd.Append(aStr[i]);
			}
		}

		protected void EvaluateFeatures()
		{
			ClearAndDeleteItems!(_featureList);

			if (_featureString.Length == 0)
				return;

			_featureList.SetText(_featureString);
			_featureString.Clear();
			delete _featureList[0];
			_featureList.RemoveAt(0);

			int i = 0;
			String tmp = scope .();

			while (i < _featureList.Count)
			{
				tmp.Set(_featureList[i]);
				tmp.Trim();

				if (tmp.Length == 0 || _featureList[i][0] != ' ')
				{
					delete _featureList[i];
					_featureList.RemoveAt(i);
					continue;
				}

				_featureList[i].Set(tmp);
				i++;
			}
		}

		protected void EvaluateAnswer(StringView aAnswer)
		{
			mixin GetNum(StringView aStr)
			{
				int result = -1;

				if (aStr.Length > 3 &&
					HttpUtil.Search(HttpUtil.Numeric, aStr[0]) > -1 &&
					HttpUtil.Search(HttpUtil.Numeric, aStr[1]) > -1 &&
					HttpUtil.Search(HttpUtil.Numeric, aStr[2]) > -1)
					if (int.Parse(aStr.Substring(0, 3)) case .Ok(let val))
						result = val;

				result
			}

			void ParsePortIP(StringView aStr)
			{
				if (aStr.Length < 15)
					return;

				int i = 0;
				int l = 0;
				uint16 port = 0;
				StringList sl = new .();
				String ip = scope .();

				for (i = aStr.Length - 1; i > 4; i--)
					if (aStr[i] == ',')
						break;

				while (i < aStr.Length && HttpUtil.Search(NumericAndComma, aStr[i]) > -1)
					i++;

				if (HttpUtil.Search(NumericAndComma, aStr[i]) == -1)
					i--;

				while (HttpUtil.Search(NumericAndComma, aStr[i]) > -1)
				{
					l++;
					i--;
				}

				i++;
				sl.SetCommaText(aStr.Substring(i, l));
				ip.AppendF("{0}.{1}.{2}.{3}", sl[0], sl[1], sl[2], sl[3]);

				if (uint32.Parse(sl[4]) case .Ok(let val1))
					if (uint32.Parse(sl[5]) case .Ok(let val2))
						port = (uint16)((val1 * 256) + val2);

				Debug.WriteLine("Server PASV addr/port - {0} : {1}", ip, port);

				if (port > 0 && _data.Connect(ip, port))
					Debug.WriteLine("Connected after PASV");

				ClearAndDeleteItems!(sl);
				delete sl;
				_status.Remove();
			}

			mixin SendFile()
			{
				_storeFile.Position = 0;
				_sending = true;
				SendChunk(false);
			}

			mixin ValidResponse(StringView aLocAnswer)
			{
				bool result = aLocAnswer.Length >= 3 &&
					HttpUtil.Search(SmallNumeric, aLocAnswer[0]) > -1 &&
					HttpUtil.Search(HttpUtil.Numeric, aLocAnswer[1]) > -1 &&
					HttpUtil.Search(HttpUtil.Numeric, aLocAnswer[2]) > -1;
				
				if (result)
					result = aLocAnswer.Length == 3 || (aLocAnswer.Length > 3 && aLocAnswer[3] == ' ');

				result
			}

			mixin Eventize(FtpStatus aStatus, bool aIndRes)
			{
				_status.Remove();

				if (aIndRes)
				{
					if (_onSuccess != null && _statusSet.HasFlag(aStatus))
						_onSuccess(_data.Iterator, aStatus);
				}
				else
				{
					if (_onFailure != null && _statusSet.HasFlag(aStatus))
						_onFailure(_data.Iterator, aStatus);
				}
			}

			String cleanAnswer = scope .(aAnswer);
			cleanAnswer.Replace("\0", "");
			cleanAnswer.Trim();

			int ansNum = GetNum!(cleanAnswer);
			Debug.WriteLine("WOULD EVAL: {0} with value: {1} from \"{2}\"", _status.First().Status.StrVal, ansNum, cleanAnswer);

			if (_status.First().Status == .Feat)
				_featureString.AppendF("{0}\r\n", cleanAnswer); // We need to parse this later
				
			if (ValidResponse!(cleanAnswer))
			{
				if (!_status.Empty)
				{
					Debug.WriteLine("EVAL: {0} with value: {1}", _status.First().Status.StrVal, ansNum);
		
					switch(_status.First().Status)
					{
					case .Con:
						{
							if (ansNum == 220)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_statusFlags &= ~_status.First().Status;
								Eventize!(_status.First().Status, false);
							}
						}
					case .User:
						{
							if (ansNum == 230)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else if (ansNum == 331 || ansNum == 332)
							{
								_status.Remove();
								Password(_password);
							}
							else
							{
								_statusFlags &= ~_status.First().Status;
								Eventize!(_status.First().Status, false);
							}
						}
					case .Pass:
						{
							if (ansNum == 230)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_statusFlags &= ~_status.First().Status;
								Eventize!(_status.First().Status, false);
							}
						}
					case .Pasv:
						{
							if (ansNum == 227)
								ParsePortIP(cleanAnswer);
							else if (ansNum >= 300 && ansNum <= 600)
								_status.Remove();
						}
					case .Port:
						{
							if (ansNum == 200)
								Eventize!(_status.First().Status, true);
							else
								Eventize!(_status.First().Status, false);
						}
					case .Type:
						{
							if (ansNum == 200)
							{
								if (_expectedBIN)
									_statusFlags |= _status.First().Status;
								else
									_statusFlags &= ~_status.First().Status;

								Debug.WriteLine("Binary mode: ", _expectedBIN);
								Eventize!(_status.First().Status, true);
							}
							else
							{
								Eventize!(_status.First().Status, false);
							}
						}
					case .Retr:
						{
							if (ansNum == 125 || ansNum == 150)
							{
								// Do nothing
							}
							else if (ansNum == 226)
							{
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_data.Disconnect(true); // break on purpose, otherwise we get invalidated ugly
								Debug.WriteLine("Disconnecting data connection");
								Eventize!(_status.First().Status, false);
							}
						}
					case .Stor:
						{
							if (ansNum == 125 || ansNum == 150)
								SendFile!();
							else if (ansNum == 226)
								Eventize!(_status.First().Status, true);
							else
								Eventize!(_status.First().Status, false);
						}
					case .CWD:
						{
							if (ansNum == 200 || ansNum == 250)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_statusFlags &= ~_status.First().Status;
								Eventize!(_status.First().Status, false);
							}
						}
					case .PWD:
						{
							if (ansNum == 257)
							{
                       			ParsePWD(cleanAnswer);
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_statusFlags &= ~_status.First().Status;
								Eventize!(_status.First().Status, false);
							}
						}
					case .Help:
						{
							if (ansNum == 211 || ansNum == 214)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_statusFlags &= ~_status.First().Status;
								Eventize!(_status.First().Status, false);
							}
						}
					case .List:
						{
							if (ansNum == 125 || ansNum == 150) { } // Do nothing
							else if (ansNum == 226)
								Eventize!(_status.First().Status, true);
							else
								Eventize!(_status.First().Status, false);
						}
					case .MKD:
						{
							if (ansNum == 250 || ansNum == 257)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_statusFlags &= ~_status.First().Status;
								Eventize!(_status.First().Status, false);
							}
						}
					case .RMD, .DEL:
						{
							if (ansNum == 250)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_statusFlags &= ~_status.First().Status;
								Eventize!(_status.First().Status, false);
							}
						}
					case .RNFR:
						{
							if (ansNum == 350)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								Eventize!(_status.First().Status, false);
							}
						}
					case .RNTO:
						{
							if (ansNum == 250)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								Eventize!(_status.First().Status, false);
							}
						}
					case .Feat:
						{
							if (ansNum >= 200 && ansNum <= 299)
							{
								_statusFlags |= _status.First().Status;
                       			EvaluateFeatures();
								Eventize!(_status.First().Status, true);
							}
							else
							{
								_featureString.Clear();
								Eventize!(_status.First().Status, false);
							}
						}
					case .Quit:
						{
							if (ansNum == 221)
							{
								_statusFlags |= _status.First().Status;
								Eventize!(_status.First().Status, true);
							}
							else
							{
								Eventize!(_status.First().Status, false);
							}
						}
					default: break;
					}
				}
			}

			if (_status.Empty && !_commandFront.Empty)
				ExecuteFrontCommand();
		}

		protected bool User(StringView aUserName)
		{
			bool result = !_pipeline;

			if (CanContinue(.User, aUserName))
			{
				_status.Insert(.User);
				String command = scope .();
				command.AppendF("USER {0}\r\n", aUserName);
				_control.SendMessage(command);
				result = true;
			}

			return result;
		}

		protected bool Password(StringView aPassword)
		{
			bool result = !_pipeline;

			if (CanContinue(.Pass, aPassword))
			{
				_status.Insert(.Pass);
				String command = scope .();
				command.AppendF("PASS {0}\r\n", aPassword);
				_control.SendMessage(command);
				result = true;
			}

			return result;
		}

		protected void SendChunk(bool aIndEvent)
		{
			uint8* buf = new .[65536]*;
			int32 readLen = 0;
			int32 sentLen = 0;

			repeat
			{
				readLen = (int32)TrySilent!(_storeFile.TryRead(.((uint8*)buf, _chunkSize)));

				if (readLen > 0)
				{
					sentLen = _data.Send(buf, readLen);

					if (aIndEvent && _onSent != null && sentLen > 0)
						_onSent(_data.Iterator, sentLen);

					if (sentLen < readLen)
						_storeFile.Position -= readLen - sentLen; // so it's sent next time
				}
				else
				{
					if (_onSent != null)
						_onSent(_data.Iterator, 0);

					StopSending();
					_data.Disconnect(false);
				}
			}
			while (readLen > 0 && sentLen > 0);

			delete buf;
		}

		protected void ExecuteFrontCommand()
		{
			FtpStatusRec rec = _commandFront.Remove();

			switch (rec.Status)
			{
			case .None: return;
			case .User: User(rec.Args[0]);
			case .Pass: Password(rec.Args[0]);
			case .List: List(rec.Args[0]);
			case .Retr: Retrieve(rec.Args[0]);
			case .Stor: Put(rec.Args[0]);
			case .CWD:  ChangeDirectory(rec.Args[0]);
			case .MKD:  MakeDirectory(rec.Args[0]);
			case .RMD:  RemoveDirectory(rec.Args[0]);
			case .DEL:  DeleteFile(rec.Args[0]);
			case .RNFR: Rename(rec.Args[0], rec.Args[1]);
			case .SYS:  SystemInfo();
			case .PWD:  PresentWorkingDirectory();
			case .Help: Help(rec.Args[0]);
			case .Type: Binary = rec.Args[0].Equals("TRUE", .OrdinalIgnoreCase);
			case .Feat: ListFeatures();
			default:    break;
			}
		}

		protected override bool GetConnected() =>
			_statusFlags.HasFlag(.Con) && base.GetConnected();

		public override int32 Get(uint8* aData, int32 aSize, Socket aSocket = null)
		{
			int32 result = _control.Get(aData, aSize, aSocket);

			if (result > 0)
			{
				String tmp = scope .(result);
				tmp.Append((char8*)aData, result);
				result = CleanInput(tmp);
				Internal.MemMove(aData, tmp.Ptr, Math.Min(tmp.Length, aSize));
			}

			return result;
		}

		public override int32 GetMessage(String aOutMsg, Socket aSocket = null)
		{
			int32 result = _control.GetMessage(aOutMsg, aSocket);

			if (result > 0)
				result = CleanInput(aOutMsg);

			return result;
		}

		public override int32 Send(uint8* aData, int32 aSize, Socket aSocket = null) =>
			_control.Send(aData, aSize);

		public override int32 SendMessage(StringView aMsg, Socket aSocket = null) =>
			_control.SendMessage(aMsg);

		public virtual bool Connect(StringView aHost, uint16 aPort)
		{
			bool result = false;
			Disconnect(true);

			if (_control.Connect(aHost, aPort))
			{
				_host.Set(aHost);
				_port = aPort;
				_status.Insert(.Con);
				result = true;
			}

			if (_data.Eventer != _control.Connection.Eventer)
				_data.Eventer = _control.Connection.Eventer;

			return result;
		}

		public virtual bool Connect() =>
			Connect(_host, _port);

		public bool Authenticate(StringView aUserName, StringView aPassword)
		{
			_password.Set(aPassword);
			return User(aUserName);
		}

		public int32 GetData(uint8* aData, int32 aSize) =>
			_data.Iterator.Get(aData, aSize);

		public void GetDataMessage(String aOutMsg)
		{
			aOutMsg.Clear();

			if (_data.Iterator != null)
				_data.Iterator.GetMessage(aOutMsg);
		}

		public bool Retrieve(StringView aFileName)
		{
			bool result = !_pipeline;

			if (CanContinue(.Retr, aFileName))
			{
				PasvPort();
				_status.Insert(.Retr);
				String command = scope .();
				command.AppendF("RETR {0}\r\n", aFileName);
				_control.SendMessage(command);
				result = true;
			}

			return result;
		}

		public virtual bool Put(StringView aFileName) // because of Socket
		{
			bool result = !_pipeline;

			if (File.Exists(aFileName) && CanContinue(.Stor, aFileName))
			{
				_storeFile = new .();
				_storeFile.Open(aFileName, .Read, .Read);

				PasvPort();
				_status.Insert(.Stor);

				String command = scope .("STOR ");
				Path.GetFileName(aFileName, command);
				command.Append("\r\n");

				_control.SendMessage(command);
				result = true;
			}

			return result;
		}

		public bool ChangeDirectory(StringView aDestPath)
		{
			bool result = !_pipeline;

			if (CanContinue(.CWD, aDestPath))
			{
				_status.Insert(.CWD);
				_statusFlags &= ~.CWD;
				String command = scope .();
				command.AppendF("CWD {0}\r\n", aDestPath);
				_control.SendMessage(command);
				result = true;
			}

			return result;
		}

		public bool MakeDirectory(StringView aDirName)
		{
			bool result = !_pipeline;

			if (CanContinue(.MKD, aDirName))
			{
				_status.Insert(.MKD);
				_statusFlags &= ~.MKD;
				String command = scope .();
				command.AppendF("MKD {0}\r\n", aDirName);
				_control.SendMessage(command);
				result = true;
			}

			return result;
		}

		public bool RemoveDirectory(StringView aDirName)
		{
			bool result = !_pipeline;

			if (CanContinue(.RMD, aDirName))
			{
				_status.Insert(.RMD);
				_statusFlags &= ~.RMD;
				String command = scope .();
				command.AppendF("RMD {0}\r\n", aDirName);
				_control.SendMessage(command);
				result = true;
			}

			return result;
		}

		public bool DeleteFile(StringView aFileName)
		{
			bool result = !_pipeline;

			if (CanContinue(.DEL, aFileName))
			{
				_status.Insert(.DEL);
				_statusFlags &= ~.DEL;
				String command = scope .();
				command.AppendF("DELE {0}\r\n", aFileName);
				_control.SendMessage(command);
				result = true;
			}

			return result;
		}

		public bool Rename(StringView aOldName, StringView aNewName)
		{
			bool result = !_pipeline;

			if (CanContinue(.RNFR, aOldName, aNewName))
			{
				String command = scope .();

				_status.Insert(.RNFR);
				_statusFlags &= ~.RNFR;
				command.AppendF("RNFR {0}\r\n", aOldName);
				_control.SendMessage(command);

				_status.Insert(.RNTO);
				_statusFlags &= ~.RNTO;
				command.Clear();
				command.AppendF("RNTO {0}\r\n", aNewName);
				_control.SendMessage(command);

				result = true;
			}

			return result;
		}

		public void List(StringView aFileName = "")
		{
			if (CanContinue(.List, aFileName))
			{
				PasvPort();
				_status.Insert(.List);

				if (aFileName.Length > 0)
				{
					String command = scope .();
					command.AppendF("LIST {0}\r\n", aFileName);
					_control.SendMessage(command);
				}
				else
				{
					_control.SendMessage("LIST\r\n");
				}
			}
		}

		public void Nlst(StringView aFileName = "")
		{
			if (CanContinue(.List, aFileName))
			{
				PasvPort();
				_status.Insert(.List);

				if (aFileName.Length > 0)
				{
					String command = scope .();
					command.AppendF("NLST {0}\r\n", aFileName);
					_control.SendMessage(command);
				}
				else
				{
					_control.SendMessage("NLST\r\n");
				}
			}
		}

		public void SystemInfo()
		{
			if (CanContinue(.SYS))
				_control.SendMessage("SYST\r\n");
		}

		public void ListFeatures()
		{
			if (CanContinue(.Feat))
			{
				_status.Insert(.Feat);
				_control.SendMessage("FEAT\r\n");
			}
		}

		public void PresentWorkingDirectory()
		{
			if (CanContinue(.PWD))
			{
				_status.Insert(.PWD);
				_control.SendMessage("PWD\r\n");
			}
		}

		public void Help(StringView aArg)
		{
			if (CanContinue(.Help, aArg))
			{
				_status.Insert(.Help);
				String command = scope .();
				command.AppendF("HELP {0}\r\n", aArg);
				_control.SendMessage(command);
			}
		}

		public void Quit()
		{
			if (CanContinue(.Quit))
			{
				_status.Insert(.Quit);
				_control.SendMessage("QUIT\r\n");
			}
		}

		public override void Disconnect(bool aIndForced = false)
		{
			_control.Disconnect(aIndForced);
			_status.Clear();
			_data.Disconnect(aIndForced);
			_lastPort = _startPort;
			ClearStatusFlags();
			_commandFront.Clear();
		}

		public override void CallAction() =>
			_control.CallAction();
	}
}
