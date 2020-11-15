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
		public const String SHLIB_VERSION_NUMBER = "1.1";

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

		public const String OPENSSL_FILE = "";
		public const int OPENSSL_LINE    = 0;

		public const int OPENSSL_MIN_API    = 0;
		public const int OPENSSL_API_COMPAT = OPENSSL_MIN_API;

		public typealias RC4_INT = uint;

		/*-------------------------------------------------------------------------------
		** aes.h
		*/

		public const int AES_ENCRYPT = 1;
		public const int AES_DECRYPT = 0;

		/*
		 * Because array size can't be a const in C, the following two are macros.
		 * Both sizes are in bytes.
		 */
		public const int AES_MAXNR      = 14;
		public const int AES_BLOCK_SIZE = 16;

		/* This should be a hidden type, but EVP requires that the size be known */
		[CRepr]
		public struct aes_key_st
		{
#if AES_LONG
			public uint[4 * (AES_MAXNR + 1)] rd_key;
#else
			public uint32[4 * (AES_MAXNR + 1)] rd_key;
#endif
			public int rounds;
		}
		public typealias AES_KEY = aes_key_st;

		[Import(LIB_CRYPTO), CLink]
		public extern static char8* AES_options();

		[Import(LIB_CRYPTO), CLink]
		public extern static int AES_set_encrypt_key(uint8* userKey, int bits, AES_KEY* key);
		[Import(LIB_CRYPTO), CLink]
		public extern static int AES_set_decrypt_key(uint8* userKey, int bits, AES_KEY* key);

		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_encrypt(uint8* inData, uint8* outData, AES_KEY* key);
		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_decrypt(uint8* inData, uint8* outData, AES_KEY* key);

		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_ecb_encrypt(uint8* inData, uint8* outData, AES_KEY* key, int enc);
		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_cbc_encrypt(uint8* inData, uint8* outData, uint length, AES_KEY* key, uint8* ivec, int enc);
		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_cfb128_encrypt(uint8* inData, uint8* outData, uint length, AES_KEY* key, uint8* ivec, int* num, int enc);
		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_cfb1_encrypt(uint8* inData, uint8* outData, uint length, AES_KEY* key, uint8* ivec, int* num, int enc);
		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_cfb8_encrypt(uint8* inData, uint8* outData, uint length, AES_KEY* key, uint8* ivec, int* num, int enc);
		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_ofb128_encrypt(uint8* inData, uint8* outData, uint length, AES_KEY* key, uint8* ivec, int* num);
		/* NB: the IV is _two_ blocks long */
		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_ige_encrypt(uint8* inData, uint8* outData, uint length, AES_KEY* key, uint8* ivec, int enc);
		/* NB: the IV is _four_ blocks long */
		[Import(LIB_CRYPTO), CLink]
		public extern static void AES_bi_ige_encrypt(uint8* inData, uint8* outData, uint length, AES_KEY* key, AES_KEY* key2, uint8* ivec, int enc);

		[Import(LIB_CRYPTO), CLink]
		public extern static int AES_wrap_key(AES_KEY* key, uint8* iv, uint8* outData, uint8* inData, uint inLen);
		[Import(LIB_CRYPTO), CLink]
		public extern static int AES_unwrap_key(AES_KEY* key, uint8* iv, uint8* outData, uint8* inData, uint inLen);

		/*-------------------------------------------------------------------------------
		** sha.h
		*/

		/*-
		 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		 * ! SHA_LONG has to be at least 32 bits wide.                    !
		 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		 */
		public typealias SHA_LONG = uint;

		public const int SHA_LBLOCK        = 16;
		public const int SHA_CBLOCK        = SHA_LBLOCK * 4; // SHA treats input data as a contiguous array of 32 bit wide big-endian values.
		public const int SHA_LAST_BLOCK    = SHA_CBLOCK - 8;
		public const int SHA_DIGEST_LENGTH = 20;

		[CRepr]
		public struct SHAstate_st
		{
		    public SHA_LONG h0, h1, h2, h3, h4;
		    public SHA_LONG Nl, Nh;
		    public SHA_LONG[SHA_LBLOCK] data;
		    public uint num;
		}
		public typealias SHA_CTX = SHAstate_st;
		
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA1_Init(SHA_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA1_Update(SHA_CTX* c, void* data, uint len);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA1_Final(uint8* md, SHA_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint8* SHA1(uint8* d, uint n, uint8* md);
		[Import(LIB_CRYPTO), CLink]
		public extern static void SHA1_Transform(SHA_CTX* c, uint8* data);

		public const int SHA256_CBLOCK = SHA_LBLOCK * 4; /* SHA-256 treats input data as a contiguous array of 32 bit wide big-endian values. */

		[CRepr]
		public struct SHA256state_st
		{
		    public SHA_LONG[8] h;
		    public SHA_LONG Nl, Nh;
		    public SHA_LONG[SHA_LBLOCK] data;
		    public uint num, md_len;
		}
		public typealias SHA256_CTX = SHA256state_st;

		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA224_Init(SHA256_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA224_Update(SHA256_CTX* c, void* data, uint len);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA224_Final(uint8* md, SHA256_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint8* SHA224(uint8* d, uint n, uint8* md);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA256_Init(SHA256_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA256_Update(SHA256_CTX* c, void* data, uint len);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA256_Final(uint8* md, SHA256_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint8* SHA256(uint8* d, uint n, uint8* md);
		[Import(LIB_CRYPTO), CLink]
		public extern static void SHA256_Transform(SHA256_CTX* c, uint8* data);
		
		public const int SHA224_DIGEST_LENGTH = 28;
		public const int SHA256_DIGEST_LENGTH = 32;
		public const int SHA384_DIGEST_LENGTH = 48;
		public const int SHA512_DIGEST_LENGTH = 64;

		/*
		 * Unlike 32-bit digest algorithms, SHA-512 *relies* on SHA_LONG64
		 * being exactly 64-bit wide. See Implementation Notes in sha512.c
		 * for further details.
		 */
		/*
		 * SHA-512 treats input data as a
		 * contiguous array of 64 bit
		 * wide big-endian values.
		 */
		public const int SHA512_CBLOCK = SHA_LBLOCK * 8;
		public typealias SHA_LONG64    = uint64;

		[CRepr]
		public struct SHA512state_st
		{
		    public SHA_LONG64[8] h;
		    public SHA_LONG64 Nl, Nh;
		    public data_struct u;
		    public uint num, md_len;

			[Union, CRepr]
			public struct data_struct {
		        SHA_LONG64[SHA_LBLOCK] d;
		        uint8[SHA512_CBLOCK] p;
			}
		}
		public typealias SHA512_CTX = SHA512state_st;

		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA384_Init(SHA512_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA384_Update(SHA512_CTX* c, void* data, uint len);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA384_Final(uint8* md, SHA512_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint8* SHA384(uint8* d, uint n, uint8* md);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA512_Init(SHA512_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA512_Update(SHA512_CTX* c, void* data, uint len);
		[Import(LIB_CRYPTO), CLink]
		public extern static int SHA512_Final(uint8* md, SHA512_CTX* c);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint8* SHA512(uint8* d, uint n, uint8* md);
		[Import(LIB_CRYPTO), CLink]
		public extern static void SHA512_Transform(SHA512_CTX* c, uint8* data);
		
		/*-------------------------------------------------------------------------------
		** cryptoerr.h
		*/
		[Import(LIB_CRYPTO), CLink]
		public extern static int ERR_load_CRYPTO_strings();

		/*
		 * CRYPTO function codes.
		 */
		public const int CRYPTO_F_CMAC_CTX_NEW            = 120;
		public const int CRYPTO_F_CRYPTO_DUP_EX_DATA      = 110;
		public const int CRYPTO_F_CRYPTO_FREE_EX_DATA     = 111;
		public const int CRYPTO_F_CRYPTO_GET_EX_NEW_INDEX = 100;
		public const int CRYPTO_F_CRYPTO_MEMDUP           = 115;
		public const int CRYPTO_F_CRYPTO_NEW_EX_DATA      = 112;
		public const int CRYPTO_F_CRYPTO_OCB128_COPY_CTX  = 121;
		public const int CRYPTO_F_CRYPTO_OCB128_INIT      = 122;
		public const int CRYPTO_F_CRYPTO_SET_EX_DATA      = 102;
		public const int CRYPTO_F_FIPS_MODE_SET           = 109;
		public const int CRYPTO_F_GET_AND_LOCK            = 113;
		public const int CRYPTO_F_OPENSSL_ATEXIT          = 114;
		public const int CRYPTO_F_OPENSSL_BUF2HEXSTR      = 117;
		public const int CRYPTO_F_OPENSSL_FOPEN           = 119;
		public const int CRYPTO_F_OPENSSL_HEXSTR2BUF      = 118;
		public const int CRYPTO_F_OPENSSL_INIT_CRYPTO     = 116;
		public const int CRYPTO_F_OPENSSL_LH_NEW          = 126;
		public const int CRYPTO_F_OPENSSL_SK_DEEP_COPY    = 127;
		public const int CRYPTO_F_OPENSSL_SK_DUP          = 128;
		public const int CRYPTO_F_PKEY_HMAC_INIT          = 123;
		public const int CRYPTO_F_PKEY_POLY1305_INIT      = 124;
		public const int CRYPTO_F_PKEY_SIPHASH_INIT       = 125;
		public const int CRYPTO_F_SK_RESERVE              = 129;
		
		/*
		 * CRYPTO reason codes.
		 */
		public const int CRYPTO_R_FIPS_MODE_NOT_SUPPORTED = 101;
		public const int CRYPTO_R_ILLEGAL_HEX_DIGIT       = 102;
		public const int CRYPTO_R_ODD_NUMBER_OF_DIGITS    = 103;
		
		/*-------------------------------------------------------------------------------
		** crypto.h
		*/

		public uint SSLeay()                   => OpenSSL_version_num();
		public char8* SSLeay_version(int type) => OpenSSL_version(type);
		public const int SSLEAY_VERSION_NUMBER = OPENSSL_VERSION_NUMBER;
		public const int SSLEAY_VERSION        = OPENSSL_VERSION;
		public const int SSLEAY_CFLAGS         = OPENSSL_CFLAGS;
		public const int SSLEAY_BUILT_ON       = OPENSSL_BUILT_ON;
		public const int SSLEAY_PLATFORM       = OPENSSL_PLATFORM;
		public const int SSLEAY_DIR            = OPENSSL_DIR;

		/*
		 * Old type for allocating dynamic locks. No longer used. Use the new thread
		 * API instead.
		 */
		[CRepr]
		public struct CRYPTO_dynloc
		{
		    public int dummy;
		}

		typealias CRYPTO_RWLOCK = void;

		[Import(LIB_CRYPTO), CLink]
		public extern static CRYPTO_RWLOCK* CRYPTO_THREAD_lock_new();
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_THREAD_read_lock(CRYPTO_RWLOCK* lock);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_THREAD_write_lock(CRYPTO_RWLOCK* lock);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_THREAD_unlock(CRYPTO_RWLOCK* lock);
		[Import(LIB_CRYPTO), CLink]
		public extern static void CRYPTO_THREAD_lock_free(CRYPTO_RWLOCK* lock);

		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_atomic_add(int* val, int amount, int* ret, CRYPTO_RWLOCK* lock);
		
		/*
		 * The following can be used to detect memory leaks in the library. If
		 * used, it turns on malloc checking
		 */
		public const int CRYPTO_MEM_CHECK_OFF     = 0x0; /* Control only */
		public const int CRYPTO_MEM_CHECK_ON      = 0x1; /* Control and mode bit */
		public const int CRYPTO_MEM_CHECK_ENABLE  = 0x2; /* Control and mode bit */
		public const int CRYPTO_MEM_CHECK_DISABLE = 0x3; /* Control only */
		
		public typealias stack_st_void = void; // For now we'll ignore the Macro-madness
		public struct crypto_ex_data_st {
			public stack_st_void* sk;
		}
		public typealias CRYPTO_EX_DATA = crypto_ex_data_st;
		
		/*
		 * Per class, we have a STACK of function pointers.
		 */
		public const int CRYPTO_EX_INDEX_SSL            = 0;
		public const int CRYPTO_EX_INDEX_SSL_CTX        = 1;
		public const int CRYPTO_EX_INDEX_SSL_SESSION    = 2;
		public const int CRYPTO_EX_INDEX_X509           = 3;
		public const int CRYPTO_EX_INDEX_X509_STORE     = 4;
		public const int CRYPTO_EX_INDEX_X509_STORE_CTX = 5;
		public const int CRYPTO_EX_INDEX_DH             = 6;
		public const int CRYPTO_EX_INDEX_DSA            = 7;
		public const int CRYPTO_EX_INDEX_EC_KEY         = 8;
		public const int CRYPTO_EX_INDEX_RSA            = 9;
		public const int CRYPTO_EX_INDEX_ENGINE         = 10;
		public const int CRYPTO_EX_INDEX_UI             = 11;
		public const int CRYPTO_EX_INDEX_BIO            = 12;
		public const int CRYPTO_EX_INDEX_APP            = 13;
		public const int CRYPTO_EX_INDEX_UI_METHOD      = 14;
		public const int CRYPTO_EX_INDEX_DRBG           = 15;
		public const int CRYPTO_EX_INDEX__COUNT         = 16;
		
		[Inline, Obsolete("No longer needed, so this is a no-op", true)]
		public static void OPENSSL_malloc_init()
		{
			while(false) continue;
		}

		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_mem_ctrl(int mode);

		[Inline]
		public static void OPENSSL_malloc(uint num) => CRYPTO_malloc(num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_zalloc(uint num) => CRYPTO_zalloc(num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_realloc(void* addr, uint num) => CRYPTO_realloc(addr, num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_clear_realloc(void* addr, uint old_num, uint num) => CRYPTO_clear_realloc(addr, old_num, num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_clear_free(void* addr, uint num) => CRYPTO_clear_free(addr, num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_free(void* addr) => CRYPTO_free(addr, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_memdup(void* str, uint sz) => CRYPTO_memdup(str, sz, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_strdup(char8* str) => CRYPTO_strdup(str, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_strndup(char8* str, uint n) => CRYPTO_strndup(str, n, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_secure_malloc(uint num) => CRYPTO_secure_malloc(num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_secure_zalloc(uint num) => CRYPTO_secure_zalloc(num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_secure_free(void* addr) => CRYPTO_secure_free(addr, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_secure_clear_free(void* addr, uint num) => CRYPTO_secure_clear_free(addr, num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void OPENSSL_secure_actual_size(void* ptr) => CRYPTO_secure_actual_size(ptr);
		
		[Import(LIB_CRYPTO), CLink]
		public extern static uint OPENSSL_strlcpy(char8* dst, char8* src, uint siz);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint OPENSSL_strlcat(char8* dst, char8* src, uint siz);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint OPENSSL_strnlen(char8* str, uint maxlen);
		[Import(LIB_CRYPTO), CLink]
		public extern static char8* OPENSSL_buf2hexstr(uint8* buffer, int len);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint8* OPENSSL_hexstr2buf(char8* str, int* len);
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_hexchar2int(uint8 c);
		
		// # define OPENSSL_MALLOC_MAX_NELEMS(type)  (((1U<<(sizeof(int)*8-1))-1)/sizeof(type))
		
		[Import(LIB_CRYPTO), CLink]
		public extern static uint OpenSSL_version_num();
		[Import(LIB_CRYPTO), CLink]
		public extern static char8* OpenSSL_version(int type);

		public const int OPENSSL_VERSION     = 0;
		public const int OPENSSL_CFLAGS      = 1;
		public const int OPENSSL_BUILT_ON    = 2;
		public const int OPENSSL_PLATFORM    = 3;
		public const int OPENSSL_DIR         = 4;
		public const int OPENSSL_ENGINES_DIR = 5;
		
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_issetugid();
		
		function void CRYPTO_EX_new(void* parent, void* ptr, CRYPTO_EX_DATA* ad, int idx, int argl, void* argp);
		function void CRYPTO_EX_free(void* parent, void* ptr, CRYPTO_EX_DATA* ad, int idx, int argl, void* argp);
		function int CRYPTO_EX_dup(CRYPTO_EX_DATA* to, CRYPTO_EX_DATA* from, void* from_d, int idx, int argl, void* argp);

		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_get_ex_new_index(int class_index, int argl, void* argp, CRYPTO_EX_new* new_func, CRYPTO_EX_dup* dup_func, CRYPTO_EX_free* free_func);

		/* No longer use an index. */
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_free_ex_index(int class_index, int idx);

		/*
		 * Initialise/duplicate/free CRYPTO_EX_DATA variables corresponding to a
		 * given class (invokes whatever per-class callbacks are applicable)
		 */
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_new_ex_data(int class_index, void* obj, CRYPTO_EX_DATA* ad);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_dup_ex_data(int class_index, CRYPTO_EX_DATA* to, CRYPTO_EX_DATA* from);
		
		[Import(LIB_CRYPTO), CLink]
		public extern static void CRYPTO_free_ex_data(int class_index, void* obj, CRYPTO_EX_DATA* ad);
		
		/*
		 * Get/set data in a CRYPTO_EX_DATA variable corresponding to a particular
		 * index (relative to the class type involved)
		 */
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_set_ex_data(CRYPTO_EX_DATA* ad, int idx, void* val);
		[Import(LIB_CRYPTO), CLink]
		public extern static void* CRYPTO_get_ex_data(CRYPTO_EX_DATA* ad, int idx);
		
		/*
		 * This function cleans up all "ex_data" state. It mustn't be called under
		 * potential race-conditions.
		 */
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_cleanup_all_ex_data()
		{
			while(false) continue;
		}
		
		/*
		 * The old locking functions have been removed completely without compatibility
		 * macros. This is because the old functions either could not properly report
		 * errors, or the returned error values were not clearly documented.
		 * Replacing the locking functions with no-ops would cause race condition
		 * issues in the affected applications. It is far better for them to fail at
		 * compile time.
		 * On the other hand, the locking callbacks are no longer used.  Consequently,
		 * the callback management functions can be safely replaced with no-op macros.
		 */
		[Inline, Obsolete("No longer available, no-op", true)]
		public static int CRYPTO_num_locks() => 1;
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_set_locking_callback(void* func) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void* CRYPTO_get_locking_callback() => null;
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_set_add_lock_callback(void* func) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void* CRYPTO_get_add_lock_callback() => null;
		
		/*
		 * These defines where used in combination with the old locking callbacks,
		 * they are not called anymore, but old code that's not called might still
		 * use them.
		 */
		public static int CRYPTO_LOCK   = 1;
		public static int CRYPTO_UNLOCK = 2;
		public static int CRYPTO_READ   = 4;
		public static int CRYPTO_WRITE  = 8;
		
		/* This structure is no longer used */
		public struct crypto_threadid_st {
		    int dummy;
		}
		public typealias CRYPTO_THREADID = crypto_threadid_st;
		/* Only use CRYPTO_THREADID_set_[numeric|pointer]() within callbacks */
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_THREADID_set_numeric(uint id, int val) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_THREADID_set_pointer(uint id, void* ptr) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static int CRYPTO_THREADID_set_callback(void* threadid_func) => 0;
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void* CRYPTO_THREADID_get_callback() => null;
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_THREADID_current(uint id) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static int CRYPTO_THREADID_cmp(void* a, void* b) => -1;
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_THREADID_cpy(void* dest, void* src) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static uint CRYPTO_THREADID_hash(uint id) => 0UL;
		
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_set_id_callback(void* func) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void* CRYPTO_get_id_callback() => null;
		[Inline, Obsolete("No longer available, no-op", true)]
		public static uint CRYPTO_thread_id() => 0UL;
		
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_set_dynlock_create_callback(void* dyn_create_function) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_set_dynlock_lock_callback(void* dyn_lock_function) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void CRYPTO_set_dynlock_destroy_callback(void* dyn_destroy_function) {}
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void* CRYPTO_get_dynlock_create_callback() => null;
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void* CRYPTO_get_dynlock_lock_callback() => null;
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void* CRYPTO_get_dynlock_destroy_callback() => null;

		function void* CRYPTO_mem_functions_m(uint a, char8* b, int c);
		function void* CRYPTO_mem_functions_r(void* a, uint b, char8* c, int d);
		function void CRYPTO_mem_functions_f(void* a, char8* b, int c);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_set_mem_functions(CRYPTO_mem_functions_m m, CRYPTO_mem_functions_r r, CRYPTO_mem_functions_f f);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_set_mem_debug(int flag);
		function void* CRYPTO_get_mem_functions_m(uint a, char8* b, int c);
		function void* CRYPTO_get_mem_functions_r(void* a, uint b, char8* c, int d);
		function void CRYPTO_get_mem_functions_f(void* a, char8* b, int c);
		[Import(LIB_CRYPTO), CLink]
		public extern static void CRYPTO_get_mem_functions(CRYPTO_mem_functions_m* m, CRYPTO_mem_functions_r* r, CRYPTO_mem_functions_f* f);
		
		[Import(LIB_CRYPTO), CLink]
		public extern static void* CRYPTO_malloc(uint num, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void* CRYPTO_zalloc(uint num, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void* CRYPTO_memdup(void* str, uint siz, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static char8* CRYPTO_strdup(char8* str, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static char8* CRYPTO_strndup(char8* str, uint s, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void CRYPTO_free(void* ptr, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void CRYPTO_clear_free(void* ptr, uint num, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void* CRYPTO_realloc(void* addr, uint num, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void* CRYPTO_clear_realloc(void *addr, uint old_num, uint num, char8* file, int line);
		
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_secure_malloc_init(uint sz, int minsize);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_secure_malloc_done();
		[Import(LIB_CRYPTO), CLink]
		public extern static void* CRYPTO_secure_malloc(uint num, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void* CRYPTO_secure_zalloc(uint num, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void CRYPTO_secure_free(void* ptr, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static void CRYPTO_secure_clear_free(void* ptr, uint num, char8* file, int line);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_secure_allocated(void* ptr);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_secure_malloc_initialized();
		[Import(LIB_CRYPTO), CLink]
		public extern static uint CRYPTO_secure_actual_size(void* ptr);
		[Import(LIB_CRYPTO), CLink]
		public extern static uint CRYPTO_secure_used();
		
		[Import(LIB_CRYPTO), CLink]
		public extern static void OPENSSL_cleanse(void *ptr, uint len);

		/* die if we have to */
		[Import(LIB_CRYPTO), CLink, NoReturn]
		public extern static void OPENSSL_die(char8* assertion, char8* file, int line);
		[Inline]
		public static void OpenSSLDie(char8* f, int l, char8* a) => OPENSSL_die(a, f, l);
		[Inline]
		public static void OPENSSL_assert(bool check, StringView msg)
		{
			if (!check) {
				String tmp = scope:: .();
				tmp.AppendF("assertion failed: {}", msg);
				OPENSSL_die(tmp.CStr(), OPENSSL_FILE, OPENSSL_LINE);
			}
		}
		
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_isservice();

		[Import(LIB_CRYPTO), CLink]
		public extern static int FIPS_mode();
		[Import(LIB_CRYPTO), CLink]
		public extern static int FIPS_mode_set(int r);

		[Import(LIB_CRYPTO), CLink]
		public extern static void OPENSSL_init();

		[CRepr]
		public struct tm
		{
		    public int tm_sec;   // seconds after the minute - [0, 60] including leap second
		    public int tm_min;   // minutes after the hour - [0, 59]
		    public int tm_hour;  // hours since midnight - [0, 23]
		    public int tm_mday;  // day of the month - [1, 31]
		    public int tm_mon;   // months since January - [0, 11]
		    public int tm_year;  // years since 1900
		    public int tm_wday;  // days since Sunday - [0, 6]
		    public int tm_yday;  // days since January 1 - [0, 365]
		    public int tm_isdst; // daylight savings time flag
		}

		[Import(LIB_CRYPTO), CLink]
		public extern static tm* OPENSSL_gmtime(int64* timer, tm* result);
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_gmtime_adj(tm* tm, int offset_day, int offset_sec);
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_gmtime_diff(int *pday, int* psec, tm* from, tm* to);

		/*
		 * CRYPTO_memcmp returns zero iff the |len| bytes at |a| and |b| are equal.
		 * It takes an amount of time dependent on |len|, but independent of the
		 * contents of |a| and |b|. Unlike memcmp, it cannot be used to put elements
		 * into a defined order as the return value when a != b is undefined, other
		 * than to be non-zero.
		 */
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_memcmp(void* in_a, void* in_b, uint len);

		/* Standard initialisation options */
		public const int OPENSSL_INIT_NO_LOAD_CRYPTO_STRINGS = 0x00000001L;
		public const int OPENSSL_INIT_LOAD_CRYPTO_STRINGS    = 0x00000002L;
		public const int OPENSSL_INIT_ADD_ALL_CIPHERS        = 0x00000004L;
		public const int OPENSSL_INIT_ADD_ALL_DIGESTS        = 0x00000008L;
		public const int OPENSSL_INIT_NO_ADD_ALL_CIPHERS     = 0x00000010L;
		public const int OPENSSL_INIT_NO_ADD_ALL_DIGESTS     = 0x00000020L;
		public const int OPENSSL_INIT_LOAD_CONFIG            = 0x00000040L;
		public const int OPENSSL_INIT_NO_LOAD_CONFIG         = 0x00000080L;
		public const int OPENSSL_INIT_ASYNC                  = 0x00000100L;
		public const int OPENSSL_INIT_ENGINE_RDRAND          = 0x00000200L;
		public const int OPENSSL_INIT_ENGINE_DYNAMIC         = 0x00000400L;
		public const int OPENSSL_INIT_ENGINE_OPENSSL         = 0x00000800L;
		public const int OPENSSL_INIT_ENGINE_CRYPTODEV       = 0x00001000L;
		public const int OPENSSL_INIT_ENGINE_CAPI            = 0x00002000L;
		public const int OPENSSL_INIT_ENGINE_PADLOCK         = 0x00004000L;
		public const int OPENSSL_INIT_ENGINE_AFALG           = 0x00008000L;
		/* public const int OPENSSL_INIT_ZLIB                   = 0x00010000L; */
		public const int OPENSSL_INIT_ATFORK                 = 0x00020000L;
		/* public const int OPENSSL_INIT_BASE_ONLY              = 0x00040000L; */
		public const int OPENSSL_INIT_NO_ATEXIT              = 0x00080000L;
		/* OPENSSL_INIT flag range 0xfff00000 reserved for OPENSSL_init_ssl() */
		/* Max OPENSSL_INIT flag value is 0x80000000 */

		/* openssl and dasync not counted as builtin */
		public const int OPENSSL_INIT_ENGINE_ALL_BUILTIN = OPENSSL_INIT_ENGINE_RDRAND | OPENSSL_INIT_ENGINE_DYNAMIC | OPENSSL_INIT_ENGINE_CRYPTODEV | OPENSSL_INIT_ENGINE_CAPI | OPENSSL_INIT_ENGINE_PADLOCK;

		public struct ossl_init_settings_st
		{
		    public char8* filename;
		    public char8* appname;
		    public uint flags;
		}
		public typealias OPENSSL_INIT_SETTINGS = ossl_init_settings_st;

		/* Library initialisation functions */
		[Import(LIB_CRYPTO), CLink]
		public extern static void OPENSSL_cleanup();
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_init_crypto(uint64 opts, OPENSSL_INIT_SETTINGS* settings);
		function void atexit_handler();
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_atexit(atexit_handler handler);
		[Import(LIB_CRYPTO), CLink]
		public extern static void OPENSSL_thread_stop();

		/* Low-level control of initialization */
		[Import(LIB_CRYPTO), CLink]
		public extern static OPENSSL_INIT_SETTINGS* OPENSSL_INIT_new();
#if !OPENSSL_NO_STDIO
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_INIT_set_config_filename(OPENSSL_INIT_SETTINGS* settings, char8* config_filename);
		[Import(LIB_CRYPTO), CLink]
		public extern static void OPENSSL_INIT_set_config_file_flags(OPENSSL_INIT_SETTINGS* settings, uint flags);
		[Import(LIB_CRYPTO), CLink]
		public extern static int OPENSSL_INIT_set_config_appname(OPENSSL_INIT_SETTINGS* settings, char8* config_appname);
#endif
		[Import(LIB_CRYPTO), CLink]
		public extern static void OPENSSL_INIT_free(OPENSSL_INIT_SETTINGS* settings);

#if !CRYPTO_ONCE_STATIC_INIT
		typealias CRYPTO_ONCE = uint;
		typealias CRYPTO_THREAD_LOCAL = uint;
		typealias CRYPTO_THREAD_ID = uint;
	#define CRYPTO_ONCE_STATIC_INIT
#endif
		
		function void CRYPTO_THREAD_run_once_init();
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_THREAD_run_once(CRYPTO_ONCE* once, CRYPTO_THREAD_run_once_init init);
		
		function void CRYPTO_THREAD_init_local_cleanup(void* ptr);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_THREAD_init_local(CRYPTO_THREAD_LOCAL* key, CRYPTO_THREAD_init_local_cleanup cleanup);
		[Import(LIB_CRYPTO), CLink]
		public extern static void *CRYPTO_THREAD_get_local(CRYPTO_THREAD_LOCAL* key);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_THREAD_set_local(CRYPTO_THREAD_LOCAL* key, void* val);
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_THREAD_cleanup_local(CRYPTO_THREAD_LOCAL* key);

		[Import(LIB_CRYPTO), CLink]
		public extern static CRYPTO_THREAD_ID CRYPTO_THREAD_get_current_id();
		[Import(LIB_CRYPTO), CLink]
		public extern static int CRYPTO_THREAD_compare_id(CRYPTO_THREAD_ID a, CRYPTO_THREAD_ID b);

		/*-------------------------------------------------------------------------------
		** buffererr.h
		*/
		[Import(LIB_CRYPTO), CLink]
		public extern static int ERR_load_BUF_strings();

		/*
		 * BUF function codes.
		 */
		public const int BUF_F_BUF_MEM_GROW       = 100;
		public const int BUF_F_BUF_MEM_GROW_CLEAN = 105;
		public const int BUF_F_BUF_MEM_NEW        = 101;
		
		/*
		 * BUF reason codes.
		 */

		/*-------------------------------------------------------------------------------
		** buffer.h
		*/

		/*-------------------------------------------------------------------------------
		** ssl.h
		*/

		/*-------------------------------------------------------------------------------
		** ssl2.h
		*/

		/*-------------------------------------------------------------------------------
		** ssl3.h
		*/

		/*-------------------------------------------------------------------------------
		** tls1.h
		*/
	}
}
