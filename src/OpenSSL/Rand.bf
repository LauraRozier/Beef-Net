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
	sealed abstract class Rand
	{
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static int ERR_load_RAND_strings();
		
		/*
		 * RAND function codes.
		 */
		public const int F_DATA_COLLECT_METHOD                 = 127;
		public const int F_DRBG_BYTES                          = 101;
		public const int F_DRBG_GET_ENTROPY                    = 105;
		public const int F_DRBG_SETUP                          = 117;
		public const int F_GET_ENTROPY                         = 106;
		public const int F_RAND_BYTES                          = 100;
		public const int F_RAND_DRBG_ENABLE_LOCKING            = 119;
		public const int F_RAND_DRBG_GENERATE                  = 107;
		public const int F_RAND_DRBG_GET_ENTROPY               = 120;
		public const int F_RAND_DRBG_GET_NONCE                 = 123;
		public const int F_RAND_DRBG_INSTANTIATE               = 108;
		public const int F_RAND_DRBG_NEW                       = 109;
		public const int F_RAND_DRBG_RESEED                    = 110;
		public const int F_RAND_DRBG_RESTART                   = 102;
		public const int F_RAND_DRBG_SET                       = 104;
		public const int F_RAND_DRBG_SET_DEFAULTS              = 121;
		public const int F_RAND_DRBG_UNINSTANTIATE             = 118;
		public const int F_RAND_LOAD_FILE                      = 111;
		public const int F_RAND_POOL_ACQUIRE_ENTROPY           = 122;
		public const int F_RAND_POOL_ADD                       = 103;
		public const int F_RAND_POOL_ADD_BEGIN                 = 113;
		public const int F_RAND_POOL_ADD_END                   = 114;
		public const int F_RAND_POOL_ATTACH                    = 124;
		public const int F_RAND_POOL_BYTES_NEEDED              = 115;
		public const int F_RAND_POOL_GROW                      = 125;
		public const int F_RAND_POOL_NEW                       = 116;
		public const int F_RAND_PSEUDO_BYTES                   = 126;
		public const int F_RAND_WRITE_FILE                     = 112;
		
		/*
		 * RAND reason codes.
		 */
		public const int R_ADDITIONAL_INPUT_TOO_LONG           = 102;
		public const int R_ALREADY_INSTANTIATED                = 103;
		public const int R_ARGUMENT_OUT_OF_RANGE               = 105;
		public const int R_CANNOT_OPEN_FILE                    = 121;
		public const int R_DRBG_ALREADY_INITIALIZED            = 129;
		public const int R_DRBG_NOT_INITIALISED                = 104;
		public const int R_ENTROPY_INPUT_TOO_LONG              = 106;
		public const int R_ENTROPY_OUT_OF_RANGE                = 124;
		public const int R_ERROR_ENTROPY_POOL_WAS_IGNORED      = 127;
		public const int R_ERROR_INITIALISING_DRBG             = 107;
		public const int R_ERROR_INSTANTIATING_DRBG            = 108;
		public const int R_ERROR_RETRIEVING_ADDITIONAL_INPUT   = 109;
		public const int R_ERROR_RETRIEVING_ENTROPY            = 110;
		public const int R_ERROR_RETRIEVING_NONCE              = 111;
		public const int R_FAILED_TO_CREATE_LOCK               = 126;
		public const int R_FUNC_NOT_IMPLEMENTED                = 101;
		public const int R_FWRITE_ERROR                        = 123;
		public const int R_GENERATE_ERROR                      = 112;
		public const int R_INTERNAL_ERROR                      = 113;
		public const int R_IN_ERROR_STATE                      = 114;
		public const int R_NOT_A_REGULAR_FILE                  = 122;
		public const int R_NOT_INSTANTIATED                    = 115;
		public const int R_NO_DRBG_IMPLEMENTATION_SELECTED     = 128;
		public const int R_PARENT_LOCKING_NOT_ENABLED          = 130;
		public const int R_PARENT_STRENGTH_TOO_WEAK            = 131;
		public const int R_PERSONALISATION_STRING_TOO_LONG     = 116;
		public const int R_PREDICTION_RESISTANCE_NOT_SUPPORTED = 133;
		public const int R_PRNG_NOT_SEEDED                     = 100;
		public const int R_RANDOM_POOL_OVERFLOW                = 125;
		public const int R_RANDOM_POOL_UNDERFLOW               = 134;
		public const int R_REQUEST_TOO_LARGE_FOR_DRBG          = 117;
		public const int R_RESEED_ERROR                        = 118;
		public const int R_SELFTEST_FAILURE                    = 119;
		public const int R_TOO_LITTLE_NONCE_REQUESTED          = 135;
		public const int R_TOO_MUCH_NONCE_REQUESTED            = 136;
		public const int R_UNSUPPORTED_DRBG_FLAGS              = 132;
		public const int R_UNSUPPORTED_DRBG_TYPE               = 120;
		
		[CRepr]
		public struct meth_st
		{
		    public function int(void* buf, int num) seed;
		    public function int(uint8* buf, int num) bytes;
		    public function void() cleanup;
		    public function int(void* buf, int num, double randomness) add;
		    public function int(uint8* buf, int num) pseudorand;
		    public function int() status;
		}
		public typealias METHOD = meth_st;

		/*
		 * The 'random pool' acts as a dumb container for collecting random input from various entropy sources. The pool has no knowledge about whether its randomness is fed into a legacy RAND_METHOD via add()
		 * or into a new style RandDRBG. It is the callers duty to 1) initialize the random pool, 2) pass it to the polling callbacks, 3) seed the RNG, and 4) cleanup the random pool again.
		 *
		 * The random pool contains no locking mechanism because its scope and lifetime is intended to be restricted to a single stack frame.
		 */
		[CRepr]
		public struct pool_st
		{
		    public uint8* buffer;          /* points to the beginning of the random pool */
		    public uint len;               /* current number of random bytes contained in the pool */

		    public int attached;           /* true pool was attached to existing buffer */
		    public int secure;             /* 1: allocated on the secure heap, 0: otherwise */

		    public uint min_len;           /* minimum number of random bytes requested */
		    public uint max_len;           /* maximum number of random bytes (allocated buffer size) */
		    public uint alloc_len;         /* current number of bytes allocated */
		    public uint entropy;           /* current entropy count in bits */
		    public uint entropy_requested; /* requested entropy count in bits */
		}

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_set_rand_method")
		]
		public extern static int set_rand_method(METHOD* meth);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_get_rand_method")
		]
		public extern static METHOD* get_rand_method();
#if !OPENSSL_NO_ENGINE
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_set_rand_engine")
		]
		public extern static int set_rand_engine(Engine.ENGINE* engine);
#endif
		
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_OpenSSL")
		]
		public extern static METHOD* OpenSSL();
		
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void cleanup() { while(false) continue; }
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_bytes")
		]
		public extern static int bytes(uint8* buf, int num);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_priv_bytes")
		]
		public extern static int priv_bytes(uint8* buf, int num);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_pseudo_bytes")
		]
		public extern static int pseudo_bytes(uint8* buf, int num);
		
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_seed")
		]
		public extern static void seed(void* buf, int num);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_keep_random_devices_open")
		]
		public extern static void keep_random_devices_open(int keep);
		
		// __NDK_FPABI__	/* __attribute__((pcs("aapcs"))) on ARM */
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_add")
		]
		public extern static void add(void* buf, int num, double randomness);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_load_file")
		]
		public extern static int load_file(char8* file, int max_bytes);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_write_file")
		]
		public extern static int write_file(char8* file);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_file_name")
		]
		public extern static char8* file_name(char8* file, uint num);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_status")
		]
		public extern static int status();
		
#if !OPENSSL_NO_EGD
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_query_egd_bytes")
		]
		public extern static int query_egd_bytes(char8* path, uint8* buf, int bytes);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_egd")
		]
		public extern static int egd(char8* path);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_egd_bytes")
		]
		public extern static int egd_bytes(char8* path, int bytes);
#endif
		
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_poll")
		]
		public extern static int poll();
		
#if BF_PLATFORM_WINDOWS
		/* application has to include <windows.h> in order to use these */
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_screen")
		]
		public extern static void screen();
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_event")
		]
		public extern static int event(uint msg, int wParam, int lparam);
#endif
	}
	
	[AlwaysInclude]
	sealed abstract class RandDRBG
	{
		/* DRBG status values */
		[CRepr]
		public enum status_e
		{
		    DRBG_UNINITIALISED,
		    DRBG_READY,
		    DRBG_ERROR
		}
		public typealias STATUS = status_e;

		/* instantiate */
		public function int instantiate_fn(RAND_DRBG* ctx, uint8* ent, uint entlen, uint8* nonce, uint noncelen, uint8* pers, uint perslen);
		/* reseed */
		public function int reseed_fn(RAND_DRBG* ctx, uint8* ent, uint entlen, uint8* adin, uint adinlen);
		/* generate output */
		public function int generate_fn(RAND_DRBG* ctx, uint8* outVal, uint outlen, uint8* adin, uint adinlen);
		/* uninstantiate */
		public function int uninstantiate_fn(RAND_DRBG* ctx);

		/*
		 * The DRBG methods
		 */
		[CRepr]
		public struct method_st
		{
		    public instantiate_fn instantiate;
		    public reseed_fn reseed;
		    public generate_fn generate;
		    public uninstantiate_fn uninstantiate;
		}
		public typealias METHOD = method_st;

		/*
		 * The state of a DRBG AES-CTR.
		 */
		[CRepr]
		public struct ctr_st
		{
		    public EVP.CIPHER_CTX* ctx_ecb;
		    public EVP.CIPHER_CTX* ctx_ctr;
		    public EVP.CIPHER_CTX* ctx_df;
		    public EVP.CIPHER* cipher_ecb;
		    public EVP.CIPHER* cipher_ctr;
		    public uint keylen;
		    public uint8[32] K;
		    public uint8[16] V;
		    /* Temporary block storage used by ctr_df */
		    public uint8[16] bltmp;
		    public uint bltmp_pos;
		    public uint8[48] KX;
		}
		public typealias CTR = ctr_st;
		
		[CRepr]
		public struct drbg_st
		{
		    public Crypto.RWLOCK* lock;
		    public drbg_st* parent;
		    public int secure;          /* 1: allocated on the secure heap, 0: otherwise */
		    public int type;            /* the nid of the underlying algorithm */
		    /*
		     * Stores the return value of openssl_get_fork_id() as of when we last reseeded.  The DRBG reseeds automatically whenever drbg->fork_id != openssl_get_fork_id().
			 * Used to provide fork-safety and reseed this DRBG in the child process.
		     */
		    public int fork_id;
		    public uint16 flags; /* various external flags */

		    /*
		     * The random_data is used by RAND_add()/drbg_add() to attach random data to the global drbg, such that the rand_drbg_get_entropy() callback can pull it during instantiation and reseeding. This is necessary to
		     * reconcile the different philosophies of the RAND and the RAND_DRBG with respect to how randomness is added to the RNG during reseeding (see PR #4328).
		     */
		    public Rand.pool_st* seed_pool;

		    /*
		     * Auxiliary pool for additional data.
		     */
		    public Rand.pool_st* adin_pool;

		    /*
		     * The following parameters are setup by the per-type "init" function.
		     *
		     * Currently the only type is CTR_DRBG, its init function is drbg_ctr_init().
		     *
		     * The parameters are closely related to the ones described in section '10.2.1 CTR_DRBG' of [NIST SP 800-90Ar1], with one crucial difference: In the NIST standard, all counts are given
		     * in bits, whereas in OpenSSL entropy counts are given in bits and buffer lengths are given in bytes.
		     *
		     * Since this difference has lead to some confusion in the past, (see [GitHub Issue #2443], formerly [rt.openssl.org #4055]) the 'len' suffix has been added to all buffer sizes for clarification.
		     */

		    public int strength;
		    public uint max_request;
		    public uint min_entropylen;
			public uint max_entropylen;
		    public uint min_noncelen;
			public uint max_noncelen;
		    public uint max_perslen;
			public uint max_adinlen;

		    /* Counts the number of generate requests since the last reseed. */
		    public uint generate_counter;
		    /*
		     * Maximum number of generate requests until a reseed is required. This value is ignored if it is zero.
		     */
		    public uint reseed_interval;
		    /* Stores the time when the last reseeding occurred */
		    public int64 reseed_time;
		    /*
		     * Specifies the maximum time interval (in seconds) between reseeds. This value is ignored if it is zero.
		     */
		    public int64 reseed_time_interval;

		    /*
		     * Enables reseed propagation (see following comment)
		     */
		    public uint enable_reseed_propagation;

		    /*
		     * Counts the number of reseeds since instantiation.
		     * This value is ignored if enable_reseed_propagation is zero.
		     *
		     * This counter is used only for seed propagation from the <master> DRBG to its two children, the <public> and <private> DRBG. This feature is very special and its sole purpose is to ensure that any randomness which
		     * is added by RAND_add() or RAND_seed() will have an immediate effect on the output of RAND_bytes() resp. RAND_priv_bytes().
		     */
		    public volatile uint reseed_counter;

		    public uint seedlen;
		    public STATUS state;

		    /* Application data, mainly used in the KATs. */
		    public Crypto.EX_DATA ex_data;

		    /* Implementation specific data (currently only one implementation) */
			public data_struct data;

		    /* Implementation specific methods */
		    public METHOD* meth;

		    /* Callback functions.  See comments in rand_lib.c */
		    public get_entropy_fn get_entropy;
		    public cleanup_entropy_fn cleanup_entropy;
		    public get_nonce_fn get_nonce;
		    public cleanup_nonce_fn cleanup_nonce;

			[CRepr, Union]
		    public struct data_struct
			{
		        public CTR ctr;
		    }
		}
		public typealias RAND_DRBG = drbg_st;

		/*
		 * RAND_DRBG  flags
		 *
		 * Note: if new flags are added, the constant `rand_drbg_used_flags` in drbg_lib.c needs to be updated accordingly.
		 */
		
		/* In CTR mode, disable derivation function ctr_df */
		public const int FLAG_CTR_NO_DF = 0x1;
		
		/* This #define was replaced by an internal constant and should not be used. */
		public const int USED_FLAGS     = FLAG_CTR_NO_DF;
		
		/*
		 * Default security strength (in the sense of [NIST SP 800-90Ar1])
		 *
		 * NIST SP 800-90Ar1 supports the strength of the DRBG being smaller than that of the cipher by collecting less entropy. The current DRBG implementation
		 * does not take RAND_DRBG_STRENGTH into account and sets the strength of the DRBG to that of the cipher.
		 *
		 * STRENGTH is currently only used for the legacy RAND implementation.
		 *
		 * Currently supported ciphers are: NID.aes_128_ctr, NID.aes_192_ctr and NID.aes_256_ctr
		 */
		public const int STRENGTH = 256;
		/* Default drbg type */
		public const int TYPE     = NID.aes_256_ctr;
		/* Default drbg flags */
		public const int FLAGS    = 0;

		/*
		 * Object lifetime functions.
		 */
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_new")
		]
		public extern static RAND_DRBG* new_(int type, uint flags, RAND_DRBG* parent);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_secure_new")
		]
		public extern static RAND_DRBG* secure_new(int type, uint flags, RAND_DRBG* parent);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_set")
		]
		public extern static int set(RAND_DRBG* drbg, int type, uint flags);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_set_defaults")
		]
		public extern static int set_defaults(int type, uint flags);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_instantiate")
		]
		public extern static int instantiate(RAND_DRBG* drbg, uint8* pers, uint perslen);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_uninstantiate")
		]
		public extern static int uninstantiate(RAND_DRBG* drbg);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_free")
		]
		public extern static void free(RAND_DRBG* drbg);
		
		/*
		 * Object "use" functions.
		 */
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_reseed")
		]
		public extern static int reseed(RAND_DRBG* drbg, uint8* adin, uint adinlen, int prediction_resistance);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_generate")
		]
		public extern static int generate(RAND_DRBG* drbg, uint8* outVal, uint outlen, int prediction_resistance, uint8* adin, uint adinlen);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_bytes")
		]
		public extern static int bytes(RAND_DRBG* drbg, uint8* outVal, uint outlen);
		
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_set_reseed_interval")
		]
		public extern static int set_reseed_interval(RAND_DRBG* drbg, uint interval);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_set_reseed_time_interval")
		]
		public extern static int set_reseed_time_interval(RAND_DRBG* drbg, int64 interval);
		
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_set_reseed_defaults")
		]
		public extern static int set_reseed_defaults(uint master_reseed_interval, uint slave_reseed_interval, int64 master_reseed_time_interval, int64 slave_reseed_time_interval);
		
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_get0_master")
		]
		public extern static RAND_DRBG* get0_master();
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_get0_public")
		]
		public extern static RAND_DRBG* get0_public();
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_get0_private")
		]
		public extern static RAND_DRBG* get0_private();
		
		/*
		 * EXDATA
		 */
		[Inline]
		public static int get_ex_new_index(int l, void* p, Crypto.EX_new newf, Crypto.EX_dup dupf, Crypto.EX_free freef) => Crypto.get_ex_new_index(Crypto.EX_INDEX_DRBG, l, p, newf, dupf, freef);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_set_ex_data")
		]
		public extern static int set_ex_data(RAND_DRBG* drbg, int idx, void* arg);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_get_ex_data")
		]
		public extern static void* get_ex_data(RAND_DRBG* drbg, int idx);
		
		/*
		 * Callback function typedefs
		 */
		public function uint get_entropy_fn(RAND_DRBG* drbg, uint8** pout, int entropy, uint min_len, uint max_len, int prediction_resistance);
		public function void cleanup_entropy_fn(RAND_DRBG* ctx, uint8* outVal, uint outlen);
		public function uint get_nonce_fn(RAND_DRBG* drbg, uint8** pout, int entropy, uint min_len, uint max_len);
		public function void cleanup_nonce_fn(RAND_DRBG* drbg, uint8* outVal, uint outlen);
		
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("RAND_DRBG_set_callbacks")
		]
		public extern static int set_callbacks(RAND_DRBG* drbg, get_entropy_fn get_entropy, cleanup_entropy_fn cleanup_entropy, get_nonce_fn get_nonce, cleanup_nonce_fn cleanup_nonce);
	}
}
