using Beef_Net.Connection;
using System;

namespace Beef_Net
{
	[CRepr]
	struct FCGI_Header
	{
		public uint8 Version;
		public uint8 ReqType;
		public uint8 RequestIdB1;
		public uint8 RequestIdB0;
		public uint8 ContentLengthB1;
		public uint8 ContentLengthB0;
		public uint8 PaddingLength;
		public uint8 Reserved;
	}
	
	[CRepr]
	struct FCGI_BeginRequestBody
	{
		public uint8 RoleB1;
		public uint8 RoleB0;
		public uint8 Flags;
		public uint8[5] Reserved;
	}
	
	[CRepr]
	struct FCGI_EndRequestBody
	{
		public uint8 AppStatusB3;
		public uint8 AppStatusB2;
		public uint8 AppStatusB1;
		public uint8 AppStatusB0;
		public uint8 ProtocolStatus;
		public uint8[3] Reserved;
	}
	
	[CRepr]
	struct FCGI_UnknownTypeBody
	{
		public uint8 _type;
		public uint8[7] Reserved;
	}
	
	[CRepr]
	struct FCGI_BeginRequestRecord
	{
		public FCGI_Header Header;
		public FCGI_BeginRequestBody Body;
	}
	
	[CRepr]
	struct FCGI_EndRequestRecord
	{
		public FCGI_Header Header;
		public FCGI_EndRequestBody Body;
	}
	
	[CRepr]
	struct FCGI_UnknownTypeRecord
	{
		public FCGI_Header Header;
		public FCGI_UnknownTypeBody Body;
	}

	public enum SpawnState
	{
		None,
		Spawning,
		Spawned
	}

	public enum FastCGIClientState
	{
		Idle,
		Connecting,
		ConnectingAgain,
		StartingServer,
		Header,
		Data,
		Flush
	}

	public function void FastCGIRequestEvent(FastCGIRequest aRequest);

	public sealed static class FCGI
	{
		/// Listening socket file number
		public const uint8 LISTENSOCK_FILENO = 0;
		/// Number of bytes in a FCGI_Header.  Future versions of the protocol will not reduce this number.
		public const uint8 HEADER_LEN = 8;
		/// Value for version component of FCGI_Header
		public const uint8 VERSION_1 = 1;
		/// Values for type component of FCGI_Header
		public const uint8 BEGIN_REQUEST = 1;
		public const uint8 ABORT_REQUEST = 2;
		public const uint8 END_REQUEST = 3;
		public const uint8 PARAMS = 4;
		public const uint8 STDIN = 5;
		public const uint8 STDOUT = 6;
		public const uint8 STDERR = 7;
		public const uint8 DATA = 8;
		public const uint8 GET_VALUES = 9;
		public const uint8 GET_VALUES_RESULT = 10;
		public const uint8 UNKNOWN_TYPE = 11;
		public const uint8 MAXTYPE = UNKNOWN_TYPE;
		/// Value for requestId component of FCGI_Header
		public const uint8 NULL_REQUEST_ID = 0;
		/// Mask for flags component of FCGI_BeginRequestBody
		public const uint8 KEEP_CONN = 1;
		/// Values for role component of FCGI_BeginRequestBody
		public const uint8 RESPONDER = 1;
		public const uint8 AUTHORIZER = 2;
		public const uint8 FILTER = 3;
		/// Values for protocolStatus component of FCGI_EndRequestBody
		public const uint8 REQUEST_COMPLETE = 0;
		public const uint8 CANT_MPX_CONN = 1;
		public const uint8 OVERLOADED = 2;
		public const uint8 UNKNOWN_ROLE = 3;
		/// Variable names for FCGI_GET_VALUES / FCGI_GET_VALUES_RESULT records
		public const String MAX_CONNS = "FCGI_MAX_CONNS";
		public const String MAX_REQS = "FCGI_MAX_REQS";
		public const String MPXS_CONNS = "FCGI_MPXS_CONNS";
	}

	class FastCGIRequest
	{
		private struct FastCGIStringSize
		{
			public int32 Size;
			public char8[4] SizeBuf;
		}

		protected int _id;
		protected FastCGIClient _client = null;
		protected StringBuffer _buffer;
		protected int32 _bufferSendPos;
		protected FCGI_Header _header;
		protected int32 _headerPos;
		protected int32 _contentLength;
		protected uint8* _inputBuffer = null;
		protected int32 _inputSize;
		protected bool _outputPending;
		protected bool _outputDone;
		protected bool _stdErrDone;
		protected FastCGIRequest _nextFree = null;
		protected FastCGIRequest _nextSend = null;
		protected FastCGIRequestEvent _onEndRequest = null;
		protected FastCGIRequestEvent _onInput = null;
		protected FastCGIRequestEvent _onOutput = null;
		protected FastCGIRequestEvent _onStdErr = null;

		private static char8[8] PaddingBuffer = .(0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0);

		public int Id
		{
			get { return _id; }
			set { SetId(value); }
		}
		public bool OutputPending { get { return _outputPending; } }
		public bool OutputDone { get { return _outputDone; } }
		public bool StdErrDone { get { return _stdErrDone; } }
		public FastCGIRequestEvent OnEndRequest
		{
			get { return _onEndRequest; }
			set { _onEndRequest = value; }
		}
		public FastCGIRequestEvent OnInput
		{
			get { return _onInput; }
			set { _onInput = value; }
		}
		public FastCGIRequestEvent OnOutput
		{
			get { return _onOutput; }
			set { _onOutput = value; }
		}
		public FastCGIRequestEvent OnStdErr
		{
			get { return _onStdErr; }
			set { _onStdErr = value; }
		}

		protected void HandleReceive()
		{
			switch(_client.ReqType)
			{
			case FCGI.STDOUT:            DoOutput();
			case FCGI.STDERR:            DoStdErr();
			case FCGI.END_REQUEST:       EndRequest();
			case FCGI.GET_VALUES_RESULT: _client.[Friend]HandleGetValuesResult();
			}
		}

		protected void HandleReceiveEnd()
		{
			switch(_client.ReqType)
			{
			case FCGI.STDOUT: _outputDone = true;
			case FCGI.STDERR: _stdErrDone = true;
			}
		}

		protected bool HandleSend()
		{
			if (_onInput != null)
				_onInput(this);

			return _inputBuffer == null;
		}

		protected void DoEndRequest()
		{
			if (_onEndRequest != null)
				_onEndRequest(this);
		}

		protected void DoOutput()
		{
			if (_onOutput != null)
				_onOutput(this);
		}

		protected void DoStdErr()
		{
			if (_onStdErr != null)
				_onStdErr(this);
		}

		protected void EndRequest()
		{
			_outputDone = false;
			_stdErrDone = false;
			_client.EndRequest(this);
			_client.Flush();
			RewindBuffer();
			DoEndRequest();
		}

		protected void RewindBuffer()
		{
			_bufferSendPos = 0;
			_headerPos = -1;
			// rewind stringbuffer
			_buffer.Pos = _buffer.Memory;
		}

		protected void SetContentLength(int32 aLength)
		{
			_contentLength = aLength;
			_header.ContentLengthB0 = (uint8)(aLength & 0xFF);
			_header.ContentLengthB1 = (uint8)((aLength >> 8) & 0xFF);
			_header.PaddingLength = (uint8)(7 - ((aLength + 7) & 7));
		}

		protected void SendEmptyRec(uint8 aType)
		{
			_header.ReqType = aType;
			SetContentLength(0);
			_buffer.AppendString(&_header, sizeof(FCGI_Header));
			// no padding needed for empty string
		}

		protected void SendGetValues()
		{
			// management record type has request id 0
			int lastRequestID = _id;
			_id = 0;
			SendParam("FCGI_MAX_REQS", "", FCGI.GET_VALUES);

			// if we're the first connection, ask max. # connections
			if (_client.[Friend]_pool.[Friend]_clientsAvail == 1)
				SendParam("FCGI_MAX_CONNS", "", FCGI.GET_VALUES);

			_id = lastRequestID;
		}

		protected void SetId(int aId)
		{
			_id = aId;
			_header.RequestIdB0 = (uint8)(aId & 0xFF);
			_header.RequestIdB1 = (uint8)((aId >> 8) & 0xFF);
		}

		public this()
		{
			_buffer = .Init(504);
			_header.Version = FCGI.VERSION_1;
			_headerPos = -1;
		}

		public ~this()
		{
			delete _buffer.Memory;
		}

		public void AbortRequest()
		{
			_header.ReqType = FCGI.ABORT_REQUEST;
			SetContentLength(0);
			_buffer.AppendString(&_header, sizeof(FCGI_Header));
			SendPrivateBuffer();
		}

		public int32 Get(char8* aBuffer, int32 aSize) =>
			_client.GetBuffer(aBuffer, aSize);

		public void ParseClientBuffer()
		{
			_outputPending = false;

			if ((_client.Iterator != null) && _client.Iterator.IgnoreRead)
				_client.[Friend]HandleReceive(null);
			else
				_client.[Friend]ParseBuffer();
		}

		public int32 SendBuffer()
		{
			// already a queue and we are not first in line ? no use in trying to send then
			if (_client.[Friend]_sendRequest != null && _client.[Friend]_sendRequest != this)
				return 0;

			// header to be sent?
			if (!SendPrivateBuffer())
				return 0;

			// first write request header, then wait for possible disconnect
			if (_bufferSendPos > 0)
				return 0;

			if (_inputBuffer == null)
				return 0;

			int32 written = _client.Send(_inputBuffer, _inputSize);
			_inputBuffer += written;
			_inputSize -= written;

			if (_inputSize == 0)
			{
				_inputBuffer = null;
				_buffer.AppendString(&PaddingBuffer[0], _header.PaddingLength);
			}
			else
			{
				_client.AddToSendQueue(this);
			}

			return written;
		}

		public bool SendPrivateBuffer()
		{
			// nothing to send ?
			if (_buffer.Pos - _buffer.Memory == _bufferSendPos)
				return true;

			bool result = false;

			// already a queue and we are not first in line ? no use in trying to send then
			if (_client.[Friend]_sendRequest == null || _client.[Friend]_sendRequest == this)
			{
				int32 written = _client.Send((uint8*)&_buffer.Memory[_bufferSendPos], (int32)(_buffer.Pos - _buffer.Memory - _bufferSendPos));
				_bufferSendPos += written;
				result = _bufferSendPos == _buffer.Pos - _buffer.Memory;

				// do not rewind buffer, unless remote side has had chance to disconnect
				if (result)
					RewindBuffer();
			}

			if (!result)
				_client.AddToSendQueue(this);

			return result;
		}

		public void SendBeginRequest(int aType)
		{
			FCGI_BeginRequestBody body = .();
			body.RoleB1 = (uint8)((aType >> 8) & 0xff);
			body.RoleB0 = (uint8)(aType & 0xff);
			body.Flags = FCGI.KEEP_CONN;
			_header.ReqType = FCGI.BEGIN_REQUEST;
			SetContentLength(sizeof(FCGI_BeginRequestBody));
			_buffer.AppendString(&_header, sizeof(FCGI_Header));
			_buffer.AppendString(&body, sizeof(FCGI_BeginRequestBody));
		}

		public void SendParam(StringView aName, StringView aValue, uint8 aReqType = FCGI.PARAMS)
		{
			void FillFastCGIStringSize(StringView aStr, ref FastCGIStringSize aFastCGIStr)
			{
				uint32 len = (uint32)aStr.Length;

				if (len > 127)
				{
					aFastCGIStr.Size = 4;
					aFastCGIStr.SizeBuf[0] = (char8)(0x80 + ((len >> 24) & 0xff));
					aFastCGIStr.SizeBuf[1] = (char8)((len >> 16) & 0xff);
					aFastCGIStr.SizeBuf[2] = (char8)((len >> 8) & 0xff);
					aFastCGIStr.SizeBuf[3] = (char8)(len & 0xff);
				}
				else
				{
					aFastCGIStr.Size = 1;
					aFastCGIStr.SizeBuf[0] = (char8)(len);
				}
			}

			FastCGIStringSize nameLen = .();
			FastCGIStringSize valueLen = .();

			FillFastCGIStringSize(aName, ref nameLen);
			FillFastCGIStringSize(aValue, ref valueLen);
			int32 totalLen = (int32)(nameLen.Size + valueLen.Size + aName.Length + aValue.Length);

			if (_header.ReqType == aReqType && _bufferSendPos == 0 && 0 <= _headerPos && _headerPos < _buffer.Pos - _buffer.Memory)
			{
				// undo padding
				_buffer.Pos -= _header.PaddingLength;
				SetContentLength(_contentLength + totalLen);
				Internal.MemMove(&_buffer.Memory[_headerPos], &_header, sizeof(FCGI_Header));
			}
			else
			{
				_header.ReqType = aReqType;
				SetContentLength(totalLen);
				_headerPos = (int32)(_buffer.Pos - _buffer.Memory);
				_buffer.AppendString(&_header, sizeof(FCGI_Header));
			}

			_buffer.AppendString(&nameLen.SizeBuf[0], nameLen.Size);
			_buffer.AppendString(&valueLen.SizeBuf[0], valueLen.Size);
			_buffer.AppendString(aName);
			_buffer.AppendString(aValue);
			_buffer.AppendString(&PaddingBuffer[0], _header.PaddingLength);
		}

		public int32 SendInput(char8* aBuffer, int32 aSize)
		{
			int32 result;

			// first send current buffer if any
			if (_inputBuffer != null)
			{
				result = SendBuffer();

				if (_inputBuffer != null)
					return result;
			}
			else
			{
				result = 0;
			}

			if (result >= aSize)
				return result;

			if (_inputBuffer == null)
			{
				_inputBuffer = (uint8*)(aBuffer + result);
				_inputSize = aSize - result;
				_header.ReqType = FCGI.STDIN;
				SetContentLength(_inputSize);
				_buffer.AppendString(&_header, sizeof(FCGI_Header));
			}

			return result + SendBuffer();
		}

		public void DoneParams() =>
			SendEmptyRec(FCGI.PARAMS);

		public void DoneInput()
		{
			SendEmptyRec(FCGI.STDIN);
			SendPrivateBuffer();
		}
	}

	public class FastCGIPool
	{
		protected FastCGIClient* _clients = null;
		protected int _clientsCount = 0;
		protected int _clientsAvail = 0;
		protected int _clientsMax;
		protected int _maxRequestsConn;
		protected FastCGIClient _freeClient = null;
		protected Timer _timer;
		protected Eventer _eventer;
		protected String _appName;
		protected String _appEnv;
		protected String _host;
		protected uint16 _port;
		protected SpawnState _spawnState;
		protected NotifyEvent _connectClients = new => ConnectClients ~ delete _;

		public String AppEnv
		{
			get { return _appEnv; }
			set { _appEnv = value; }
		}
		public String AppName
		{
			get { return _appName; }
			set { _appName = value; }
		}
		public int ClientsMax
		{
			get { return _clientsMax; }
			set { _clientsMax = value; }
		}
		public Eventer Eventer
		{
			get { return _eventer; }
			set { _eventer = value; }
		}
		public int MaxRequestsConn
		{
			get { return _maxRequestsConn; }
			set { _maxRequestsConn = value; }
		}
		public String Host
		{
			get { return _host; }
			set { _host = value; }
		}
		public uint16 Port
		{
			get { return _port; }
			set { _port = value; }
		}
		public Timer Timer { get { return _timer; } }

		protected void AddToFreeClients(FastCGIClient aClient)
		{
			if (aClient.[Friend]_nextFree != null)
				return;
			
			if (_freeClient == null)
				_freeClient = aClient;
			else
				aClient.[Friend]_nextFree = _freeClient.[Friend]_nextFree;

			_freeClient.[Friend]_nextFree = aClient;
		}

		protected FastCGIClient CreateClient()
		{
			if (_clientsAvail == _clientsCount)
			{
				int oldCount = _clientsCount;
				_clientsCount += 64;

				if (_clients != null)
				{
					int oldSize = oldCount * strideof(FastCGIClient);
					FastCGIClient* tmp = new FastCGIClient[oldCount]*;
					Internal.MemCpy(tmp, _clients, oldSize, alignof(FastCGIClient));

					Internal.Free(_clients);

					_clients = (FastCGIClient*)Internal.Malloc(_clientsCount * strideof(FastCGIClient));
					Internal.MemCpy(_clients, tmp, oldSize, alignof(FastCGIClient));
					delete tmp;
				}
				else
				{
					_clients = (FastCGIClient*)Internal.Malloc(_clientsCount * strideof(FastCGIClient));
				}
			}

			FastCGIClient result = new FastCGIClient();
			result.[Friend]_pool = this;
			result.Eventer = _eventer;
			_clients[_clientsAvail] = result;
			_clientsAvail++;
			return result;
		}

		protected void ConnectClients(Object aSender)
		{
			for (int i = 0; i < _clientsAvail; i++)
				if (_clients[i].[Friend]_state == .StartingServer)
					_clients[i].Connect();
		}

		protected void StartServer()
		{
			if (_spawnState == .None)
			{
				_spawnState = .Spawning;
				SpawnFCGIProcess(_appName, _appEnv, _port);
	
				if (_timer == null)
					_timer = new Timer();
	
				_timer.OneShot = true;
				_timer.OnTimer = _connectClients;
			}

			_timer.Interval = TimeSpan(0, 0, 2);
		}
		
		public this()
		{
			_clientsMax = 1;
			_maxRequestsConn = 1;
		}

		public ~this()
		{
			if (_clients != null)
			{
				for (int i = 0; i < _clientsAvail; i++)
					delete _clients[i];
	
				Internal.Free(_clients);
			}

			if (_timer != null)
				delete _timer;
		}

		public FastCGIRequest BeginRequest(uint8 aType)
		{
			FastCGIRequest result = null;

			while (_freeClient != null)
			{
				FastCGIClient tempClient = _freeClient.[Friend]_nextFree;
				result = tempClient.BeginRequest(aType);

				if (result != null)
					break;

				// Result = nil -> no free requesters on next free client
				if (tempClient == _freeClient)
					_freeClient = null;
				else
					_freeClient.[Friend]_nextFree = tempClient.[Friend]_nextFree;

				tempClient.[Friend]_nextFree = null;
			}
			
			// all clients busy
			if (result == null)
				if (_clientsAvail < _clientsMax)
					return CreateClient().BeginRequest(aType);

			return result;
		}

		public void EndRequest(FastCGIClient aClient)
		{
			// TODO: wait for other requests to be completed
			if (aClient.RequestsSent == _maxRequestsConn)
				aClient.Disconnect();

			AddToFreeClients(aClient);
		}

		private int SpawnFCGIProcess(String aApp, String aEnvironment, uint16 aPort)
		{
			return 0;
		}
	}

	public class FastCGIClient : TcpConnection
	{
		protected FastCGIRequest* _requests;
		protected int _requestsCount;
		protected int _nextRequestID;
		protected int _requestsSent;
		protected FastCGIRequest _freeRequest;
		protected FastCGIRequest _sendRequest;
		protected FastCGIRequest _request;
		protected FastCGIClientState _state;
		protected FastCGIClient _nextFree;
		protected FastCGIPool _pool;
		protected char8* _buffer;
		protected char8* _bufferEnd;
		protected char8* _bufferPos;
		protected uint32 _bufferSize;
		protected uint8 _reqType;
		protected int _contentLength;
		protected int _paddingLength;
		
		public uint8 ReqType { get { return _reqType; } }
		public int RequestsSent { get { return _requestsSent; } }

		protected override void ConnectEvent(Handle aSocket)
		{
			if (_state == .StartingServer)
			  _pool.[Friend]_spawnState = .Spawned;

			_state = .Header;

			if (_pool != null)
			  _pool.[Friend]AddToFreeClients(this);

			
			base.ConnectEvent(aSocket);
		}

		protected override void DisconnectEvent(Handle aSocket)
		{
			base.DisconnectEvent(aSocket);

			_requestsSent = 0;
			bool needReconnect = false;

			for (int i = 0; i < _nextRequestID; i++)
			{
				if (_requests[i].[Friend]_nextFree == null)
				{	
					// see if buffer contains request, then assume we can resend that
					if (_requests[i].[Friend]_bufferSendPos > 0)
					{
						needReconnect = true;
						_requests[i].[Friend]_bufferSendPos = 0;
						_requests[i].SendPrivateBuffer();
					}
					else
					{
						if (_requests[i].[Friend]_buffer.Memory == _requests[i].[Friend]_buffer.Pos)
							needReconnect = true;
						else
							_requests[i].[Friend]EndRequest();
					}
				}
			}

			if (needReconnect)
				Connect();
		}

		protected override void ErrorEvent(Handle aSocket, StringView aMsg)
		{
		}

		protected FastCGIRequest CreateRequester()
		{
			return null;
		}

		protected void HandleGetValuesResult()
		{
		}

		protected void HandleReceive(Socket aSocket)
		{
		}

		protected void HandleSend(Socket aSocket)
		{
		}

		protected void ParseBuffer()
		{
		}
		
		public this(): base()
		{
		}
		
		public ~this()
		{
		}

		public void AddToSendQueue(FastCGIRequest aRequest)
		{
		}

		public FastCGIRequest BeginRequest(uint8 aType)
		{
			return null;
		}

		public void EndRequest(FastCGIRequest aRequest)
		{
		}

		public void Flush()
		{
		}

		public int32 GetBuffer(char8* aBuffer, int32 aSize)
		{
			return 0;
		}

		public override bool Connect()
		{
			return false;
		}
	}
}
