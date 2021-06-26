using System;
using System.Net;

namespace Beef_Net.Socket
{
	enum SocketFamily
	{
		Any,
		AnyPreferIPv4,
		AnyPreferIPv6,
		IPv4,
		IPv6
	}

	enum SocketState
	{
		Invalid,
		Opened,
		Bound,
		Connecting,
		SocksConnected,
		Connected,
		Accepting,
		Listening,
		Closed,
		DnsLookup
	}

	enum SocketSendFlags
	{
		Normal,
		Urgent
	}

	enum SocketLingerState
	{
		Off,
		On,
		NotSet
	}

	enum SocketKeepAliveState
	{
		Off,
		On,
		System
	}

#if BF_PLATFORM_WINDOWS
	typealias IPv4Address = int32;
#else
	typealias IPv4Address = uint32;
#endif

	[CRepr]
	struct IPv6Address
	{
		public uint16[8] Nibbles;
	}

#if BF_PLATFORM_WINDOWS
	[CRepr]
	struct WSAData
    {
        public uint16 wVersion;
        public uint16 wHighVersion;
#if BF_64_BIT
        public uint16 iMaxSockets;
        public uint16 iMaxUdpDg;
        public char8* lpVendorInfo;
        public char8[256 + 1] szDescription;
        public char8[128 + 1] szSystemStatus;
#else
        char8[256+1] szDescription;
        char8[128+1] szSystemStatus;
        uint16 iMaxSockets;
        uint16 iMaxUdpDg;
        char8* lpVendorInfo;
#endif
	}
#endif

	static
	{
		public static void SocketStateToString(SocketState state, String outStr)
		{
			switch(state)
			{
			case .Invalid:        outStr.Set("Invalid"); return;
			case .Opened:         outStr.Set("Opened"); return;
			case .Bound:          outStr.Set("Bound"); return;
			case .Connecting:     outStr.Set("Connecting"); return;
			case .SocksConnected: outStr.Set("SocksConnected"); return;
			case .Connected:      outStr.Set("Connected"); return;
			case .Accepting:      outStr.Set("Accepting"); return;
			case .Listening:      outStr.Set("Listening"); return;
			case .Closed:         outStr.Set("Closed"); return;
			case .DnsLookup:      outStr.Set("DnsLookup"); return;
			}
		}

		public static void SocketStateToString(SocketFamily family, String outStr)
		{
			switch(family)
			{
			case .Any:           outStr.Set("Any"); return;
			case .AnyPreferIPv4: outStr.Set("Prefer IPv4"); return;
			case .AnyPreferIPv6: outStr.Set("Prefer IPv6"); return;
			case .IPv4:          outStr.Set("Only IPv4"); return;
			case .IPv6:          outStr.Set("Only IPv6"); return;
			}
		}

		public const int32 INVALID_SOCKET = -1;
		
#if BF_PLATFORM_WINDOWS
		[Import("wsock32.lib"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 WSAStartup(uint16 versionRequired, WSAData* wsaData);
		[Import("wsock32.lib"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 WSACleanup();

		public static Platform.BfpCritSect* GLOBAL_SOCKET_CRIT_SECTION = Platform.BfpCritSect_Create() ~ Platform.BfpCritSect_Release(_);

		public static int32 GLOBAL_SOCKET_COUNT = 0;
#endif
	}

	abstract class BaseSocket
	{
		public const SocketFamily DefaultSocketFamily = .IPv4;
		public const int DefaultSocketTimeout = 12001;

		SocketFamily _socketFamily;
		int32 _socketHandle;
		int32 _acceptedSocket;
		SocketState _state;

		public this()
		{
			_socketHandle = INVALID_SOCKET;
			_socketFamily = DefaultSocketFamily;
			_state = .Closed;
		}

		public ~this()
		{
			if (_state != .Invalid) {
				if (_state != .Closed)
					Close();

#if BF_PLATFORM_WINDOWS
				Platform.BfpCritSect_Enter(GLOBAL_SOCKET_CRIT_SECTION);

				if (--GLOBAL_SOCKET_COUNT <= 0)
					UnloadWinsock();

				Platform.BfpCritSect_Leave(GLOBAL_SOCKET_CRIT_SECTION);
#endif
			}
		}

		public static void Init()
		{
#if BF_PLATFORM_WINDOWS
			WSAData wsaData = default;
			WSAStartup(0x202, &wsaData);
#endif
		}

		public static void UnloadWinsock()
		{
#if BF_PLATFORM_WINDOWS
			Platform.BfpCritSect_Enter(GLOBAL_SOCKET_CRIT_SECTION);
			WSACleanup();
			Platform.BfpCritSect_Leave(GLOBAL_SOCKET_CRIT_SECTION);
#endif
		}

		public void Close()
		{

		}
	}
}
