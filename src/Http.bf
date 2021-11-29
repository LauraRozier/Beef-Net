using Beef_Net.Connection;
using System;
using System.IO;
using System.Reflection;

namespace Beef_Net
{
	public enum HttpMethod
	{
		case Unknown = 0x00;
		case Connect = 0x01;
		case Delete  = 0x02;
		case Get     = 0x04;
		case Head    = 0x08;
		case Options = 0x10;
		case Post    = 0x20;
		case Put     = 0x40;

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .Unknown:  return "";
				case .Connect:  return "CONNECT";
				case .Delete:   return "DELETE";
				case .Get:      return "GET";
				case .Head:     return "HEAD";
				case .Options:  return "OPTIONS";
				case .Post:     return "POST";
				case .Put:      return "PUT";
				}
			}
		}
	}

	public enum HttpParameter : uint8
	{
		case Connection;
		case ContentLength;
		case ContentType;
		case Accept;
		case AcceptCharset;
		case AcceptEncoding;
		case AcceptLanguage;
		case Host;
		case From;
		case Referer;
		case UserAgent;
		case Range;
		case TransferEncoding;
		case IfModifiedSince;
		case IfUnmodifiedSince;
		case Cookie;
		case XRequestedWith;
		case Authorization;
		/// Not to be used for anything other then array-sizing
		case MaxVal;

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .Connection:        return "CONNECTION";
				case .ContentLength:     return "CONTENT-LENGTH";
				case .ContentType:       return "CONTENT-TYPE";
				case .Accept:            return "ACCEPT";
				case .AcceptCharset:     return "ACCEPT-CHARSET";
				case .AcceptEncoding:    return "ACCEPT-ENCODING";
				case .AcceptLanguage:    return "ACCEPT-LANGUAGE";
				case .Host:              return "HOST";
				case .From:              return "FROM";
				case .Referer:           return "REFERER";
				case .UserAgent:         return "USER-AGENT";
				case .Range:             return "RANGE";
				case .TransferEncoding:  return "TRANSFER-ENCODING";
				case .IfModifiedSince:   return "IF-MODIFIED-SINCE";
				case .IfUnmodifiedSince: return "IF-UNMODIFIED-SINCE";
				case .Cookie:            return "COOKIE";
				case .XRequestedWith:    return "X-REQUESTED-WITH";
				case .Authorization:     return "AUTHORIZATION";
				default:                 return "";
				}
			}
		}
	}

	public enum HttpStatus : uint32
	{
		case Unknown                 = 0;

		case Continue                = 100;
		case SwitchingProtocols      = 101;
		case Processing              = 102;
		case EarlyHints              = 103;

		case OK                      = 200;
		case Created                 = 201;
		case Accepted                = 202;
		case NonAuthInfo             = 203;
		case NoContent               = 204;
		case ResetContent            = 205;
		case PartialContent          = 206;
		case MultiStatus             = 207;
		case AlreadyReported         = 208;

		case MultipleChoices         = 300;
		case MovedPermanently        = 301;
		case Found                   = 302;
		case SeeOther                = 303;
		case NotModified             = 304;
		case UseProxy                = 305;
		case SwitchProxy             = 306;
		case TempRedirect            = 307;
		case PermRedirect            = 308;

		case BadRequest              = 400;
		case Unauthorized            = 401;
		case PaymentRequired         = 402;
		case Forbidden               = 403;
		case NotFound                = 404;
		case MethodNotAllowed        = 405;
		case NotAcceptable           = 406;
		case ProxyAuthRequired       = 407;
		case RequestTimeout          = 408;
		case Conflict                = 409;
		case Gone                    = 410;
		case LengthRequired          = 411;
		case PreconditionFailed      = 412;
		case PayloadTooLarge         = 413;
		case RequestTooLong          = 414;
		case UnsupportedMediaType    = 415;
		case RangeNotSatisfiable     = 416;
		case ExpectationsFailed      = 417;
		case ImATeapot               = 418;
		case MisdirectedRequest      = 421;
		case UnprocessableEntity     = 422;
		case Locked                  = 423;
		case FailedDependency        = 424;
		case TooEarly                = 425;
		case UpgradeRequired         = 426;
		case PreconditionRequired    = 428;
		case TooManyRequests         = 429;
		case ReqHdrFieldsTooLarge    = 431;
		case UnavailForLegalReasons  = 451;

		case InternalError           = 500;
		case NotImplemented          = 501;
		case BadGateway              = 502;
		case ServiceUnavailable      = 503;
		case GatewayTimeout          = 504;
		case HttpVersionNotSupported = 505;
		case VariantAlsoNegotiates   = 506;
		case InsufficientStorage     = 507;
		case LoopDetected            = 508;
		case NotExtended             = 510;
		case NetworkAuthRequired     = 511;

		public const HttpStatus DisconnectStatuses =
			// 4xx
			.BadRequest | .Unauthorized | .PaymentRequired | .Forbidden | .NotFound | .MethodNotAllowed | .NotAcceptable | .ProxyAuthRequired | .RequestTimeout | .Conflict | .Gone |
			.LengthRequired | .PreconditionFailed | .PayloadTooLarge | .RequestTooLong | .UnsupportedMediaType | .RangeNotSatisfiable | .ExpectationsFailed | .ImATeapot | .MisdirectedRequest |
			.UnprocessableEntity | .Locked | .FailedDependency | .TooEarly | .UpgradeRequired | .PreconditionRequired | .TooManyRequests | .ReqHdrFieldsTooLarge | .UnavailForLegalReasons |
			// 5xx
			.InternalError | .NotImplemented | .BadGateway | .ServiceUnavailable | .GatewayTimeout | .HttpVersionNotSupported | .VariantAlsoNegotiates | .InsufficientStorage |
			.LoopDetected | .NotExtended | .NetworkAuthRequired;

		public static Self FromCode(uint32 aCode)
		{
			TypeInstance typeInst = (TypeInstance)typeof(Self);

			for (let field in typeInst.GetFields())
				if ((uint32)field.[Friend]mFieldData.mData == aCode)
					return *((Self*)(&field.[Friend]mFieldData.mData));

			return .Unknown;
		}

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .Unknown:                 return "";

				case .Continue:                return "Continue";
				case .SwitchingProtocols:      return "Switching Protocols";
				case .Processing:              return "Processing";
				case .EarlyHints:              return "Early Hints";

				case .OK:                      return "OK";
				case .Created:                 return "Created";
				case .Accepted:                return "Accepted";
				case .NonAuthInfo:             return "Non-Authoritative Information";
				case .NoContent:               return "No Content";
				case .ResetContent:            return "Reset Content";
				case .PartialContent:          return "Partial Content";
				case .MultiStatus:             return "Multi-Status";
				case .AlreadyReported:         return "Already Reported";

				case .MultipleChoices:         return "Multiple Choices";
				case .MovedPermanently:        return "Moved Permanently";
				case .Found:                   return "Found";
				case .SeeOther:                return "See Other";
				case .NotModified:             return "Not Modified";
				case .UseProxy:                return "Use Proxy";
				case .SwitchProxy:             return "Switch Proxy";
				case .TempRedirect:            return "Temporary Redirect";
				case .PermRedirect:            return "Permanent Redirect";

				case .BadRequest:              return "Bad Request";
				case .Unauthorized:            return "Unauthorized";
				case .PaymentRequired:         return "Payment Required";
				case .Forbidden:               return "Forbidden";
				case .NotFound:                return "Not Found";
				case .MethodNotAllowed:        return "Method Not Allowed";
				case .NotAcceptable:           return "Not Acceptable";
				case .ProxyAuthRequired:       return "Proxy Authentication Required";
				case .RequestTimeout:          return "Request Timeout";
				case .Conflict:                return "Conflict";
				case .Gone:                    return "Gone";
				case .LengthRequired:          return "Length Required";
				case .PreconditionFailed:      return "Precondition Failed";
				case .PayloadTooLarge:         return "Payload Too Large";
				case .RequestTooLong:          return "Request Too Long";
				case .UnsupportedMediaType:    return "Unsupported Media Type";
				case .RangeNotSatisfiable:     return "Range Not Satisfiable";
				case .ExpectationsFailed:      return "Expectations Failed";
				case .ImATeapot:               return "I'm A Teapot \u{1FAD6}";
				case .MisdirectedRequest:      return "Misdirected Request";
				case .UnprocessableEntity:     return "Unprocessable Entity";
				case .Locked:                  return "Locked";
				case .FailedDependency:        return "Failed Dependency";
				case .TooEarly:                return "Too Early";
				case .UpgradeRequired:         return "Upgrade Required";
				case .PreconditionRequired:    return "Precondition Required";
				case .TooManyRequests:         return "Too Many Requests";
				case .ReqHdrFieldsTooLarge:    return "Request Header Fields Too Large";
				case .UnavailForLegalReasons:  return "Unavailable For Legal Reasons";

				case .InternalError:           return "Internal Server Error";
				case .NotImplemented:          return "Method Not Implemented";
				case .BadGateway:              return "Bad Gateway";
				case .ServiceUnavailable:      return "Service Unavailable";
				case .GatewayTimeout:          return "Gateway Timeout";
				case .HttpVersionNotSupported: return "HTTP Version Not Supported";
				case .VariantAlsoNegotiates:   return "Variant Also Negotiates";
				case .InsufficientStorage:     return "Insufficient Storage";
				case .LoopDetected:            return "Loop Detected";
				case .NotExtended:             return "Not Extended";
				case .NetworkAuthRequired:     return "Network Authentication Required";
				}
			}
		}
		public StringView Destription
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .BadRequest:              return "<html><head><title>400 Bad Request</title></head><body>\n<h1>Bad Request</h1>\n<p>The server cannot or will not process the request due to an apparent client error.</p>\n</body></html>\n";
				case .Unauthorized:            return "<html><head><title>401 Unauthorized</title></head><body>\n<h1>Unauthorized</h1>\n<p>You must provide valid credentials to access this resource.</p>\n</body></html>\n";
				case .PaymentRequired:         return "<html><head><title>402 Payment Required</title></head><body>\n<h1>Payment Required</h1>\n<p>Payment is required to use this service.</p>\n</body></html>\n";
				case .Forbidden:               return "<html><head><title>403 Forbidden</title></head><body>\n<h1>Forbidden</h1>\n<p>You do not have permission to access this resource.</p>\n</body></html>\n";
				case .NotFound:                return "<html><head><title>404 Not Found</title></head><body>\n<h1>Not Found</h1>\n<p>The requested URL was not found on this server.</p>\n</body></html>\n";
				case .MethodNotAllowed:        return "<html><head><title>405 Method Not Allowed</title></head><body>\n<h1>Method Not Allowed</h1>\n<p>A request method is not supported for the requested resource.</p>\n</body></html>\n";
				case .NotAcceptable:           return "<html><head><title>406 Not Acceptable</title></head><body>\n<h1>Not Acceptable</h1>\n<p>The requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request.</p>\n</body></html>\n";
				case .ProxyAuthRequired:       return "<html><head><title>407 Proxy Authentication Required</title></head><body>\n<h1>Proxy Authentication Required</h1>\n<p>The client must first authenticate itself with the proxy.</p>\n</body></html>\n";
				case .RequestTimeout:          return "<html><head><title>408 Request Timeout</title></head><body>\n<h1>Request Timeout</h1>\n<p>The server timed out waiting for the request.</p>\n</body></html>\n";
				case .Conflict:                return "<html><head><title>409 Conflict</title></head><body>\n<h1>Conflict</h1>\n<p>Indicates that the request could not be processed because of conflict in the current state of the resource.</p>\n</body></html>\n";
				case .Gone:                    return "<html><head><title>410 Gone</title></head><body>\n<h1>Gone</h1>\n<p>The requested resource is no longer available.</p>\n</body></html>\n";
				case .LengthRequired:          return "<html><head><title>411 Length Required</title></head><body>\n<h1>Length Required</h1>\n<p>The request did not specify the length of its content, which is required by the requested resource.</p>\n</body></html>\n";
				case .PreconditionFailed:      return "<html><head><title>412 Precondition Failed</title></head><body>\n<h1>Precondition Failed</h1>\n<p>The precondition on the request evaluated to false.</p>\n</body></html>\n";
				case .PayloadTooLarge:         return "<html><head><title>413 Payload Too Large</title></head><body>\n<h1>Payload Too Large</h1>\n<p>The request is larger than the server is willing or able to process.</p>\n</body></html>\n";
				case .RequestTooLong:          return "<html><head><title>414 Request Too Long</title></head><body>\n<h1>Bad Request</h1>\n<p>Your browser did a request that was too long for this server to parse.</p>\n</body></html>\n";
				case .UnsupportedMediaType:    return "<html><head><title>415 Unsupported Media Type</title></head><body>\n<h1>Unsupported Media Type</h1>\n<p>The request entity has a media type which the server or resource does not support.</p>\n</body></html>\n";
				case .RangeNotSatisfiable:     return "<html><head><title>416 Range Not Satisfiable</title></head><body>\n<h1>Range Not Satisfiable</h1>\n<p>The client has asked for a portion of the file, but the server cannot supply that portion.</p>\n</body></html>\n";
				case .ExpectationsFailed:      return "<html><head><title>417 Expectations Failed</title></head><body>\n<h1>Expectations Failed</h1>\n<p>The server cannot meet the requirements of the Expect request-header field.</p>\n</body></html>\n";
				case .ImATeapot:               return "<html><head><title>418 I'm A Teapot</title></head><body>\n<h1>I'm A Teapot</h1><br>\n<img src=\"data:image/png;base64,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\" alt=\"Teapot\" />\n</body></html>\n";
				case .MisdirectedRequest:      return "<html><head><title>421 Misdirected Request</title></head><body>\n<h1>Misdirected Request</h1>\n<p>The request was directed at a server that is not able to produce a response.</p>\n</body></html>\n";
				case .UnprocessableEntity:     return "<html><head><title>422 Unprocessable Entity</title></head><body>\n<h1>Unprocessable Entity</h1>\n<p>The request was well-formed but was unable to be followed due to semantic errors.</p>\n</body></html>\n";
				case .Locked:                  return "<html><head><title>423 Locked</title></head><body>\n<h1>Locked</h1>\n<p>The resource that is being accessed is locked.</p>\n</body></html>\n";
				case .FailedDependency:        return "<html><head><title>424 Failed Dependency</title></head><body>\n<h1>Failed Dependency</h1>\n<p>The request failed because it depended on another request and that request failed.</p>\n</body></html>\n";
				case .TooEarly:                return "<html><head><title>425 Too Early</title></head><body>\n<h1>Too Early</h1>\n<p>Indicates that the server is unwilling to risk processing a request that might be replayed.</p>\n</body></html>\n";
				case .UpgradeRequired:         return "<html><head><title>426 Upgrade Required</title></head><body>\n<h1>Upgrade Required</h1>\n<p>The client should switch to a different protocol.</p>\n</body></html>\n";
				case .PreconditionRequired:    return "<html><head><title>428 Precondition Required</title></head><body>\n<h1>Precondition Required</h1>\n<p>The origin server requires the request to be conditional. Intended to prevent the 'lost update' problem, where a client GETs a resource's state, modifies it, and PUTs it back to the server, when meanwhile a third party has modified the state on the server, leading to a conflict.</p>\n</body></html>\n";
				case .TooManyRequests:         return "<html><head><title>429 Too Many Requests</title></head><body>\n<h1>Too Many Requests</h1>\n<p>The user has sent too many requests in a given amount of time.</p>\n</body></html>\n";
				case .ReqHdrFieldsTooLarge:    return "<html><head><title>431 Request Header Fields Too Large</title></head><body>\n<h1>Request Header Fields Too Large</h1>\n<p>The server is unwilling to process the request because either an individual header field, or all the header fields collectively, are too large.</p>\n</body></html>\n";
				case .UnavailForLegalReasons:  return "<html><head><title>451 Unavailable For Legal Reasons</title></head><body>\n<h1>Unavailable For Legal Reasons</h1>\n<p>The server operator has received a legal demand to deny access to a resource or to a set of resources that includes the requested resource.</p>\n</body></html>\n";

				case .InternalError:           return "<html><head><title>500 Internal Server Error</title></head><body>\n<h1>Internal Server Error</h1>\n<p>An error occurred while generating the content for this request.</p>\n</body></html>\n";
				case .NotImplemented:          return "<html><head><title>501 Method Not Implemented</title></head><body>\n<h1>Method Not Implemented</h1>\n<p>The method used in the request is invalid.</p>\n</body></html>\n";
				case .BadGateway:              return "<html><head><title>502 Bad Gateway</title></head><body>\n<h1>Bad Gateway</h1>\n<p>The server was acting as a gateway or proxy and received an invalid response from the upstream server.</p>\n</body></html>\n";
				case .ServiceUnavailable:      return "<html><head><title>503 Service Unavailable</title></head><body>\n<h1>Service Unavailable</h1>\n<p>The server cannot handle the request (because it is overloaded or down for maintenance).</p>\n</body></html>\n";
				case .GatewayTimeout:          return "<html><head><title>504 Gateway Timeout</title></head><body>\n<h1>Gateway Timeout</h1>\n<p>The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.</p>\n</body></html>\n";
				case .HttpVersionNotSupported: return "<html><head><title>505 HTTP Version Not Supported</title></head><body>\n<h1>HTTP Version Not Supported</h1>\n<p>The server does not support the HTTP protocol version used in the request.</p>\n</body></html>\n";
				case .VariantAlsoNegotiates:   return "<html><head><title>506 Variant Also Negotiates</title></head><body>\n<h1>Variant Also Negotiates</h1>\n<p>Transparent content negotiation for the request results in a circular reference.</p>\n</body></html>\n";
				case .InsufficientStorage:     return "<html><head><title>507 Insufficient Storage</title></head><body>\n<h1>Insufficient Storage</h1>\n<p>The server is unable to store the representation needed to complete the request.</p>\n</body></html>\n";
				case .LoopDetected:            return "<html><head><title>508 Loop Detected</title></head><body>\n<h1>Loop Detected</h1>\n<p>The server detected an infinite loop while processing the request.</p>\n</body></html>\n";
				case .NotExtended:             return "<html><head><title>510 Not Extended</title></head><body>\n<h1>Not Extended</h1>\n<p>Further extensions to the request are required for the server to fulfil it.</p>\n</body></html>\n";
				case .NetworkAuthRequired:     return "<html><head><title>511 Network Authentication Required</title></head><body>\n<h1>Network Authentication Required</h1>\n<p>The client needs to authenticate to gain network access.</p>\n</body></html>\n";
				default:                       return "";
				}
			}
		}
	}

	public enum HttpTransferEncoding
	{
		Identity,
		Chunked
	}

	public enum WriteBlockStatus
	{
		PendingData,
		WaitingData,
		Done
	}

	public enum ChunkState
	{
		Initial,
		Data,
		DataEnd,
		Trailer,
		Finished
	}

	public enum SetupEncodingState
	{
		None,
		WaitHeaders,
		StartHeaders
	}

	public struct RequestInfo
	{
	    public HttpMethod RequestType;
	    public DateTime DateTime;
	    public char8* Method;
	    public char8* Argument;
	    public char8* QueryParams;
	    public char8* VersionStr;
	    public uint32 Version;
	}

	public struct HeaderOutInfo
	{
	    public int32 ContentLength;
	    public HttpTransferEncoding TransferEncoding;
	    public StringBuffer ExtraHeaders;
	    public uint32 Version;
	}

	public struct ResponseInfo
	{
	    public HttpStatus Status;
	    public String ContentType;
	    public String ContentCharset;
	    public DateTime LastModified;
	}

	public typealias HttpParameterArray = uint8*[(uint8)HttpParameter.MaxVal];
	
	public delegate WriteBlockStatus WriteBlockMethod();
	public delegate void ProcMethod();
	public delegate bool ParseBufferMethod();

	public abstract class OutputItem
	{
		protected bool _persistent = false;
		protected uint8* _buffer = null;
		protected int32 _bufferPos = 0;
		protected int32 _bufferSize = 0;
		protected int32 _bufferOffset = 0;
		protected bool _outputPending = false;
		protected bool _eof = false;
		protected OutputItem _pref = null;
		protected OutputItem _next = null;
		protected OutputItem _prefDelayFree = null;
		protected OutputItem _nextDelayFree = null;
		protected HttpSocket _socket = null;
		protected WriteBlockMethod _writeBlock = null;
		
		public bool Persistent { get { return _persistent; } }
		public HttpSocket Socket { get { return _socket; } }

		protected mixin BufferEmptyToWriteStatus(bool aValue)
		{
			WriteBlockStatus status = aValue ? .Done : .PendingData;
			status
		}

		protected mixin EofToWriteStatus(bool aValue)
		{
			WriteBlockStatus status = aValue ? .Done : .WaitingData;
			status
		}

		protected virtual void DoneInput() { }

		protected virtual int32 HandleInput(uint8* aBuffer, int32 aSize)
		{
  			/* discard input */
			return aSize;
		}

		protected virtual WriteBlockStatus WriteBlock()
		{
			if (_outputPending)
			{
				if (_bufferSize > _bufferPos)
					_bufferPos += _socket.Send(&_buffer[_bufferPos], _bufferSize - _bufferPos);

				_outputPending = _bufferPos < _bufferSize;
				return BufferEmptyToWriteStatus!(!_outputPending);
			}
			else
			{
				return EofToWriteStatus!(_eof);
			}
		}

		public this(HttpSocket aSocket)
		{
			_socket = aSocket;
		}

		public ~this()
		{
			if (_socket.[Friend]_currentInput == this)
				_socket.[Friend]_currentInput = null;

			if (_prefDelayFree == null)
				_socket.[Friend]_delayFreeItems = _nextDelayFree;
			else
				_prefDelayFree.[Friend]_nextDelayFree = _nextDelayFree;

			if (_nextDelayFree != null)
				_nextDelayFree.[Friend]_prefDelayFree = _prefDelayFree;
		}

		public void LogError(StringView aMsg) =>
			_socket.[Friend]LogError(aMsg, 0);
	}

	public class MemoryOutput : OutputItem
	{
		protected bool _deleteBuffer;

		public this(HttpSocket aSocket, void* aBuffer, int32 aBufferOffset, int32 aBufferSize, bool aIndDeleteBuffer) : base (aSocket)
		{
			_buffer = (uint8*)aBuffer;
			_bufferPos = aBufferOffset;
			_bufferSize = aBufferSize;
			_deleteBuffer = aIndDeleteBuffer;
			_outputPending = true;
		}

		public ~this()
		{
			if (_deleteBuffer)
				Internal.Free(_buffer); // Perhaps `delete _buffer;` is enough
		}
	}

	public class MemoryStreamOutput : OutputItem
	{
		protected bool _deleteStream;
		protected MemoryStream _stream = null;

		protected override WriteBlockStatus WriteBlock()
		{
			if (!_outputPending)
				return .Done;

			int32 written = _socket.Send(&_stream.[Friend]mMemory[(int)_stream.Position], (int32)(_stream.Length - _stream.Position));
			_stream.Position = _stream.Position + written;
			_outputPending = _stream.Position < _stream.Length;
			_eof = !_outputPending;
			return EofToWriteStatus!(_eof);
		}

		public this(HttpSocket aSocket, MemoryStream aStream, bool aIndDeleteStream) : base (aSocket)
		{
			_stream = aStream;
			_deleteStream = aIndDeleteStream;
			_outputPending = true;
		}

		public ~this()
		{
			if (_deleteStream)
				delete _stream;
		}
	}

	public abstract class BufferOutput : OutputItem
	{
		private const int ReserveChunkBytes = 12;
		private const uint32 DataBufferSize = 32 * 1024;
		private const char8[16] HexDigits = .(
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
		);

		protected ProcMethod _prepareBuffer = null;
		protected ProcMethod _finishBuffer = null;
		protected int32 _bufferMemSize = 0;

		protected ProcMethod _pb = new => PrepareBuffer ~ delete _;
		protected ProcMethod _pc = new => PrepareChunk ~ delete _;
		protected WriteBlockMethod _wb = new => WriteBuffer ~ delete _;
		protected WriteBlockMethod _wc = new => WriteChunk ~ delete _;
		protected WriteBlockMethod _wp = new => WritePlain ~ delete _;
		protected ProcMethod _fb = new => FinishBuffer ~ delete _;
		protected ProcMethod _fc = new => FinishChunk ~ delete _;

		protected int32 HexReverse(int32 aValue, char8* aBuffer)
		{
			var aValue;
			var aBuffer;
			int32 result = 0;

			repeat
			{
				*aBuffer = HexDigits[aValue & 0xF];
				aValue >>= 4;
				aBuffer--;
				result++;
			}
			while (aValue > 0);

			return result;
		} 

    	protected void PrepareBuffer()
		{
			/* Also for "plain" encoding */
			_bufferPos = 0;
			_bufferOffset = 0;
			_bufferSize = _bufferMemSize;
		}

	    protected void PrepareChunk()
		{
 			/* 12 bytes for starting space, 7 bytes to end: <CR><LF>0<CR><LF><CR><LF> */
			_bufferPos = ReserveChunkBytes;
			_bufferOffset = _bufferPos;
			_bufferSize = _bufferMemSize - 7;
		}

	    protected void FinishBuffer() { /* Nothing to do */ }

	    protected void FinishChunk()
		{
			int32 offset = HexReverse(_bufferPos - _bufferOffset, (char8*)(_buffer + _bufferOffset - 3));
			_buffer[_bufferOffset - 2] = (uint8)'\r';
			_buffer[_bufferOffset - 1] = (uint8)'\n';
			_buffer[_bufferPos] = (uint8)'\r';
			_buffer[_bufferPos + 1] = (uint8)'\n';
			_bufferSize = _bufferPos + 2;
			_bufferPos = _bufferOffset - offset - 2;
		}

	    protected void SelectChunked()
		{
			_prepareBuffer = _pc;
			_writeBlock = _wc;
			_finishBuffer = _fc;
			PrepareChunk();
		}

	    protected void SelectBuffered()
		{
			_prepareBuffer = _pb;
			_writeBlock = _wb;
			_finishBuffer = _fb;
			PrepareBuffer();
		}

	    protected void SelectPlain()
		{
			_prepareBuffer = _pb;
			_writeBlock = _wp;
			_finishBuffer = _fb;
			PrepareBuffer();
		}

	    protected void PrependBufferOutput(int32 aMinBufferSize)
		{
			_finishBuffer();
			_socket.PrependOutput(new MemoryOutput(_socket, _buffer, _bufferOffset, _bufferPos, true), this);
			_bufferMemSize = aMinBufferSize;

			if (_bufferMemSize < DataBufferSize)
				_bufferMemSize = DataBufferSize;

			_buffer = (uint8*)Internal.Malloc(_bufferMemSize);
			_prepareBuffer();
		}

	    protected void PrependStreamOutput(Stream aStream, bool aIndDelete)
		{
			if (aStream is MemoryStream)
				_socket.PrependOutput(new MemoryStreamOutput(_socket, (MemoryStream)aStream, aIndDelete), this);
			else
				_socket.PrependOutput(new StreamOutput(_socket, aStream, aIndDelete), this);
		}

    	protected abstract WriteBlockStatus FillBuffer();

	    protected WriteBlockStatus WriteChunk()
		{
			WriteBlockStatus result;

			if ((!_outputPending) && (!_eof))
			{
				result = FillBuffer();
				_eof = result == .Done;
				_outputPending = _bufferPos > _bufferOffset;

				if (_outputPending)
					FinishChunk();

				if (_eof)
				{
					if (!_outputPending)
					{
						/* _bufferPos/Size still in "fill mode" */
						_bufferSize = 0;
						_bufferPos = 0;
						_outputPending = true;
					}

					_buffer[_bufferSize] = (uint8)'0';
					_buffer[_bufferSize + 1] = (uint8)'\r';
					_buffer[_bufferSize + 2] = (uint8)'\n';
					/* No trailer */
					_buffer[_bufferSize + 3] = (uint8)'\r';
					_buffer[_bufferSize + 4] = (uint8)'\n';
					_bufferSize += 5;
				}
			}
			else
			{
				result = EofToWriteStatus!(_eof);
			}

			if (_outputPending)
			{
				result = base.WriteBlock();

				if (result == .Done && !_eof)
				{
					result = .PendingData;
					PrepareChunk();
				}
			}

			return result;
		}

	    protected WriteBlockStatus WriteBuffer()
		{
			WriteBlockStatus result;

			if (!_outputPending)
			{
				result = FillBuffer();
				_eof = result == .Done;
				_outputPending = _eof;

				if (_outputPending || _bufferPos == _bufferSize)
				{
					if (_bufferPos > _bufferOffset)
					{
						_socket.[Friend]AddContentLength(_bufferPos - _bufferOffset);

						if (!_eof)
						{
							PrependBufferOutput(0);
						}
						else
						{
							_bufferSize = _bufferPos;
							_bufferPos = _bufferOffset;
						}
					}
					else
					{
						_bufferSize = 0;
						_bufferPos = 0;
					}

					if (_eof)
						_socket.[Friend]DoneBuffer(this);
				}
			}
			else
			{
				result = EofToWriteStatus!(_eof);
			}

			if (result == .Done)
				result = base.WriteBlock();

			return result;
		}

	    protected WriteBlockStatus WritePlain()
		{
			WriteBlockStatus result;

			if (!_outputPending)
			{
				result = FillBuffer();
				_eof = result == .Done;

				if (_bufferPos > _bufferOffset)
				{
					_bufferSize = _bufferPos;
					_bufferPos = _bufferOffset;
					_outputPending = true;
				}
				else
				{
					_bufferSize = 0;
					_bufferPos = 0;
				}
			}

			result = base.WriteBlock();

			if (result != .PendingData)
			{
				PrepareBuffer();

				if (!_eof)
					result = .PendingData;
			}

			return result;
		}

	    protected override WriteBlockStatus WriteBlock() =>
			_writeBlock();

		public this(HttpSocket aSocket) : base (aSocket)
		{
			_buffer = (uint8*)Internal.Malloc(DataBufferSize);
			_prepareBuffer = _pb;
			_writeBlock = _wp;
			_finishBuffer = _fb;
			_bufferMemSize = DataBufferSize;
		}

		public ~this()
		{
			Internal.Free(_buffer);
		}

		public void Add(void* aBuffer, int32 aSize)
		{
			var aSize;
			int32 copySize;

			while (true)
			{
				copySize = _bufferSize - _bufferPos;

				if (copySize > aSize)
					copySize = aSize;

				Internal.MemMove(&_buffer[_bufferPos], aBuffer, copySize);
				_bufferPos += copySize;
				aSize -= copySize;

				if (aSize == 0)
					break;

				PrependBufferOutput(aSize);
			}
		}

		public void Add(StringView aStr) =>
			Add(aStr.Ptr, (int32)aStr.Length);

		public void Add(Stream aStream, bool aQueue = false, bool aIndDelete = true)
		{
			int32 size = (int32)(aStream.Length - aStream.Position);
			int32 copySize;

			while (true)
			{
				copySize = _bufferSize - _bufferPos;

				if (copySize > size)
					copySize = size;

				aStream.TryRead(.(&_buffer[_bufferPos], copySize));
				_bufferPos += copySize;
				size -= copySize;

				if (size == 0)
					break;

				if (aQueue)
				{
					PrependBufferOutput(0);
					PrependStreamOutput(aStream, aIndDelete);
				}
				else
				{
					PrependBufferOutput(size);
				}
			}
		}
	}

	public class StreamOutput : BufferOutput
	{
		protected Stream _stream;
		protected bool _deleteStream;
		protected int32 _streamSize = 0;

		protected override WriteBlockStatus FillBuffer()
		{
			int32 read = (int32)TrySilent!(_stream.TryRead(.(&_buffer[_bufferPos], _bufferSize - _bufferPos)));
			_bufferPos += read;
			return BufferEmptyToWriteStatus!(_stream.Position >= _streamSize);
		}

		public this(HttpSocket aSocket, Stream aStream, bool aIndDeleteStream) : base (aSocket)
		{
			_stream = aStream;
			_deleteStream = aIndDeleteStream;
			_streamSize = (int32)aStream.Length;
		}

		public ~this()
		{
			if (_deleteStream)
				delete _stream;
		}
	}

	public class HttpConnection : TcpConnection
	{
	    protected override void CanSendEvent(Handle aSocket)
		{
			((HttpSocket)aSocket).WriteBlock();
			((HttpSocket)aSocket).[Friend]FreeDelayFreeItems();
		}

		protected virtual void LogAccess(StringView aMessage) { }

	    protected override void ReceiveEvent(Handle aSocket)
		{
			((HttpSocket)aSocket).HandleReceive();
			((HttpSocket)aSocket).[Friend]FreeDelayFreeItems();
		}
	}
	
	[AlwaysInclude(IncludeAllMethods=true), Reflect(.All)]
	public abstract class HttpSocket : SSLSocket
	{
		private const uint32 RequestBufferSize = 4 * 1024;
		private const uint32 DataBufferSize = 32 * 1024;

	    protected uint8* _buffer = null;
	    protected uint8* _bufferPos = null;
	    protected uint8* _bufferEnd = null;
	    protected uint8* _requestBuffer = null;
	    protected uint8* _requestPos = null;

	    protected int32 _bufferSize = 0;
	    protected int32 _inputRemaining = 0;
		
		protected bool _requestInputDone = false;
		protected bool _requestHeaderDone = false;
		protected bool _outputDone = false;
	    protected bool _keepAlive = false;

	    protected OutputItem _currentInput = null;
	    protected OutputItem _currentOutput = null;
	    protected OutputItem _lastOutput = null;
	    protected OutputItem _delayFreeItems = null;

	    protected ChunkState _chunkState = .Finished;
	    protected ParseBufferMethod _parseBuffer = null;
	    protected HttpParameterArray _parameters = .();

		protected ParseBufferMethod _pr = new => ParseRequest ~ delete _;
		protected ParseBufferMethod _pep = new => ParseEntityPlain ~ delete _;
		protected ParseBufferMethod _pec = new => ParseEntityChunked ~ delete _;
    
    	public HttpParameterArray Parameters { get { return _parameters; } }

		protected bool TrySingleDigit(char8 aDigit, out uint8 aOutDigit) =>
			TrySingleDigit((uint8)aDigit, out aOutDigit);

		protected bool TrySingleDigit(uint8 aDigit, out uint8 aOutDigit)
		{
			bool result = (aDigit >= (uint8)'0') && (aDigit <= (uint8)'9');

			if (result)
				aOutDigit = aDigit - (uint8)'0';
			else
				aOutDigit = 0;

			return result;
		}

		protected bool HttpVersionCheck(uint8* aStr, uint8* aStrEnd, out uint32 aVersion)
		{
			uint8 majorVersion = 0;
			uint8 minorVersion = 0;
			bool result = (aStrEnd - aStr) == 8 &&
				CompareMem(aStr, (uint8*)"HTTP/", 5) &&
				TrySingleDigit(aStr[5], out majorVersion) &&
				aStr[6] == '.' &&
				TrySingleDigit(aStr[7], out minorVersion);

			aVersion = majorVersion * 10 + minorVersion;
			return result;
		}

		protected void HexToInt(char8* aBuffer, out uint32 aValue, out int aCode)
		{
			var aBuffer;
			uint32 val = 0;
			uint32 incr = 0;
			aCode = 0;
			char8* start = aBuffer;

			while (*aBuffer != 0x0)
			{
				if (*aBuffer >= '0' && *aBuffer <= '9')
					incr = (uint8)*aBuffer - (uint8)'0';
				else if (*aBuffer >= 'A' && *aBuffer <= 'F')
					incr = (uint8)*aBuffer - (uint8)'A' + 10;
				else if (*aBuffer >= 'a' && *aBuffer <= 'f')
					incr = (uint8)*aBuffer - (uint8)'a' + 10;
				else
				{
					aCode = aBuffer - start + 1;
					break;
				}

				val = (val << 4) + incr;
				aBuffer++;
			}

			aValue = val;
		}
		
		protected abstract void AddContentLength(int32 aLength);

	    protected int32 CalcAvailableBufferSpace() =>
			(int32)(_bufferSize - (_bufferEnd - _buffer) - 1);

	    protected void DelayFree(OutputItem aOutputItem)
		{
			if (aOutputItem == null)
				return;

			/* Check whether already in delayed free list */
			if (aOutputItem == _delayFreeItems || aOutputItem.[Friend]_prefDelayFree != null)
				return;

			if (_delayFreeItems != null)
				_delayFreeItems.[Friend]_prefDelayFree = aOutputItem;

			aOutputItem.[Friend]_nextDelayFree = _delayFreeItems;
			_delayFreeItems = aOutputItem;
		}

	    protected virtual void DoneBuffer(BufferOutput aOutput) { }

	    protected void FreeDelayFreeItems()
		{
			OutputItem item;

			while (_delayFreeItems != null)
			{
				item = _delayFreeItems;
				_delayFreeItems = _delayFreeItems.[Friend]_nextDelayFree;

				if (!item.Persistent)
					delete item;
			}
		}

	    protected virtual void LogAccess(StringView aMsg) { }

	    protected virtual void LogMessage() { }

	    protected virtual void FlushRequest()
		{
			for (int i = 0; i < _parameters.Count; i++)
				_parameters[i] = null;

			ResetDefaults();
		}

	    protected void PackRequestBuffer()
		{
			uint8* freeBuff = null;

			if (_requestBuffer != null && _bufferEnd - _bufferPos <= RequestBufferSize)
			{
				/* Switch back to normal size buffer */
				freeBuff = _buffer;
				_buffer = _requestBuffer;
				_bufferSize = RequestBufferSize;
				_requestBuffer = null;
			}

			if (_requestPos != null)
			{
				int32 bytesLeft = (int32)(_bufferEnd - _requestPos);
				_bufferEnd = _buffer + bytesLeft;
				RelocateVariable(ref _bufferPos);
				RelocateVariables();
				/* Include null-terminator, where _bufferEnd is pointing at */
				Internal.MemMove(_buffer, _requestPos, bytesLeft + 1);
				_requestPos = null;
			}

			if (freeBuff != null)
				Internal.Free(freeBuff);
		}

	    protected void PackInputBuffer()
		{
			/* Use bigger buffer for more speed */
			if (_requestBuffer == null)
			{
				_requestBuffer = _buffer;
				_buffer = (uint8*)Internal.Malloc(DataBufferSize);
				_bufferSize = DataBufferSize;
				_requestPos = null;
			}

			int bytesLeft = _bufferEnd - _bufferPos;
			Internal.MemMove(_buffer, _bufferPos, bytesLeft);
			_bufferEnd = _buffer + bytesLeft;
			_bufferPos = _buffer;
		}

		protected bool CompareMem(uint8* aStrA, uint8* aStrB, int32 aLength)
		{
			bool result = true;

			for (int32 i = 0; i < aLength; i++)
				if (aStrA[i] != aStrB[i])
				{
					result = false;
					break;
				}

			return result;
		}

		protected bool CompareMem(char8* aStrA, char8* aStrB, int32 aLength) =>
			CompareMem((uint8*)aStrA, (uint8*)aStrB, aLength);

		protected uint8* StrScan(uint8* aBuffer, uint8 aValue)
		{
			uint8* curPos = aBuffer;

			while (curPos != null && *curPos != 0x0)
			{
				if (*curPos == aValue)
					return curPos;

				curPos++;
			}

			return null;
		}

	    protected bool ParseRequest()
		{
			if (_requestHeaderDone)
				return !_requestInputDone;

			uint8* nextLine, lineEnd;

			while (true)
			{
				lineEnd = StrScan(_bufferPos, (uint8)'\n');

				if (lineEnd == null)
				{
					if (_requestBuffer != null || _requestPos != null)
						PackRequestBuffer();
					else if (CalcAvailableBufferSpace() == 0)
						WriteError(.RequestTooLong);

					return true;
				}

				nextLine = lineEnd + 1;

				if (lineEnd > _bufferPos && *(lineEnd - 1) == (uint8)'\r')
					lineEnd--;

				*lineEnd = 0x0;
				ParseLine(lineEnd);
				_bufferPos = nextLine;

				if (_requestHeaderDone)
					return !_requestInputDone;
			}
		}

	    protected bool ParseEntityPlain()
		{
			int32 numBytes =  (int32)(_bufferEnd - _bufferPos);

			if (numBytes > _inputRemaining)
				numBytes = _inputRemaining;

			/* If no output item to feed into, discard */
			if (_currentInput != null)
				numBytes = _currentInput.[Friend]HandleInput(_bufferPos, numBytes);

			_bufferPos += numBytes;
			_inputRemaining -= numBytes;
			bool result = _inputRemaining > 0;

			/* Prepare for more data, if more data coming */
			if (result && _bufferPos + _inputRemaining > _buffer + _bufferSize)
				PackInputBuffer();

			return result;
		}

	    protected bool ParseEntityChunked()
		{
			uint8* lineEnd, nextLine;
			int code;

			while (true)
			{
				if (_chunkState == .Finished)
					return false;

				if (_chunkState == .Data)
				{
					if (ParseEntityPlain())
						return true;
					else
						_chunkState = .DataEnd;
				}

				lineEnd = StrScan(_bufferPos, (uint8)'\n');

				if (lineEnd == null)
					return true;

				nextLine = lineEnd + 1;

				if (lineEnd > _bufferPos && *(lineEnd - 1) == (uint8)'\r')
					lineEnd--;

				switch (_chunkState)
				{
				case .Initial:
					{
						*lineEnd = 0x0;
						uint32 intRemain;
						HexToInt((char8*)_bufferPos, out intRemain, out code);
						_inputRemaining = (int32)intRemain;

						if (code == 1)
						{
							_chunkState = .Finished;
							Disconnect();
							return false;
						}

						if (_inputRemaining == 0)
							_chunkState = .Trailer;
						else
							_chunkState = .Data;
					}
				case .DataEnd:
					{
						/* Skip empty line */
						_chunkState = .Initial;
					}
				case .Trailer:
					{
						/* Trailer is optional, empty line indicates end */
						if (lineEnd == _bufferPos)
							_chunkState = .Finished;
						else
							ParseParameterLine(lineEnd);
					}
				default: break;
				}

				_bufferPos = nextLine;
			}
		}

	    protected virtual void ParseLine(uint8* aLineEnd)
		{
			if (_bufferPos[0] == 0x0)
			{
				_requestHeaderDone = true;
				ProcessHeaders();
			}
			else
			{
				ParseParameterLine(aLineEnd);
			}
		}

	    protected void ParseParameterLine(uint8* aLineEnd)
		{
			uint8* pos = StrScan(_bufferPos, (uint8)' ');

			if (pos == null || pos == _bufferPos || *(pos - 1) != (uint8)':')
			{
				WriteError(.BadRequest);
				return;
			}

			/* Null-terminate at colon */
			*(pos - 1) = 0x0;
			String tmp = scope .((char8*)_bufferPos);
			tmp.ToUpper();
			int32 len = (int32)(pos - _bufferPos - 1);
			TypeInstance typeInst = (TypeInstance)typeof(HttpParameter);
			HttpParameter param;

			for (let field in typeInst.GetFields())
			{
				// RelocateVariable(ref _parameters[field.[Friend]mFieldData.mData]);
				param = *((HttpParameter*)(&field.[Friend]mFieldData.mData));

				if (param.StrVal.Length == len && CompareMem(tmp.Ptr, param.StrVal.Ptr, len))
				{
					repeat
					{
						pos++;
					}
					while (*pos == (uint8)' ');

					_parameters[(uint8)param] = pos;
					break;
				}
			}
		}

	    protected void PrepareNextRequest()
		{
  			/* Next request */
			_requestInputDone = false;
			_requestHeaderDone = false;
			_outputDone = false;
			_requestPos = _bufferPos;
			FlushRequest();

  			/* Rewind buffer pointers if at end of buffer anyway */
			if (_bufferPos == _bufferEnd)
				PackRequestBuffer();
		}

	    protected bool ProcessEncoding()
		{
			bool result = true;
			String tmp = scope .();
			uint8* param = _parameters[(uint8)HttpParameter.ContentLength];

			if (param != null)
			{
				tmp.Append((char8*)param);
				_parseBuffer = _pep;

				if (Int32.Parse(tmp) case .Ok(let val))
					_inputRemaining = val;
				else
					WriteError(.BadRequest);

				return result;
			}
			
			param = _parameters[(uint8)HttpParameter.TransferEncoding];

			if (param != null)
			{
				tmp.Clear();
				tmp.Append((char8*)param);

				if (tmp.Equals("chunked", .OrdinalIgnoreCase))
				{
					_parseBuffer = _pec;
					_chunkState = .Initial;
				}
				else
				{
					result = false;
				}
			}

			/* Only if keep-alive, then user must specify either of above headers to indicate next header's start */
			param = _parameters[(uint8)HttpParameter.Connection];

			if (param != null)
			{
				tmp.Clear();
				tmp.Append((char8*)param);
				_requestInputDone = tmp.Equals("keep-alive", .OrdinalIgnoreCase);

				if (!_requestInputDone)
				{
					_parseBuffer = _pep;
					_inputRemaining = int32.MaxValue;
				}
			}
			else
			{
				_requestInputDone = false;
			}

			return result;
		}

	    protected abstract void ProcessHeaders();

	    protected void RelocateVariable(ref char8* aVar)
		{
			if (aVar == null)
				return;

			aVar = (char8*)(_buffer + (((uint8*)aVar) - _requestPos));
		}

	    protected void RelocateVariable(ref uint8* aVar)
		{
			if (aVar == null)
				return;

			aVar = _buffer + (aVar - _requestPos);
		}

	    protected virtual void RelocateVariables()
		{
			TypeInstance typeInst = (TypeInstance)typeof(HttpParameter);

			for (let field in typeInst.GetFields())
				if (field.[Friend]mFieldData.mData != (int)HttpParameter.MaxVal)
					RelocateVariable(ref _parameters[field.[Friend]mFieldData.mData]);
		}

	    protected virtual void ResetDefaults()
		{
  			_parseBuffer = _pr;
		}

	    protected bool SetupEncoding(BufferOutput aOutputItem, HeaderOutInfo* aHeaderOut)
		{
			if (aHeaderOut.ContentLength == 0)
			{
				if (aHeaderOut.Version >= 11)
				{
					/* We can use chunked encoding */
					aHeaderOut.TransferEncoding = .Chunked;
					aOutputItem.[Friend]SelectChunked();
				}
				else
				{
					/* We need to buffer the response to find its length */
					aHeaderOut.TransferEncoding = .Identity;
					aOutputItem.[Friend]SelectBuffered();
					/* Need to accumulate data before starting header output */
					AddToOutput(aOutputItem);
					return false;
				}
			}
			else
			{
				aHeaderOut.TransferEncoding = .Identity;
				aOutputItem.[Friend]SelectPlain();
			}

			return true;
		}

	    protected virtual void WriteError(HttpStatus aStatus) { }

	    public this() : base()
		{
			_buffer = (uint8*)Internal.Malloc(RequestBufferSize);
			_bufferSize = RequestBufferSize;
			_bufferPos = _buffer;
			_bufferEnd = _bufferPos;
			_buffer[0] = 0x0;
			_keepAlive = true;
		}

	    public ~this()
		{
			FreeDelayFreeItems();
			Internal.Free(_buffer);
			_buffer = null;
		}

	    public void AddToOutput(OutputItem aOutputItem)
		{
			aOutputItem.[Friend]_pref = _lastOutput;

			if (_lastOutput != null)
				_lastOutput.[Friend]_next = aOutputItem;
			else
				_currentOutput = aOutputItem;

			_lastOutput = aOutputItem;
		}

	    public override void Disconnect(bool aIndForced = true)
		{
			base.Disconnect(aIndForced);
			OutputItem item;

			while (_currentOutput != null)
			{
				item = _currentOutput;
				_currentOutput = _currentOutput.[Friend]_next;
				delete item;
			}

			if (_currentInput != null)
				DeleteAndNullify!(_currentInput);
		}

	    public void PrependOutput(OutputItem aNewItem, OutputItem aItem)
		{
			aNewItem.[Friend]_pref = aItem.[Friend]_pref;
			aNewItem.[Friend]_next = aItem;
			aItem.[Friend]_pref = aNewItem;

			if (_currentOutput == aItem)
				_currentOutput = aNewItem;
		}

	    public void RemoveOutput(OutputItem aOutputItem)
		{
			if (aOutputItem.[Friend]_pref != null)
				aOutputItem.[Friend]_pref.[Friend]_next = aOutputItem.[Friend]_next;
			
			if (aOutputItem.[Friend]_next != null)
				aOutputItem.[Friend]_next.[Friend]_pref = aOutputItem.[Friend]_pref;

			if (_lastOutput == aOutputItem)
				_lastOutput = aOutputItem.[Friend]_pref;

			if (_currentOutput == aOutputItem)
				_currentOutput = aOutputItem.[Friend]_next;

			aOutputItem.[Friend]_pref = null;
			aOutputItem.[Friend]_next = null;
		}

	    public void HandleReceive()
		{
			if (_requestInputDone)
			{
				IgnoreRead = true;
				return;
			}

			int32 read = CalcAvailableBufferSpace();

			/* If buffer has filled up, keep ignoring and continue parsing requests */
			if (read > 0)
			{
				IgnoreRead = false;
				read = Get(_bufferEnd, read);

				if (read == 0)
					return;

				_bufferEnd += read;
				*_bufferEnd = 0x0;
			}

			ParseBuffer();

			if (_ignoreWrite)
				WriteBlock();
		}

	    public bool ParseBuffer()
		{
			bool result = false;
			ParseBufferMethod parseFunc = null;

			repeat
			{
				parseFunc = _parseBuffer;
				result = parseFunc();

				if ((!result) && (!_requestInputDone))
				{
					_requestInputDone = true;

					if (_currentInput != null)
						_currentInput.[Friend]DoneInput();
				}
			} /* If parse func changed mid-run, then we should continue calling the new one: header + data */
			while (result && parseFunc != _parseBuffer);

			return result;
		}

	    public void WriteBlock()
		{
			while (true)
			{
				if (_currentOutput == null)
				{
					if ((!_outputDone) || ((!_requestInputDone) && _keepAlive))
						break;

					if (!_keepAlive)
					{
						Disconnect();
						return;
					}

					PrepareNextRequest();

					if (ParseBuffer() && IgnoreRead)
						HandleReceive(); // End of input buffer reached, try reading more

					if (_currentOutput == null)
						break;
				}

				/* If we cannot send, then the send buffer is full */
				if (_connectionStatus != .Connected || !_socketState.HasFlag(.CanSend))
					break;

				switch (_currentOutput.[Friend]WriteBlock())
				{
				case .Done:
					{
						if (_currentOutput == _lastOutput)
						  	_lastOutput = null;

						/* Some output items may trigger this parse/write loop */
						DelayFree(_currentOutput);
						_currentOutput = _currentOutput.[Friend]_next;
					}
				default:
					{
						/* Wait for more data from external source */
						break;
					}
				}

				/* Nothing left to write, request was busy and now completed */
				if (_currentOutput == null)
				{
				  	LogMessage();
				  	_outputDone = true;
				}
			}
		}
	}
}
