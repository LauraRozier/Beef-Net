/*
* Generated by util/mkerr.pl DO NOT EDIT
* Copyright 1995-2019 The OpenSSL Project Authors. All Rights Reserved.
*
* Licensed under the OpenSSL license (the "License").  You may not use
* this file except in compliance with the License.  You can obtain a copy
* in the file LICENSE in the source distribution or at
* https://www.openssl.org/source/license.html
*/
using System;

namespace Beef_Net.OpenSSL
{
	[AlwaysInclude]
	sealed abstract class SSLeay
	{
		/* SSLeay compat */
		public const int VERSION_NUMBER = OPENSSL_VERSION_NUMBER;

		public const int VERSION        = OpenSSL.VERSION;
		public const int CFLAGS         = OpenSSL.CFLAGS;
		public const int BUILT_ON       = OpenSSL.BUILT_ON;
		public const int PLATFORM       = OpenSSL.PLATFORM;
		public const int DIR            = OpenSSL.DIR;

		public uint SSLeay()            => OpenSSL.version_num();
		public char8* version(int type) => OpenSSL.version(type);
	}
	
	[AlwaysInclude]
	sealed abstract class OpenSSL
	{
		public const int VERSION     = 0;
		public const int CFLAGS      = 1;
		public const int BUILT_ON    = 2;
		public const int PLATFORM    = 3;
		public const int DIR         = 4;
		public const int ENGINES_DIR = 5;

		[Inline, Obsolete("No longer needed, so this is a no-op", true)]
		public static void malloc_init() { while(false) continue; }

		[Inline]
		public static void* malloc(uint num) => Crypto.malloc(num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void* zalloc(uint num) => Crypto.zalloc(num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void* realloc(void* addr, uint num) => Crypto.realloc(addr, num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void* clear_realloc(void* addr, uint old_num, uint num) => Crypto.clear_realloc(addr, old_num, num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void clear_free(void* addr, uint num) => Crypto.clear_free(addr, num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void free(void* addr) => Crypto.free(addr, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void* memdup(void* data, uint size) => Crypto.memdup(data, size, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static char8* strdup(char8* str) => Crypto.strdup(str, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static char8* strndup(char8* str, uint n) => Crypto.strndup(str, n, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void* secure_malloc(uint num) => Crypto.secure_malloc(num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void* secure_zalloc(uint num) => Crypto.secure_zalloc(num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void secure_free(void* addr) => Crypto.secure_free(addr, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static void secure_clear_free(void* addr, uint num) => Crypto.secure_clear_free(addr, num, OPENSSL_FILE, OPENSSL_LINE);

		[Inline]
		public static uint secure_actual_size(void* ptr) => Crypto.secure_actual_size(ptr);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_strlcpy")]
		public extern static uint strlcpy(char8* dst, char8* src, uint size);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_strlcat")]
		public extern static uint strlcat(char8* dst, char8* src, uint size);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_strnlen")]
		public extern static uint strnlen(char8* str, uint maxlen);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_buf2hexstr")]
		public extern static char8* buf2hexstr(uint8* buffer, int len);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_hexstr2buf")]
		public extern static uint8* hexstr2buf(char8* str, int* len);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_hexchar2int")]
		public extern static int hexchar2int(uint8 c);

		[Inline]
		public static uint MALLOC_MAX_NELEMS<T>() => ((1U << (sizeof(int) * 8 - 1)) - 1) / (uint32)sizeof(T);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OpenSSL_version_num")]
		public extern static uint version_num();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OpenSSL_version")]
		public extern static char8* version(int type);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_issetugid")]
		public extern static int issetugid();

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_cleanse")]
		public extern static void cleanse(void *ptr, uint len);

		/* die if we have to */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_die"), NoReturn]
		public extern static void die(char8* assertion, char8* file, int line);
		[Inline]
		public static void OpenSSLDie(char8* f, int l, char8* a) => die(a, f, l);
		[Inline]
		public static void assert(bool check, StringView msg)
		{
			if (!check) {
				String tmp = scope:: .();
				tmp.AppendF("assertion failed: {}", msg);
				die(tmp.CStr(),  OPENSSL_FILE,  OPENSSL_LINE);
			}
		}

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_isservice")]
		public extern static int isservice();

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_init")]
		public extern static void init();

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_gmtime")]
		public extern static OSSLType.tm* gmtime(int64* timer, OSSLType.tm* result);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_gmtime_adj")]
		public extern static int gmtime_adj(OSSLType.tm* tm, int offset_day, int offset_sec);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_gmtime_diff")]
		public extern static int gmtime_diff(int *pday, int* psec, OSSLType.tm* from, OSSLType.tm* to);

		/* Standard initialisation options */
		public const int INIT_NO_LOAD_CRYPTO_STRINGS = 0x00000001L;
		public const int INIT_LOAD_CRYPTO_STRINGS    = 0x00000002L;
		public const int INIT_ADD_ALL_CIPHERS        = 0x00000004L;
		public const int INIT_ADD_ALL_DIGESTS        = 0x00000008L;
		public const int INIT_NO_ADD_ALL_CIPHERS     = 0x00000010L;
		public const int INIT_NO_ADD_ALL_DIGESTS     = 0x00000020L;
		public const int INIT_LOAD_CONFIG            = 0x00000040L;
		public const int INIT_NO_LOAD_CONFIG         = 0x00000080L;
		public const int INIT_ASYNC                  = 0x00000100L;
		public const int INIT_ENGINE_RDRAND          = 0x00000200L;
		public const int INIT_ENGINE_DYNAMIC         = 0x00000400L;
		public const int INIT_ENGINE_OPENSSL         = 0x00000800L;
		public const int INIT_ENGINE_CRYPTODEV       = 0x00001000L;
		public const int INIT_ENGINE_CAPI            = 0x00002000L;
		public const int INIT_ENGINE_PADLOCK         = 0x00004000L;
		public const int INIT_ENGINE_AFALG           = 0x00008000L;
		/* public const int INIT_ZLIB                   = 0x00010000L; */
		public const int INIT_ATFORK                 = 0x00020000L;
		/* public const int INIT_BASE_ONLY              = 0x00040000L; */
		public const int INIT_NO_ATEXIT              = 0x00080000L;
		/* INIT flag range 0xfff00000 reserved for init_ssl() */
		/* Max INIT flag value is 0x80000000 */

		/* openssl and dasync not counted as builtin */
		public const int INIT_ENGINE_ALL_BUILTIN = INIT_ENGINE_RDRAND | INIT_ENGINE_DYNAMIC | INIT_ENGINE_CRYPTODEV | INIT_ENGINE_CAPI | INIT_ENGINE_PADLOCK;

		[CRepr]
		public struct init_settings_st
		{
		    public char8* filename;
		    public char8* appname;
		    public uint flags;
		}
		public typealias INIT_SETTINGS = init_settings_st;

		/* Library initialisation functions */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_cleanup")]
		public extern static void cleanup();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_init_crypto")]
		public extern static int init_crypto(uint64 opts, INIT_SETTINGS* settings);
		function void atexit_handler();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_atexit")]
		public extern static int atexit(atexit_handler handler);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_thread_stop")]
		public extern static void thread_stop();

		/* Low-level control of initialization */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_INIT_new")]
		public extern static INIT_SETTINGS* INIT_new();
#if !OPENSSL_NO_STDIO
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_INIT_set_config_filename")]
		public extern static int INIT_set_config_filename(INIT_SETTINGS* settings, char8* config_filename);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_INIT_set_config_file_flags")]
		public extern static void INIT_set_config_file_flags(INIT_SETTINGS* settings, uint flags);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_INIT_set_config_appname")]
		public extern static int INIT_set_config_appname(INIT_SETTINGS* settings, char8* config_appname);
#endif
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_INIT_free")]
		public extern static void INIT_free(INIT_SETTINGS* settings);

		[Inline]
		public static int add_all_algorithms_conf() => init_crypto(INIT_ADD_ALL_CIPHERS | INIT_ADD_ALL_DIGESTS | INIT_LOAD_CONFIG, null);
		[Inline]
		public static int add_all_algorithms_noconf() => init_crypto(INIT_ADD_ALL_CIPHERS | INIT_ADD_ALL_DIGESTS, null);

#if OPENSSL_LOAD_CONF
		[Inline]
		public static int add_all_algorithms() => add_all_algorithms_conf();
#else
		[Inline]
		public static int add_all_algorithms() => add_all_algorithms_noconf();
#endif

		[Inline]
		public static int add_all_ciphers() => init_crypto(INIT_ADD_ALL_CIPHERS, null);
		[Inline]
		public static int add_all_digests() => init_crypto(INIT_ADD_ALL_DIGESTS, null);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_config")]
		public extern static void config(char8* config_name);

		[Inline]
		public static int no_config() => init_crypto(INIT_NO_LOAD_CONFIG, null);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_load_builtin_modules")]
		public extern static void load_builtin_modules();
	}
}
