using Beef_OpenSSL;
using System;
using System.IO;

namespace Beef_Net
{
	static
	{
		public static Platform.BfpCritSect* CS = Platform.BfpCritSect_Create() ~ Platform.BfpCritSect_Release(_);

		public static EventerType BestEventerType()
		{
#if BF_PLATFORM_LINUX
	#if !FORCE_SELECT
			int32 tmp = EPoll.create(1);

			if (tmp >= 0)
			{
				EPoll.close(tmp);
				return .EpollEventer;
			}
			else
			{
				return .SelectEventer;
			}
	#else
			return .SelectEventer;
	#endif
#else
			return .SelectEventer;
#endif
		}

#if BF_PLATFORM_WINDOWS
		public const uint32 IOCPARM_MASK = (uint32)0x7FU;              // parameters must be < 128 bytes
		public const uint32 IOC_VOID     = (uint32)0x20000000U;        // no parameters
		public const uint32 IOC_OUT      = (uint32)0x40000000U;        // copy out parameters
		public const uint32 IOC_IN       = (uint32)0x80000000U;        // copy in parameters
		public const uint32 IOC_INOUT    = IOC_IN | IOC_OUT;
		// 0x20000000 distinguishes new & old ioctl's

		public const uint32 FIONREAD = IOC_OUT | ((sizeof(uint32) & IOCPARM_MASK) << 16) | (((uint32)'f') << 8) | 127; // get # bytes to read
		public const uint32 FIONBIO  = IOC_IN | ((sizeof(uint32) & IOCPARM_MASK) << 16) | (((uint32)'f') << 8) | 126;  // set/clear non-blocking i/o
		public const uint32 FIOASYNC = IOC_IN | ((sizeof(uint32) & IOCPARM_MASK) << 16) | (((uint32)'f') << 8) | 125;  // set/clear async i/o

		// Socket I/O Controls
		public const uint32 SIOCSHIWAT = (uint32)(IOC_IN | ((sizeof(uint32) & IOCPARM_MASK) << 16) | (((uint32)'s') << 8) | 0); // set high watermark
		public const uint32 SIOCGHIWAT = IOC_OUT | ((sizeof(uint32) & IOCPARM_MASK) << 16) | (((uint32)'s') << 8) | 1;          // get high watermark
		public const uint32 SIOCSLOWAT = (uint32)(IOC_IN | ((sizeof(uint32) & IOCPARM_MASK) << 16) | (((uint32)'s') << 8) | 2); // set low watermark
		public const uint32 SIOCGLOWAT = IOC_OUT | ((sizeof(uint32) & IOCPARM_MASK) << 16) | (((uint32)'s') << 8) | 3;          // get low watermark
		public const uint32 SIOCATMARK = IOC_OUT | ((sizeof(uint32) & IOCPARM_MASK) << 16) | (((uint32)'s') << 8) | 7;          // at oob mark?

		// Protocols
		public const uint16 IPPROTO_IP             = 0;   // dummy for IP
		public const uint16 IPPROTO_HOPOPTS        = 0;   // IPv6 hop-by-hop options
		public const uint16 IPPROTO_ICMP           = 1;   // control message protocol
		public const uint16 IPPROTO_IGMP           = 2;   // internet group management protocol
		public const uint16 IPPROTO_GGP            = 3;   // gateway^2 (deprecated)
		public const uint16 IPPROTO_IPV4           = 4;   // IPv4
		public const uint16 IPPROTO_ST             = 5;
		public const uint16 IPPROTO_TCP            = 6;   // tcp
		public const uint16 IPPROTO_CBT            = 7;
		public const uint16 IPPROTO_EGP            = 8;
		public const uint16 IPPROTO_IGP            = 9;
		public const uint16 IPPROTO_PUP            = 12;  // pup
		public const uint16 IPPROTO_UDP            = 17;  // user datagram protocol
		public const uint16 IPPROTO_IDP            = 22;  // xns idp
		public const uint16 IPPROTO_RDP            = 27;
		public const uint16 IPPROTO_IPV6           = 41;  // IPv6
		public const uint16 IPPROTO_ROUTING        = 43;  // IPv6 routing header
		public const uint16 IPPROTO_FRAGMENT       = 44;  // IPv6 fragmentation header
		public const uint16 IPPROTO_ESP            = 50;  // IPsec ESP header
		public const uint16 IPPROTO_AH             = 51;  // IPsec AH
		public const uint16 IPPROTO_ICMPV6         = 58;  // ICMPv6
		public const uint16 IPPROTO_NONE           = 59;  // IPv6 no next header
		public const uint16 IPPROTO_DSTOPTS        = 60;  // IPv6 destination options
		public const uint16 IPPROTO_ND             = 77;  // UNOFFICIAL net disk proto
		public const uint16 IPPROTO_ICLFXBM        = 78;
		public const uint16 IPPROTO_PIM            = 103;
		public const uint16 IPPROTO_PGM            = 113;
		public const uint16 IPPROTO_L2TP           = 115;
		public const uint16 IPPROTO_SCTP           = 132;

		public const uint16 IPPROTO_RAW            = 255; // raw IP packet
		public const uint16 IPPROTO_MAX            = 256;

		//  These are reserved for internal use by Windows.
		public const uint16 IPPROTO_RESERVED_RAW           = 257;
		public const uint16 IPPROTO_RESERVED_IPSEC         = 258;
		public const uint16 IPPROTO_RESERVED_IPSECOFFLOAD  = 259;
		public const uint16 IPPROTO_RESERVED_MAX           = 260;

		// Port/socket numbers: network standard functions
		public const uint16 IPPORT_TCPMUX         = 1;
		public const uint16 IPPORT_ECHO           = 7;
		public const uint16 IPPORT_DISCARD        = 9;
		public const uint16 IPPORT_SYSTAT         = 11;
		public const uint16 IPPORT_DAYTIME        = 13;
		public const uint16 IPPORT_NETSTAT        = 15;
		public const uint16 IPPORT_QOTD           = 17;
		public const uint16 IPPORT_MSP            = 18;
		public const uint16 IPPORT_CHARGEN        = 19;
		public const uint16 IPPORT_FTP_DATA       = 20;
		public const uint16 IPPORT_FTP            = 21;
		public const uint16 IPPORT_TELNET         = 23;
		public const uint16 IPPORT_SMTP           = 25;
		public const uint16 IPPORT_TIMESERVER     = 37;
		public const uint16 IPPORT_NAMESERVER     = 42;
		public const uint16 IPPORT_WHOIS          = 43;
		public const uint16 IPPORT_MTP            = 57;

		// Port/socket numbers: host specific functions
		public const uint16 IPPORT_TFTP           = 69;
		public const uint16 IPPORT_RJE            = 77;
		public const uint16 IPPORT_FINGER         = 79;
		public const uint16 IPPORT_TTYLINK        = 87;
		public const uint16 IPPORT_SUPDUP         = 95;

		// UNIX TCP sockets
		public const uint16 IPPORT_POP3           = 110;
		public const uint16 IPPORT_NTP            = 123;
		public const uint16 IPPORT_EPMAP          = 135;
		public const uint16 IPPORT_NETBIOS_NS     = 137;
		public const uint16 IPPORT_NETBIOS_DGM    = 138;
		public const uint16 IPPORT_NETBIOS_SSN    = 139;
		public const uint16 IPPORT_IMAP           = 143;
		public const uint16 IPPORT_SNMP           = 161;
		public const uint16 IPPORT_SNMP_TRAP      = 162;
		public const uint16 IPPORT_IMAP3          = 220;
		public const uint16 IPPORT_LDAP           = 389;
		public const uint16 IPPORT_HTTPS          = 443;
		public const uint16 IPPORT_MICROSOFT_DS   = 445;

		public const uint16 IPPORT_EXECSERVER     = 512;
		public const uint16 IPPORT_LOGINSERVER    = 513;
		public const uint16 IPPORT_CMDSERVER      = 514;
		public const uint16 IPPORT_EFSSERVER      = 520;

		// UNIX UDP sockets
		public const uint16 IPPORT_BIFFUDP        = 512;
		public const uint16 IPPORT_WHOSERVER      = 513;
		public const uint16 IPPORT_ROUTESERVER    = 520;
		// 520+1 also used

		// Ports < IPPORT_RESERVED are reserved for privileged processes (e.g. root).
		public const uint16 IPPORT_RESERVED       = 1024;

		public const uint16 IPPORT_REGISTERED_MIN = IPPORT_RESERVED;
		public const uint16 IPPORT_REGISTERED_MAX = 0xBFFF;
		public const uint16 IPPORT_DYNAMIC_MIN    = 0xC000;
		public const uint16 IPPORT_DYNAMIC_MAX    = 0xFFFF;

		// Link numbers
		public const uint32 IMPLINK_IP        = 155;
		public const uint32 IMPLINK_LOWEXPER  = 156;
		public const uint32 IMPLINK_HIGHEXPER = 158;

		public const fd_handle INVALID_SOCKET = (fd_handle)~0;
		public const int32 SOCKET_ERROR       = -1;            // WinSock2 SOCKET_ERROR
		public const int32 FROM_PROTOCOL_INFO = -1;

		public const int32 SHUT_RDWR            = 0x02;          // SD_BOTH
		public const int32 SHUT_WR              = 0x01;          // SD_SEND

		// Default Values
		public const int32 DEFAULT_BACKLOG = 5;
		public const int32 BUFFER_SIZE     = 262144;

		// Socket Types
		public const int8 SOCK_STREAM    = 1; // stream socket
		public const int8 SOCK_DGRAM     = 2; // datagram socket
		public const int8 SOCK_RAW       = 3; // raw-protocol interface
		public const int8 SOCK_RDM       = 4; // reliably-delivered message
		public const int8 SOCK_SEQPACKET = 5; // sequenced packet stream

		// Define socket-level options
		public const int32 SO_DEBUG       = 0x0001; // turn on debugging info recording
		public const int32 SO_ACCEPTCONN  = 0x0002; // socket has had listen()
		public const int32 SO_REUSEADDR   = 0x0004; // allow local address reuse
		public const int32 SO_KEEPALIVE   = 0x0008; // keep connections alive
		public const int32 SO_DONTROUTE   = 0x0010; // just use interface addresses
		public const int32 SO_BROADCAST   = 0x0020; // permit sending of broadcast msgs
		public const int32 SO_USELOOPBACK = 0x0040; // bypass hardware when possible
		public const int32 SO_LINGER      = 0x0080; // linger on close if data present
		public const int32 SO_OOBINLINE   = 0x0100; // leave received OOB data in line

		public const int32 SO_DONTLINGER       = ~SO_LINGER;
		public const int32 SO_EXCLUSIVEADDRUSE = ~SO_REUSEADDR; // disallow local address reuse

		// Additional options
		public const int32 SO_SNDBUF    = 0x1001; // send buffer size
		public const int32 SO_RCVBUF    = 0x1002; // receive buffer size
		public const int32 SO_SNDLOWAT  = 0x1003; // send low-water mark
		public const int32 SO_RCVLOWAT  = 0x1004; // receive low-water mark
		public const int32 SO_SNDTIMEO  = 0x1005; // send timeout
		public const int32 SO_RCVTIMEO  = 0x1006; // receive timeout
		public const int32 SO_ERROR     = 0x1007; // get error status and clear
		public const int32 SO_TYPE      = 0x1008; // get socket type
		public const int32 SO_BSP_STATE = 0x1009; // get socket 5-tuple state

		// WinSock 2 extension -- new options
		public const int32 SO_GROUP_ID       = 0x2001; // ID of a socket group
		public const int32 SO_GROUP_PRIORITY = 0x2002; // the relative priority within a group
		public const int32 SO_MAX_MSG_SIZE   = 0x2003; // maximum message size
		public const int32 SO_PROTOCOL_INFOA = 0x2004; // WSAPROTOCOL_INFOA structure
		public const int32 SO_PROTOCOL_INFOW = 0x2005; // WSAPROTOCOL_INFOW structure

	#if UNICODE
		public const int32 SO_PROTOCOL_INFO = SO_PROTOCOL_INFOW;
	#else
		public const int32 SO_PROTOCOL_INFO = SO_PROTOCOL_INFOA;
	#endif

		public const int32 PVD_CONFIG            = 0x3001; // configuration info for service provider
		public const int32 SO_CONDITIONAL_ACCEPT = 0x3002; // enable true conditional accept: connection is not ack-ed to the other side until conditional function returns CF_ACCEPT
		public const int32 SO_PAUSE_ACCEPT       = 0x3003; // pause accepting new connections
		public const int32 SO_COMPARTMENT_ID     = 0x3004; // get/set the compartment for a socket
		public const int32 SO_RANDOMIZE_PORT     = 0x3005; // randomize assignment of wildcard ports
		public const int32 SO_PORT_SCALABILITY   = 0x3006; // enable port scalability

		// Base constant used for defining WSK-specific options.
		public const uint32 WSK_SO_BASE = 0x4000U;

		// Options to use with [gs]etsockopt at the PROTO_TCP level.
		public const uint32 TCP_NODELAY = 0x0001U;

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

		// Desired design of maximum size and alignment. These are implementation specific.
		public const uint8 _SS_MAXSIZE   = 128;           // Maximum size.
		public const uint8 _SS_ALIGNSIZE = sizeof(int64); // Desired alignment.

		// Definitions used for sockaddr_storage structure paddings design.
		public const uint8 _SS_PAD1SIZE = _SS_ALIGNSIZE - sizeof(int16);
		public const uint8 _SS_PAD2SIZE = _SS_MAXSIZE - (sizeof(int16) + _SS_PAD1SIZE + _SS_ALIGNSIZE);

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

		// Define a level for socket I/O controls in the same numbering space as IPPROTO_TCP, IPPROTO_IP, etc.
		public const uint32 SOL_SOCKET  = 0xFFFFU;

		// Maximum queue length specifiable by listen.
		public const uint32 SOMAXCONN   = 0x7FFFFFFFU;
		

		public const int32 MSG           = 0x0;
		public const int32 MSG_OOB       = 0x1; // process out-of-band data
		public const int32 MSG_PEEK      = 0x2; // peek at incoming message
		public const int32 MSG_DONTROUTE = 0x4; // send without using routing tables
		public const int32 MSG_WAITALL   = 0x8; // do not complete until packet is completely filled

		public const int32 MSG_PARTIAL   = 0x8000; // partial send or recv for message xport

		// WinSock 2 extension -- new flags for WSASend(), WSASendTo(), WSARecv() and WSARecvFrom()
		public const int32 MSG_INTERRUPT = 0x10; // send/recv in the interrupt context

		public const int32 MSG_MAXIOVLEN = 16;

		// Define constant based on rfc883, used by gethostbyxxxx() calls.
		public const uint32 MAXGETHOSTSTRUCT = 1024;

		// WinSock 2 extension -- bit values and indices for FD_XXX network events
		// "64 sockets ought to be enough for anybody"
		public const int32 FD_SETSIZE =   1024; //      ...except me!

		public const int32 FD_READ_BIT                     = 0;
		public const int32 FD_READ                         = 1 << FD_READ_BIT;

		public const int32 FD_WRITE_BIT                    = 1;
		public const int32 FD_WRITE                        = 1 << FD_WRITE_BIT;

		public const int32 FD_OOB_BIT                      = 2;
		public const int32 FD_OOB                          = 1 << FD_OOB_BIT;

		public const int32 FD_ACCEPT_BIT                   = 3;
		public const int32 FD_ACCEPT                       = 1 << FD_ACCEPT_BIT;

		public const int32 FD_CONNECT_BIT                  = 4;
		public const int32 FD_CONNECT                      = 1 << FD_CONNECT_BIT;

		public const int32 FD_CLOSE_BIT                    = 5;
		public const int32 FD_CLOSE                        = 1 << FD_CLOSE_BIT;

		public const int32 FD_QOS_BIT                      = 6;
		public const int32 FD_QOS                          = 1 << FD_QOS_BIT;

		public const int32 FD_GROUP_QOS_BIT                = 7;
		public const int32 FD_GROUP_QOS                    = 1 << FD_GROUP_QOS_BIT;

		public const int32 FD_ROUTING_INTERFACE_CHANGE_BIT = 8;
		public const int32 FD_ROUTING_INTERFACE_CHANGE     = 1 << FD_ROUTING_INTERFACE_CHANGE_BIT;

		public const int32 FD_ADDRESS_LIST_CHANGE_BIT      = 9;
		public const int32 FD_ADDRESS_LIST_CHANGE          = 1 << FD_ADDRESS_LIST_CHANGE_BIT;

		public const int32 FD_MAX_EVENTS                   = 10;
		public const int32 FD_ALL_EVENTS                   = (1 << FD_MAX_EVENTS) - 1;

		// All Windows Sockets error constants are biased by WSABASEERR from the "normal"
		public const int32 WSABASEERR = 10000;

		// Windows Sockets definitions of regular Microsoft C error constants
		public const int32 WSAEINTR  = WSABASEERR + 4;
		public const int32 WSAEBADF  = WSABASEERR + 9;
		public const int32 WSAEACCES = WSABASEERR + 13;
		public const int32 WSAEFAULT = WSABASEERR + 14;
		public const int32 WSAEINVAL = WSABASEERR + 22;
		public const int32 WSAEMFILE = WSABASEERR + 24;

		// Windows Sockets definitions of regular Berkeley error constants
		public const int32 WSAEWOULDBLOCK     = WSABASEERR + 35;
		public const int32 WSAEINPROGRESS     = WSABASEERR + 36;
		public const int32 WSAEALREADY        = WSABASEERR + 37;
		public const int32 WSAENOTSOCK        = WSABASEERR + 38;
		public const int32 WSAEDESTADDRREQ    = WSABASEERR + 39;
		public const int32 WSAEMSGSIZE        = WSABASEERR + 40;
		public const int32 WSAEPROTOTYPE      = WSABASEERR + 41;
		public const int32 WSAENOPROTOOPT     = WSABASEERR + 42;
		public const int32 WSAEPROTONOSUPPORT = WSABASEERR + 43;
		public const int32 WSAESOCKTNOSUPPORT = WSABASEERR + 44;
		public const int32 WSAEOPNOTSUPP      = WSABASEERR + 45;
		public const int32 WSAEPFNOSUPPORT    = WSABASEERR + 46;
		public const int32 WSAEAFNOSUPPORT    = WSABASEERR + 47;
		public const int32 WSAEADDRINUSE      = WSABASEERR + 48;
		public const int32 WSAEADDRNOTAVAIL   = WSABASEERR + 49;
		public const int32 WSAENETDOWN        = WSABASEERR + 50;
		public const int32 WSAENETUNREACH     = WSABASEERR + 51;
		public const int32 WSAENETRESET       = WSABASEERR + 52;
		public const int32 WSAECONNABORTED    = WSABASEERR + 53;
		public const int32 WSAECONNRESET      = WSABASEERR + 54;
		public const int32 WSAENOBUFS         = WSABASEERR + 55;
		public const int32 WSAEISCONN         = WSABASEERR + 56;
		public const int32 WSAENOTCONN        = WSABASEERR + 57;
		public const int32 WSAESHUTDOWN       = WSABASEERR + 58;
		public const int32 WSAETOOMANYREFS    = WSABASEERR + 59;
		public const int32 WSAETIMEDOUT       = WSABASEERR + 60;
		public const int32 WSAECONNREFUSED    = WSABASEERR + 61;
		public const int32 WSAELOOP           = WSABASEERR + 62;
		public const int32 WSAENAMETOOLONG    = WSABASEERR + 63;
		public const int32 WSAEHOSTDOWN       = WSABASEERR + 64;
		public const int32 WSAEHOSTUNREACH    = WSABASEERR + 65;
		public const int32 WSAENOTEMPTY       = WSABASEERR + 66;
		public const int32 WSAEPROCLIM        = WSABASEERR + 67;
		public const int32 WSAEUSERS          = WSABASEERR + 68;
		public const int32 WSAEDQUOT          = WSABASEERR + 69;
		public const int32 WSAESTALE          = WSABASEERR + 70;
		public const int32 WSAEREMOTE         = WSABASEERR + 71;

		// Extended Windows Sockets error constant definitions
		public const int32 WSASYSNOTREADY         = WSABASEERR + 91;
		public const int32 WSAVERNOTSUPPORTED     = WSABASEERR + 92;
		public const int32 WSANOTINITIALISED      = WSABASEERR + 93;
		public const int32 WSAEDISCON             = WSABASEERR + 101;
		public const int32 WSAENOMORE             = WSABASEERR + 102;
		public const int32 WSAECANCELLED          = WSABASEERR + 103;
		public const int32 WSAEINVALIDPROCTABLE   = WSABASEERR + 104;
		public const int32 WSAEINVALIDPROVIDER    = WSABASEERR + 105;
		public const int32 WSAEPROVIDERFAILEDINIT = WSABASEERR + 106;
		public const int32 WSASYSCALLFAILURE      = WSABASEERR + 107;
		public const int32 WSASERVICE_NOT_FOUND   = WSABASEERR + 108;
		public const int32 WSATYPE_NOT_FOUND      = WSABASEERR + 109;
		public const int32 WSA_E_NO_MORE          = WSABASEERR + 110;
		public const int32 WSA_E_CANCELLED        = WSABASEERR + 111;
		public const int32 WSAEREFUSED            = WSABASEERR + 112;

		// Error return codes from gethostbyname() and gethostbyaddr() (when using the resolver).  Note that these errors are retrieved via WSAGetLastError() and must therefore follow
		// the rules for avoiding clashes with error numbers from specific implementations or language run-time systems.  For this reason the codes are based at WSABASEERR+1001.
		// Note also that [WSA]NO_ADDRESS is defined only for compatibility purposes.

		// Authoritative Answer: Host not found
		public const int32 WSAHOST_NOT_FOUND = WSABASEERR + 1001;

		// Non-Authoritative: Host not found, or SERVERFAIL
		public const int32 WSATRY_AGAIN      = WSABASEERR + 1002;

		// Non-recoverable errors, FORMERR, REFUSED, NOTIMP
		public const int32 WSANO_RECOVERY    = WSABASEERR + 1003;

		// Valid name, no data record of requested type
		public const int32 WSANO_DATA        = WSABASEERR + 1004;

		// Define QOS related error return codes
		public const int32 WSA_QOS_RECEIVERS          = WSABASEERR + 1005; // at least one Reserve has arrived
		public const int32 WSA_QOS_SENDERS            = WSABASEERR + 1006; // at least one Path has arrived
		public const int32 WSA_QOS_NO_SENDERS         = WSABASEERR + 1007; // there are no senders
		public const int32 WSA_QOS_NO_RECEIVERS       = WSABASEERR + 1008; // there are no receivers
		public const int32 WSA_QOS_REQUEST_CONFIRMED  = WSABASEERR + 1009; // Reserve has been confirmed
		public const int32 WSA_QOS_ADMISSION_FAILURE  = WSABASEERR + 1010; // error due to lack of resources
		public const int32 WSA_QOS_POLICY_FAILURE     = WSABASEERR + 1011; // rejected for administrative reasons - bad credentials
		public const int32 WSA_QOS_BAD_STYLE          = WSABASEERR + 1012; // unknown or conflicting style
		public const int32 WSA_QOS_BAD_OBJECT         = WSABASEERR + 1013; // problem with some part of the filterspec or providerspecific buffer in general
		public const int32 WSA_QOS_TRAFFIC_CTRL_ERROR = WSABASEERR + 1014; // problem with some part of the flowspec
		public const int32 WSA_QOS_GENERIC_ERROR      = WSABASEERR + 1015; // general error
		public const int32 WSA_QOS_ESERVICETYPE       = WSABASEERR + 1016; // invalid service type in flowspec
		public const int32 WSA_QOS_EFLOWSPEC          = WSABASEERR + 1017; // invalid flowspec
		public const int32 WSA_QOS_EPROVSPECBUF       = WSABASEERR + 1018; // invalid provider specific buffer
		public const int32 WSA_QOS_EFILTERSTYLE       = WSABASEERR + 1019; // invalid filter style
		public const int32 WSA_QOS_EFILTERTYPE        = WSABASEERR + 1020; // invalid filter type
		public const int32 WSA_QOS_EFILTERCOUNT       = WSABASEERR + 1021; // incorrect number of filters
		public const int32 WSA_QOS_EOBJLENGTH         = WSABASEERR + 1022; // invalid object length
		public const int32 WSA_QOS_EFLOWCOUNT         = WSABASEERR + 1023; // incorrect number of flows
		public const int32 WSA_QOS_EUNKOWNPSOBJ       = WSABASEERR + 1024; // unknown object in provider specific buffer
		public const int32 WSA_QOS_EPOLICYOBJ         = WSABASEERR + 1025; // invalid policy object in provider specific buffer
		public const int32 WSA_QOS_EFLOWDESC          = WSABASEERR + 1026; // invalid flow descriptor in the list
		public const int32 WSA_QOS_EPSFLOWSPEC        = WSABASEERR + 1027; // inconsistent flow spec in provider specific buffer
		public const int32 WSA_QOS_EPSFILTERSPEC      = WSABASEERR + 1028; // invalid filter spec in provider specific buffer
		public const int32 WSA_QOS_ESDMODEOBJ         = WSABASEERR + 1029; // invalid shape discard mode object in provider specific buffer
		public const int32 WSA_QOS_ESHAPERATEOBJ      = WSABASEERR + 1030; // invalid shaping rate object in provider specific buffer
		public const int32 WSA_QOS_RESERVED_PETYPE    = WSABASEERR + 1031; // reserved policy element in provider specific buffer

		// Compatibility
		public const int32 HOST_NOT_FOUND = WSAHOST_NOT_FOUND;
		public const int32 TRY_AGAIN      = WSATRY_AGAIN;
		public const int32 NO_RECOVERY    = WSANO_RECOVERY;
		public const int32 NO_DATA        = WSANO_DATA;

		// no address, look for MX record
		public const int32 WSANO_ADDRESS = WSANO_DATA;
		public const int32 NO_ADDRESS    = WSANO_ADDRESS;

		// WinSock 2 extension -- new error codes and type definition
		public const uint32 WSA_IO_PENDING        = 997; // ERROR_IO_PENDING;
		public const uint32 WSA_IO_INCOMPLETE     = 996; // ERROR_IO_INCOMPLETE;
		public const uint32 WSA_INVALID_HANDLE    = 6;   // ERROR_INVALID_HANDLE;
		public const uint32 WSA_INVALID_PARAMETER = 87;  // ERROR_INVALID_PARAMETER;
		public const uint32 WSA_NOT_ENOUGH_MEMORY = 8;   // ERROR_NOT_ENOUGH_MEMORY;
		public const uint32 WSA_OPERATION_ABORTED = 995; // ERROR_OPERATION_ABORTED;

		public const uint32 WSA_INVALID_EVENT       = 0x0;         // WSAEVENT(nil);
		public const uint32 WSA_MAXIMUM_WAIT_EVENTS = 64;          // MAXIMUM_WAIT_OBJECTS;
		public const uint32 WSA_WAIT_FAILED         = 0xFFFFFFFFU; // WAIT_FAILED;
		public const uint32 WSA_WAIT_EVENT_0        = 0x00000000U; // WAIT_OBJECT_0;
		public const uint32 WSA_WAIT_IO_COMPLETION  = 0x000000C0U; // WAIT_IO_COMPLETION;
		public const uint32 WSA_WAIT_TIMEOUT        = 0x00000102U; // WAIT_TIMEOUT;
		public const uint32 WSA_INFINITE            = 0xFFFFFFFFU; // INFINITE;

		// WinSock 2 extension -- manifest constants for return values of the condition function
		public const uint32 CF_ACCEPT = 0x0000;
		public const uint32 CF_REJECT = 0x0001;
		public const uint32 CF_DEFER  = 0x0002;

		// WinSock 2 extension -- manifest constants for shutdown()
		public const uint16 SD_RECEIVE = 0x00;
		public const uint16 SD_SEND = 0x01;
		public const uint16 SD_BOTH  = 0x02;

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

		[Inline]
		public static uint32 _IO(uint32 x, uint32 y) =>
			IOC_VOID | (x << 8) | y;

		[Inline]
		public static uint32 _IOR(uint32 x, uint32 y, uint32 t) =>
			IOC_OUT | ((t & IOCPARM_MASK) << 16) | (x << 8) | y;

		[Inline]
		public static uint32 _IOW(uint32 x, uint32 y, uint32 t) =>
			(uint32)(IOC_IN | ((t & IOCPARM_MASK) << 16) | (x << 8) | y);

		[Inline]
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

					aFDSet.fd_count--;
					break;
				}

				i++;
			}
		}

		[Inline]
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

		/*
		// lws2override.pp version... Wut?
		public static void FD_SET(fd_handle aFd, ref fd_set aFDSet)
		{
			if (aFDSet.fd_count < FD_SETSIZE)
			{
				aFDSet.fd_array[aFDSet.fd_count] = aFd;
				aFDSet.fd_count++;
			}
		}
		*/

		[Inline]
		public static void FD_ZERO(ref fd_set aFDSet) =>
			aFDSet.fd_count = 0;

		[Inline]
		public static bool FD_ISSET(fd_handle aFd, ref fd_set aFDSet) =>
			WinSock2.__WSAFDIsSet(aFd, ref aFDSet) != 0;
#elif BF_PLATFORM_LINUX
		[Inline]
		public static void FD_CLR(fd_handle aFd, ref fd_set aFDSet)
		{
		}

		[Inline]
		public static void FD_SET(fd_handle aFd, ref fd_set aFDSet)
		{
		}

		[Inline]
		public static void FD_ZERO(ref fd_set aFDSet)
		{
		}

		[Inline]
		public static bool FD_ISSET(fd_handle aFd, ref fd_set aFDSet) =>
			false;
#endif // !BF_PLATFORM_WINDOWS

		[Inline]
		public static bool IsSSLBlockError(int32 errNum) =>
			(errNum == SSL.ERROR_WANT_READ || errNum == SSL.ERROR_WANT_WRITE);
		
		[Inline]
		public static bool IsSSLNonFatalError(int32 errNum, int32 aRet)
		{
			bool result = false;
			int32 tmp;

			if (errNum == SSL.ERROR_SYSCALL)
				repeat
				{
					tmp = (int32)Error.get_error();

					if (tmp == 0) // we need to check the ret
					{
						if (aRet <= 0) // EOF or BIO crap, we skip those
							return result;

						result = Common.IsNonFatalError(aRet);
					}
					else  // check what exactly
					{
						return Common.IsNonFatalError(tmp);
					}
				} while(tmp > 0); // we need to empty the queue

			return result;
		}

		public static void GetSSLErrorStr(int errNum, String aOutStr)
		{
			var errNum;
			aOutStr.Clear();
			char8* buf = scope .[2048]*;
			
			repeat
			{
				Error.error_string_n((uint)errNum, buf, 2048 * sizeof(char8));
				aOutStr.Append(buf);
				aOutStr.Append(Environment.NewLine);
				errNum = (int)Error.get_error();
			} while(errNum != 0);
		}
		
		public static BIO.bio_st* errbio;
		public static BIO.bio_st* outbio;
		public static BIO.bio_st* inbio;

		public static void Beef_Net_Init()
		{
#if BF_PLATFORM_WINDOWS
			WSAData dump = .();
			WinSock2.WSAStartup(0x101, &dump);
#endif

			/*
			// The old, obsolete way
			SSL.library_init();
			SSL.load_error_strings();
			*/
			// OpenSSL.init();
			OpenSSL.add_all_algorithms();
			BIO.ERR_load_BIO_strings();
			Crypto.ERR_load_CRYPTO_strings();
			SSL.load_error_strings();

			errbio = BIO.new_fp(((FileStream)Console.Error.[Friend]mStream).[Friend]mBfpFile, BIO.NOCLOSE);
			outbio = BIO.new_fp(((FileStream)Console.Out.[Friend]mStream).[Friend]mBfpFile, BIO.NOCLOSE);
			inbio = BIO.new_fp(((FileStream)Console.In.[Friend]mStream).[Friend]mBfpFile, BIO.NOCLOSE);
			BIO.printf(outbio, OpenSSL.init_ssl(0, null) < 0 ? "Could not initialize the OpenSSL library !\n" : "OpenSSL library initialized!\n");
		}

		public static void Beef_Net_Cleanup()
		{
			/*
			// The old, obsolete way
			EVP.cleanup();
			Crypto.cleanup_all_ex_data();
			Error.remove_state(0);
			*/
			BIO.free(inbio);
			BIO.free(outbio);
			BIO.free(errbio);
			OpenSSL.cleanup();

#if BF_PLATFORM_WINDOWS
			WinSock2.WSACleanup();
#endif
		}
	}
}
