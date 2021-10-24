using System;

namespace Beef_Net
{
	public delegate void AccessEvent(StringView aMsg);

	public abstract class UriHandler
	{
		private UriHandler _next = null;
		private HttpMethod _methods = .Head | .Get | .Post | .Delete | .Put;

		public HttpMethod Methods
		{
			get { return _methods; }
			set { _methods = value; }
		}

		public abstract OutputItem HandleUri(HttpServerSocket aSocket);

		public virtual void RegisterWithEventer(Eventer aEventer) { }
	}
	
	[AlwaysInclude(IncludeAllMethods=true), Reflect(.All)]
	public class HttpServerSocket : HttpSocket
	{
	    protected StringBuffer _logMessage;
	    protected SetupEncodingState _setupEncodingState = .None;

	    public HeaderOutInfo _headerOut;
	    public RequestInfo _requestInfo;
	    public ResponseInfo _responseInfo;
		
	    protected override void AddContentLength(int32 aLength) =>
			_headerOut.ContentLength += aLength;

	    protected override void DoneBuffer(BufferOutput aOutput)
		{
			if (_currentOutput != aOutput)
			{
				RemoveOutput(aOutput);
				aOutput.[Friend]_next = _currentOutput;
				_currentOutput = aOutput;
			}

			WriteHeaders(aOutput, null);
		}

	    protected override void FlushRequest()
		{
			/* Reset structure to zero, not called from constructor */
			// Request
			_requestInfo.Argument = null;
			_requestInfo.QueryParams = null;
			_requestInfo.Version = 0;

			_headerOut.ContentLength = 0;
			_headerOut.TransferEncoding = .Identity;
			_headerOut.ExtraHeaders.Pos = _headerOut.ExtraHeaders.Memory;
			_headerOut.Version = 0;

			base.FlushRequest();
		}

	    protected virtual OutputItem HandleURI() =>
			((HttpServer)_creator).[Friend]HandleUri(this);
		
	    protected override void LogAccess(StringView aMsg) =>
			((HttpServer)_creator).[Friend]LogAccess(aMsg);

	    protected override void LogMessage()
		{
			/* log a message about this request, '<StatusCode> <Length> "<Referer>" "<User-Agent>"' */
			String tmp = scope .();
			_responseInfo.Status.Underlying.ToString(tmp);
			_logMessage.AppendString(tmp.Ptr, (uint32)tmp.Length);
			_logMessage.AppendChar(' ');

			tmp.Clear();
			_headerOut.ContentLength.ToString(tmp);
			_logMessage.AppendString(tmp.Ptr, (uint32)tmp.Length);
			_logMessage.AppendString((StringView)" \"");

			_logMessage.AppendString((char8*)_parameters[(uint8)HttpParameter.Referer]);
			_logMessage.AppendString((StringView)"\" \"");

			_logMessage.AppendString((char8*)_parameters[(uint8)HttpParameter.UserAgent]);
			_logMessage.AppendChar('"');
			_logMessage.AppendChar(0x0);
  			LogAccess(StringView(_logMessage.Memory));
		}

	    protected override void RelocateVariables()
		{
			RelocateVariable(ref _requestInfo.Method);
			RelocateVariable(ref _requestInfo.Argument);
			RelocateVariable(ref _requestInfo.QueryParams);
			RelocateVariable(ref _requestInfo.VersionStr);
			base.RelocateVariables();
		}

	    protected override void ResetDefaults()
		{
			base.ResetDefaults();
			_requestInfo.RequestType = .Unknown;
			_setupEncodingState = .None;

			_responseInfo.Status = .OK;
			_responseInfo.ContentType = "application/octet-stream";
			_responseInfo.ContentCharset = "";
			_responseInfo.LastModified = DateTime(0);
		}

	    protected override void ParseLine(uint8* aLineEnd)
		{
			if (_requestInfo.RequestType == .Unknown)
			{
				ParseRequestLine(aLineEnd);
				return;
			}

			base.ParseLine(aLineEnd);
		}

	    protected void ParseRequestLine(uint8* aLineEnd)
		{
			/*
var
  lPos: pchar;
  I: TLHTTPMethod;
  NowLocal: TDateTime;
begin
  { make a timestamp for this request }
  NowLocal := Now;
  FRequestInfo.DateTime := LocalTimeToGMT(NowLocal);
  { begin log message }
  FLogMessage.Pos := FLogMessage.Memory;
  AppendString(FLogMessage, PeerAddress);
  AppendString(FLogMessage, ' - [');
  AppendString(FLogMessage, FormatDateTime('dd/mmm/yyyy:hh:nn:ss', NowLocal));
  AppendString(FLogMessage, TLHTTPServer(FCreator).FLogMessageTZString);
  AppendString(FLogMessage, FBufferPos, pLineEnd-FBufferPos);
  AppendString(FLogMessage, '" ');

  { decode version }
  lPos := pLineEnd;
  repeat
    if lPos^ = ' ' then break;
    dec(lPos);
    if lPos < FBufferPos then
    begin
      WriteError(hsBadRequest);
      exit;
    end;
  until false;

  lPos^ := #0;
  inc(lPos);
  { lPos = version string }
  if not HTTPVersionCheck(lPos, pLineEnd, FRequestInfo.Version) then
  begin
    WriteError(hsBadRequest);
    exit;
  end;
  FRequestInfo.VersionStr := lPos;
  FHeaderOut.Version := FRequestInfo.Version;
  
  { trim spaces at end of URI }
  dec(lPos);
  repeat
    if lPos = FBufferPos then break;
    dec(lPos);
    if lPos^ <> ' ' then break;
    lPos^ := #0;
  until false;

  { decode method }
  FRequestInfo.Method := FBufferPos;
  lPos := StrScan(FBufferPos, ' ');
  if lPos = nil then
  begin
    WriteError(hsBadRequest);
    exit;
  end;

  lPos^ := #0;
  for I := Low(TLHTTPMethod) to High(TLHTTPMethod) do
  begin
    if (I = hmUnknown) or (((lPos-FBufferPos) = Length(HTTPMethodStrings[I]))
      and CompareMem(FBufferPos, PChar(HTTPMethodStrings[I]), lPos-FBufferPos)) then
    begin
      repeat
        inc(lPos);
      until lPos^ <> ' ';
      FRequestInfo.Argument := lPos;
      FRequestInfo.RequestType := I;
      break;
    end;
  end;

  if ((pLineEnd-FRequestInfo.Argument) > 7) and (StrIComp(FRequestInfo.Argument, 'http://') = 0) then
  begin
    { absolute URI }
    lPos := FRequestInfo.Argument+7;
    while (lPos^ = '/') do 
      Inc(lPos);
    FParameters[hpHost] := lPos;
    lPos := StrScan(lPos, '/');
    FRequestInfo.Argument := lPos;
  end;
  { FRequestInfo.Argument now points to an "abs_path" }
  if FRequestInfo.Argument[0] <> '/' then
  begin
    WriteError(hsBadRequest);
    exit;
  end;
  repeat
    Inc(FRequestInfo.Argument);
  until FRequestInfo.Argument[0] <> '/';
			*/
		}

	    protected bool PrepareResponse(OutputItem aOutputItem, bool aCustomErrorMessage)
		{
			/*
var
  lDateTime: TDateTime;
begin
  { check modification date }
  if FResponseInfo.Status < hsBadRequest then
  begin
    if (FParameters[hpIfModifiedSince] <> nil) 
      and (FResponseInfo.LastModified <> 0.0) then
    begin
      if TryHTTPDateStrToDateTime(FParameters[hpIfModifiedSince], lDateTime) then
      begin
        if lDateTime > FRequestInfo.DateTime then
          FResponseInfo.Status := hsBadRequest
        else
        if FResponseInfo.LastModified <= lDateTime then
          FResponseInfo.Status := hsNotModified;
      end;
    end else
    if (FParameters[hpIfUnmodifiedSince] <> nil) then
    begin
      if TryHTTPDateStrToDateTime(FParameters[hpIfUnmodifiedSince], lDateTime) then
      begin
        if (FResponseInfo.LastModified = 0.0) 
          or (lDateTime < FResponseInfo.LastModified) then
          FResponseInfo.Status := hsPreconditionFailed;
      end;
    end;
  end;

  if (FResponseInfo.Status < hsOK) or (FResponseInfo.Status in [hsNoContent, hsNotModified]) then
  begin
    { RFC says we MUST not include a response for these statuses }
    ACustomErrorMessage := false;
    FHeaderOut.ContentLength := 0;
  end;
  
  Result := (FResponseInfo.Status = hsOK) or ACustomErrorMessage;
  if not Result then
  begin
    WriteError(FResponseInfo.Status);
    DelayFree(AOutputItem);
  end;
			*/
			return false;
		}

	    protected override void ProcessHeaders()
		{
			/* Process request */
			/*
var
  lPos, lConnParam: pchar;
begin
  { do HTTP/1.1 Host-field present check }
  if (FRequestInfo.Version > 10) and (FParameters[hpHost] = nil) then
  begin
    WriteError(hsBadRequest);
    exit;
  end;
      
  lPos := StrScan(FRequestInfo.Argument, '?');
  if lPos <> nil then
  begin
    lPos^ := #0;
    FRequestInfo.QueryParams := lPos+1;
  end;

  FKeepAlive := FRequestInfo.Version > 10;
  lConnParam := FParameters[hpConnection];
  if lConnParam <> nil then
  begin
    if StrIComp(lConnParam, 'keep-alive') = 0 then
      FKeepAlive := true
    else
    if StrIComp(lConnParam, 'close') = 0 then
      FKeepAlive := false;
  end;
  
  HTTPDecode(FRequestInfo.Argument);
  if not CheckPermission(FRequestInfo.Argument) then
  begin
    WriteError(hsForbidden);
  end else begin
    if not ProcessEncoding then
    begin
      WriteError(hsNotImplemented);
      exit;
    end;
      
    FCurrentInput := HandleURI;
    { if we have a valid outputitem, wait until it is ready 
      to produce its response }
    if FCurrentInput = nil then
    begin
      if FResponseInfo.Status = hsOK then
        WriteError(hsNotFound)
      else
        WriteError(FResponseInfo.Status);
    end else if FRequestInputDone then
      FCurrentInput.DoneInput;
  end;
			*/
		}

	    protected override void WriteError(HttpStatus aStatus)
		{
			if (HttpStatus.DisconnectStatuses.HasFlag(aStatus))
				_keepAlive = false;

			MemoryOutput msgOut = null;
			String msg = scope .(aStatus.Destription);
			_requestHeaderDone = true;
			_responseInfo.Status = aStatus;
			_headerOut.ContentLength = (int32)msg.Length;
			_headerOut.TransferEncoding = .Identity;

			if (msg.Length > 0)
			{
				_responseInfo.ContentType = "text/html";
				msgOut = scope MemoryOutput(this, msg.Ptr, 0, (int32)msg.Length, false);
			}
			else
			{
				_responseInfo.ContentType = "";
			}

			WriteHeaders(null,  msgOut);
		}

	    protected void WriteHeaders(OutputItem aHeaderResponse, OutputItem aDataResponse)
		{
			/*
var
  lTemp: string[23];
  lMessage: TStringBuffer;
  tempStr: string;
begin
  lMessage := InitStringBuffer(504);
  
  AppendString(lMessage, 'HTTP/1.1 ');
  Str(HTTPStatusCodes[FResponseInfo.Status], lTemp);
  AppendString(lMessage, lTemp);
  AppendChar(lMessage, ' ');
  AppendString(lMessage, HTTPTexts[FResponseInfo.Status]);
  AppendString(lMessage, #13#10+'Date: ');
  AppendString(lMessage, FormatDateTime(HTTPDateFormat, FRequestInfo.DateTime));
  AppendString(lMessage, ' GMT');
  tempStr := TLHTTPServer(FCreator).ServerSoftware;
  if Length(tempStr) > 0 then
  begin
    AppendString(lMessage, #13#10+'Server: ');
    AppendString(lMessage, tempStr);
  end;
  if Length(FResponseInfo.ContentType) > 0 then
  begin
    AppendString(lMessage, #13#10+'Content-Type: ');
    AppendString(lMessage, FResponseInfo.ContentType);
    if Length(FResponseInfo.ContentCharset) > 0 then
    begin
      AppendString(lMessage, '; charset=');
      AppendString(lMessage, FResponseInfo.ContentCharset);
    end;
  end;
  if FHeaderOut.TransferEncoding = teIdentity then
  begin
    AppendString(lMessage, #13#10+'Content-Length: ');
    Str(FHeaderOut.ContentLength, lTemp);
    AppendString(lMessage, lTemp);
  end else begin
    { only other possibility: teChunked }
    AppendString(lMessage, #13#10+'Transfer-Encoding: chunked');
  end;
  if FResponseInfo.LastModified <> 0.0 then
  begin
    AppendString(lMessage, #13#10+'Last-Modified: ');
    AppendString(lMessage, FormatDateTime(HTTPDateFormat, FResponseInfo.LastModified));
    AppendString(lMessage, ' GMT');
  end;
  AppendString(lMessage, #13#10+'Connection: ');
  if FKeepAlive then
    AppendString(lMessage, 'keep-alive')
  else
    AppendString(lMessage, 'close');
  AppendString(lMessage, #13#10);
  with FHeaderOut.ExtraHeaders do
    AppendString(lMessage, Memory, Pos-Memory);
  AppendString(lMessage, #13#10);
  if AHeaderResponse <> nil then
  begin
    AHeaderResponse.FBuffer := lMessage.Memory;
    AHeaderResponse.FBufferSize := lMessage.Pos-lMessage.Memory;
  end else
    AddToOutput(TMemoryOutput.Create(Self, lMessage.Memory, 0,
      lMessage.Pos-lMessage.Memory, true));

  if ADataResponse <> nil then
  begin
    if FRequestInfo.RequestType = hmHead then
      DelayFree(ADataResponse)
    else
      AddToOutput(ADataResponse);
  end;
			*/
		}

	    public this() : base()
		{
			_logMessage = StringBuffer.Init(256);
			_headerOut.ExtraHeaders = StringBuffer.Init(256);
			ResetDefaults();
		}

	    public ~this()
		{
			Internal.Free(_logMessage.Memory);
			Internal.Free(_headerOut.ExtraHeaders.Memory);
		}

	    public bool SetupEncoding(BufferOutput aOutputItem)
		{
			mixin SetupEncodingToState(bool aValue)
			{
				SetupEncodingState result = aValue ? .StartHeaders : .WaitHeaders;
				result
			}

			if (_setupEncodingState > .None)
				return _setupEncodingState == .StartHeaders;

			bool result = base.SetupEncoding(aOutputItem, &_headerOut);
			_setupEncodingState = SetupEncodingToState!(result);
			return result;
		}

	    public void StartMemoryResponse(MemoryOutput aOutputItem, bool aIndCustomErrorMessage = false)
		{
			if (PrepareResponse(aOutputItem, aIndCustomErrorMessage))
			{
				if (_requestInfo.RequestType != .Head)
					_headerOut.ContentLength = aOutputItem.[Friend]_bufferSize;
			}
			else
			{
				_headerOut.ContentLength = 0;
				WriteHeaders(null, aOutputItem);
			}
		}

	    public void StartResponse(BufferOutput aOutputItem, bool aIndCustomErrorMessage = false)
		{
  			if (PrepareResponse(aOutputItem, aIndCustomErrorMessage))
    			if (_requestInfo.RequestType == .Head || SetupEncoding(aOutputItem))
      				WriteHeaders(null, aOutputItem);
		}
	}

	public class HttpServer : HttpConnection
	{
	    protected UriHandler _handlerList = null;
	    protected String _logMessageTZString = new .() ~ delete _;
	    protected String _serverSoftware = new .() ~ delete _;
	    protected AccessEvent _onAccess = null;

	    public StringView ServerSoftware
		{
			get { return _serverSoftware; }
			set { _serverSoftware.Set(value); }
		}
	    public AccessEvent OnAccess
		{
			get { return _onAccess; }
			set { _onAccess = value; }
		}

	    protected OutputItem HandleUri(HttpServerSocket aSocket)
		{
			OutputItem result = null;
			UriHandler handler = _handlerList;

			while (handler != null)
			{
				if (handler.Methods.HasFlag(aSocket.[Friend]_requestInfo.RequestType))
				{
					result = handler.HandleUri(aSocket);

					if (aSocket.[Friend]_responseInfo.Status != .OK)
						break;

					if (result != null)
						break;
				}

				handler = handler.[Friend]_next;
			}

			return result;
		}

	    protected override void LogAccess(StringView aMsg)
		{
			if (_onAccess != null)
				_onAccess(aMsg);
		}

	    protected override void RegisterWithEventer()
		{
			base.RegisterWithEventer();
			UriHandler handler = _handlerList;

			while (handler != null)
			{
				handler.[Friend]RegisterWithEventer(Eventer);
				handler = handler.[Friend]_next;
			}
		}

		public this() : base()
		{
			_port = 80; // Default to plain http
			SocketClass = typeof(HttpServerSocket);
			TimeSpan ts = TimeZoneInfo.Local.GetUtcOffset(DateTime.UtcNow);
			int32 utcOffset = (ts.Hours * 100) + ts.Minutes;
			_logMessageTZString.Clear();

			if (utcOffset > 0)
				_logMessageTZString.AppendF(" +{0:D4} \"", utcOffset);
			else
				_logMessageTZString.AppendF(" {0:D4} \"", utcOffset);
		}

    	public void RegisterHandler(UriHandler aHandler)
		{
			if (aHandler == null)
				return;

			aHandler.[Friend]_next = _handlerList;
			_handlerList = aHandler;

			if (Eventer != null)
				aHandler.[Friend]RegisterWithEventer(Eventer);
		}
	}
}
