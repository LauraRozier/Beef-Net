using Beef_Net.Connection;
using Beef_Net.Interfaces;
using System;
using System.IO;

namespace Beef_Net
{
	public enum SmtpStatus
	{
		case None      = 0x000000;
		case Con       = 0x000001;
		case Helo      = 0x000002;
		case Ehlo      = 0x000004;
		case AuthLogin = 0x000008;
		case AuthPlain = 0x000010;
		case StartTLS  = 0x000020;
		case Mail      = 0x000040;
		case Rcpt      = 0x000080;
		case Data      = 0x000100;
		case Rset      = 0x000200;
		case Quit      = 0x000400;
		case Last      = 0x000800;

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .None:      return "None";
				case .Con:       return "Connect";
				case .Helo:      return "HELO";
				case .Ehlo:      return "EHLO";
				case .AuthLogin: return "AuthLogin";
				case .AuthPlain: return "AuthPlain";
				case .StartTLS:  return "STARTTLS";
				case .Mail:      return "MAIL";
				case .Rcpt:      return "RCPT";
				case .Data:      return "DATA";
				case .Rset:      return "RSET";
				case .Quit:      return "QUIT";
				case .Last:      return "LAST";
				}
			}
		}
	}

	public struct SmtpStatusRec
	{
		public SmtpStatus Status;
		public String[] Args = new .[2](new .(), new .());
	}

	public delegate void SmtpClientStatusEvent(Socket aSocket, SmtpStatus aStatus);

	public class SmtpStatusFront
	{
		public const int MAX_FRONT_ITEMS = 10;

		protected SmtpStatusRec _emptyItem;
		protected SmtpStatusRec[] _items = new .[MAX_FRONT_ITEMS] ~ { for (SmtpStatusRec item in _) { DeleteContainerAndItems!(item.Args); } delete _; };
		protected int _top = 0;
		protected int _bottom = 0;
		protected int _count = 0;

		public int Count { get { return _count; } }
		public bool Empty { get { return _count == 0; } }

		public this(SmtpStatusRec aDefaultItem)
		{
			_emptyItem = aDefaultItem;
			Clear();
		}

		public SmtpStatusRec First()
		{
			if (_count > 0)
				return _items[_bottom];

			return _emptyItem;
		}

		public SmtpStatusRec Remove()
		{
			SmtpStatusRec result = First();

			if (_count > 0)
			{
				_count--;
				_bottom++;

				if (_bottom >= MAX_FRONT_ITEMS)
					_bottom = 0;
			}

			return result;
		}

		public bool Insert(SmtpStatusRec aValue)
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

		public bool Insert(SmtpStatus aStatus, StringView aArg1 = "", StringView aArg2 = "")
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

	public class Mail
	{
		protected String _sender = new .() ~ delete _;
		protected String _recipients = new .() ~ delete _;
		protected String _subject = new .() ~ delete _;
		protected String _mailText = new .() ~ delete _;
		protected MimeStream _mailStream = null;

		public StringView Sender
		{
			get { return _sender; }
			set { _sender.Set(value); }
		}
		public StringView Recipients
		{
			get { return _recipients; }
			set { _recipients.Set(value); }
		}
		public StringView Subject
		{
			get { return _subject; }
			set { _subject.Set(value); }
		}
		public int SectionCount { get { return _mailStream.Count; } }

		public MimeSection GetSection(int aIdx) =>
			_mailStream.GetSection(aIdx);

		public void SetSection(int aIdx, MimeSection aValue) =>
			_mailStream.SetSection(aIdx, aValue);

		public void AddTextSection(StringView aText, StringView aCharSet = "UTF-8") =>
			_mailStream.AddTextSection(aText, aCharSet);

		public void AddFileSection(StringView aFileName) =>
			_mailStream.AddFileSection(aFileName);

		public void AddStreamSection(Stream aStream, bool aIndFreeStream = false) =>
			_mailStream.AddStreamSection(aStream, aIndFreeStream);

		public void DeleteSection(int aIdx) =>
			_mailStream.Delete(aIdx);

		public void RemoveSection(MimeSection aSection) =>
			_mailStream.Remove(aSection);

		public void Reset() =>
			_mailStream.Reset();
	}

	public abstract class Smtp : Component
	{
		protected StringList _featureList = new .() ~ DeleteContainerAndItems!(_);
		protected TcpConnection _connection = new .() ~ delete _;

	    public bool Connected { get { return _connection.Connected; } }
	    public ref TcpConnection Connection { get { return ref _connection; } }
	    public Eventer Eventer
		{
			get { return _connection.Eventer; }
			set { _connection.Eventer = value; }
		}
	    public int64 Timeout
		{
			get { return _connection.Timeout; }
			set { _connection.Timeout = value; }
		}
	    public Session Session
		{
			get { return _connection.Session; }
			set { _connection.Session = value; }
		}
	    public ref StringList FeatureList { get { return ref _featureList; } }

		protected override void SetCreator(Component aValue)
		{
			base.SetCreator(aValue);
			_connection.Creator = aValue;
		}

		public this() : base()
		{
			_connection.Creator = this;
			_connection.SocketClass = typeof(Socket);
		}

		public bool HasFeature(StringView aFeature)
		{
			StringList tmp = new .();
			String feature = scope .(aFeature);
			feature.ToUpper();
			feature.Replace(' ', ',');
			tmp.SetCommaText(feature);

			mixin Cleanup(bool aResult)
			{
				SmtpClient.ClearAndDeleteItemsSafe!(tmp);
				delete tmp;
				return aResult;
			}

			for (int i = 0; i < _featureList.Count; i++)
			{
				if (_featureList[i].IndexOf(tmp[0]) == 0)
				{
					if (tmp.Count == 1)
					{
						// No arguments, feature found, just exit true
						Cleanup!(true);
					}
					else
					{
						// Check arguments
						bool allArgs = true;

						for (int j = 0; j < tmp.Count; j++)
							if (_featureList[i].IndexOf(tmp[j]) < 0) // Some argument not found
							{
								allArgs = false;
								break;
							}

						if (allArgs)
							Cleanup!(true);
					}
				}
			}

			Cleanup!(false);
		}
	}

	public class SmtpClient : Smtp, IClient
	{
		private const uint16 DEFAULT_CHUNK = 8192;
		private readonly static SmtpStatusRec EMPTY_REC = .() ~ DeleteContainerAndItems!(_.Args);
		private readonly static char8[] NumericAndComma = new char8[11] (
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ','
		) ~ delete _;
		private readonly static char8[] SmallNumeric = new .[5]('1', '2', '3', '4', '5') ~ delete _;
		
		protected SmtpStatus _statusFlags = .None;
		protected SmtpStatus _statusSet = .None | .Con | .Helo | .Ehlo | .AuthLogin |
			.AuthPlain | .StartTLS | .Mail | .Rcpt | .Data | .Rset | .Quit | .Last;
		protected SmtpStatusFront _status = new .(EMPTY_REC) ~ delete _;
		protected SmtpStatusFront _commandFront = new .(EMPTY_REC) ~ delete _;

		protected bool _pipeline = false;

    	protected int _authStep = 0;
	    protected int _charCount = 0; // Count of chars from last CRLF

		protected StringList _fsl = new .() ~ DeleteContainerAndItems!(_);
	    protected String _buffer = new .() ~ delete _;
	    protected String _dataBuffer = new .() ~ delete _; // Intermediate wait buffer on DATA command
	    protected String _tempBuffer = new .() ~ delete _; // Used independently from FBuffer for feature list

	    protected Stream _stream;

	    protected SocketEvent _onConnect = null;
	    protected SocketEvent _onDisconnect = null;
	    protected SocketErrorEvent _onError = null;
	    protected SocketEvent _onReceive = null;
	    protected SocketProgressEvent _onSent = null;
	    protected SmtpClientStatusEvent _onSuccess = null;
	    protected SmtpClientStatusEvent _onFailure = null;

		protected SocketEvent _onCo = new => OnCo ~ delete _;
		protected SocketEvent _onDs = new => OnDs ~ delete _;
		protected SocketErrorEvent _onEr = new => OnEr ~ delete _;
		protected SocketEvent _onCs = new => OnCs ~ delete _;
		protected SocketEvent _onRe = new => OnRe ~ delete _;

	    public SmtpStatus StatusSet
		{
			get { return _statusSet; }
			set { _statusSet = value; }
		}
		public SmtpStatus StatusFlags
		{
			get { return _statusFlags; }
			set { _statusFlags = value; }
		}
    	public bool PipeLine
		{
			get { return _pipeline; }
			set { _pipeline = value; }
		}
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
	    public ref SocketEvent OnReceive
		{
			get { return ref _onReceive; }
			set { _onReceive = value; }
		}
	    public ref SocketProgressEvent OnSent
		{
			get { return ref _onSent; }
			set { _onSent = value; }
		}
	    public ref SmtpClientStatusEvent OnSuccess
		{
			get { return ref _onSuccess; }
			set { _onSuccess = value; }
		}
	    public ref SmtpClientStatusEvent OnFailure
		{
			get { return ref _onFailure; }
			set { _onFailure = value; }
		}

    	protected bool CanContinue(SmtpStatus aStatus, StringView aArg1 = "", StringView aArg2 = "")
		{
			bool result = _pipeline || _status.Empty;

			if (!result)
				_commandFront.Insert(aStatus, aArg1, aArg2);

			return result;
		}
    
    	protected int32 CleanInput(String aStr)
		{
			_fsl.SetText(aStr);

			if ((SmtpStatus.Con | SmtpStatus.Ehlo).HasFlag(_status.First().Status))
			{
				String tmp = scope .(aStr);
				tmp.ToUpper();
				_tempBuffer.Append(tmp);
			}

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

	    protected void OnCo(Socket aSocket)
		{
			if (_onConnect != null)
				_onConnect(aSocket);
		}

	    protected void OnDs(Socket aSocket)
		{
			if (_onDisconnect != null)
				_onDisconnect(aSocket);
		}

	    protected void OnEr(StringView aMsg, Socket aSocket)
		{
			if (_onFailure != null)
			{
				while (!_status.Empty)
					_onFailure(aSocket, _status.Remove().Status);
			}
			else
			{
				_status.Clear();
			}

			if (_onError != null)
				_onError(aMsg, aSocket);
		}

	    protected void OnRe(Socket aSocket)
		{
			if (_onReceive != null)
				_onReceive(aSocket);
		}

	    protected void OnCs(Socket aSocket) =>
			SendData(_status.First().Status == .Data);

		

		public static mixin ClearAndDeleteItemsSafe(var container)
		{
			for (var value in container)
			{
				if (value is String && ((String)value).IsDynAlloc)
				delete value;
			}

			container.Clear();
		}

    	protected void EvaluateServer()
		{
			ClearAndDeleteItemsSafe!(_featureList);

			if (_tempBuffer.Length == 0)
				return;

			if (_tempBuffer.IndexOf("ESMTP") > -1)
				_featureList.Add("EHLO");

			_tempBuffer.Clear();
		}

    	protected void EvaluateFeatures()
		{
			ClearAndDeleteItemsSafe!(_featureList);

			if (_tempBuffer.IsEmpty)
				return;

			_featureList.SetText(_tempBuffer);
			_tempBuffer.Clear();
			delete _featureList[0];
			_featureList.RemoveAt(0);
			int i = 0;

			while (i < _featureList.Count)
			{
				_featureList[i].Remove(0, 4); // Remove the response code
				_featureList[i].Replace('=', ' ');

				if (_featureList.IndexOf(_featureList[i]) != i)
				{
					delete _featureList[i];
					_featureList.RemoveAt(i);
					continue;
				}

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

			mixin Eventize(SmtpStatus aStatus, bool aIndRes)
			{
				_status.Remove();

				if (aIndRes)
				{
					if (_onSuccess != null && _statusSet.HasFlag(aStatus))
						_onSuccess(_connection.Iterator, aStatus);
				}
				else
				{
					if (_onFailure != null && _statusSet.HasFlag(aStatus))
						_onFailure(_connection.Iterator, aStatus);
				}
			}

			String cleanAnswer = scope .(aAnswer);
			cleanAnswer.Replace("\0", "");
			cleanAnswer.Trim();

			int ansNum = GetNum!(cleanAnswer);
			String tmp = scope .();
			SmtpStatusRec rec;

			if (ValidResponse!(aAnswer) && !_status.Empty)
			{
				rec = _status.First();

				switch (rec.Status)
				{
				case .Con,
					 .Helo,
					 .Ehlo:
					{
						if (ansNum >= 200 && ansNum <= 299)
						{
							if (rec.Status == .Con)
								EvaluateServer();
							else if (rec.Status == .Ehlo)
								EvaluateFeatures();

							Eventize!(rec.Status, true);
						}
						else
						{
							Eventize!(rec.Status, false);
							Disconnect(false);
							ClearAndDeleteItemsSafe!(_featureList);
							_tempBuffer.Clear();
						}
					}
				case .StartTLS:
					{
						if (ansNum >= 200 && ansNum <= 299)
						{
							Eventize!(rec.Status, true);
							_connection.Iterator.SetState(.SSLActive);
						}
						else
						{
							Eventize!(rec.Status, false);
						}
					}
				case .AuthLogin:
					{
						if (ansNum >= 200 && ansNum <= 299)
						{
							Eventize!(rec.Status, true);
						}
						else if (ansNum >= 300 && ansNum <= 399)
						{
							if (_authStep == 0)
							{
								tmp.Set(rec.Args[0]);
								tmp.Append("\r\n");
								AddToBuffer(tmp);
								_authStep++;
								SendData();
							}
							else if (_authStep == 1)
							{
								tmp.Set(rec.Args[1]);
								tmp.Append("\r\n");
								AddToBuffer(tmp);
								_authStep++;
								SendData();
							}
							else
							{
								Eventize!(rec.Status, false);
							}
						}
						else
						{
							Eventize!(rec.Status, false);
						}
					}
				case .AuthPlain:
					{
						if (ansNum >= 200 && ansNum <= 299)
						{
							Eventize!(rec.Status, true);
						}
						else if (ansNum >= 300 && ansNum <= 399)
						{
							tmp.Set(rec.Args[0]);
							tmp.Append(rec.Args[1], "\r\n");
							AddToBuffer(tmp);
							SendData();
						}
						else
						{
							Eventize!(rec.Status, false);
						}
					}
				case .Mail,
					 .Rcpt: Eventize!(rec.Status, ansNum >= 200 && ansNum <= 299);
				case .Data:
					{
						if (ansNum >= 200 && ansNum <= 299)
						{
							Eventize!(rec.Status, true);
						}
						else if (ansNum >= 300 && ansNum <= 399)
						{
							AddToBuffer(_dataBuffer);
							_dataBuffer.Clear();
							SendData(true);
						}
						else
						{
							_dataBuffer.Clear();
							Eventize!(rec.Status, false);
						}
					}
				case .Rset: Eventize!(rec.Status, ansNum >= 200 && ansNum <= 299);
				case .Quit:
					{
						Eventize!(rec.Status, ansNum >= 200 && ansNum <= 299);
						/*
						// Ported over for potential future reference. Also commented in lNet src
						if (_onDisconnect != null)
							_onDisconnect(_connection.Iterator);
						*/
						Disconnect(false);
					}
				default: break;
				}
			}

			if (_status.Empty && !_commandFront.Empty)
				ExecuteFrontCommand();
		}

    	protected void ExecuteFrontCommand()
		{
			SmtpStatusRec rec = _commandFront.Remove();

			switch (rec.Status)
			{
			case .None: return;
			case .Helo: Helo(rec.Args[0]);
			case .Ehlo: Ehlo(rec.Args[0]);
			case .Mail: Mail(rec.Args[0]);
			case .Rcpt: Rcpt(rec.Args[0]);
			case .Data: Data(rec.Args[0]);
			case .Rset: Rset();
			case .Quit: Quit();
			default:    break;
			}
		}

		protected void AddToBuffer(StringView aStr)
		{
			bool skip = false;
			String str = scope .(aStr);

			for (int i = 0; i < str.Length; i++)
			{
				if (skip)
				{
					skip = false;
					continue;
				}

				if (str[i] == '\r' || str[i] == '\n')
				{
					if (str[i] == '\r')
					{
						if (i < str.Length && str[i + 1] == '\n')
						{
							_charCount = 0;
							skip = true; // Skip the crlf
						}
						else // Insert LF to a standalone CR
						{
							str.Insert(i + 1, "\n");
							_charCount = 0;
							skip = true; // Skip the new crlf
						}
					}
					else if (str[i] == '\n')
					{
						str.Insert(i, "\r");
						_charCount = 0;
						skip = true; // Skip the new crlf
					}
				}
				else if (_charCount >= 1000) // line too long
				{
					str.Insert(i, "\r\n");
					_charCount = 0;
					skip = true; // Skip the new crlf
				}
				else
				{
					_charCount++;
				}
			}

			_buffer.Append(str);
		}

		protected void SendData(bool aIndFromStream = false)
		{
			int32 SBUF_SIZE = 65535;

			mixin FillBuffer()
			{
				String str = scope .(SBUF_SIZE - _buffer.Length);
				_stream.TryRead(.((uint8*)str.Ptr, str.Length));

				AddToBuffer(str);

				if (_stream.Position == _stream.Length) // We finished the stream
				{
					AddToBuffer("\r\n.\r\n");
					_stream = null;
				}
			}

			if (aIndFromStream && _stream != null)
				FillBuffer!();

			int len = 1;
			int sent = 0;

			while (_buffer.Length > 0 && len > 0)
			{
				len = _connection.SendMessage(_buffer);
				sent += len;

				if (len > 0)
					_buffer.Remove(0, len);

				if (aIndFromStream && _stream != null && _buffer.Length < SBUF_SIZE)
					FillBuffer!();
			}

			if (_onSent != null && _status.First().Status == .Data)
				_onSent(_connection.Iterator, sent);
		}

		protected static void EncodeBase64(StringView aStr, String aOutStr)
		{
			aOutStr.Clear();

			if (aStr.IsEmpty)
				return;

			MemoryStream dummy = scope .();
			Base64EncodingStream enc = new .(dummy);

			enc.TryWrite(.((uint8*)aStr.Ptr, aStr.Length));
			delete enc;
			
			dummy.Seek(0);
			dummy.TryRead(.((uint8*)aOutStr.PrepareBuffer((int)dummy.Length), (int)dummy.Length));
		}

		protected virtual void EncodeMimeHeaderText(StringView aStr, String aOutStr) =>
			aOutStr.Set(aStr);

    	public this() : base()
		{
			_port = 25;

			_connection.OnConnect = _onCo;
			_connection.OnDisconnect = _onDs;
			_connection.OnError = _onEr;
			_connection.OnReceive = _onRe;
			_connection.OnCanSend = _onCs;
		}

    	public ~this()
		{
			if (_connection.Connected)
				Quit();

			_status.Clear();
			_commandFront.Clear();
		}

		public virtual bool Connect(StringView aHost, uint16 aPort = 25)
		{
			bool result = false;
			Disconnect(true);

			if (_connection.Connect(aHost, aPort))
			{
				_tempBuffer.Clear();
				_host.Set(aHost);
				_port = aPort;
				_status.Insert(.Con);
				result = true;
			}

			return result;
		}

		public virtual bool Connect() =>
			Connect(_host, _port);

		public virtual int32 Get(uint8* aData, int32 aSize, Socket aSocket = null)
		{
			int32 result = _connection.Get(aData, aSize, aSocket);

			if (result > 0)
			{
				String tmp = scope .(result);
				tmp.Append((char8*)aData, result);
				result = CleanInput(tmp);
				Internal.MemMove(aData, tmp.Ptr, Math.Min(tmp.Length, aSize));
			}

			return result;
		}

		public virtual int32 GetMessage(String aOutMsg, Socket aSocket = null)
		{
			int32 result = _connection.GetMessage(aOutMsg, aSocket);

			if (result > 0)
				result = CleanInput(aOutMsg);

			return result;
		}

		public void SendMail(StringView aFrom, StringView aRecipients, StringView aSubject, StringView aMsg)
		{
			_stream = null;
			String from = scope .();
			String recipients = scope .();
			String subject = scope .();

			EncodeMimeHeaderText(aFrom, from);
			EncodeMimeHeaderText(aRecipients, recipients);
			EncodeMimeHeaderText(aSubject, subject);

			if (recipients.Length > 0 && from.Length > 0)
			{
				Mail(from);
				recipients.Replace(' ', ',');
				_fsl.SetCommaText(recipients);

				for (int i = 0; i < _fsl.Count; i++)
					Rcpt(_fsl[i]);

				String tmp = scope .();
				String command = scope .();
				_fsl.GetCommaText(tmp);
				command.AppendF("From: {0}\r\nSubject: {1}\r\nTo: {2}\r\n\r\n{3}", from, subject, tmp, aMsg);
				Data(command);
			}
		}
		
		public void SendMail(StringView aFrom, StringView aRecipients, StringView aSubject, Stream aStream)
		{
			_stream = null;
			String from = scope .();
			String recipients = scope .();
			String subject = scope .();

			EncodeMimeHeaderText(aFrom, from);
			EncodeMimeHeaderText(aRecipients, recipients);
			EncodeMimeHeaderText(aSubject, subject);

			_stream = aStream;

			if (recipients.Length > 0 && from.Length > 0)
			{
				Mail(from);
				recipients.Replace(' ', ',');
				_fsl.SetCommaText(recipients);

				for (int i = 0; i < _fsl.Count; i++)
					Rcpt(_fsl[i]);

				String tmp = scope .();
				String command = scope .();
				_fsl.GetCommaText(tmp);
				command.AppendF("From: {0}\r\nSubject: {1}\r\nTo: {2}\r\n", from, subject, tmp);
				Data(command);
			}
		}

		public void SendMail(Mail aMail)
		{
			if (aMail.[Friend]_mailText.Length > 0)
				SendMail(aMail.Sender, aMail.Recipients, aMail.Subject, aMail.[Friend]_mailText);
			else if (aMail.[Friend]_mailStream != null)
				SendMail(aMail.Sender, aMail.Recipients, aMail.Subject, aMail.[Friend]_mailStream);
		}

		public void Helo(StringView aHost = "")
		{
			String host = scope .(aHost);

			if (host.IsEmpty)
				host.Set(_host);

			if (CanContinue(.Helo, host))
			{
				_tempBuffer.Clear();
				String tmp = scope .();
				tmp.AppendF("HELO <{0}>\r\n", host);
				AddToBuffer(tmp);
				_status.Insert(.Helo);
				SendData();
			}
		}

		public void Ehlo(StringView aHost = "")
		{
			String host = scope .(aHost);

			if (host.IsEmpty)
				host.Set(_host);

			if (CanContinue(.Ehlo, host))
			{
				_tempBuffer.Clear();
				String tmp = scope .();
				tmp.AppendF("EHLO <{0}>\r\n", host);
				AddToBuffer(tmp);
				_status.Insert(.Ehlo);
				SendData();
			}
		}

		public void StartTLS()
		{
			if (CanContinue(.StartTLS))
			{
				AddToBuffer("STARTTLS\r\n");
				_status.Insert(.StartTLS);
				SendData();
			}
		}

		public void AuthLogin(StringView aName, StringView aPass)
		{
			String name = scope .();
			String pass = scope .();

			EncodeBase64(aName, name);
			EncodeBase64(aPass, pass);

			_authStep = 0; // First, send username

			if (CanContinue(.AuthLogin, name, pass))
			{
				AddToBuffer("AUTH LOGIN\r\n");
				_status.Insert(.AuthLogin, name, pass);
				SendData();
			}
		}

		public void AuthPlain(StringView aName, StringView aPass)
		{
			String name = scope .();
			String pass = scope .();
			String tmp = scope .("\0");

			tmp.Append(aName);
			EncodeBase64(tmp, name);

			tmp.Set("\0");
			tmp.Append(aPass);
			EncodeBase64(tmp, pass);

			_authStep = 0;

			if (CanContinue(.AuthPlain, name, pass))
			{
				AddToBuffer("AUTH PLAIN\r\n");
				_status.Insert(.AuthPlain, name, pass);
				SendData();
			}
		}

		public void Mail(StringView aFrom)
		{
			if (CanContinue(.Mail, aFrom))
			{
				String tmp = scope .();
				tmp.AppendF("MAIL FROM:<{0}>\r\n", aFrom);
				AddToBuffer(tmp);
				_status.Insert(.Mail);
				SendData();
			}
		}

		public void Rcpt(StringView aRcptTo)
		{
			if (CanContinue(.Rcpt, aRcptTo))
			{
				String tmp = scope .();
				tmp.AppendF("RCPT TO:<{0}>\r\n", aRcptTo);
				AddToBuffer(tmp);
				_status.Insert(.Rcpt);
				SendData();
			}
		}

		public void Data(StringView aStr)
		{
			if (CanContinue(.Data, aStr))
			{
				AddToBuffer("DATA \r\n");
				_dataBuffer.Clear();

				if (_stream != null)
				{
					if (aStr.Length > 0)
						_dataBuffer.Append(aStr);
				}
				else
				{
					_dataBuffer.AppendF("{0}\r\n.\r\n", aStr);
				}

				_status.Insert(.Data);
				SendData(false);
			}
		}

		public void Rset()
		{
			if (CanContinue(.Rset))
			{
				AddToBuffer("RSET\r\n");
				_status.Insert(.Rset);
				SendData();
			}
		}

		public void Quit()
		{
			if (CanContinue(.Quit))
			{
				AddToBuffer("QUIT\r\n");
				_status.Insert(.Quit);
				SendData();
			}
		}
    
    	public override void Disconnect(bool aIndForced = false)
		{
			_connection.Disconnect(aIndForced);
			_status.Clear();
			_commandFront.Clear();
		}

		public override void CallAction() =>
			_connection.CallAction();
	}
}
