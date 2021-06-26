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

	static
	{
		/// Listening socket file number
		public const uint8 FCGI_LISTENSOCK_FILENO = 0;
		/// Number of bytes in a FCGI_Header.  Future versions of the protocol will not reduce this number.
		public const uint8 FCGI_HEADER_LEN = 8;
		/// Value for version component of FCGI_Header
		public const uint8 FCGI_VERSION_1 = 1;
		/// Values for type component of FCGI_Header
		public const uint8 FCGI_BEGIN_REQUEST = 1;
		public const uint8 FCGI_ABORT_REQUEST = 2;
		public const uint8 FCGI_END_REQUEST = 3;
		public const uint8 FCGI_PARAMS = 4;
		public const uint8 FCGI_STDIN = 5;
		public const uint8 FCGI_STDOUT = 6;
		public const uint8 FCGI_STDERR = 7;
		public const uint8 FCGI_DATA = 8;
		public const uint8 FCGI_GET_VALUES = 9;
		public const uint8 FCGI_GET_VALUES_RESULT = 10;
		public const uint8 FCGI_UNKNOWN_TYPE = 11;
		public const uint8 FCGI_MAXTYPE = FCGI_UNKNOWN_TYPE;
		/// Value for requestId component of FCGI_Header
		public const uint8 FCGI_NULL_REQUEST_ID = 0;
		/// Mask for flags component of FCGI_BeginRequestBody
		public const uint8 FCGI_KEEP_CONN = 1;
		/// Values for role component of FCGI_BeginRequestBody
		public const uint8 FCGI_RESPONDER = 1;
		public const uint8 FCGI_AUTHORIZER = 2;
		public const uint8 FCGI_FILTER = 3;
		/// Values for protocolStatus component of FCGI_EndRequestBody
		public const uint8 FCGI_REQUEST_COMPLETE = 0;
		public const uint8 FCGI_CANT_MPX_CONN = 1;
		public const uint8 FCGI_OVERLOADED = 2;
		public const uint8 FCGI_UNKNOWN_ROLE = 3;
		/// Variable names for FCGI_GET_VALUES / FCGI_GET_VALUES_RESULT records
		public const String FCGI_MAX_CONNS = "FCGI_MAX_CONNS";
		public const String FCGI_MAX_REQS = "FCGI_MAX_REQS";
		public const String FCGI_MPXS_CONNS = "FCGI_MPXS_CONNS";
	}

	class FastCGIRequest
	{
		public function void FastCGIRequestEvent(FastCGIRequest aRequest);

		private struct FastCGIStringSize
		{
			public uint32 Size;
			public char8[4] SizeBuf;
		}

		protected int _id;
		protected FastCGIClient _client = null;
		protected StringBuffer _buffer;
		protected int _bufferSendPos;
		protected FCGI_Header _header;
		protected int _headerPos;
		protected int _contentLength;
		protected char8* _inputBuffer = null;
		protected int _inputSize;
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

		public bool OutputPending
		{
			get { return _outputPending; }
		}

		public bool OutputDone
		{
			get { return _outputDone; }
		}

		public bool StdErrDone
		{
			get { return _stdErrDone; }
		}

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
			case FCGI_STDOUT: DoOutput();
			case FCGI_STDERR: DoStdErr();
			case FCGI_END_REQUEST: EndRequest();
			case FCGI_GET_VALUES_RESULT: _client.HandleGetValuesResult();
			}
		}

		protected void HandleReceiveEnd()
		{
			switch(_client.ReqType)
			{
			case FCGI_STDOUT: _outputDone = true;
			case FCGI_STDERR: _stdErrDone = true;
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

		protected void SetContentLength(int aLength)
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
			StringBuffer.AppendString(ref _buffer, &_header, sizeof(FCGI_Header));
			// no padding needed for empty string
		}

		protected void SendGetValues()
		{
			// management record type has request id 0
			int lastRequestID = _id;
			_id = 0;
			SendParam("FCGI_MAX_REQS", "", FCGI_GET_VALUES);

			// if we're the first connection, ask max. # connections
			if (_client._pool._clientsAvail == 1)
				SendParam("FCGI_MAX_CONNS", "", FCGI_GET_VALUES);

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
			_buffer = StringBuffer.InitStringBuffer(504);
			_header.Version = FCGI_VERSION_1;
			_headerPos = -1;
		}

		public ~this()
		{
			delete _buffer.Memory;
		}

		public void AbortRequest()
		{
			_header.ReqType = FCGI_ABORT_REQUEST;
			SetContentLength(0);
			StringBuffer.AppendString(ref _buffer, &_header, sizeof(FCGI_Header));
			SendPrivateBuffer();
		}

		public int Get(char8* aBuffer, int aSize) =>
			_client.GetBuffer(aBuffer, aSize);

		public void ParseClientBuffer()
		{
			_outputPending = false;

			if ((_client.Iterator != null) && _client.Iterator.IgnoreRead)
			{
				_client.HandleReceive(null);
			}
			else
			{
				_client.ParseBuffer();
			}
		}

		public int SendBuffer()
		{
			// already a queue and we are not first in line ? no use in trying to send then
			if (_client._sendRequest != null && _client._sendRequest != this)
				return 0;

			// header to be sent?
			if (!SendPrivateBuffer())
				return 0;

			// first write request header, then wait for possible disconnect
			if (_bufferSendPos > 0)
				return 0;

			if (_inputBuffer == null)
				return 0;

			int written = _client.Send(*_inputBuffer, _inputSize);
			_inputBuffer += written;
			_inputSize -= written;

			if (_inputSize == 0)
			{
				_inputBuffer = null;
				StringBuffer.AppendString(ref _buffer, &PaddingBuffer[0], _header.PaddingLength);
			}
			else
				_client.AddToSendQueue(this);

			return written;
		}

		public bool SendPrivateBuffer()
		{
			// nothing to send ?
			if (_buffer.Pos - _buffer.Memory == _bufferSendPos)
				return true;

			bool result = false;

			// already a queue and we are not first in line ? no use in trying to send then
			if (_client._sendRequest = null || _client._sendRequest = this)
			{
				int written = _client.Send(_buffer.Memory[_bufferSendPos], _buffer.Pos - _buffer.Memory - _bufferSendPos);
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
			body.Flags = FCGI_KEEP_CONN;
			_header.ReqType = FCGI_BEGIN_REQUEST;
			SetContentLength(sizeof(FCGI_BeginRequestBody));
			StringBuffer.AppendString(ref _buffer, &_header, sizeof(FCGI_Header));
			StringBuffer.AppendString(ref _buffer, &body, sizeof(FCGI_BeginRequestBody));
		}

		public void SendParam(StringView aName, StringView aValue, uint8 aReqType = FCGI_PARAMS)
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
			int totalLen = nameLen.Size + valueLen.Size + aName.Length + aValue.Length;

			if (_header.ReqType == aReqType && _bufferSendPos == 0 && 0 <= _headerPos && _headerPos < _buffer.Pos - _buffer.Memory)
			{
				// undo padding
				_buffer.Pos -= _header.PaddingLength;
				SetContentLength(_contentLength + totalLen);
				Internal.MemMove(&_header, &_buffer.Memory[_headerPos], sizeof(FCGI_Header));
			}
			else
			{
				_header.ReqType = aReqType;
				SetContentLength(totalLen);
				_headerPos = _buffer.Pos - _buffer.Memory;
				StringBuffer.AppendString(ref _buffer, &_header, sizeof(FCGI_Header));
			}

			StringBuffer.AppendString(ref _buffer, &nameLen.SizeBuf[0], nameLen.Size);
			StringBuffer.AppendString(ref _buffer, &valueLen.SizeBuf[0], valueLen.Size);
			StringBuffer.AppendString(ref _buffer, aName);
			StringBuffer.AppendString(ref _buffer, aValue);
			StringBuffer.AppendString(ref _buffer, &PaddingBuffer[0], _header.PaddingLength);
		}

		public int SendInput(char8* aBuffer, int aSize)
		{
			int result;

			// first send current buffer if any
			if (_inputBuffer != null)
			{
				result = SendBuffer();

				if (_inputBuffer != null)
					return result;
			}
			else
				result = 0;

			if (result >= aSize)
				return result;

			if (_inputBuffer == null)
			{
				_inputBuffer = aBuffer + result;
				_inputSize = aSize - result;
				_header.ReqType = FCGI_STDIN;
				SetContentLength(_inputSize);
				StringBuffer.AppendString(ref _buffer, &_header, sizeof(FCGI_Header));
			}

			return result + SendBuffer();
		}

		public void DoneParams() =>
			SendEmptyRec(FCGI_PARAMS);

		public void DoneInput()
		{
			SendEmptyRec(FCGI_STDIN);
			SendPrivateBuffer();
		}
	}

	class FastCGIPool
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

		public enum SpawnState
		{
			None,
			Spawning,
			Spawned
		}

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

		public Timer Timer
		{
			get { return _timer; }
		}

		protected void AddToFreeClients(FastCGIClient aClient)
		{
			if (aClient._nextFree != null)
				return;
			
			if (_freeClient == null)
			{
				_freeClient = aClient;
			}
			else
			{
				aClient._nextFree = _freeClient.FNextFree;
			}

			_freeClient._nextFree = aClient;
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
			result._pool = this;
			result.Eventer = _eventer;
			_clients[_clientsAvail] = result;
			_clientsAvail++;
			return result;
		}

		protected void ConnectClients(Object aSender)
		{
			for (int i = 0; i < _clientsAvail; i++)
				if (_clients[i]._state == .StartingServer)
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
				_timer.OnTimer = => ConnectClients;
			}

			_timer.Interval = 2000;
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
				FastCGIClient tempClient = _freeClient._nextFree;
				result = tempClient.BeginRequest(aType);

				if (result != null)
					break;

				// Result = nil -> no free requesters on next free client
				if (tempClient == _freeClient)
				{
					_freeClient = null;
				}
				else
				{
					_freeClient._nextFree = tempClient._nextFree;
				}

				tempClient._nextFree = null;
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

	class FastCGIClient
	{
	}
}
