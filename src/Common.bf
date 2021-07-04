using System;
using System.Collections;
using System.Globalization;

namespace Beef_Net
{
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
	public struct SockAddr
	{
		public uint16 sa_family;  // address family
		public uint8[14] sa_data; // up to 14 bytes of direct address
	}

	public struct SocketAddress
	{
		public sa_family_t Family;
		public USockAddr u;

		[Union]
		public struct USockAddr
		{
			public sockaddr_in IPv4;
			public sockaddr_in6 IPv6;
		}
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
	public struct fd_set
	{
		public uint fd_count;                    // how many are SET?
		public uint[Common.FD_SETSIZE] fd_array; // an array of SOCKETs
	}

	public typealias fd_handle = uint32;

	static class Common
	{

		public const int FD_SETSIZE = 64;

		public const int LMSG                 = 0;
		public const fd_handle INVALID_SOCKET = (fd_handle)~0;
		public const int SOCKET_ERROR         = -1;            // WinSock2 SOCKET_ERROR
		public const int SHUT_RDWR            = 0x02;          // SD_BOTH
		public const int SHUT_WR              = 0x01;          // SD_SEND

		// Default Values
		public const int DEFAULT_BACKLOG = 5;
		public const int BUFFER_SIZE     = 262144;

		// Socket Types
		public const uint8 SOCK_STREAM    = 1; // stream socket
		public const uint8 SOCK_DGRAM     = 2; // datagram socket
		public const uint8 SOCK_RAW       = 3; // raw-protocol interface
		public const uint8 SOCK_RDM       = 4; // reliably-delivered message
		public const uint8 SOCK_SEQPACKET = 5; // sequenced packet stream
		
		// Supported address families.
		public const uint16 AF_UNSPEC     = 0;
		public const uint16 AF_UNIX       = 1;      // local to host (pipes, portals
		public const uint16 AF_INET       = 2;      // internetwork: UDP, TCP, etc.
		public const uint16 AF_IMPLINK    = 3;      // arpanet imp addresses
		public const uint16 AF_PUP        = 4;      // pup protocols: e.g. BSP
		public const uint16 AF_CHAOS      = 5;      // mit CHAOS protocols
		public const uint16 AF_NS         = 6;      // XEROX NS protocols
		public const uint16 AF_IPX        = AF_NS;  // IPX protocols: IPX, SPX, etc.
		public const uint16 AF_ISO        = 7;      // ISO protocols
		public const uint16 AF_OSI        = AF_ISO; // OSI is ISO
		public const uint16 AF_ECMA       = 8;      // european computer manufacturers
		public const uint16 AF_DATAKIT    = 9;      // datakit protocols
		public const uint16 AF_CCITT      = 10;     // CCITT protocols, X.25 etc
		public const uint16 AF_SNA        = 11;     // IBM SNA
		public const uint16 AF_DECnet     = 12;     // DECnet
		public const uint16 AF_DLI        = 13;     // Direct data link interface
		public const uint16 AF_LAT        = 14;     // LAT
		public const uint16 AF_HYLINK     = 15;     // NSC Hyperchannel
		public const uint16 AF_APPLETALK  = 16;     // AppleTalk
		public const uint16 AF_NETBIOS    = 17;     // NetBios-style addresses
		public const uint16 AF_VOICEVIEW  = 18;     // VoiceView
		public const uint16 AF_FIREFOX    = 19;     // Protocols from Firefox
		public const uint16 AF_UNKNOWN1   = 20;     // Somebody is using this!
		public const uint16 AF_BAN        = 21;     // Banyan
		public const uint16 AF_ATM        = 22;     // Native ATM Services
		public const uint16 AF_INET6      = 23;     // Internetwork Version 6
		public const uint16 AF_CLUSTER    = 24;     // Microsoft Wolfpack
		public const uint16 AF_12844      = 25;     // IEEE 1284.4 WG AF
		public const uint16 AF_IRDA       = 26;     // IrDA
		public const uint16 AF_NETDES     = 28;     // Network Designers OSI & gateway enabled protocols
		
		public const uint16 AF_TCNPROCESS = 29;
		public const uint16 AF_TCNMESSAGE = 30;
		public const uint16 AF_ICLFXBM    = 31;
		
		public const uint16 AF_BTH        = 32;     // Bluetooth RFCOMM/L2CAP protocols
		public const uint16 AF_LINK       = 33;
		
		public const uint16 AF_MAX        = 34;

		// Protocol families, same as address families.
		public const uint16 PF_UNSPEC    = AF_UNSPEC;
		public const uint16 PF_UNIX      = AF_UNIX;
		public const uint16 PF_INET      = AF_INET;
		public const uint16 PF_IPX       = AF_IPX;
		public const uint16 PF_APPLETALK = AF_APPLETALK;
		public const uint16 PF_INET6     = AF_INET6;
		public const uint16 PF_IMPLINK   = AF_IMPLINK;
		public const uint16 PF_PUP       = AF_PUP;
		public const uint16 PF_CHAOS     = AF_CHAOS;
		public const uint16 PF_NS        = AF_NS;
		public const uint16 PF_ISO       = AF_ISO;
		public const uint16 PF_OSI       = AF_OSI;
		public const uint16 PF_ECMA      = AF_ECMA;
		public const uint16 PF_DATAKIT   = AF_DATAKIT;
		public const uint16 PF_CCITT     = AF_CCITT;
		public const uint16 PF_SNA       = AF_SNA;
		public const uint16 PF_DECnet    = AF_DECnet;
		public const uint16 PF_DLI       = AF_DLI;
		public const uint16 PF_LAT       = AF_LAT;
		public const uint16 PF_HYLINK    = AF_HYLINK;
		public const uint16 PF_VOICEVIEW = AF_VOICEVIEW;
		public const uint16 PF_FIREFOX   = AF_FIREFOX;
		public const uint16 PF_UNKNOWN1  = AF_UNKNOWN1;
		public const uint16 PF_BAN       = AF_BAN;
		public const uint16 PF_ATM       = AF_ATM;
		public const uint16 PF_BTH       = AF_BTH;

		public const uint16 PF_MAX       = AF_MAX;

		// Address constants
		public static readonly String ADDR_ANY  = "0.0.0.0";
		public static readonly String ADDR_BR   = "255.255.255.255";
		public static readonly String ADDR_LO   = "127.0.0.1";
		public static readonly String ADDR6_ANY = "::0";
		public static readonly String ADDR6_LO  = "::1";

		// ICMP
		public const int32 ICMP_ECHOREPLY     = 0;
		public const int32 ICMP_UNREACH       = 3;
		public const int32 ICMP_ECHO          = 8;
		public const int32 ICMP_TIME_EXCEEDED = 11;

		// Protocols
		public const int32 PROTO_IP     = 0;
		public const int32 PROTO_ICMP   = 1;
		public const int32 PROTO_IGMP   = 2;
		public const int32 PROTO_TCP    = 6;
		public const int32 PROTO_UDP    = 17;
		public const int32 PROTO_IPV6   = 41;
		public const int32 PROTO_ICMPV6 = 58;
		public const int32 PROTO_RAW    = 255;
		public const int32 PROTO_MAX    = 256;

		public const uint32 SOL_SOCKET   = 0xFFFFU;

		// Define socket-level options
		public const uint32 SO_DEBUG       = 0x0001U; // turn on debugging info recording
		public const uint32 SO_ACCEPTCONN  = 0x0002U; // socket has had listen()
		public const uint32 SO_REUSEADDR   = 0x0004U; // allow local address reuse
		public const uint32 SO_KEEPALIVE   = 0x0008U; // keep connections alive
		public const uint32 SO_DONTROUTE   = 0x0010U; // just use interface addresses
		public const uint32 SO_BROADCAST   = 0x0020U; // permit sending of broadcast msgs
		public const uint32 SO_USELOOPBACK = 0x0040U; // bypass hardware when possible
		public const uint32 SO_LINGER      = 0x0080U; // linger on close if data present
		public const uint32 SO_OOBINLINE   = 0x0100U; // leave received OOB data in line
		
		public const uint32 SO_DONTLINGER       = (uint32)(~SO_LINGER);
		public const uint32 SO_EXCLUSIVEADDRUSE = (uint32)(~SO_REUSEADDR); // disallow local address reuse

		// Additional options
		public const uint32 SO_SNDBUF    = 0x1001U; // send buffer size
		public const uint32 SO_RCVBUF    = 0x1002U; // receive buffer size
		public const uint32 SO_SNDLOWAT  = 0x1003U; // send low-water mark
		public const uint32 SO_RCVLOWAT  = 0x1004U; // receive low-water mark
		public const uint32 SO_SNDTIMEO  = 0x1005U; // send timeout
		public const uint32 SO_RCVTIMEO  = 0x1006U; // receive timeout
		public const uint32 SO_ERROR     = 0x1007U; // get error status and clear
		public const uint32 SO_TYPE      = 0x1008U; // get socket type
		public const uint32 SO_BSP_STATE = 0x1009U; // get socket 5-tuple state

		// WinSock 2 extension -- new options
		public const uint32 SO_GROUP_ID       = 0x2001U; // ID of a socket group
		public const uint32 SO_GROUP_PRIORITY = 0x2002U; // the relative priority within a group
		public const uint32 SO_MAX_MSG_SIZE   = 0x2003U; // maximum message size
		public const uint32 SO_PROTOCOL_INFOA = 0x2004U; // WSAPROTOCOL_INFOA structure
		public const uint32 SO_PROTOCOL_INFOW = 0x2005U; // WSAPROTOCOL_INFOW structure

#if UNICODE
		public const uint32 SO_PROTOCOL_INFO = SO_PROTOCOL_INFOW;
#else
		public const uint32 SO_PROTOCOL_INFO = SO_PROTOCOL_INFOA;
#endif

		public const uint32 PVD_CONFIG            = 0x3001U; // configuration info for service provider
		public const uint32 SO_CONDITIONAL_ACCEPT = 0x3002U; // enable true conditional accept: connection is not ack-ed to the other side until conditional function returns CF_ACCEPT
		public const uint32 SO_PAUSE_ACCEPT       = 0x3003U;   // pause accepting new connections
		public const uint32 SO_COMPARTMENT_ID     = 0x3004U;   // get/set the compartment for a socket
		public const uint32 SO_RANDOMIZE_PORT     = 0x3005U;   // randomize assignment of wildcard ports
		public const uint32 SO_PORT_SCALABILITY   = 0x3006U;   // enable port scalability

		// Base constant used for defining WSK-specific options.
		public const int WSK_SO_BASE = 0x4000;

		// Options to use with [gs]etsockopt at the PROTO_TCP level.
		public const int TCP_NODELAY = 0x0001;

		public const uint32 FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x100U;
		public const uint32 FORMAT_MESSAGE_IGNORE_INSERTS  = 0x200U;
		public const uint32 FORMAT_MESSAGE_FROM_STRING     = 0x400U;
		public const uint32 FORMAT_MESSAGE_FROM_HMODULE    = 0x800U;
		public const uint32 FORMAT_MESSAGE_FROM_SYSTEM     = 0x1000U;
		public const uint32 FORMAT_MESSAGE_ARGUMENT_ARRAY  = 0x2000U;
		public const uint32 FORMAT_MESSAGE_MAX_WIDTH_MASK  = 255;

		[Import("kernel32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static uint32 FormatMessageA(uint32 dwFlags, void* lpSource, uint32 dwMessageId, uint32 dwLanguageId, char8* lpBuffer, uint32 nSize, void* Arguments);

		[Import("kernel32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static uint32 FormatMessageW(uint32 dwFlags, void* lpSource, uint32 dwMessageId, uint32 dwLanguageId, char16* lpBuffer, uint32 nSize, void* Arguments);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static int getaddrinfo(char8* nodename, char8* servname, AddrInfo* hints, out AddrInfo* res);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static void freeaddrinfo(AddrInfo* ai);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static HostEnt* gethostbyname(char8* name);
		
		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static int32 select(int aNFds, fd_set* aReadFds, fd_set* aWriteFds, fd_set* aExceptFds, TimeVal* timeout);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static int32 getpeername(fd_handle s, SockAddr* aName, int32* aNameLen);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static int32 getsockname(fd_handle s, SockAddr* aName, int32* aNameLen);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static int32 setsockopt(fd_handle s, int32 level, int32 optname, void* optval, int32 optlen);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static int32 getsockopt(fd_handle s, int32 level, int32 optname, void* optval, ref int32 optlen);

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static int32 WSAGetLastError();

		[Import("ws2_32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static int32 __WSAFDIsSet(fd_handle aSocket, ref fd_set aFDSet);

		[Inline]
		public static uint16 bswap_16(uint16 val) =>
			((val >> 8) & 0xFFU) |
			((val & 0xFFU) << 8);

		[Inline]
		public static uint32 bswap_32(uint32 val) =>
			((val & 0xFF000000U) >> 24) |
			((val & 0x00FF0000U) >>  8) |
			((val & 0x0000FF00U) <<  8) |
			((val & 0x000000FFU) << 24);

		[Inline]
		public static uint64 bswap_64(uint64 val) =>
			((val & 0xFF00000000000000UL) >> 56) |
			((val & 0x00FF000000000000UL) >> 40) |
			((val & 0x0000FF0000000000UL) >> 24) |
			((val & 0x000000FF00000000UL) >>  8) |
			((val & 0x00000000FF000000UL) <<  8) |
			((val & 0x0000000000FF0000UL) << 24) |
			((val & 0x000000000000FF00UL) << 40) |
			((val & 0x00000000000000FFUL) << 56);

#if BF_LITTLE_ENDIAN
		public static uint16 htons(uint16 val) =>
			bswap_16(val);

		public static uint32 htonl(uint32 val) =>
			bswap_32(val);

		public static uint16 ntohs(uint16 val) =>
			bswap_16(val);

		public static uint32 ntohl(uint32 val) =>
			bswap_32(val);
#else
		public static uint16 htons(uint16 val) => val;

		public static uint32 htonl(uint32 val) => val;

		public static uint16 ntohs(uint16 val) => val;

		public static uint32 ntohl(uint32 val) => val;
#endif

		public static void GetHostIP(StringView aName, String aOutStr)
		{
			aOutStr.Clear();
			HostEnt* he = null;
			he = gethostbyname(aName.Ptr);

			if (he != null)
				NetAddrToStr(*(in_addr*)he.h_addr_list[0], aOutStr);
		}

		public static void NetAddrToStr(in_addr aEntry, String aOutStr)
		{
			aOutStr.Clear();
			aOutStr.AppendF("{0}.{1}.{2}.{3}", aEntry.s_bytes[0], aEntry.s_bytes[1], aEntry.s_bytes[2], aEntry.s_bytes[3]);
		}

		public static void HostAddrToStr(in_addr aEntry, String aOutStr) =>
			NetAddrToStr(in_addr() { s_addr = htonl(aEntry.s_addr) }, aOutStr);

		public static in_addr StrToHostAddr(StringView aIP)
		{
			in_addr result = .() { s_addr = 0 };
			String tmp = scope .(aIP);
			String dummy = scope .();
			int j;
			Result<uint32, UInt32.ParseError> pres;

			for (int i = 0; i < 4; i++)
			{
				if (i < 3)
				{
					j = tmp.IndexOf('.');

					if (j == 0)
						return result;

					dummy.Set(tmp.Substring(0, j - 1));
					tmp.Remove(0, j);
				}
				else
				{
					dummy.Set(tmp);
				}

				pres = UInt32.Parse(dummy);

				if (pres == .Err)
					return result;

				result.s_bytes[i] = (uint8)pres.Value;
			}

			result.s_addr = ntohl(result.s_addr);
			return result;
		}

		public static in_addr StrToNetAddr(StringView aIP) =>
			.() { s_addr = htonl(StrToHostAddr(aIP).s_addr) };

		public static void HostAddrToStr6(in6_addr aEntry, String aOutStr)
		{
			var aOutStr;

			if (aOutStr == null)
				aOutStr = new .();

			List<uint8> zr1 = new .();
			List<uint8> zr2 = new .();
			uint8 zc1 = 0;
			uint8 zc2 = 0;

			for (uint8 i = 0; i <= 7; i++)
			{
				if (aEntry.u6_addr16[i] == 0)
				{
					zr2.Add(i);
					zc2++;
				}
				else
				{
					if (zc1 < zc2)
					{
						zc1 = zc2;
						delete zr1;
						zr1 = zr2;
						zc2 = 0;
						zr2 = new .();
					}
				}
			}

			if (zc1 < zc2)
			{
				zc1 = zc2;
				zr1 = zr2;
			}

			aOutStr.Clear();
			bool have_skipped = false;
			String tmp = scope .();

			for (uint8 i = 0; i <= 7; i++)
			{
				if (!zr1.Contains(i))
				{
					if (have_skipped)
					{
						if (aOutStr.IsEmpty)
						{
							aOutStr.Set("::");
						}
						else
						{
							aOutStr.Append(':');
						}

						have_skipped = false;
					}

					tmp.Clear();
					ntohs(aEntry.u6_addr16[i]).ToString(tmp, "X", CultureInfo.InvariantCulture);
					aOutStr.AppendF("{0}:", tmp);
				}
				else
				{
					have_skipped = true;
				}
			}

			if (have_skipped)
			{
				if (aOutStr.IsEmpty)
				{
					aOutStr.Set("::");
				}
				else
				{
					aOutStr.Append(':');
				}
			}
			
			if (aOutStr.IsEmpty)
				aOutStr.Set("::");

			if (!zr1.Contains(7))
				aOutStr.RemoveFromEnd(1);
			
			delete zr1;
			delete zr2;
		}

		public static in6_addr StrToHostAddr6(StringView aIP)
		{
			String tmpIp = scope .(aIP);
			in6_addr result = .();
			Internal.MemSet(&result, 0, sizeof(in6_addr));

			// Every 16-bit block is converted at its own and stored into Result. When the '::' zero-spacer is found, its location is stored. Afterwards the
			// address is shifted and zero-filled.
			int index = 0;
			int zeroAt = -1;
			int p = tmpIp.IndexOf(':');
			uint16 w = 0;
			bool failed = false;
			String part = scope .();
			Result<int32, Int32.ParseError> pres;

			while (p > 0 && tmpIp.Length > 0 && index < 8)
			{
				part.Set("0x");
				part.Append(tmpIp.Substring(0, p - 1));
				tmpIp.Remove(0, p);

				if (part.Length > 0) // is there a digit?
				{
					pres = Int32.Parse(part, .HexNumber);

					if (pres == .Err)
					{
						failed = true;
					}
					else
					{
						w = (uint16)pres.Value;
					}
				}
				else
				{
					w = 0;
				}

				result.u6_addr16[index] = htons(w);

				if (failed)
				{	
					Internal.MemSet(&result, 0, sizeof(in6_addr));
					return result;
				}

				if (tmpIp[1] == ':')
				{
					zeroAt = index;
					tmpIp.Remove(0);
				}

				index++;
				p = tmpIp.IndexOf(':');

				if (p == 0)
					p = tmpIp.Length + 1;
			}

			// address      a:b:c::f:g:h
			// Result now   a : b : c : f : g : h : 0 : 0, ZeroAt = 2, Index = 6
			// Result after a : b : c : 0 : 0 : f : g : h
			if (zeroAt >= 0)
			{
				Internal.MemMove(&result.u6_addr16[zeroAt + 1], &result.u6_addr16[(8 - index) + zeroAt + 1], 2 * (index - zeroAt - 1));
				Internal.MemSet(&result.u6_addr16[zeroAt + 1], 0, 2 * (8 - index));
			}
			
			return result;
		}

		public static void NetAddrToStr6(in6_addr aEntry, String aOutStr) =>
			HostAddrToStr6(aEntry, aOutStr);

		public static in6_addr StrToNetAddr6(StringView aIP) =>
			StrToHostAddr6(aIP);

		[Inline]
		public static bool IsIP6Empty(sockaddr_in6 aIP6)
		{
			for (int i = 0; i <= aIP6.sin6_addr.u6_addr32.Count; i++) do
				if (aIP6.sin6_addr.u6_addr32[i] != 0)
					return false;
			
			return true;
		}

		public static void GetHostIP6(StringView aName, String aOutStr)
		{
			aOutStr.Clear();
			AddrInfo h = .();
			AddrInfo* r;

			Internal.MemSet(&h, 0, sizeof(AddrInfo));
			h.ai_family = AF_INET6;
			h.ai_protocol = PF_INET6;
			h.ai_socktype = SOCK_STREAM;
			
			int n = getaddrinfo(aName.Ptr, null, &h, out r);
			
			if (n != 0)
				return;
			
			NetAddrToStr6(.(*r.ai_addr), aOutStr);
			freeaddrinfo(r);
		}

		public static void FillAddressInfo(ref SocketAddress aAddrInfo, sa_family_t aFamily, StringView aAddress, uint16 aPort)
		{
			aAddrInfo.u.IPv4.sin_family = aFamily;
			aAddrInfo.u.IPv4.sin_port = htons(aPort);

			switch (aFamily)
			{
			case Common.AF_INET:
				{
					aAddrInfo.u.IPv4.sin_addr.s_addr = htonl(StrToNetAddr(aAddress).s_addr);

					if (aAddress != Common.ADDR_ANY && aAddrInfo.u.IPv4.sin_addr.s_addr == 0)
					{
						String tmp = scope .();
						GetHostIP(aAddress, tmp);
						aAddrInfo.u.IPv4.sin_addr.s_addr = htonl(StrToNetAddr(tmp).s_addr);
					}
				}
			case Common.AF_INET6:
				{
					
					aAddrInfo.u.IPv6.sin6_addr = StrToNetAddr6(aAddress);

					if (aAddress != Common.ADDR6_ANY && IsIP6Empty(aAddrInfo.u.IPv6))
					{
						String tmp = scope .();
						GetHostIP6(aAddress, tmp);
						aAddrInfo.u.IPv6.sin6_addr = StrToNetAddr6(tmp);
					}
				}
			}
		}

		[Inline]
		public static int fpSelect(int aNFds, fd_set* aReadFds, fd_set* aWriteFds, fd_set* aExceptFds, TimeVal* aTimeout) =>
			select(aNFds, aReadFds, aWriteFds, aExceptFds, aTimeout);

		public static void FD_CLR(fd_handle aFd, ref fd_set aFDSet)
		{
			uint i = 0;

			while (i < aFDSet.fd_count)
			{
				if (aFDSet.fd_array[i] == aFd)
				{
					while (i < aFDSet.fd_count - 1)
					{
						aFDSet.fd_array[i] = aFDSet.fd_array[i + 1];
						i++;
					}

					aFDSet.fd_count = aFDSet.fd_count - 1;
					break;
				}

				i++;
			}
		}

		public static void FD_SET(fd_handle aFd, ref fd_set aFDSet)
		{
			uint i = 0;

			while (i < aFDSet.fd_count)
			{
				if (aFDSet.fd_array[i] == aFd)
					break;

				i++;
			}

			if (i == aFDSet.fd_count)
			{
				if (aFDSet.fd_count < FD_SETSIZE)
				{
					aFDSet.fd_array[i] = aFd;
					aFDSet.fd_count = aFDSet.fd_count + 1;
				}
			}
		}

		public static void FD_ZERO(ref fd_set aFDSet)
		{
			aFDSet.fd_count = 0;
		}

		public static bool FD_ISSET(fd_handle aFd, ref fd_set aFDSet) =>
			__WSAFDIsSet(aFd, ref aFDSet) != 0;

		public static bool SetNoDelay(fd_handle aHandle, bool aValue)
		{
			int opt = aValue ? 1 : 0;
			
			if (SetSockOpt(aHandle, PROTO_TCP, TCP_NODELAY, &opt, sizeof(int)) < 0)
				return false;
		
			return true;
		}

		public static int32 SocketError() =>
			(int32)WSAGetLastError();

		public static void StrError(int32 aErrNum, String aOutStr, bool aIndUseUTF8 = false)
		{
			uint32 MAX_ERROR = 1024;
			String tmp = scope .();
			aOutStr.AppendF(" [{0}]: ", aErrNum);

			if (aIndUseUTF8)
			{
				char16* tmpPtr = scope char16[MAX_ERROR]*;
				FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_ARGUMENT_ARRAY, null, (uint32)aErrNum, 0, &tmpPtr[0], MAX_ERROR, null);
				System.Text.UTF16.Decode(tmpPtr, tmp);
			}
			else
			{
				char8* tmpPtr = scope char8[MAX_ERROR]*;
				int len = FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_ARGUMENT_ARRAY, null, (uint32)aErrNum, 0, &tmpPtr[0], MAX_ERROR, null);
				tmp.Append(tmpPtr, len);
			}

			aOutStr.Append(tmp);
		}

		public static int32 SetSockOpt(fd_handle aHandle, int32 aLevel, int32 aOptName, void* aOptVal, int32 aOptLen) =>
			setsockopt(aHandle, aLevel, aOptName, aOptVal, aOptLen);

		public static int32 GetSockName(fd_handle aHandle, sockaddr_in* aName, int32* aNameLen) =>
			getsockname(aHandle, (SockAddr*)(aName), aNameLen);

		/*
		https://github.com/alrieckert/freepascal/blob/master/packages/rtl-extra/src/inc/sockets.inc
		https://github.com/farshadmohajeri/extpascal/blob/master/SocketsDelphi.pas
		https://students.mimuw.edu.pl/SO/Linux/Kod/include/linux/socket.h.html
		D:\Program Files (x86)\Embarcadero\Studio\20.0\source\rtl\win\Winapi.Winsock2.pas
		*/
	}
}
