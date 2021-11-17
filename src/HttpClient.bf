using System;

namespace Beef_Net
{
	public enum HttpClientError
	{
		case None;
		case MalformedStatusLine;
		case VersionNotSupported;
		case UnsupportedEncoding;

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .None:                return "";
				case .MalformedStatusLine: return "Malformed Status Line";
				case .VersionNotSupported: return "Version Not Supported";
				case .UnsupportedEncoding: return "Unsupported Encoding";
				}
			}
		}
	}

	public enum HttpClientState
	{
		Idle,
		Waiting,
		Receiving
	}

	public struct ClientRequest
	{
	    public HttpMethod Method;
	    public String Uri;
	    public String QueryParams;
	    public uint64 RangeStart;
	    public uint64 RangeEnd;
	}

	public struct ClientResponse
	{
	    public HttpStatus Status;
	    public uint32 Version;
	    public String Reason; 
	}
	
	public delegate void CanWriteEvent(HttpClientSocket aSocket, ref WriteBlockStatus aOutEof);
	public delegate int32 InputEvent(HttpClientSocket aSocket, uint8* aBuffer, int32 aSize);
	public delegate void HttpClientEvent(HttpClientSocket aSocket);

	class ClientOutput : OutputItem
	{
		protected override void DoneInput() =>
			((HttpClient)(((HttpClientSocket)_socket).[Friend]_creator)).[Friend]DoDoneInput((HttpClientSocket)_socket);

		protected override int32 HandleInput(uint8* aBuffer, int32 aSize) =>
			((HttpClient)(((HttpClientSocket)_socket).[Friend]_creator)).[Friend]DoHandleInput((HttpClientSocket)_socket, aBuffer, aSize);

		protected override WriteBlockStatus WriteBlock() =>
			((HttpClient)(((HttpClientSocket)_socket).[Friend]_creator)).[Friend]DoWriteBlock((HttpClientSocket)_socket);

		public this(HttpClientSocket aSocket) : base(aSocket)
		{
			_persistent = true;
		}
	}
	
	[AlwaysInclude(IncludeAllMethods=true), Reflect(.All)]
	public class HttpClientSocket : HttpSocket
	{
	    protected HttpClientError _error = .None;
	    protected ClientRequest* _request = null;// ~ if (_ != null) { delete _.QueryParams; delete _.Uri; };
	    protected ClientResponse* _response = null;// ~ if (_ != null) { delete _.Reason; };
	    protected HeaderOutInfo* _headerOut = null; // ~ if (_ != null) { _.ExtraHeaders.Free(); };
		protected String* _userAgent = null;

	    public HttpClientError Error
		{
			get { return _error; }
			set { _error = value; }
		}
	    public ClientResponse* Response { get { return _response; } }
	    public HttpStatus ResponseStatus { get { return _response.Status; } }

	    protected override void AddContentLength(int32 aLength) =>
			((HttpClient)_creator).[Friend]_headerOut.ContentLength += aLength;

	    protected void Cancel(HttpClientError aError)
		{
			_error = aError;
			Disconnect();
		}

	    protected override void ParseLine(uint8* aLineEnd)
		{
			if (_error != .None)
				return;

			if (_response.Status == .Unknown)
			{
				ParseStatusLine(aLineEnd);
				return;
			}

			base.ParseLine(aLineEnd);
		}

	    protected void ParseStatusLine(uint8* aLineEnd)
		{
			uint8* pos = _bufferPos;

			while (true)
			{
				if (pos >= aLineEnd)
				{
					Cancel(.MalformedStatusLine);
					return;
				}

				if (*pos == (uint8)' ')
					break;

				pos++;
			}

			if (!HttpVersionCheck(_bufferPos, pos, out _response.Version))
			{
				Cancel(.MalformedStatusLine);
				return;
			}

			if (_response.Version > 11)
			{
				Cancel(.VersionNotSupported);
				return;
			}

			/* Status code */
			pos++;

			if (pos + 3 >= aLineEnd || pos[3] != (uint8)' ')
			{
				Cancel(.MalformedStatusLine);
				return;
			}

			_response.Status = HttpStatus.FromCode(((pos[0] - (uint8)'0') * 100) + ((pos[1] - (uint8)'0') * 10) + (pos[2] - (uint8)'0'));

			if (_response.Status == .Unknown)
			{
				Cancel(.MalformedStatusLine);
				return;
			}

			pos += 4;

			if (pos < aLineEnd)
				_response.Reason = new .((char8*)pos);
		}

	    protected override void ProcessHeaders()
		{
			if (!ProcessEncoding())
				Cancel(.UnsupportedEncoding);

			((HttpClient)_creator).[Friend]DoProcessHeaders(this);
		}

	    protected override void ResetDefaults()
		{
			base.ResetDefaults();
			_error = .None;
		}

	    public this() : base()
		{
			_currentInput = new ClientOutput(this);
			ResetDefaults();
		}

	    public ~this()
		{
			if (_currentInput != null)
			{
				((ClientOutput)_currentInput).[Friend]_persistent = false;
				DeleteAndNullify!(_currentInput);
			}
		}

	    public void GetResponseReason(String aOutStr) =>
			aOutStr.Set(_response.Reason);

    	public void SendRequest()
		{
			String tmp = scope .(23);
			StringBuffer msg = .Init(504);
			msg.AppendString(_request.Method.StrVal, true);
			msg.AppendChar(' ');
			msg.AppendString(_request.Uri);
			msg.AppendChar(' ');
			msg.AppendString("HTTP/1.1\r\nHost: ");
			msg.AppendString(((HttpClient)_creator).Host);

			if (((HttpClient)_creator).Port != 80)
			{
				msg.AppendChar(':');
				((HttpClient)_creator).Port.ToString(tmp);
				msg.AppendString(tmp);
			}

			msg.AppendString("\r\n");

			if ((*_userAgent).Length > 0)
			{
				tmp.Clear();
				tmp.AppendF("User-Agent: {0}\r\n", *_userAgent);
				msg.AppendString(tmp);
			}

			if (_headerOut.ContentLength > 0)
			{
				tmp.Clear();
				msg.AppendString("Content-Length: ");
				_headerOut.ContentLength.ToString(tmp);
				tmp.Append("\r\n");
				msg.AppendString(tmp);
			}

			bool hasRangeStart = ((HttpClient)_creator).RangeStart != uint64.MaxValue;
			bool hasRangeEnd = ((HttpClient)_creator).RangeEnd != uint64.MaxValue;

			if (hasRangeStart || hasRangeEnd)
			{
				msg.AppendString("Range: bytes=");

				if (hasRangeStart)
				{
					tmp.Clear();
					((HttpClient)_creator).RangeStart.ToString(tmp);
					msg.AppendString(tmp);
				}

				msg.AppendChar('-');

				if (hasRangeEnd)
				{
					tmp.Clear();
					((HttpClient)_creator).RangeEnd.ToString(tmp);
					msg.AppendString(tmp);
				}

				msg.AppendString("\r\n");
			}

			msg.AppendString(_headerOut.ExtraHeaders.Memory, (int32)(_headerOut.ExtraHeaders.Pos - _headerOut.ExtraHeaders.Memory));
			msg.AppendString("\r\n");
			AddToOutput(new MemoryOutput(this, msg.Memory, 0, (int32)(msg.Pos - msg.Memory), true));
			AddToOutput(_currentInput);

			PrepareNextRequest();
			WriteBlock();
		}
	}

	public class HttpClient : HttpConnection
	{
	    protected ClientRequest _request = .() ~ { delete _.QueryParams; delete _.Uri; };
	    protected ClientResponse _response = .() ~ { delete _.Reason; };
	    protected HeaderOutInfo _headerOut = .();
	    protected HttpClientState _state = .Idle;
	    protected int32 _pendingResponses = 0;
	    protected bool _outputEof = false;
	    protected CanWriteEvent _onCanWrite = null;
	    protected InputEvent _onInput = null;
	    protected HttpClientEvent _onDoneInput = null;
	    protected HttpClientEvent _onProcessHeaders = null;
		protected String _userAgent = new .("Beef-Net/1.0") ~ delete _;

	    public ClientRequest Request { get { return _request; } }
	    public uint64 RangeStart
		{
			get { return _request.RangeStart; }
			set { _request.RangeStart = value; }
		}
	    public uint64 RangeEnd
		{
			get { return _request.RangeEnd; }
			set { _request.RangeEnd = value; }
		}
	    public StringView Uri
		{
			get { return _request.Uri; }
			set { _request.Uri.Set(value); }
		}
	    public HttpMethod Method
		{
			get { return _request.Method; }
			set { _request.Method = value; }
		}
	    public ClientResponse Response { get { return _response; } }
	    public int32 ContentLength
		{
			get { return _headerOut.ContentLength; }
			set { _headerOut.ContentLength = value; }
		}
	    public HttpClientState State { get { return _state; } }
	    public int32 PendingResponses { get { return _pendingResponses; } }
	    public CanWriteEvent OnCanWrite
		{
			get { return _onCanWrite; }
			set { _onCanWrite = value; }
		}
	    public InputEvent OnInput
		{
			get { return _onInput; }
			set { _onInput = value; }
		}
	    public HttpClientEvent OnDoneInput
		{
			get { return _onDoneInput; }
			set { _onDoneInput = value; }
		}
	    public HttpClientEvent OnProcessHeaders
		{
			get { return _onProcessHeaders; }
			set { _onProcessHeaders = value; }
		}
	    public StringView UserAgent
		{
			get { return _userAgent; }
			set { _userAgent.Set(value); }
		}

		protected void EscapeCookie(StringView aInStr, String aOutStr)
		{
			aOutStr.Set(aInStr);
			aOutStr.Replace(";", "%3B");
		}

	    protected override void ConnectEvent(Handle aSocket)
		{
			base.ConnectEvent(aSocket);
			InternalSendRequest();
		}

	    protected void DoDoneInput(HttpClientSocket aSocket)
		{
			_pendingResponses--;

			if (_pendingResponses == 0)
				_state = .Idle;
			else
				_state = .Waiting;

			if (_onDoneInput != null)
				_onDoneInput(aSocket);
		}

	    protected int32 DoHandleInput(HttpClientSocket aSocket, uint8* aBuffer, int32 aSize)
		{
			_state = .Receiving;

			if (_onInput != null)
				return _onInput(aSocket, aBuffer, aSize);
			else
				return aSize;
		}

	    protected void DoProcessHeaders(HttpClientSocket aSocket)
		{
			if (_onProcessHeaders != null)
				_onProcessHeaders(aSocket);
		}

	    protected WriteBlockStatus DoWriteBlock(HttpClientSocket aSocket)
		{
			WriteBlockStatus result = .Done;

			if (!_outputEof)
				if (_onCanWrite != null)
					_onCanWrite(aSocket, ref result);

			return result;
		}

	    protected override Socket InitSocket(Socket aSocket)
		{
			((HttpClientSocket)aSocket).[Friend]_headerOut = &_headerOut;
			((HttpClientSocket)aSocket).[Friend]_request = &_request;
			((HttpClientSocket)aSocket).[Friend]_response = &_response;
			((HttpClientSocket)aSocket).[Friend]_userAgent = &_userAgent;
			return base.InitSocket(aSocket);
		}

	    protected void InternalSendRequest()
		{
			_outputEof = false;
			((HttpClientSocket)_iterator).SendRequest();
			_pendingResponses++;

			if (_state == .Idle)
				_state = .Waiting;
		}

	    public this() : base()
		{
			_port = 80;
			SocketClass = typeof(HttpClientSocket);
			_request.Method = .Get;
			_request.QueryParams = new .();
			_request.Uri = new .();
			_headerOut.ExtraHeaders = .Init(256);
			ResetRange();
		}

	    public ~this()
		{
			Internal.Free(_headerOut.ExtraHeaders.Memory); // Maybe `delete _headerOut.ExtraHeaders.Memory;` is enough
		}

	    public void AddExtraHeader(StringView aHeader)
		{
			_headerOut.ExtraHeaders.AppendString(aHeader);
			_headerOut.ExtraHeaders.AppendString("\r\n");
		}

	    public void AddCookie(StringView aName, StringView aValue, StringView aPath = "", StringView aDomain = "", StringView aVersion = "0")
		{
			String tmp = scope .();
			EscapeCookie(aValue, tmp);
			String header = scope $"Cookie: $Version={aVersion}; {aName}={tmp}";

			if (aPath.Length > 0)
				header.AppendF(";$Path={0}", aPath);

			if (aDomain.Length > 0)
				header.AppendF(";$Domain={0}", aDomain);

			AddExtraHeader(header);
		}

	    public void ClearExtraHeaders() =>
			_headerOut.ExtraHeaders.Clear();

	    public void ResetRange()
		{
			_request.RangeStart = uint64.MaxValue;
			_request.RangeEnd = uint64.MaxValue;
		}

	    public void SendRequest()
		{
			if (!Connected)
				Connect(_host, _port);
			else
				InternalSendRequest();
		}
	}
}
