using System;
using System.IO;
using Beef_Net.Connection;

namespace Beef_Net
{
	public enum HowEnum
	{
		TE_WILL = 251,
		TE_WONT,
		TE_DO,
		TE_DONW
	}

	public delegate void OnFullDlg();

	class ControlStack
	{
		public const uint8 TL_CSLENGTH = 3;

		protected char8[] _items = new .[TL_CSLENGTH] ~ delete _;
		protected uint8 _index = 0;
		protected OnFullDlg _onFull = null;

		public uint8 ItemIndex
		{
			get { return _index; }
		}

		public bool Full
		{
			get { return _index >= TL_CSLENGTH ? true : false; }
		}

		public ref OnFullDlg OnFull
		{
			get { return ref _onFull; }
			set { _onFull = value; }
		}

		public char8 GetItem(uint8 aIndex)
		{
			if (aIndex < TL_CSLENGTH)
				return _items[aIndex];

			return Telnet.TS_NOP;
		}

		public void SetItem(uint8 aIndex, char8 aValue)
		{
			if (aIndex < TL_CSLENGTH)
				_items[aIndex] = aValue;
		}

		public void Clear() =>
			_index = 0;

		public void Push(char8 aValue)
		{
			if (_index < TL_CSLENGTH)
			{
				_items[_index] = aValue;
				_index++;

				if (Full && _onFull != null)
					_onFull();
			}
		}
	}

	class Telnet
	{
		// Telnet printer signals
		public const char8 TS_NUL         = (char8)0;
		public const char8 TS_ECHO        = (char8)1;
		public const char8 TS_SGA         = (char8)3; // Surpass go-ahead
		public const char8 TS_BEL         = (char8)7;
		public const char8 TS_BS          = (char8)8;
		public const char8 TS_HT          = (char8)9;
		public const char8 TS_LF          = (char8)10;
		public const char8 TS_VT          = (char8)11;
		public const char8 TS_FF          = (char8)12;
		public const char8 TS_CR          = (char8)13;
		// Telnet control signals
		public const char8 TS_NAWS        = (char8)31;
		public const char8 TS_DATA_MARK   = (char8)128;
		public const char8 TS_BREAK       = (char8)129;
		public const char8 TS_HYI         = (char8)133; // Hide Your Input
		// Data types codes
		public const char8 TS_STDTELNET   = (char8)160;
		public const char8 TS_TRANSPARENT = (char8)161;
		public const char8 TS_EBCDIC      = (char8)162;
		// Control bytes
		public const char8 TS_SE          = (char8)240;
		public const char8 TS_NOP         = (char8)241;
		public const char8 TS_GA          = (char8)249; // go ahead currently ignored(full duplex)
		public const char8 TS_SB          = (char8)250;
		public const char8 TS_WILL        = (char8)251;
		public const char8 TS_WONT        = (char8)252;
		public const char8 TS_DO          = (char8)253;
		public const char8 TS_DONT        = (char8)254;
		// Mother of all power
		public const char8 TS_IAC         = (char8)255;

		protected ControlStack _stack = null;
		protected TcpConnection _connection = null;
		protected char8[] _possible = new .() ~ delete _; //: TLTelnetControlChars;
		protected char8[] _activeOpts = new .() ~ delete _; //: TLTelnetControlChars;
		protected MemoryStream _output = null;
		protected char8 _operation = 0;
		protected uint8 _commandCharIndex = 0;
		protected SocketEvent _onReceive = null;
		protected SocketEvent _onConnect = null;
		protected SocketEvent _onDisconnect = null;
		protected SocketErrorEvent _onError = null;
		protected String[3] _commandArgs = .() ~ { for (var value in _) if (value.IsDynAlloc) delete value; };
		protected char8[] _orders = new .() ~ delete _; //: TLTelnetControlChars;
		protected char8[] _buffer = new .() ~ delete _;
		protected int _bufferIndex = 0;
		protected int _bufferEnd = 0;

		public ref MemoryStream Output
		{
			get { return ref _output; }
		}

		public bool Connected
		{
			get { return _connection.Connected; }
		}

		public int64 Timeout
		{
			get { return _connection.Timeout; }
			set { _connection.Timeout = value; }
		}

		public ref SocketEvent OnReceive
		{
			get { return ref _onReceive; }
			set { _onReceive = value; }
		}

		public ref SocketEvent OnDisconnect
		{
			get { return ref _onDisconnect; }
			set { _onDisconnect = value; }
		}

		public ref SocketEvent OnConnect
		{
			get { return ref _onConnect; }
			set { _onConnect = value; }
		}

		public ref SocketErrorEvent OnError
		{
			get { return ref _onError; }
			set { _onError = value; }
		}

		public ref TcpConnection Connection
		{
			get { return ref _connection; }
		}

		public Type SocketClass
		{
			get { return _connection.SocketClass; }
			set { _connection.SocketClass = value; }
		}

		public Session Session
		{
			get { return _connection.Session; }
			set { _connection.Session = value; }
		}

		protected void InflateBuffer()
		{
			int newLen = Math.Max(_buffer.Count, 25) * 10;

			char8[] newArr = new char8[newLen](?);
			Internal.MemCpy(&newArr[0], &_buffer[0], _buffer.Count);
			delete _buffer;
			_buffer = newArr;
		}

		[Inline]
		protected bool AddToBuffer(StringView aStr)
		{
			while (aStr.Length + _bufferEnd > _buffer.Count) do
				InflateBuffer();

			Internal.MemMove(aStr.Ptr, &_buffer[_bufferEnd], aStr.Length);
			_bufferEnd += aStr.Length;
			return false;
		}

		/*
		protected
		function AddToBuffer(const aStr: string): Boolean; inline;

		function Question(const Command: Char; const Value: Boolean): Char;
		procedure SetCreator(AValue: TLComponent); override;

		procedure StackFull;
		procedure DoubleIAC(var s: string);
		function TelnetParse(const msg: string): Integer;
		procedure React(const Operation, Command: Char); virtual; abstract;
		procedure SendCommand(const Command: Char; const Value: Boolean); virtual; abstract;

		procedure OnCs(aSocket: TLSocket);

		public
		constructor Create(aOwner: TComponent); override;
		destructor Destroy; override;

		function Get(out aData; const aSize: Integer; aSocket: TLSocket = nil): Integer; virtual; abstract;
		function GetMessage(out msg: string; aSocket: TLSocket = nil): Integer; virtual; abstract;

		function Send(const aData; const aSize: Integer; aSocket: TLSocket = nil): Integer; virtual; abstract;
		function SendMessage(const msg: string; aSocket: TLSocket = nil): Integer; virtual; abstract;

		function OptionIsSet(const Option: Char): Boolean;
		function RegisterOption(const aOption: Char; const aCommand: Boolean): Boolean;
		procedure SetOption(const Option: Char);
		procedure UnSetOption(const Option: Char);

		procedure Disconnect(const Forced: Boolean = False); override;

		procedure SendCommand(const aCommand: Char; const How: TLHowEnum); virtual;
		*/
	}

	class TelnetClient
	{
		protected bool _localEcho;

		public bool LocalEcho
		{
			get { return _localEcho; }
			set { _localEcho = value; }
		}

		/*
		protected
		 procedure OnEr(const msg: string; aSocket: TLSocket);
		 procedure OnDs(aSocket: TLSocket);
		 procedure OnRe(aSocket: TLSocket);
		 procedure OnCo(aSocket: TLSocket);

		 procedure React(const Operation, Command: Char); override;

		 procedure SendCommand(const Command: Char; const Value: Boolean); override;
		public
		 constructor Create(aOwner: TComponent); override;

		 function Connect(const anAddress: string; const aPort: Word): Boolean;
		 function Connect: Boolean;

		 function Get(out aData; const aSize: Integer; aSocket: TLSocket = nil): Integer; override;
		 function GetMessage(out msg: string; aSocket: TLSocket = nil): Integer; override;

		 function Send(const aData; const aSize: Integer; aSocket: TLSocket = nil): Integer; override;
		 function SendMessage(const msg: string; aSocket: TLSocket = nil): Integer; override;

		 procedure CallAction; override;
		*/
	}
}
