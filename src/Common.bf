using System;
using System.Collections;
using System.Globalization;

namespace Beef_Net
{
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
	public struct fd_set
	{
		public uint fd_count;             // how many are SET?
#if BF_PLATFORM_WINDOWS
		public uint[FD_SETSIZE] fd_array; // an array of SOCKETs
#endif
	}

	static class Common
	{
		public const uint32 FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x100U;
		public const uint32 FORMAT_MESSAGE_IGNORE_INSERTS  = 0x200U;
		public const uint32 FORMAT_MESSAGE_FROM_STRING     = 0x400U;
		public const uint32 FORMAT_MESSAGE_FROM_HMODULE    = 0x800U;
		public const uint32 FORMAT_MESSAGE_FROM_SYSTEM     = 0x1000U;
		public const uint32 FORMAT_MESSAGE_ARGUMENT_ARRAY  = 0x2000U;
		public const uint32 FORMAT_MESSAGE_MAX_WIDTH_MASK  = 255;

#if BF_PLATFORM_WINDOWS
		[Import("kernel32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static uint32 FormatMessageA(uint32 dwFlags, void* lpSource, uint32 dwMessageId, uint32 dwLanguageId, char8* lpBuffer, uint32 nSize, void* Arguments);

		[Import("kernel32.dll"), CLink, CallingConvention(.Stdcall)]
		private extern static uint32 FormatMessageW(uint32 dwFlags, void* lpSource, uint32 dwMessageId, uint32 dwLanguageId, char16* lpBuffer, uint32 nSize, void* Arguments);
#endif

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
#if BF_PLATFORM_WINDOWS
			HostEnt* he = null;
			he = WinSock2.gethostbyname(aName.Ptr);

			if (he != null)
				NetAddrToStr(*(in_addr*)he.h_addr_list[0], aOutStr);
#endif
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

			for (int i = 0; i < 4; i++)
			{
				if (i < 3)
				{
					j = tmp.IndexOf('.');

					if (j == 0)
						return result;

					dummy.Set(tmp.Substring(0, j));
					tmp.Remove(0, j + 1);
				}
				else
				{
					dummy.Set(tmp);
				}

				if (UInt32.Parse(dummy) case .Ok(let val))
					result.s_bytes[i] = (uint8)val;
				else
					return result;
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
							aOutStr.Set("::");
						else
							aOutStr.Append(':');

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
					aOutStr.Set("::");
				else
					aOutStr.Append(':');
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

			while (p > 0 && tmpIp.Length > 0 && index < 8)
			{
				part.Set("0x");
				part.Append(tmpIp.Substring(0, p - 1));
				tmpIp.Remove(0, p);

				if (part.Length > 0) // is there a digit?
				{
					if (Int32.Parse(part, .HexNumber) case .Ok(let val))
						w = (uint16)val;
					else
						failed = true;
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

#if BF_PLATFORM_WINDOWS
			int n = WinSock2.getaddrinfo(aName.Ptr, null, &h, out r);
#endif
			
			if (n != 0)
				return;

			NetAddrToStr6(.(*r.ai_addr), aOutStr);
#if BF_PLATFORM_WINDOWS
			WinSock2.freeaddrinfo(r);
#endif
		}

		public static void FillAddressInfo(ref SocketAddress aAddrInfo, sa_family_t aFamily, StringView aAddress, uint16 aPort)
		{
			aAddrInfo.u.IPv4.sin_family = aFamily;
			aAddrInfo.u.IPv4.sin_port = htons(aPort);

			switch (aFamily)
			{
			case AF_INET:
				{
					aAddrInfo.u.IPv4.sin_addr.s_addr = StrToNetAddr(aAddress).s_addr;

					if (aAddress != ADDR_ANY && aAddrInfo.u.IPv4.sin_addr.s_addr == 0)
					{
						String tmp = scope .();
						GetHostIP(aAddress, tmp);
						aAddrInfo.u.IPv4.sin_addr.s_addr = StrToNetAddr(tmp).s_addr;
					}
				}
			case AF_INET6:
				{
					
					aAddrInfo.u.IPv6.sin6_addr = StrToNetAddr6(aAddress);

					if (aAddress != ADDR6_ANY && IsIP6Empty(aAddrInfo.u.IPv6))
					{
						String tmp = scope .();
						GetHostIP6(aAddress, tmp);
						aAddrInfo.u.IPv6.sin6_addr = StrToNetAddr6(tmp);
					}
				}
			}
		}

		public static bool SetNoDelay(fd_handle aHandle, bool aValue)
		{
			uint32 opt = aValue ? 1 : 0;
			
			if (SetSockOpt(aHandle, PROTO_TCP, TCP_NODELAY, &opt, sizeof(int)) < 0)
				return false;
		
			return true;
		}

		public static bool SetBlocking(fd_handle aHandle, bool aValue)
		{
			uint32 opt = aValue ? 1 : 0;
			
			if (IOCtlSocket(aHandle, (int32)FIONBIO, &opt) == SOCKET_ERROR)
				return false;
		
			return true;
		}

		[Inline]
		public static bool IsBlockError(int32 aErrorNum) =>
#if BF_PLATFORM_WINDOWS
			aErrorNum == WSAEWOULDBLOCK;
#endif

		[Inline]
		public static bool IsNonFatalError(int32 aErrorNum) =>
#if BF_PLATFORM_WINDOWS
			(aErrorNum == WSAEINVAL)        || (aErrorNum == WSAEFAULT)       ||
			(aErrorNum == WSAEOPNOTSUPP)    || (aErrorNum == WSAEMSGSIZE)     ||
			(aErrorNum == WSAEADDRNOTAVAIL) || (aErrorNum == WSAEAFNOSUPPORT) ||
			(aErrorNum == WSAEDESTADDRREQ);
#endif

		[Inline]
		public static bool IsPipeError(int32 aErrorNum)
		{
#if BF_PLATFORM_WINDOWS
			bool result = aErrorNum == WSAECONNRESET;
	#if DEBUG
			System.Diagnostics.Debug.WriteLine("Warning - check these ambiguous errors");
	#endif
#endif
			return result;
		}

		public static int32 SocketError() =>
#if BF_PLATFORM_WINDOWS
			(int32)WinSock2.WSAGetLastError();
#endif

#if BF_PLATFORM_LINUX
		[CLink, CallingConvention(.Cdecl)]
		private extern static char8* strerror(int32 errnum);

		[LinkName("UnixHelper_geterrno"), CallingConvention(.Cdecl)]
		public extern static int32 geterrno();

		[LinkName("UnixHelper_seterrno"), CallingConvention(.Cdecl)]
		public extern static void seterrno(int32 errnum);
#endif

		public static void StrError(int32 aErrNum, String aOutStr, bool aIndUseUTF8 = false)
		{
#if BF_PLATFORM_WINDOWS
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
				int len = (int)FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_ARGUMENT_ARRAY, null, (uint32)aErrNum, 0, &tmpPtr[0], MAX_ERROR, null);
				tmp.Append(tmpPtr, len);
			}

			aOutStr.Append(tmp);
#elif BF_PLATFORM_LINUX
			aOutStr.Append(strerror(aErrNum));
#endif
		}

		public static fd_handle Accept(fd_handle aHandle, SockAddr* aAddr, int32* aAddrLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.accept(aHandle, (sockaddr_in*)aAddr, aAddrLen);
#endif

		public static int32 Bind(fd_handle aHandle, SockAddr* aName, int32 aNameLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.bind(aHandle, (sockaddr_in*)aName, aNameLen);
#endif

		public static int32 CloseSocket(fd_handle aHandle) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.closesocket(aHandle);
#endif

		public static int32 Connect(fd_handle aHandle, SockAddr* aName, int32 aNameLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.connect(aHandle, (sockaddr_in*)aName, aNameLen);
#endif

		public static int32 IOCtlSocket(fd_handle aHandle, int32 cmd, uint32* aArgP) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.ioctlsocket(aHandle, cmd, aArgP);
#endif

		public static int32 GetPeerName(fd_handle aHandle, SockAddr* aName, int32* aNameLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.getpeername(aHandle, (sockaddr_in*)aName, aNameLen);
#endif

		public static int32 GetSockName(fd_handle aHandle, SockAddr* aName, int32* aNameLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.getsockname(aHandle, (sockaddr_in*)aName, aNameLen);
#endif

		public static int32 SetSockOpt(fd_handle aHandle, int32 aLevel, int32 aOptName, void* aOptVal, int32 aOptLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.setsockopt(aHandle, aLevel, aOptName, aOptVal, aOptLen);
#endif

		public static int32 GetSockOpt(fd_handle aHandle, int32 aLevel, int32 aOptName, void* aOptVal, int32* aOptLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.getsockopt(aHandle, aLevel, aOptName, aOptVal, aOptLen);
#endif

		public static int32 Listen(fd_handle aHandle, int32 aBacklog) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.listen(aHandle, aBacklog);
#endif

		public static int32 Recv(fd_handle aHandle, uint8* aBuf, int32 aLen, int32 aFlags) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.recv(aHandle, aBuf, aLen, aFlags);
#endif

		public static int32 RecvFrom(fd_handle aHandle, uint8* aBuf, int32 aLen, int32 aFlags, SockAddr* aFromAddr, int32* aFromLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.recvfrom(aHandle, aBuf, aLen, aFlags, (sockaddr_in*)aFromAddr, aFromLen);
#endif

		public static int32 Select(int nfds, fd_set* aReadFds, fd_set* aWriteFds, fd_set* aExceptFds, TimeVal* timeout) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.select(nfds, aReadFds, aWriteFds, aExceptFds, timeout);
#endif

		public static int32 Send(fd_handle aHandle, uint8* aBuf, int32 aLen, int32 aFlags) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.send(aHandle, aBuf, aLen, aFlags);
#endif

		public static int32 SendTo(fd_handle aHandle, uint8* aBuf, int32 aLen, int32 aFlags, SockAddr* aToAddr, int32 aToLen) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.sendto(aHandle, aBuf, aLen, aFlags, (sockaddr_in*)aToAddr, aToLen);
#endif

		public static int32 Shutdown(fd_handle aHandle, int32 aHow) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.shutdown(aHandle, aHow);
#endif

		public static fd_handle Socket(int32 aAf, int32 aType, int32 aProtocol) =>
#if BF_PLATFORM_WINDOWS
			WinSock2.socket(aAf, aType, aProtocol);
#endif

		/*
		https://github.com/alrieckert/freepascal/blob/master/packages/rtl-extra/src/inc/sockets.inc
		https://github.com/farshadmohajeri/extpascal/blob/master/SocketsDelphi.pas
		https://students.mimuw.edu.pl/SO/Linux/Kod/include/linux/socket.h.html
		D:\Program Files (x86)\Embarcadero\Studio\20.0\source\rtl\win\Winapi.Winsock2.pas
		*/
	}
}
