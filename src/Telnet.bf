using Beef_Net.Connection;
using Beef_Net.Interfaces;
using System;
using System.Collections;
using System.IO;
using System.Reflection;

namespace Beef_Net
{
	public enum HowEnum : uint8
	{
		TE_WILL = 251,
		TE_WONT,
		TE_DO,
		TE_DONT
	}

	public delegate void OnFullEvent();

	class ControlStack
	{
		public const uint8 TL_CSLENGTH = 3;

		protected char8[] _items = new .[TL_CSLENGTH] ~ delete _;
		protected uint8 _index = 0;
		protected OnFullEvent _onFull = null;

		public uint8 ItemIndex { get { return _index; } }
		public bool Full { get { return _index >= TL_CSLENGTH ? true : false; } }
		public ref OnFullEvent OnFull
		{
			get { return ref _onFull; }
			set { _onFull = value; }
		}
		public char8 this[uint8 aIndex]
		{
			get
			{
				if (aIndex < TL_CSLENGTH)
					return _items[aIndex];

				return Telnet.CB_NOP;
			}
			set
			{
				if (aIndex < TL_CSLENGTH)
					_items[aIndex] = value;
			}
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

	public abstract class Telnet : Component, IDirect
	{
		/*
		 * Control bytes
		 */
		public const char8 CB_EOF   = (char8)236; // End of file: EOF is already used...
		public const char8 CB_SUSP  = (char8)237; // Suspend process
		public const char8 CB_ABORT = (char8)238; // Abort process
		public const char8 CB_EOR   = (char8)239; // end of record (transparent mode)
		public const char8 CB_SE    = (char8)240; // end sub negotiation
		public const char8 CB_NOP   = (char8)241; // nop
		public const char8 CB_DM    = (char8)242; // data mark--for connect. cleaning
		public const char8 CB_BREAK = (char8)243; // break
		public const char8 CB_IP    = (char8)244; // interrupt process--permanently
		public const char8 CB_AO    = (char8)245; // abort output--but let prog finish
		public const char8 CB_AYT   = (char8)246; // are you there
		public const char8 CB_EC    = (char8)247; // erase the current character
		public const char8 CB_EL    = (char8)248; // erase the current line
		public const char8 CB_GA    = (char8)249; // you may reverse the line
		public const char8 CB_SB    = (char8)250; // interpret as subnegotiation
		
		/*
		 * Operations
		 */
		public const char8 OP_WILL  = (char8)251; // I will use option
		public const char8 OP_WONT  = (char8)252; // I won't use option
		public const char8 OP_DO    = (char8)253; // please, you use option
		public const char8 OP_DONT  = (char8)254; // you are not to use option
		public const char8 OP_IAC   = (char8)255; // interpret as command:
		
		/*
		 * Options
		 *
		 * https://www.iana.org/assignments/telnet-options/telnet-options.xhtml
		 */
		// Telnet printer signals
		public const char8 OPT_BIN         = (char8)0;   // Binary Transmission
		public const char8 OPT_ECHO        = (char8)1;   // Echo
		public const char8 OPT_RECONNECT   = (char8)2;   // Reconnection
		public const char8 OPT_SGA         = (char8)3;   // Surpass go-ahead
		public const char8 OPT_AMSN        = (char8)4;   // Approx Message Size Negotiation
		public const char8 OPT_STATUS      = (char8)5;   // Status
		public const char8 OPT_TIMING_MARK = (char8)6;   // Timing Mark
		public const char8 OPT_RCTE        = (char8)7;   // Remote Controlled Trans and Echo
		public const char8 OPT_OLW         = (char8)8;   // Output Line Width
		public const char8 OPT_OPS         = (char8)9;   // Output Page Size
		public const char8 OPT_OCRD        = (char8)10;  // Output Carriage-Return Disposition
		public const char8 OPT_OHTS        = (char8)11;  // Output Horizontal Tab Stops
		public const char8 OPT_OHTD        = (char8)12;  // Output Horizontal Tab Disposition
		public const char8 OPT_OFD         = (char8)13;  // Output Formfeed Disposition
		public const char8 OPT_OVT         = (char8)14;  // Output Vertical Tabstops
		public const char8 OPT_OVTD        = (char8)15;  // Output Vertical Tab Disposition
		public const char8 OPT_OLD         = (char8)16;  // Output Linefeed Disposition
		public const char8 OPT_Ext_ASCII   = (char8)17;  // Extended ASCII
		public const char8 OPT_LOGOUT      = (char8)18;  // Logout
		public const char8 OPT_BM          = (char8)19;  // Byte Macro
		public const char8 OPT_DET         = (char8)20;  // Data Entry Terminal
		public const char8 OPT_SUPDUP      = (char8)21;  // SUPDUP
		public const char8 OPT_SUPDUP_Out  = (char8)22;  // SUPDUP Output
		public const char8 OPT_SL          = (char8)23;  // Send Location
		// Telnet control signals
		public const char8 OPT_TERM_TYPE     = (char8)24;  // Terminal Type
		public const char8 OPT_EoR           = (char8)25;  // End of Record
		public const char8 OPT_TACACS_UI     = (char8)26;  // TACACS User Identification
		public const char8 OPT_OM            = (char8)27;  // Output Marking
		public const char8 OPT_TLN           = (char8)28;  // Terminal Location Number
		public const char8 OPT_T3270R        = (char8)29;  // Telnet 3270 Regime
		public const char8 OPT_X3PAD         = (char8)30;  // X.3 PAD
		public const char8 OPT_NAWS          = (char8)31;  // Negotiate About Window Size
		public const char8 OPT_TS            = (char8)32;  // Terminal Speed
		public const char8 OPT_RFC           = (char8)33;  // Remote Flow Control
		public const char8 OPT_LINEMODE      = (char8)34;  // Linemode
		public const char8 OPT_XDL           = (char8)35;  // X Display Location
		public const char8 OPT_ENV_VARS      = (char8)36;  // Environment variables
		public const char8 OPT_AUTH          = (char8)37;  // Authentication
		public const char8 OPT_ENC           = (char8)38;  // Encryption
		public const char8 OPT_NEO           = (char8)39;  // New Environment Option
		public const char8 OPT_TN3270E       = (char8)40;  // TN3270E
		public const char8 OPT_XAUTH         = (char8)41;  // XAUTH
		public const char8 OPT_CHARSET       = (char8)42;  // CHARSET
		public const char8 OPT_TRSP          = (char8)43;  // Telnet Remote Serial Port (RSP)
		public const char8 OPT_CPCO          = (char8)44;  // Com Port Control Option
		public const char8 OPT_TSLE          = (char8)45;  // Telnet Suppress Local Echo
		public const char8 OPT_TS_TLS        = (char8)46;  // Telnet Start TLS
		public const char8 OPT_KERMIT        = (char8)47;  // KERMIT
		public const char8 OPT_SEND_URL      = (char8)48;  // SEND-URL
		public const char8 OPT_FORWARD_X     = (char8)49;  // FORWARD_X
		public const char8 OPT_DATA_MARK     = (char8)128; // Data Mark
		public const char8 OPT_BREAK         = (char8)129; // Break
		public const char8 OPT_HYI           = (char8)133; // Hide Your Input
		public const char8 OPT_TELOPT_PRAGMA = (char8)138; // TELOPT PRAGMA LOGON
		public const char8 OPT_TELOPT_SSPI   = (char8)139; // TELOPT SSPI LOGON
		public const char8 OPT_TELOPT_P_HB   = (char8)140; // TELOPT PRAGMA HEARTBEAT
		// Data types codes
		public const char8 OPT_STDTELNET     = (char8)160; // 
		public const char8 OPT_TRANSPARENT   = (char8)161; // 
		public const char8 OPT_EBCDIC        = (char8)162; //
		public const char8 OPT_EXOPL         = (char8)255; // extended-options-list

		// ASCII control chars
		public const char8 ASCII_NUL = (char8)0;   // NULL
		public const char8 ASCII_SOH = (char8)1;   // Start of Header
		public const char8 ASCII_STX = (char8)2;   // Start of Text
		public const char8 ASCII_ETX = (char8)3;   // End of Text
		public const char8 ASCII_EOT = (char8)4;   // End of Transmission
		public const char8 ASCII_ENQ = (char8)5;   // Enquiry
		public const char8 ASCII_ACK = (char8)6;   // Acknowledge
		public const char8 ASCII_BEL = (char8)7;   // Bell
		public const char8 ASCII_BS  = (char8)8;   // Backspace
		public const char8 ASCII_HT  = (char8)9;   // Horizontal Tab
		public const char8 ASCII_LF  = (char8)10;  // Line Feed
		public const char8 ASCII_VT  = (char8)11;  // Vertical Tab
		public const char8 ASCII_FF  = (char8)12;  // Form Feed
		public const char8 ASCII_CR  = (char8)13;  // Carriage Return
		public const char8 ASCII_SO  = (char8)14;  // Shift Out
		public const char8 ASCII_SI  = (char8)15;  // Shift In
		public const char8 ASCII_DLE = (char8)16;  // Data link escape
		public const char8 ASCII_DC1 = (char8)17;  // Device control 1
		public const char8 ASCII_DC2 = (char8)18;  // Device control 2
		public const char8 ASCII_DC3 = (char8)19;  // Device control 3
		public const char8 ASCII_DC4 = (char8)20;  // Device control 4
		public const char8 ASCII_NAK = (char8)21;  // Negative-acknowledge
		public const char8 ASCII_SYN = (char8)22;  // Synchronous idle
		public const char8 ASCII_ETB = (char8)23;  // End of trans. block
		public const char8 ASCII_CAN = (char8)24;  // Cancel
		public const char8 ASCII_EM  = (char8)25;  // End of medium
		public const char8 ASCII_SUB = (char8)26;  // Substitute
		public const char8 ASCII_ESC = (char8)27;  // Escape
		public const char8 ASCII_FS  = (char8)28;  // File separator
		public const char8 ASCII_GS  = (char8)29;  // Group separator
		public const char8 ASCII_RS  = (char8)30;  // Record separator
		public const char8 ASCII_US  = (char8)31;  // Unit separator
		public const char8 ASCII_DEL = (char8)127; // Delete

		public readonly static String[] TelnetOpNames = new .[256] (
			"0x00", "0x01", "0x02", "0x03", "0x04", "0x05", "0x06", "0x07", "0x08", "0x09", "0x0a", "0x0b", "0x0c", "0x0d", "0x0e", "0x0f",
			"0x10", "0x11", "0x12", "0x13", "0x14", "0x15", "0x16", "0x17", "0x18", "0x19", "0x1a", "0x1b", "0x1c", "0x1d", "0x1e", "0x1f",
			"\x20", "\x21", "\x22", "\x23", "\x24", "\x25", "\x26", "\x27", "\x28", "\x29", "\x2a", "\x2b", "\x2c", "\x2d", "\x2e", "\x2f",
			"\x30", "\x31", "\x32", "\x33", "\x34", "\x35", "\x36", "\x37", "\x38", "\x39", "\x3a", "\x3b", "\x3c", "\x3d", "\x3e", "\x3f",
			"\x40", "\x41", "\x42", "\x43", "\x44", "\x45", "\x46", "\x47", "\x48", "\x49", "\x4a", "\x4b", "\x4c", "\x4d", "\x4e", "\x4f",
			"\x50", "\x51", "\x52", "\x53", "\x54", "\x55", "\x56", "\x57", "\x58", "\x59", "\x5a", "\x5b", "\x5c", "\x5d", "\x5e", "\x5f",
			"\x60", "\x61", "\x62", "\x63", "\x64", "\x65", "\x66", "\x67", "\x68", "\x69", "\x6a", "\x6b", "\x6c", "\x6d", "\x6e", "\x6f",
			"\x70", "\x71", "\x72", "\x73", "\x74", "\x75", "\x76", "\x77", "\x78", "\x79", "\x7a", "\x7b", "\x7c", "\x7d", "\x7e", "0x7f",
			"0x80", "0x81", "0x82", "0x83", "0x84", "0x85", "0x86", "0x87", "0x88", "0x89", "0x8a", "0x8b", "0x8c", "0x8d", "0x8e", "0x8f",
			"0x90", "0x91", "0x92", "0x93", "0x94", "0x95", "0x96", "0x97", "0x98", "0x99", "0x9a", "0x9b", "0x9c", "0x9d", "0x9e", "0x9f",
			"\xa0", "\xa1", "\xa2", "\xa3", "\xa4", "\xa5", "\xa6", "\xa7", "\xa8", "\xa9", "\xaa", "\xab", "\xac", "\xad", "\xae", "\xaf",
			"\xb0", "\xb1", "\xb2", "\xb3", "\xb4", "\xb5", "\xb6", "\xb7", "\xb8", "\xb9", "\xba", "\xbb", "\xbc", "\xbd", "\xbe", "\xbf",
			"\xc0", "\xc1", "\xc2", "\xc3", "\xc4", "\xc5", "\xc6", "\xc7", "\xc8", "\xc9", "\xca", "\xcb", "\xcc", "\xcd", "\xce", "\xcf",
			"\xd0", "\xd1", "\xd2", "\xd3", "\xd4", "\xd5", "\xd6", "\xd7", "\xd8", "\xd9", "\xda", "\xdb", "\xdc", "\xdd", "\xde", "\xdf",
			"\xe0", "\xe1", "\xe2", "\xe3", "\xe4", "\xe5", "\xe6", "\xe7", "\xe8", "\xe9", "\xea", "\xeb", "CB_EOF" /*ec*/, "CB_SUSP" /*ed*/, "CB_ABORT" /*ee*/, "CB_EOR" /*ef*/,
			"CB_SE" /*f0*/, "CB_NOP" /*f1*/, "CB_DM" /*f2*/, "CB_BREAK" /*f3*/, "CB_IP" /*f4*/, "CB_AO" /*f5*/, "CB_AYT" /*f6*/, "CB_EC" /*f7*/, "CB_EL" /*f8*/, "CB_GA" /*f9*/, "CB_SB" /*fa*/, "OP_WILL" /*fb*/,
			"OP_WONT" /*fc*/, "OP_DO" /*fd*/, "OP_DONT" /*fe*/, "OP_IAC" /*ff*/
		) ~ delete _;

		public readonly static String[] TelnetCmdNames = new .[256] (
			"OPT_BIN" /*00*/, "OPT_ECHO" /*01*/, "OPT_RECONNECT" /*02*/, "OPT_SGA" /*03*/, "OPT_AMSN" /*04*/, "OPT_STATUS" /*05*/, "OPT_TIMING_MARK" /*06*/, "OPT_RCTE" /*07*/, "OPT_OLW" /*08*/, "OPT_OPS" /*09*/,
			"OPT_OCRD" /*0a*/, "OPT_OHTS" /*0b*/, "OPT_OHTD" /*0c*/, "OPT_OFD" /*0d*/, "OPT_OVT" /*0e*/, "OPT_OVTD" /*0f*/,
			"OPT_OLD" /*10*/, "OPT_Ext_ASCII" /*11*/, "OPT_LOGOUT" /*12*/, "OPT_BM" /*13*/, "OPT_DET" /*14*/, "OPT_SUPDUP" /*15*/, "OPT_SUPDUP_Out" /*16*/, "OPT_SL" /*17*/, "OPT_TERM_TYPE" /*18*/, "OPT_EoR" /*19*/,
			"OPT_TACACS_UI" /*1a*/, "OPT_OM" /*1b*/, "OPT_TLN" /*1c*/, "OPT_T3270R" /*1d*/, "OPT_X3PAD" /*1e*/, "OPT_NAWS" /*1f*/,
			"OPT_TS" /*20*/, "OPT_RFC" /*21*/, "OPT_LINEMODE" /*22*/, "OPT_XDL" /*23*/, "OPT_ENV_VARS" /*24*/, "OPT_AUTH" /*25*/, "OPT_ENC" /*26*/, "OPT_NEO" /*27*/, "OPT_TN3270E" /*28*/, "OPT_XAUTH" /*29*/,
			"OPT_CHARSET" /*2a*/, "OPT_TRSP" /*2b*/, "OPT_CPCO" /*2c*/, "OPT_TSLE" /*2d*/, "OPT_TS_TLS" /*2e*/, "OPT_KERMIT" /*2f*/,
			"OPT_SEND_URL" /*30*/, "OPT_FORWARD_X" /*31*/, "\x32", "\x33", "\x34", "\x35", "\x36", "\x37", "\x38", "\x39", "\x3a", "\x3b", "\x3c", "\x3d", "\x3e", "\x3f",
			"\x40", "\x41", "\x42", "\x43", "\x44", "\x45", "\x46", "\x47", "\x48", "\x49", "\x4a", "\x4b", "\x4c", "\x4d", "\x4e", "\x4f",
			"\x50", "\x51", "\x52", "\x53", "\x54", "\x55", "\x56", "\x57", "\x58", "\x59", "\x5a", "\x5b", "\x5c", "\x5d", "\x5e", "\x5f",
			"\x60", "\x61", "\x62", "\x63", "\x64", "\x65", "\x66", "\x67", "\x68", "\x69", "\x6a", "\x6b", "\x6c", "\x6d", "\x6e", "\x6f",
			"\x70", "\x71", "\x72", "\x73", "\x74", "\x75", "\x76", "\x77", "\x78", "\x79", "\x7a", "\x7b", "\x7c", "\x7d", "\x7e", "ASCII_DEL" /*7f*/,
			"OPT_DATA_MARK" /*80*/, "OPT_BREAK" /*81*/, "0x82", "0x83", "0x84", "OPT_HYI" /*85*/, "0x86", "0x87", "0x88", "0x89", "OPT_TELOPT_PRAGMA" /*8a*/, "OPT_TELOPT_SSPI" /*8b*/, "OPT_TELOPT_P_HB" /*8c*/,
			"0x8d", "0x8e", "0x8f",
			"0x90", "0x91", "0x92", "0x93", "0x94", "0x95", "0x96", "0x97", "0x98", "0x99", "0x9a", "0x9b", "0x9c", "0x9d", "0x9e", "0x9f",
			"OPT_STDTELNET" /*a0*/, "OPT_TRANSPARENT" /*a1*/, "OPT_EBCDIC" /*a2*/, "\xa3", "\xa4", "\xa5", "\xa6", "\xa7", "\xa8", "\xa9", "\xaa", "\xab", "\xac", "\xad", "\xae", "\xaf",
			"\xb0", "\xb1", "\xb2", "\xb3", "\xb4", "\xb5", "\xb6", "\xb7", "\xb8", "\xb9", "\xba", "\xbb", "\xbc", "\xbd", "\xbe", "\xbf",
			"\xc0", "\xc1", "\xc2", "\xc3", "\xc4", "\xc5", "\xc6", "\xc7", "\xc8", "\xc9", "\xca", "\xcb", "\xcc", "\xcd", "\xce", "\xcf",
			"\xd0", "\xd1", "\xd2", "\xd3", "\xd4", "\xd5", "\xd6", "\xd7", "\xd8", "\xd9", "\xda", "\xdb", "\xdc", "\xdd", "\xde", "\xdf",
			"\xe0", "\xe1", "\xe2", "\xe3", "\xe4", "\xe5", "\xe6", "\xe7", "\xe8", "\xe9", "\xea", "\xeb", "\xec", "\xed", "\xee", "\xef",
			"\xf0", "\xf1", "\xf2", "\xf3", "\xf4", "\xf5", "\xf6", "\xf7", "\xf8", "\xf9", "\xfa", "\xfb", "\xfc", "\xfd", "\xfe", "OPT_EXOPL" /*ff*/
		) ~ delete _;

		protected ControlStack _stack = null;
		protected TcpConnection _connection = null;

		protected List<char8> _possible = new .() ~ delete _; //: TLTelnetControlChars;
		protected List<char8> _activeOpts = new .() ~ delete _; //: TLTelnetControlChars;

		protected DynMemStream _output = null;
		protected char8 _operation = 0;
		protected uint8 _commandCharIndex = 0;

		protected SocketEvent _onConnect = null;
		protected SocketEvent _onDisconnect = null;
		protected SocketErrorEvent _onError = null;
		protected SocketEvent _onReceive = null;

		protected String[3] _commandArgs = .() ~ { for (var value in _) if (value != null && value.IsDynAlloc) delete value; };
		protected List<char8> _orders = new .() ~ delete _; //: TLTelnetControlChars;
		protected char8[] _buffer = new .() ~ delete _;
		protected int _bufferIndex = 0;
		protected int _bufferEnd = 0;

		protected SocketEvent _onCs = new => OnCs ~ delete _;
		protected OnFullEvent _stackFull = new => StackFull ~ delete _;

		public DynMemStream Output { get { return _output; } }
		public bool Connected { get { return _connection.Connected; } }
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
		public ref TcpConnection Connection { get { return ref _connection; } }
		public bool IsSSLSocket
		{
			get { return _connection.SocketClass == typeof(SSLSocket); }
			set { _connection.SocketClass = typeof(SSLSocket); }
		}
		public Session Session
		{
			get { return _connection.Session; }
			set { _connection.Session = value; }
		}

		protected void InflateBuffer()
		{
			char8[] newArr = new .[Math.Max(_buffer.Count, 25) * 10];

			if (_buffer.Count > 0)
				Internal.MemCpy(&newArr[0], &_buffer[0], _buffer.Count);

			delete _buffer;
			_buffer = newArr;
		}

		[Inline]
		protected bool AddToBuffer(Span<char8> aStr)
		{
			while (aStr.Length + _bufferEnd > _buffer.Count) do
				InflateBuffer();

			Internal.MemMove(&_buffer[_bufferEnd], aStr.Ptr, aStr.Length);
			_bufferEnd += aStr.Length;
			return false;
		}

		protected char8 Question(char8 aCommand, bool aValue) =>
			aValue
				? (_orders.Contains(aCommand) ? OP_DO : OP_WILL)
				: (_orders.Contains(aCommand) ? OP_DONT : OP_WONT);

		protected override void SetCreator(Component aValue)
		{
			base.SetCreator(aValue);
			_connection.Creator = aValue;
		}

		protected void StackFull()
		{
#if DEBUG
			System.Diagnostics.Debug.WriteLine("**STACKFULL**");
#endif

			if (_stack[1] == OP_IAC)
			{
				_output.Write((uint8)_stack[1]);
				_output.Write((uint8)_stack[2]);
			}
			else
			{
				React(_stack[1], _stack[2]);
			}

			_stack.Clear();
		}

		protected void DoubleIAC(String aStr)
		{
			int_strsize i = 0;

			if (aStr.Length > 0)
				while (i < aStr.Length)
				{
					if (aStr[i] == OP_IAC)
					{
						// procedure Insert(Source: string or dynamic array; var Dest: string or dynamic array; Index: Integer);
						// Insert(OP_IAC, s, i);
						aStr.Insert(i, OP_IAC);
						i += 2;
					}

					i++;
				}
		}

		protected int TelnetParse(StringView aMsg)
		{
			int result = 0;

			for (int i = 0; i < aMsg.Length; i++)
			{
				if (_stack.ItemIndex > 0 || aMsg[i] == OP_IAC)
				{
					if (aMsg[i] == CB_GA)
						_stack.Clear();
					else
						_stack.Push(aMsg[i]);
				}
				else
				{
					_output.Write((uint8)aMsg[i]);
					result++;
				}
			}

			return result;
		}

		protected abstract void React(char8 aOperation, char8 aCommand);
		protected abstract void SendCommand(char8 aCommand, bool aValue);

		protected void OnCs(Socket aSocket)
		{
			int n = 1;
			
			while (n > 0 && _bufferIndex < _bufferEnd)
			{
				n = _connection.Send((uint8*)&_buffer[_bufferIndex], (int32)(_bufferEnd - _bufferIndex));

				if (n > 0)
				  	_bufferIndex += n;
			}

			if (_bufferEnd - _bufferIndex < _bufferIndex) // if we can, move the "right" side of the buffer back to the left
			{
				Internal.MemMove(&_buffer[0], &_buffer[_bufferIndex], _bufferEnd - _bufferIndex);
				_bufferEnd -= _bufferIndex;
				_bufferIndex = 0;
			}
		}

		public this() : base()
		{
			_connection = new TcpConnection();
			_connection.Creator = this;
			_connection.OnCanSend = _onCs;

			_output = new DynMemStream();
			_commandCharIndex = 0;
			_stack = new ControlStack();
			_stack.OnFull = _stackFull;
		}

		public ~this()
		{
			Disconnect(true);
			delete _output;
			delete _connection;
			delete _stack;
		}

		public abstract int32 Get(uint8* aData, int32 aSize, Socket aSocket = null);
		public abstract int32 GetMessage(String aOutMsg, Socket aSocket = null);

		public abstract int32 Send(uint8* aData, int32 aSize, Socket aSocket = null);
		public abstract int32 SendMessage(StringView aMsg, Socket aSocket = null);

		public bool OptionIsSet(char8 aOption) =>
			_activeOpts.Contains(aOption);

		public bool RegisterOption(char8 aOption, bool aIndCommand)
		{
			if (!_possible.Contains(aOption))
			{
				_possible.Add(aOption);

				if (aIndCommand)
					_orders.Add(aOption);

				return true;
			}

			return false;
		}

		public void SetOption(char8 aOption)
		{
			if (_possible.Contains(aOption))
				SendCommand(aOption, true);
		}

		public void UnSetOption(char8 aOption)
		{
			if (_possible.Contains(aOption))
				SendCommand(aOption, false);
		}

		public override void Disconnect(bool aIndForced = false) =>
			_connection.Disconnect(aIndForced);

		public virtual void SendCommand(char8 aCommand, HowEnum aHow)
		{
			String tmp = scope .();
#if DEBUG
			tmp.Append("**SENT** ", TelnetOpNames[aHow.Underlying], " ", TelnetCmdNames[(uint8)aCommand]);
			System.Diagnostics.Debug.WriteLine(tmp);
			tmp.Clear();
#endif
			tmp.Append(OP_IAC);
			tmp.Append((char8)aHow.Underlying);
			tmp.Append(aCommand);
			AddToBuffer(tmp);
			OnCs(null);
		}
	}

	public class TelnetClient : Telnet, IClient
	{
		protected bool _localEcho = false;
		protected SocketEvent _onCo = new => OnCo ~ delete _;
		protected SocketEvent _onDs = new => OnDs ~ delete _;
		protected SocketErrorEvent _onEr = new => OnEr ~ delete _;
		protected SocketEvent _onRe = new => OnRe ~ delete _;

		public bool LocalEcho
		{
			get { return _localEcho; }
			set { _localEcho = value; }
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
			if (_onError != null)
				_onError(aMsg, aSocket);
			else
				_output.TryWrite(.((uint8*)aMsg.Ptr, aMsg.Length));
		}

		protected void OnRe(Socket aSocket)
		{
			String tmp = new .();

			if (aSocket.GetMessage(tmp) > 0)
				if (TelnetParse(tmp) > 0 && _onReceive != null)
				  	_onReceive(aSocket);

			delete tmp;
		}

		protected override void React(char8 aOperation, char8 aCommand)
		{
			String tmp = scope .();

			mixin Accept(char8 aOperation, char8 aCommand)
			{
				_activeOpts.Add(aCommand);
#if DEBUG
				tmp.Append("**SENT** ", TelnetOpNames[(uint8)aOperation], " ", TelnetCmdNames[(uint8)aCommand]);
				System.Diagnostics.Debug.WriteLine(tmp);
				tmp.Clear();
#endif
				tmp.Append(OP_IAC);
				tmp.Append(aOperation);
				tmp.Append(aCommand);
			    AddToBuffer(tmp);
			    OnCs(null);
			}

			mixin Refuse(char8 aOperation, char8 aCommand)
			{
				_activeOpts.Remove(aCommand);
#if DEBUG
				tmp.Append("**SENT** ", TelnetOpNames[(uint8)aOperation], " ", TelnetCmdNames[(uint8)aCommand]);
				System.Diagnostics.Debug.WriteLine(tmp);
				tmp.Clear();
#endif
				tmp.Append(OP_IAC);
				tmp.Append(aOperation);
				tmp.Append(aCommand);
			    AddToBuffer(tmp);
			    OnCs(null);
			}

#if DEBUG
			tmp.Append("**GOT** ", TelnetOpNames[(uint8)aOperation], " ", TelnetCmdNames[(uint8)aCommand]);
			System.Diagnostics.Debug.WriteLine(tmp);
			tmp.Clear();
#endif
  			switch (aOperation)
			{
    		case OP_DO:
				{
					if (_possible.Contains(aCommand))
						Accept!(OP_WILL, aCommand);
					else
						Refuse!(OP_WONT, aCommand);
				}
    		case OP_DONT:
				{
					if (_possible.Contains(aCommand))
						Refuse!(OP_WONT, aCommand);
				}
    		case OP_WILL:
				{
					if (_possible.Contains(aCommand))
						_activeOpts.Add(aCommand);
					else
						Refuse!(OP_DONT, aCommand);
				}
    		case OP_WONT:
				{
					if (_possible.Contains(aCommand))
						_activeOpts.Remove(aCommand);
				}
			}
		}

		protected override void SendCommand(char8 aCommand, bool aValue)
		{
  			if (Connected)
			{
				String tmp = scope .();
#if DEBUG
				tmp.Append("**SENT** ", TelnetOpNames[(uint8)Question(aCommand, aValue)], " ", TelnetCmdNames[(uint8)aCommand]);
				System.Diagnostics.Debug.WriteLine(tmp);
				tmp.Clear();
#endif

				if (Question(aCommand, aValue) == OP_WILL)
      				_activeOpts.Add(aCommand);

				tmp.Append(OP_IAC);
				tmp.Append(Question(aCommand, aValue));
				tmp.Append(aCommand);
    			AddToBuffer(tmp);
    			OnCs(null);
			}
		}

		public this(): base()
		{
			_connection.OnConnect = _onCo;
			_connection.OnDisconnect = _onDs;
			_connection.OnError = _onEr;
			_connection.OnReceive = _onRe;
			
			_possible.Add(OPT_ECHO);
			_possible.Add(OPT_HYI);
			_possible.Add(OPT_SGA);
			_activeOpts.Clear();
			_orders.Clear();
		}

		public virtual bool Connect(StringView aAddress, uint16 aPort)
		{
			_host.Set(aAddress);
			_port = aPort;
			return _connection.Connect(aAddress, aPort);
		}

		public virtual bool Connect() =>
			_connection.Connect(_host, _port);

		public override int32 Get(uint8* aData, int32 aSize, Socket aSocket = null)
		{
			int result = TrySilent!(_output.TryRead(.((uint8*)aData, aSize)));

			if (_output.Position == _output.Length)
				_output.RemoveFromStart((int)_output.Length);

			return (int32)result;
		}

		public override int32 GetMessage(String aOutMsg, Socket aSocket = null)
		{
			aOutMsg.Clear();
			int result = 0;
			int len = (int)_output.Length;

			if (len > 0)
			{
				uint8[] buff = new uint8[len];

				_output.Position = 0;
				result = TrySilent!(_output.TryRead(.(&buff[0], len)));

				if (result > 0)
				{
					System.Text.Encoding.ASCII.DecodeToUTF8(.(&buff[0], len), aOutMsg);
					_output.RemoveFromStart(result);
				}

				delete buff;
			}

			return (int32)result;
		}

		public override int32 Send(uint8* aData, int32 aSize, Socket aSocket = null)
		{
#if DEBUG
  			System.Diagnostics.Debug.WriteLine("**SEND START** ");
#endif
  			int32 result = 0;

  			if (aSize > 0)
			{
				String tmp = scope .();
				tmp.PrepareBuffer(aSize);
				Internal.MemMove(tmp.Ptr, aData, aSize);
    			DoubleIAC(tmp);

    			if (LocalEcho && (!OptionIsSet(OPT_ECHO)) && (!OptionIsSet(OPT_HYI)))
      				_output.TryWrite(.((uint8*)tmp.Ptr, tmp.Length));

    			AddToBuffer(tmp);
    			OnCs(null);

    			result = aSize;
  			}

#if DEBUG
  			System.Diagnostics.Debug.WriteLine("**SEND END** ");
#endif
			return result;
		}

		public override int32 SendMessage(StringView aMsg, Socket aSocket = null)
		{
			int32 len = (int32)aMsg.Length;
			uint8* buff = scope .[len]*;
			System.Text.Encoding.ASCII.Encode(aMsg, .(buff, len));
			return Send(buff, len);
		}

		public override void CallAction()
		{
			if (_connection != null)
				_connection.CallAction();
		}
	}
}
