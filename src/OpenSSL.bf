/*
* Copyright 1999-2020 The OpenSSL Project Authors. All Rights Reserved.
*
* Licensed under the OpenSSL license (the "License").  You may not use
* this file except in compliance with the License.  You can obtain a copy
* in the file LICENSE in the source distribution or at
* https://www.openssl.org/source/license.html
*/
using System;

namespace Beef_Net
{
	// Ported for OpenSSL 1.1.1h
	sealed abstract class OpenSSL
	{
#if BF_PLATFORM_WINDOWS
	#if !(BF_32_BIT || BF_64_BIT)
		#error Unsupported CPU
	#endif

		private const String LIB_SSL    = "libssl-1_1.dll";
		private const String LIB_CRYPTO = "libcrypto-1_1.dll";
#elif BF_PLATFORM_LINUX
	#if !BF_64_BIT
		#error Unsupported CPU
	#endif
		private const String LIB_SSL    = "libssl.so";
		private const String LIB_CRYPTO = "libcrypto.so";
#else
	#error Unsupported platform
#endif
		/*-------------------------------------------------------------------------------
		** opensslv.h
		*/

		/*-
		* Numeric release version identifier:
		* MNNFFPPS: major minor fix patch status
		* The status nibble has one of the values 0 for development, 1 to e for betas
		* 1 to 14, and f for release.  The patch level is exactly that.
		* For example:
		* 0.9.3-dev      0x00903000
		* 0.9.3-beta1    0x00903001
		* 0.9.3-beta2-dev 0x00903002
		* 0.9.3-beta2    0x00903002 (same as ...beta2-dev)
		* 0.9.3          0x0090300f
		* 0.9.3a         0x0090301f
		* 0.9.4          0x0090400f
		* 1.2.3z         0x102031af
		*
		* For continuity reasons (because 0.9.5 is already out, and is coded
		* 0x00905100), between 0.9.5 and 0.9.6 the coding of the patch level
		* part is slightly different, by setting the highest bit.  This means
		* that 0.9.5a looks like this: 0x0090581f.  At 0.9.6, we can start
		* with 0x0090600S...
		*
		* (Prior to 0.9.3-dev a different scheme was used: 0.9.2b is 0x0922.)
		* (Prior to 0.9.5a beta1, a different scheme was used: MMNNFFRBB for
		*  major minor fix final patch/beta)
		*/
		public const int OPENSSL_VERSION_NUMBER  = 0x1010108fL;
		public const String OPENSSL_VERSION_TEXT = "OpenSSL 1.1.1h  22 Sep 2020";

		/*-
		* The macros below are to be used for shared library (.so, .dll, ...)
		* versioning.  That kind of versioning works a bit differently between
		* operating systems.  The most usual scheme is to set a major and a minor
		* number, and have the runtime loader check that the major number is equal
		* to what it was at application link time, while the minor number has to
		* be greater or equal to what it was at application link time.  With this
		* scheme, the version number is usually part of the file name, like this:
		*
		*      libcrypto.so.0.9
		*
		* Some unixen also make a softlink with the major version number only:
		*
		*      libcrypto.so.0
		*
		* On Tru64 and IRIX 6.x it works a little bit differently.  There, the
		* shared library version is stored in the file, and is actually a series
		* of versions, separated by colons.  The rightmost version present in the
		* library when linking an application is stored in the application to be
		* matched at run time.  When the application is run, a check is done to
		* see if the library version stored in the application matches any of the
		* versions in the version string of the library itself.
		* This version string can be constructed in any way, depending on what
		* kind of matching is desired.  However, to implement the same scheme as
		* the one used in the other unixen, all compatible versions, from lowest
		* to highest, should be part of the string.  Consecutive builds would
		* give the following versions strings:
		*
		*      3.0
		*      3.0:3.1
		*      3.0:3.1:3.2
		*      4.0
		*      4.0:4.1
		*
		* Notice how version 4 is completely incompatible with version, and
		* therefore give the breach you can see.
		*
		* There may be other schemes as well that I haven't yet discovered.
		*
		* So, here's the way it works here: first of all, the library version
		* number doesn't need at all to match the overall OpenSSL version.
		* However, it's nice and more understandable if it actually does.
		* The current library version is stored in the macro SHLIB_VERSION_NUMBER,
		* which is just a piece of text in the format "M.m.e" (Major, minor, edit).
		* For the sake of Tru64, IRIX, and any other OS that behaves in similar ways,
		* we need to keep a history of version numbers, which is done in the
		* macro SHLIB_VERSION_HISTORY.  The numbers are separated by colons and
		* should only keep the versions that are binary compatible with the current.
		*/
		public const String SHLIB_VERSION_HISTORY = "";
		public const String SHLIB_VERSION_NUMBER  = "1.1";

		/*-------------------------------------------------------------------------------
		** opensslconf.h
		*/

		/*
		 * OpenSSL was configured with the following options:
		 */
#if BF_PLATFORM_WINDOWS
	#if BF_32_BIT
		#define OPENSSL_SYS_WIN32
		#define THIRTY_TWO_BIT
		#define BN_LLONG
	#elif BF_64_BIT
		#define OPENSSL_SYS_WIN64A
		#define SIXTY_FOUR_BIT
	#endif

	#define OPENSSL_NO_MD2
	#define OPENSSL_NO_RC5
	#define OPENSSL_THREADS
	#define OPENSSL_RAND_SEED_OS
	#define OPENSSL_NO_AFALGENG
	#define OPENSSL_NO_ASAN
	#define OPENSSL_NO_CRYPTO_MDEBUG
	#define OPENSSL_NO_CRYPTO_MDEBUG_BACKTRACE
	#define OPENSSL_NO_DEVCRYPTOENG
	#define OPENSSL_NO_EC_NISTP_64_GCC_128
	#define OPENSSL_NO_EGD
	#define OPENSSL_NO_EXTERNAL_TESTS
	#define OPENSSL_NO_FUZZ_AFL
	#define OPENSSL_NO_FUZZ_LIBFUZZER
	#define OPENSSL_NO_HEARTBEATS
	#define OPENSSL_NO_MSAN
	#define OPENSSL_NO_SCTP
	#define OPENSSL_NO_SSL_TRACE
	#define OPENSSL_NO_SSL3
	#define OPENSSL_NO_SSL3_METHOD
	#define OPENSSL_NO_UBSAN
	#define OPENSSL_NO_UNIT_TEST
	#define OPENSSL_NO_WEAK_SSL_CIPHERS
	#define OPENSSL_NO_STATIC_ENGINE

	#define OPENSSL_EXPORT_VAR_AS_FUNCTION
#elif BF_PLATFORM_LINUX
	#if BF_64_BIT
		#define OPENSSL_SYS_WIN64A
		#define SIXTY_FOUR_BIT_LONG
	#endif
		
	#define OPENSSL_NO_MD2
	#define OPENSSL_NO_RC5
	#define OPENSSL_THREADS
	#define OPENSSL_RAND_SEED_OS
	#define OPENSSL_NO_ASAN
	#define OPENSSL_NO_CRYPTO_MDEBUG
	#define OPENSSL_NO_CRYPTO_MDEBUG_BACKTRACE
	#define OPENSSL_NO_DEVCRYPTOENG
	#define OPENSSL_NO_EC_NISTP_64_GCC_128
	#define OPENSSL_NO_EGD
	#define OPENSSL_NO_EXTERNAL_TESTS
	#define OPENSSL_NO_FUZZ_AFL
	#define OPENSSL_NO_FUZZ_LIBFUZZER
	#define OPENSSL_NO_HEARTBEATS
	#define OPENSSL_NO_MSAN
	#define OPENSSL_NO_SCTP
	#define OPENSSL_NO_SSL_TRACE
	#define OPENSSL_NO_SSL3
	#define OPENSSL_NO_SSL3_METHOD
	#define OPENSSL_NO_UBSAN
	#define OPENSSL_NO_UNIT_TEST
	#define OPENSSL_NO_WEAK_SSL_CIPHERS
	#define OPENSSL_NO_STATIC_ENGINE
#endif

		typealias RC4_INT = uint;
	}
}
