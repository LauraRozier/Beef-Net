using System;

namespace Beef_Net
{
#if BF_PLATFORM_WINDOWS
	public typealias sa_family_t = uint16;

	[CRepr, Union, Packed]
	public struct in_addr
	{
		public uint32 s_addr;
		public uint8[4] s_bytes;
	}

	[CRepr, Union, Packed]
	public struct in6_addr
	{
		public uint8[16] u6_addr8;
		public uint16[8] u6_addr16;
		public uint32[4] u6_addr32;
		public int8[16] s6_addr8;
		public int8[16] s6_addr;
		public int16[8] s6_addr16;
		public int32[4] s6_addr32;

		public this()
		{
			s6_addr32 = .(0, 0, 0, 0);
		}

		public this(SockAddr aAddr)
		{
			u6_addr8 = .(
				(uint8)(aAddr.sa_family & 0xFFU),
				(uint8)(aAddr.sa_family >> 8),
				aAddr.sa_data[0],
				aAddr.sa_data[1],
				aAddr.sa_data[2],
				aAddr.sa_data[3],
				aAddr.sa_data[4],
				aAddr.sa_data[5],
				aAddr.sa_data[6],
				aAddr.sa_data[7],
				aAddr.sa_data[8],
				aAddr.sa_data[9],
				aAddr.sa_data[10],
				aAddr.sa_data[11],
				aAddr.sa_data[12],
				aAddr.sa_data[13]
			);
		}
	}

	[CRepr, Packed]
	public struct sockaddr_in
	{
		  public sa_family_t sin_family; // Address family
		  public uint16 sin_port;        // Port
		  public in_addr sin_addr;       // IPV6 address
		  public uint8[8] xpad;
	}

	[CRepr, Packed]
	public struct sockaddr_in6
	{
		  public sa_family_t sin6_family; // Address family
		  public uint16 sin6_port;        // Port
		  public uint32 sin6_flowinfo;    // Flow information.
		  public in6_addr sin6_addr;      // IPV6 address
		  public uint32 sin6_scope_id;
	}

	[CRepr]
	public struct AddrInfo
	{
		public int ai_flags;
		public int ai_family;
		public int ai_socktype;
		public int ai_protocol;
		public uint ai_addrlen;
		public char8* ai_canonname;
		public SockAddr* ai_addr;
		public AddrInfo* ai_next;
	}

	[CRepr]
	public struct HostEnt
	{
		public char8* h_name;       // official name of host
		public char8** h_aliases;   // alias list
		public int16 h_addrtype;    // host address type
		public int16 h_length;      // length of address
		public uint8** h_addr_list; // list of addresses
	}

	[CRepr]
	public struct TimeVal
	{
		public int64 tv_sec;  // seconds
		public int64 tv_usec; // and microseconds
	}

	[CRepr]
	public struct WSAData // !!! also WSDATA
	{
	    public uint16 wVersion;
	    public uint16 wHighVersion;
#if BF_64_BIT
	    public uint16 iMaxSockets;
	    public uint16 iMaxUdpDg;
	    public char8* lpVendorInfo;
	    public char8[WinSock2.WSADESCRIPTION_LEN + 1] szDescription;
	    public char8[WinSock2.WSASYS_STATUS_LEN + 1] szSystemStatus;
#else
	    public char8[WinSock2.WSADESCRIPTION_LEN + 1] szDescription;
	    public char8[WinSock2.WSASYS_STATUS_LEN + 1] szSystemStatus;
	    public uint16 iMaxSockets;
	    public uint16 iMaxUdpDg;
	    public char8* lpVendorInfo;
#endif
	}

	public typealias fd_handle = uint32;

	sealed static class WinSock2
	{
		public const int WSADESCRIPTION_LEN = 256;
		public const int WSASYS_STATUS_LEN  = 128;

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int getaddrinfo(char8* nodename, char8* servname, AddrInfo* hints, out AddrInfo* res);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static void freeaddrinfo(AddrInfo* ai);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static HostEnt* gethostbyname(char8* name);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static fd_handle accept(fd_handle s, sockaddr_in* addr, int32* addrlen);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 bind(fd_handle s, sockaddr_in* name, int32 namelen);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 closesocket(fd_handle s);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 connect(fd_handle s, sockaddr_in* name, int32 namelen);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 ioctlsocket(fd_handle s, int32 cmd, uint32* argp);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 getpeername(fd_handle s, sockaddr_in* name, int32* nameLen);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 getsockname(fd_handle s, sockaddr_in* name, int32* nameLen);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 setsockopt(fd_handle s, int32 level, int32 optname, void* optval, int32 optlen);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 getsockopt(fd_handle s, int32 level, int32 optname, void* optval, int32* optlen);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 listen(fd_handle s, int32 backlog);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 recv(fd_handle s, uint8* buf, int32 len, int32 flags);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 recvfrom(fd_handle s, uint8* buf, int32 len, int32 flags, sockaddr_in* fromaddr, int32* fromlen);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 select(int nfds, fd_set* readfds, fd_set* writefds, fd_set* exceptfds, TimeVal* timeout);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 send(fd_handle s, uint8* buf, int32 len, int32 flags);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 sendto(fd_handle s, uint8* buf, int32 len, int32 flags, sockaddr_in* toaddr, int32 tolen);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 shutdown(fd_handle s, int32 how);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static fd_handle socket(int32 af, int32 type, int32 protocol);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 WSAStartup(uint16 wVersionRequired, WSAData* _WSData);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 WSACleanup();

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static bool WSAIsBlocking();

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 WSAUnhookBlockingHook();

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static void* WSASetBlockingHook(void* lpBlockFunc);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 WSACancelBlockingCall();

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 WSAGetLastError();

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		public extern static int32 __WSAFDIsSet(fd_handle aSocket, ref fd_set aFDSet);
	}
#endif
}
