using System;
using Beef_Net.Connection;

namespace Beef_Net
{
	public enum SocketState
	{
		ServerSocket = 0x00,
		Blocking = 0x01,
		ReuseAddress = 0x02,
		CanSend = 0x04,
		CanReceive = 0x08,
		SSLActive = 0x10,
		NoDelay = 0x20
	}

	public enum SocketConnectionStatus
	{
		None = 0x0,
		Connecting = 0x1,
		Connected = 0x2,
		Disconnecting = 0x4
	}

	public enum SocketOperation
	{
		Send,
		Receive
	}

	// Callback Event procedure for errors
	public function void SocketErrorEvent(StringView aMsg,  Socket aSocket);

	// Callback Event procedure for others
	public function void SocketEvent(Socket aSocket);

	// Callback Event procedure for progress reports
	public function void SocketProgressEvent(Socket aSocket, int aBytes);

	class Socket : Handle
	{
		protected SocketAddress _address;
		protected SocketAddress _peerAddress;
		protected bool _reuseAddress;
		protected SocketConnectionStatus _connectionStatus;
		protected Socket _nextSock;
		protected Socket _prevSock;
		protected SocketState _socketState;
		protected SocketEvent _onFree;
		protected bool _blocking;
		protected int _listenBacklog;
		protected int _protocol;
		protected int _socketType;
		protected int _socketNet;
		protected Component _creator;
		protected Session _session;
		protected BaseConnection _connection;
    
    	protected int SocketType // inherit and publicize if you need to set this outside
		{
			get { return _socketType; }
			set { _socketType = value; }
		}

		public bool Connected
		{
			get { return _connectionStatus == .Connected; }
		}

		public bool Connecting
		{
			get { return _connectionStatus == .Connecting; }
		}

		public SocketConnectionStatus ConnectionStatus
		{
			get { return _connectionStatus; }
		}

		public int ListenBacklog
		{
			get { return _listenBacklog; }
			set { _listenBacklog = value; }
		}

		public int Protocol
		{
			get { return _protocol; }
			set { _protocol = value; }
		}

		public int SocketNet
		{
			get { return _socketNet; }
			set { _socketNet = value; }
		}

		public uint16 PeerPort
		{
			get {
				return _socketType == Common.SOCK_STREAM
					? Common.ntohs(_address.u.IPv4.sin_port)
					: Common.ntohs(_peerAddress.u.IPv4.sin_port);
			}
		}

		public uint16 LocalPort
		{
			get { return Common.ntohs(_address.u.IPv4.sin_port); }
		}

		public Socket NextSock
		{
			get { return _nextSock; }
			set { _nextSock = value; }
		}

		public Socket PrevSock
		{
			get { return _prevSock; }
			set { _prevSock = value; }
		}

		public SocketState SocketState
		{
			get { return _socketState; }
		}

		public Component Creator
		{
			get { return _creator; }
		}

		public Session Session
		{
			get { return _session; }
		}
		
		protected SockAddr* GetIPAddressPointer()
		{
			switch (_socketNet)
			{
			case Common.AF_INET: return (SockAddr*)&_address.u.IPv4;
			case Common.AF_INET6: return (SockAddr*)&_address.u.IPv6;
			default: Runtime.FatalError("Unknown socket network type (not IPv4 or IPv6)");
			}
		}

		protected int32 GetIPAddressLength()
		{
			switch (_socketNet)
			{
			case Common.AF_INET: return sizeof(sockaddr_in);
			case Common.AF_INET6: return sizeof(sockaddr_in6);
			default: Runtime.FatalError("Unknown socket network type (not IPv4 or IPv6)");
			}
		}
		
		protected virtual bool SetupSocket(uint16 aPort, StringView aAddress)
		{
			/*
var
  Done: Boolean;
  Arg, Opt: Integer;
begin
  Result := false;
  if FConnectionStatus = scNone then begin
    Done := true;
    FHandle := fpSocket(FSocketNet, FSocketType, FProtocol);
    if FHandle = INVALID_SOCKET then
      Exit(Bail('Socket error', LSocketError));
    SetOptions;

    if FSocketType = SOCK_DGRAM then begin
      Arg := 1;
      if fpsetsockopt(FHandle, SOL_SOCKET, SO_BROADCAST, @Arg, Sizeof(Arg)) = SOCKET_ERROR then
        Exit(Bail('SetSockOpt error', LSocketError));
    end;

    if FReuseAddress then begin
      Arg := 1;
      Opt := SO_REUSEADDR;
      {$ifdef WIN32} // I expect 64 has it oddly, so screw them for now
      if (Win32Platform = 2) and (Win32MajorVersion >= 5) then
        Opt := Integer(not Opt);
      {$endif}
      if fpsetsockopt(FHandle, SOL_SOCKET, Opt, @Arg, Sizeof(Arg)) = SOCKET_ERROR then
        Exit(Bail('SetSockOpt error', LSocketError));
    end;

    {$ifdef darwin}
    Arg := 1;
    if fpsetsockopt(FHandle, SOL_SOCKET, SO_NOSIGPIPE, @Arg, Sizeof(Arg)) = SOCKET_ERROR then
      Exit(Bail('SetSockOpt error', LSocketError));
    {$endif}

    FillAddressInfo(FAddress, FSocketNet, Address, aPort);
    FillAddressInfo(FPeerAddress, FSocketNet, LADDR_BR, aPort);

    Result  :=  Done;
  end;
			*/
		}

		protected virtual int DoSend(char8* aData, int aSize)
		{
			/*
var
  AddressLength: Longint = SizeOf(FPeerAddress);
begin
  if FSocketType = SOCK_STREAM then
    Result := Sockets.fpSend(FHandle, @aData, aSize, LMSG)
  else begin
    case FAddress.IPv4.sin_family of
      LAF_INET  :
        begin
          AddressLength := SizeOf(FPeerAddress.IPv4);
          Result := sockets.fpsendto(FHandle, @aData, aSize, LMSG, @FPeerAddress.IPv4, AddressLength);
        end;
      LAF_INET6 :
        begin
          AddressLength := SizeOf(FPeerAddress.IPv6);
          Result := sockets.fpsendto(FHandle, @aData, aSize, LMSG, @FPeerAddress.IPv6, AddressLength);
        end;
    end;
  end;
			*/
		}

		protected virtual int DoGet(char8* aData, int aSize)
		{
			/*
var
  AddressLength: Longint = SizeOf(FPeerAddress);
begin
  if FSocketType = SOCK_STREAM then
    Result := sockets.fpRecv(FHandle, @aData, aSize, LMSG)
  else begin
    case FAddress.IPv4.sin_family of
      LAF_INET  :
        begin
          AddressLength := SizeOf(FPeerAddress.IPv4);
          Result := sockets.fpRecvfrom(FHandle, @aData, aSize, LMSG, @FPeerAddress.IPv4, @AddressLength);
        end;
      LAF_INET6 :
        begin
          AddressLength := SizeOf(FPeerAddress.IPv6);
          Result := sockets.fpRecvfrom(FHandle, @aData, aSize, LMSG, @FPeerAddress.IPv6, @AddressLength);
        end;
    end;
  end;
			*/
		}

		protected virtual int HandleResult(int aResult, SocketOperation aOp)
		{
			/*
const
  GSStr: array[TLSocketOperation] of string = ('Send', 'Get');
var
  LastError: Longint;
begin
  Result := aResult;
  if Result = SOCKET_ERROR then begin
    LastError := LSocketError;
    if IsBlockError(LastError) then case aOp of
      soSend:
         begin
           FSocketState := FSocketState - [ssCanSend];
           IgnoreWrite := False;
         end;
      soReceive:
         begin
           FSocketState := FSocketState - [ssCanReceive];
           IgnoreRead := False;
         end;
    end else if IsNonFatalError(LastError) then
      LogError(GSStr[aOp] + ' error', LastError) // non fatals don't cause disconnect
    else if (aOp = soSend) and IsPipeError(LastError) then begin
      LogError(GSStr[aOp] + ' error', LastError);
      HardDisconnect(True); {$warning check if we need aOp = soSend in the IF, perhaps bad recv is possible?}
    end else
      Bail(GSStr[aOp] + ' error', LastError);

    Result := 0;
  end;
			*/
		}

		public void GetPeerAddress(String aOutStr)
		{
			aOutStr.Clear();
			Common.NetAddrToStr(
				_socketType == Common.SOCK_STREAM
					? _address.u.IPv4.sin_addr
					: _peerAddress.u.IPv4.sin_addr,
				aOutStr
			);
		}

		public void GetLocalAddress(String aOutStr)
		{
			aOutStr.Clear();
			sockaddr_in a = .();
			int32 l = sizeof(sockaddr_in);

			if (Common.GetSockName(_handle, &a, &l) > 0)
				Common.NetAddrToStr(a.sin_addr, aOutStr);
		}

		[Inline]
		protected bool SendPossible()
		{
			/*
  Result := True;
  if FConnectionStatus <> scConnected then
    Exit(LogError('Can''t send when not connected', -1));

  if not (ssCanSend in FSocketState) then begin
    if not Assigned(FConnection)
    or not Assigned(FConnection.FOnCanSend) then
      LogError('Send buffer full, try again later', -1);
    Exit(False);
  end;

  if ssServerSocket in FSocketState then
    Exit(LogError('Can''t send on server socket', -1));
			*/
		}

		[Inline]
		protected bool ReceivePossible() =>
			(SocketConnectionStatus.Connected | SocketConnectionStatus.Disconnecting).HasFlag(_connectionStatus) &&
			_socketState.HasFlag(.CanReceive) && !_socketState.HasFlag(.ServerSocket);

		protected virtual void SetOptions()
		{
			SetBlocking(_blocking);
		}

		protected void SetBlocking(bool aValue)
		{
			/*
  if FHandle >= 0 then // we already set our socket
    if not lCommon.SetBlocking(FHandle, aValue) then
      Bail('Error on SetBlocking', LSocketError)
    else begin
      FBlocking := aValue;
      if aValue then
        FSocketState := FSocketState + [ssBlocking]
      else
        FSocketState := FSocketState - [ssBlocking];
    end;
			*/
		}

		protected void SetReuseAddress(bool aValue)
		{
			/*
  if FConnectionStatus = scNone then begin
    FReuseAddress := aValue;
    if aValue then
      FSocketState := FSocketState + [ssReuseAddress]
    else
      FSocketState := FSocketState - [ssReuseAddress];
  end;
			*/
		}

		protected void SetNoDelay(bool aValue)
		{
			/*
  if FHandle >= 0 then begin // we already set our socket
    if not lCommon.SetNoDelay(FHandle, aValue) then
      Bail('Error on SetNoDelay', LSocketError)
    else begin
      if aValue then
        FSocketState := FSocketState + [ssNoDelay]
      else
        FSocketState := FSocketState - [ssNoDelay];
    end;
  end;
			*/
		}

		protected void HardDisconnect(bool aIndNoShutdown = false)
		{
			/*
var
  NeedsShutdown: Boolean;
begin
  NeedsShutdown := (FConnectionStatus = scConnected) and (FSocketType = SOCK_STREAM)
               and (not (ssServerSocket in FSocketState));
  if NoShutdown then
    NeedsShutdown := False;

  FDispose := True;
  FSocketState := FSocketState + [ssCanSend, ssCanReceive];
  FIgnoreWrite := True;
  if FConnectionStatus in [scConnected, scConnecting, scDisconnecting] then begin
    FConnectionStatus := scNone;
    if NeedsShutdown then
      if fpShutDown(FHandle, SHUT_RDWR) <> 0 then
        LogError('Shutdown error', LSocketError);

    if Assigned(FEventer) then
      FEventer.UnregisterHandle(Self);

    if CloseSocket(FHandle) <> 0 then
      LogError('Closesocket error', LSocketError);
    FHandle := INVALID_SOCKET;
  end;
			*/
		}

		protected void SoftDisconnect()
		{
			/*
  if FConnectionStatus in [scConnected, scConnecting] then begin
    if  (FConnectionStatus = scConnected) and (not (ssServerSocket in FSocketState))
    and (FSocketType = SOCK_STREAM) then begin
      FConnectionStatus := scDisconnecting;
      if fpShutDown(FHandle, SHUT_WR) <> 0 then
        LogError('Shutdown error', LSocketError);
    end else
      HardDisconnect; // UDP or ServerSocket
  end;
			*/
		}

		protected bool Bail(StringView aMsg, int32 aErrNum)
		{
			if (!_dispose)
			{
				Disconnect(true);
				LogError(aMsg, aErrNum);
			}

			return false;
		}

		protected virtual bool LogError(StringView aMsg, int32 aErrNum)
		{
			if (_onError != null)
			{
				String tmp = scope .(aMsg);

				if (aErrNum > 0)
				{
					Common.StrError(aErrNum, tmp);
				}

				_onError(this, tmp);
			}

			return false;
		}

		public this() : base()
		{
			_handle = Common.INVALID_SOCKET;
			_listenBacklog = Common.DEFAULT_BACKLOG;
			_prevSock = null;
			_nextSock = null;
			_socketState = .CanSend;
			_connectionStatus = .None;
			_socketType = Common.SOCK_STREAM;
			_socketNet = Common.AF_INET;
			_protocol = Common.PROTO_TCP;
		}

		public ~this()
		{
			if (_onFree != null)
				_onFree(this);

			if (_eventer != null)
				_eventer.[Friend]InternalUnplugHandle(this);

			Disconnect(true);
		}

		public virtual bool SetState(SocketState aState, bool aIndTurnOn = true)
		{
			/*
  Result := False;

  case aState of
    ssServerSocket      : if TurnOn then
                            FSocketState := FSocketState + [aState]
                          else
                            raise Exception.Create('Can not turn off server socket feature');

    ssBlocking          : SetBlocking(TurnOn);
    ssReuseAddress      : SetReuseAddress(TurnOn);

    ssCanSend,
    ssCanReceive        : if TurnOn then
                            FSocketState := FSocketState + [aState]
                          else
                            FSocketState := FSocketState - [aState];

    ssSSLActive         : raise Exception.Create('Can not turn SSL/TLS on in TLSocket instance');
    ssNoDelay           : SetNoDelay(TurnOn);
  end;

  Result := True;
			*/
		}

		public bool Listen(uint16 aPort, StringView aIntf = Common.ADDR_ANY)
		{
			/*
  Result := False;

  if FConnectionStatus <> scNone then
    Disconnect(True);

  SetupSocket(APort, AIntf);
  if fpBind(FHandle, GetIPAddressPointer, GetIPAddressLength) = SOCKET_ERROR then
    Bail('Error on bind', LSocketError)
  else
    Result := true;
  if (FSocketType = SOCK_STREAM) and Result then
    if fpListen(FHandle, FListenBacklog) = SOCKET_ERROR then
      Result := Bail('Error on Listen', LSocketError)
    else
      Result := true;
			*/
		}

		public bool Accept(fd_handle aSerSock)
		{
			/*
var
  AddressLength: tsocklen;
begin
  Result := false;
  AddressLength := GetIPAddressLength;

  if FConnectionStatus <> scNone then
    Disconnect(True);

  FHandle := fpAccept(sersock, GetIPAddressPointer, @AddressLength);
  if FHandle <> INVALID_SOCKET then begin
    SetOptions;
    FIsAcceptor := True;
    Result := true;
  end else
    Bail('Error on accept', LSocketError);
			*/
		}

		public bool Connect(StringView aAddress, uint16 aPort)
		{
			/*
  Result := False;

  if FConnectionStatus <> scNone then
    Disconnect(True);

  if SetupSocket(APort, Address) then begin
    fpConnect(FHandle, GetIPAddressPointer, GetIPAddressLength);
    FConnectionStatus := scConnecting;
    Result := True;
  end;
			*/
		}

		public virtual int Send(char8* aData, int aSize)
		{
			/*
  Result := 0;

  if aSize = 0 then
    raise Exception.Create('Invalid buffersize 0 in Send');

  if SendPossible then begin
    if aSize <= 0 then begin
      LogError('Send error: Size <= 0', -1);
      Exit(0);
    end;

    Result := HandleResult(DoSend(aData, aSize), soSend);
  end;
			*/
		}

		public int SendMessage(StringView aMsg) =>
			Send(aMsg.Ptr, aMsg.Length);

		public virtual int Get(char8* aData, int aSize)
		{
			/*
  Result := 0;

  if aSize = 0 then
    raise Exception.Create('Invalid buffer size 0 in Get');

  if ReceivePossible then begin
    Result := DoGet(aData, aSize);

    if Result = 0 then
      if FSocketType = SOCK_STREAM then
        Disconnect(True)
      else begin
        Bail('Receive Error [0 on recvfrom with UDP]', 0);
        Exit(0);
      end;

    Result := HandleResult(Result, soReceive);
  end;
			*/
		}

		public int GetMessage(String aOutStr)
		{
			aOutStr.Clear();
			char8* tmpPtr = scope char8[Common.BUFFER_SIZE]*;
			int len = Get(tmpPtr, Common.BUFFER_SIZE);
			aOutStr.Append(tmpPtr, len);
			return aOutStr.Length;
		}

		public virtual void Disconnect(bool aIndForced = false)
		{
			/*
  if FDispose // don't do anything when already invalid
  and (FHandle = INVALID_SOCKET)
  and (FConnectionStatus = scNone) then
    Exit;

  if Forced then
    HardDisconnect
  else
    SoftDisconnect;
			*/
		}
	}
}
