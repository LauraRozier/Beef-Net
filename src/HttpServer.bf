using System;
using System.Reflection;

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

	    protected virtual OutputItem HandleUri() =>
			((HttpServer)_creator).[Friend]HandleUri(this);
		
	    protected override void LogAccess(StringView aMsg) =>
			((HttpServer)_creator).[Friend]LogAccess(aMsg);

	    protected override void LogMessage()
		{
			/* log a message about this request, '<StatusCode> <Length> "<Referer>" "<User-Agent>"' */
			String tmp = scope .();
			_responseInfo.Status.Underlying.ToString(tmp);
			_logMessage.AppendString(tmp.Ptr, (int32)tmp.Length);
			_logMessage.AppendChar(' ');

			tmp.Clear();
			_headerOut.ContentLength.ToString(tmp);
			_logMessage.AppendString(tmp.Ptr, (int32)tmp.Length);
			_logMessage.AppendString(" \"");

			_logMessage.AppendString((char8*)_parameters[(uint8)HttpParameter.Referer]);
			_logMessage.AppendString("\" \"");

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
  			/* Make a timestamp for this request */
			DateTime nowLocal = DateTime.Now;
			_requestInfo.DateTime = nowLocal.ToUniversalTime(); // UTC == GMT
  			/* Begin log message */
			String tmp = scope .();
			_logMessage.Pos = _logMessage.Memory;
			GetPeerAddress(tmp);
			_logMessage.AppendString(tmp);
			_logMessage.AppendString(" - [");
			tmp.Clear();
			nowLocal.ToString(tmp, "dd/mmm/yyyy:hh:nn:ss");
			_logMessage.AppendString(tmp);
			_logMessage.AppendString(((HttpServer)_creator).[Friend]_logMessageTZString);
			_logMessage.AppendString(_bufferPos, (int32)(aLineEnd - _bufferPos));
			_logMessage.AppendString("\" ");

			/* Decode version */
			uint8* pos = aLineEnd;

			while (true)
			{
				if (*pos == (uint8)' ')
					break;

				pos--;

				if (pos < _bufferPos)
				{
					WriteError(.BadRequest);
					return;
				}
			}

			*pos = 0x0;
			pos++;

  			/* pos = version string */
			if (!HttpVersionCheck(pos, aLineEnd, out _requestInfo.Version))
			{
				WriteError(.BadRequest);
				return;
			}

			_requestInfo.VersionStr = (char8*)pos;
			_headerOut.Version = _requestInfo.Version;
  			/* Trim spaces at end of URI */
			pos--;

			while (true)
			{
				if (pos == _bufferPos)
					break;

				pos--;

				if (*pos != (uint8)' ')
					break;

				*pos = 0x0;
			}

  			/* Decode method */
			_requestInfo.Method = (char8*)_bufferPos;
			pos = StrScan(_bufferPos, (uint8)' ');

			if (pos == null)
			{
				WriteError(.BadRequest);
				return;
			}

			*pos = 0x0;
			TypeInstance typeInst = (TypeInstance)typeof(HttpMethod);
			HttpMethod method;

			for (let field in typeInst.GetFields())
			{
				method = *((HttpMethod*)(&field.[Friend]mFieldData.mData));

				if (method == .Unknown || (pos - _bufferPos == method.StrVal.Length && CompareMem(_bufferPos, (uint8*)method.StrVal.Ptr, (int32)(pos - _bufferPos))))
				{
					repeat
					{
						pos++;
					}
					while (*pos == ' ');

					_requestInfo.Argument = (char8*)pos;
					_requestInfo.RequestType = method;
					break;
				}
			}

			tmp.Clear();
			tmp.Append(_requestInfo.Argument);

			if ((aLineEnd - (uint8*)_requestInfo.Argument) > 7 && tmp.Equals("http://", .OrdinalIgnoreCase))
			{
    			/* Absolute URI */
				pos = (uint8*)_requestInfo.Argument + 7;

				while (*pos == (uint8)'/')
					pos++;

				_parameters[(uint8)HttpParameter.Host] = pos;
				pos = StrScan(pos, (uint8)'/');
				_requestInfo.Argument = (char8*)pos;
			}

			/* _requestInfo.Argument now points to an "abs_path" */
			if (_requestInfo.Argument[0] != '/')
			{
				WriteError(.BadRequest);
				return;
			}

			repeat
			{
				_requestInfo.Argument++;
			}
			while (_requestInfo.Argument[0] == '/');
		}

	    protected bool PrepareResponse(OutputItem aOutputItem, bool aIndCustomErrorMessage)
		{
			var aIndCustomErrorMessage;

			/* Check modification date */
			if (_responseInfo.Status < .BadRequest)
			{
				DateTime dt = .(0);

				if (_parameters[(uint8)HttpParameter.IfModifiedSince] != null && _responseInfo.LastModified.Ticks != 0)
				{
					if (HttpUtil.TryHttpDateStrToDateTime((char8*)_parameters[(uint8)HttpParameter.IfModifiedSince], ref dt))
					{
						if (dt > _requestInfo.DateTime)
							_responseInfo.Status = .BadRequest;
						else if (_responseInfo.LastModified <= dt)
							_responseInfo.Status = .NotModified;
					}
				}
				else if (_parameters[(uint8)HttpParameter.IfUnmodifiedSince] != null)
				{
					if (HttpUtil.TryHttpDateStrToDateTime((char8*)_parameters[(uint8)HttpParameter.IfUnmodifiedSince], ref dt))
					{
						if (_responseInfo.LastModified.Ticks == 0 || dt < _responseInfo.LastModified)
							_responseInfo.Status = .PreconditionFailed;
					}
				}
			}

			if (_responseInfo.Status < .OK || (HttpStatus.NoContent | HttpStatus.NotModified).HasFlag(_responseInfo.Status))
			{
				/* RFC says we MUST not include a response for these statuses */
				aIndCustomErrorMessage = false;
				_headerOut.ContentLength = 0;
			}

			bool result = _responseInfo.Status == .OK || aIndCustomErrorMessage;

			if (!result)
			{
				WriteError(_responseInfo.Status);
				DelayFree(aOutputItem);
			}

			return result;
		}

	    protected override void ProcessHeaders()
		{
			/* Process request */
			/* Do HTTP/1.1 Host-field present check */
			if (_requestInfo.Version > 10 && _parameters[(uint8)HttpParameter.Host] == null)
			{
				WriteError(.BadRequest);
				return;
			}

			uint8* pos = StrScan((uint8*)_requestInfo.Argument, (uint8)'?');

			if (pos != null)
			{
				*pos = 0x0;
				_requestInfo.QueryParams = (char8*)(pos + 1);
			}

			_keepAlive = _requestInfo.Version > 10;
			uint8* connParam = _parameters[(uint8)HttpParameter.Connection];
			String tmp = scope .();
			tmp.Append((char8*)connParam);

			if (connParam != null)
			{
				if (tmp.Equals("keep-alive", .OrdinalIgnoreCase))
					_keepAlive = true;
				else if (tmp.Equals("close", .OrdinalIgnoreCase))
					_keepAlive = false;
			}

			tmp.Clear();
			tmp.Append(_requestInfo.Argument);
			String tmpArg = scope .();
			HttpUtil.HttpDecode(tmp, tmpArg);

			if (!HttpUtil.CheckPermission(tmpArg))
			{
				WriteError(.Forbidden);
			}
			else
			{
				if (!ProcessEncoding())
				{
					WriteError(.NotImplemented);
					return;
				}

				_currentInput = HandleUri();

				/* If we have a valid outputitem, wait until it is ready to produce its response */
				if (_currentInput == null)
					WriteError(_responseInfo.Status == .OK ? .NotFound : _responseInfo.Status);
				else if (_requestInputDone)
					_currentInput.[Friend]DoneInput();
			}
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
			StringBuffer msg = .Init(504);
			String tmp = scope .();
			msg.AppendString("HTTP/1.1 ");
			_responseInfo.Status.Underlying.ToString(tmp);
			msg.AppendString(tmp);
			msg.AppendChar(' ');
			msg.AppendString(_responseInfo.Status.StrVal);
			msg.AppendString("\r\nDate: ");
			tmp.Clear();
			_requestInfo.DateTime.ToString(tmp, HttpUtil.HttpDateFormat);
			msg.AppendString(tmp);
			msg.AppendString(" GMT");

			tmp.Clear();
			tmp.Append(((HttpServer)_creator).ServerSoftware);

			if (tmp.Length > 0)
			{
				msg.AppendString("\r\nServer: ");
				msg.AppendString(tmp);
			}

			if (_responseInfo.ContentType.Length > 0)
			{
				msg.AppendString("\r\nContent-Type: ");
				msg.AppendString(_responseInfo.ContentType);

				if (_responseInfo.ContentCharset.Length > 0)
				{
					msg.AppendString("; charset=");
					msg.AppendString(_responseInfo.ContentCharset);
				}
			}

			if (_headerOut.TransferEncoding == .Identity)
			{
				msg.AppendString("\r\nContent-Length: ");
				tmp.Clear();
				_headerOut.ContentLength.ToString(tmp);
				msg.AppendString(tmp);
			}
			else
			{
				/* Only other possibility: .Chunked */
				msg.AppendString("\r\nTransfer-Encoding: chunked");
			}

			if (_responseInfo.LastModified.Ticks != 0)
			{
				msg.AppendString("\r\nLast-Modified: ");
				tmp.Clear();
				_responseInfo.LastModified.ToString(tmp, HttpUtil.HttpDateFormat);
				msg.AppendString(tmp);
				msg.AppendString(" GMT");
			}

			msg.AppendString("\r\nConnection: ");
			msg.AppendString(_keepAlive ? "keep-alive" : "close");

			msg.AppendString("\r\n");
			msg.AppendString(_headerOut.ExtraHeaders.Memory, (int32)(_headerOut.ExtraHeaders.Pos - _headerOut.ExtraHeaders.Memory));
			msg.AppendString("\r\n");

			if (aHeaderResponse != null)
			{
				aHeaderResponse.[Friend]_buffer = (uint8*)msg.Memory;
				aHeaderResponse.[Friend]_bufferSize = (int32)(msg.Pos - msg.Memory);
			}
			else
			{
				AddToOutput(new MemoryOutput(this, msg.Memory, 0, (int32)(msg.Pos - msg.Memory), true));
			}

			if (aDataResponse != null)
			{
				if (_requestInfo.RequestType == .Head)
					DelayFree(aDataResponse);
				else
					AddToOutput(aDataResponse);
			}
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
