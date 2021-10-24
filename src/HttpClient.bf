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
		protected bool _persistent = false;

		protected override void DoneInput() =>
			((HttpClient)(((HttpClientSocket)_socket).[Friend]_creator)).[Friend]DoDoneInput((HttpClientSocket)_socket);

		public this(HttpClientSocket aSocket) : base(aSocket)
		{
			_persistent = true;
		}

		public new int32 HandleInput(uint8* aBuffer, int32 aSize) =>
			((HttpClient)(((HttpClientSocket)_socket).[Friend]_creator)).[Friend]DoHandleInput((HttpClientSocket)_socket, aBuffer, aSize);

		public new WriteBlockStatus WriteBlock() =>
			((HttpClient)(((HttpClientSocket)_socket).[Friend]_creator)).[Friend]DoWriteBlock((HttpClientSocket)_socket);
	}
	
	[AlwaysInclude(IncludeAllMethods=true), Reflect(.All)]
	public class HttpClientSocket : HttpSocket
	{
	    protected HttpClientError _error = .None;
	    protected ClientRequest* _request = null;
	    protected ClientResponse* _response = null;
	    protected HeaderOutInfo* _headerOut = null;

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
			/*
var
  lPos: pchar;
begin
  lPos := FBufferPos;
  repeat
    if lPos >= pLineEnd then
    begin
      Cancel(ceMalformedStatusLine);
      exit;
    end;
    if lPos^ = ' ' then
      break;
    Inc(lPos);
  until false;
  if not HTTPVersionCheck(FBufferPos, lPos, FResponse^.Version) then
  begin
    Cancel(ceMalformedStatusLine);
    exit;
  end;

  if (FResponse^.Version > 11) then
  begin
    Cancel(ceVersionNotSupported);
    exit;
  end;

  { status code }
  Inc(lPos);
  if (lPos+3 >= pLineEnd) or (lPos[3] <> ' ') then
  begin
    Cancel(ceMalformedStatusLine);
    exit;
  end;
  FResponse^.Status := CodeToHTTPStatus((ord(lPos[0])-ord('0'))*100
    + (ord(lPos[1])-ord('0'))*10 + (ord(lPos[2])-ord('0')));
  if FResponse^.Status = hsUnknown then
  begin
    Cancel(ceMalformedStatusLine);
    exit;
  end;

  Inc(lPos, 4);
  if lPos < pLineEnd then
    FResponse^.Reason := lPos;
			*/
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
			/*
var
  lMessage: TStringBuffer;
  lTemp: string[23];
  hasRangeStart, hasRangeEnd: boolean;
begin
  lMessage := InitStringBuffer(504);

  AppendString(lMessage, HTTPMethodStrings[FRequest^.Method]);
  AppendChar(lMessage, ' ');
  AppendString(lMessage, FRequest^.URI);
  AppendChar(lMessage, ' ');
  AppendString(lMessage, 'HTTP/1.1'+#13#10+'Host: ');
  AppendString(lMessage, TLHTTPClient(FCreator).Host);
  if TLHTTPClient(FCreator).Port <> 80 then
  begin
    AppendChar(lMessage, ':');
    Str(TLHTTPClient(FCreator).Port, lTemp);
    AppendString(lMessage, lTemp);
  end;
  AppendString(lMessage, #13#10);
  if FHeaderOut^.ContentLength > 0 then
  begin
    AppendString(lMessage, 'Content-Length: ');
    Str(FHeaderOut^.ContentLength, lTemp);
    AppendString(lMessage, lTemp+#13#10);
  end;
  hasRangeStart := TLHTTPClient(FCreator).RangeStart <> high(qword);
  hasRangeEnd := TLHTTPClient(FCreator).RangeEnd <> high(qword);
  if hasRangeStart or hasRangeEnd then
  begin
    AppendString(lMessage, 'Range: bytes=');
    if hasRangeStart then
    begin
      Str(TLHTTPClient(FCreator).RangeStart, lTemp);
      AppendString(lMessage, lTemp);
    end;
    AppendChar(lMessage, '-');
    if hasRangeEnd then
    begin
      Str(TLHTTPClient(FCreator).RangeEnd, lTemp);
      AppendString(lMessage, lTemp);
    end;
    AppendString(lMessage, #13#10);
  end;
  with FHeaderOut^.ExtraHeaders do
    AppendString(lMessage, Memory, Pos-Memory);
  AppendString(lMessage, #13#10);
  AddToOutput(TMemoryOutput.Create(Self, lMessage.Memory, 0,
    lMessage.Pos-lMessage.Memory, true));
  AddToOutput(FCurrentInput);

  PrepareNextRequest;
  WriteBlock;
			*/
		}
	}

	public class HttpClient : HttpConnection
	{
	    protected ClientRequest _request;
	    protected ClientResponse _response;
	    protected HeaderOutInfo _headerOut;
	    protected HttpClientState _state = .Idle;
	    protected int32 _pendingResponses = 0;
	    protected bool _outputEof = false;
	    protected CanWriteEvent _onCanWrite = null;
	    protected InputEvent _onInput = null;
	    protected HttpClientEvent _onDoneInput = null;
	    protected HttpClientEvent _onProcessHeaders = null;

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
			_headerOut.ExtraHeaders.AppendString((StringView)"\r\n");
		}

	    public void AddCookie(StringView aName, StringView aValue, StringView aPath = "", StringView aDomain = "", StringView aVersion = "0")
		{
			String tmp = scope .();
			EscapeCookie(aValue, tmp);
			String header = scope .()..AppendF("Cookie: $Version={0}; {1}={2}", aVersion, aName, tmp);

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
