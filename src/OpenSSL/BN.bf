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
	sealed abstract class BN
	{
		[CRepr]
		public struct bignum_st
		{
		    public ULONG* d; /* Pointer to an array of 'BN_BITS2' bit chunks. */
		    public int top;  /* Index of last used d +1. */
		    /* The next are internal book keeping for bn_expand. */
		    public int dmax; /* Size of the d array. */
		    public int neg;  /* one if the number is negative */
		    public int flags;
		}
		public typealias BIGNUM = bignum_st;
		
		/* How many bignums are in each "pool item"; */
		public const int CTX_POOL_SIZE    = 16;
		/* The stack frame info is resizing, set a first-time expansion size; */
		public const int CTX_START_FRAMES = 32;

		/* A bundle of bignums that can be linked with other bundles */
		[CRepr]
		public struct bignum_pool_item
		{
		    /* The bignum values */
		    public BIGNUM[CTX_POOL_SIZE] vals;
		    /* Linked-list admin */
		    public bignum_pool_item* prev, next;
		}
		public typealias POOL_ITEM = bignum_pool_item;

		/* A linked-list of bignums grouped in bundles */
		[CRepr]
		public struct bignum_pool
		{
		    /* Linked-list admin */
		    public POOL_ITEM* head, current, tail;
		    /* Stack depth and allocation size */
		    public uint used, size;
		}
		public typealias POOL = bignum_pool;

		/* A wrapper to manage the "stack frames" */
		[CRepr]
		public struct bignum_ctx_stack
		{
		    /* Array of indexes into the bignum stack */
		    public uint* indexes;
		    /* Number of stack frames, and the size of the allocated array */
		    public uint depth, size;
		}
		public typealias STACK = bignum_ctx_stack;

		[CRepr]
		public struct bignum_ctx
		{
			/* The bignum bundles */
			public POOL pool;
			/* The "stack frames", if you will */
			public STACK stack_;
			/* The number of bignums currently assigned */
			public uint used;
			/* Depth of stack overflow */
			public int err_stack;
			/* Block "gets" until an "end" (compatibility behaviour) */
			public int too_many;
			/* Flags. */
			public int flags;
		}
		public typealias CTX = bignum_ctx;

		[CRepr]
		public struct blinding_st
		{
		    public BIGNUM* A;
		    public BIGNUM* Ai;
		    public BIGNUM* e;
		    public BIGNUM* mod;                /* just a reference */
		    public Crypto.THREAD_ID tid;
		    public int counter;
		    public uint flags;
		    public MONT_CTX* m_ctx;
		    public function int(BIGNUM* r, BIGNUM* a, BIGNUM* p, BIGNUM* m, CTX* ctx, MONT_CTX* m_ctx) bn_mod_exp;
		    public Crypto.RWLOCK* lock;
		}
		public typealias BLINDING = blinding_st;

		[CRepr]
		public struct mont_ctx_st
		{
			public int ri;      /* number of bits in R */
			public BIGNUM RR;   /* used to convert to montgomery form, possibly zero-padded */
			public BIGNUM N;    /* The modulus */
			public BIGNUM Ni;   /* R*(1/R mod N) - N*Ni = 1 (Ni is only stored for bignum algorithm) */
			public ULONG[2] n0; /* least significant word(s) of Ni; (type changed with 0.9.9, was "BN_ULONG n0;" before) */
			public int flags;
		}
		public typealias MONT_CTX = mont_ctx_st;

		[CRepr]
		public struct recp_ctx_st
		{
			public BIGNUM N;     /* the divisor */
			public BIGNUM Nr;    /* the reciprocal */
			public int num_bits;
			public int shift;
			public int flags;
		}
		public typealias RECP_CTX = recp_ctx_st;

		[CRepr]
		public struct gencb_st
		{
		    uint ver;     /* To handle binary (in)compatibility */
		    void* arg;    /* callback-specific data */
			cb_struct cb;

			[Union, CRepr]
			public struct cb_struct
			{
		        /* if (ver==1) - handles old style callbacks */
		        function void(int, int, void*) cb_1;
		        /* if (ver==2) - new callback style */
		        function int(int, int, GENCB*) cb_2;
		    }
		}
		public typealias GENCB = gencb_st;

		/*
		 * 64-bit processor with LP64 ABI
		 */
#if SIXTY_FOUR_BIT_LONG
		public typealias ULONG = uint64;
		public const int BYTES = 8;
#endif

		/*
		 * 64-bit processor other than LP64 ABI
		 */
#if SIXTY_FOUR_BIT
		public typealias ULONG = uint64;
		public const int BYTES = 8;
#endif
		
		/*
		 * 32-bit processor
		 */
#if THIRTY_TWO_BIT
		public typealias ULONG = uint32;
		public const int BYTES = 4;
#endif

		public const ULONG BITS2 = BYTES * 8;
		public const ULONG BITS  = BITS2 * 2;
		public const ULONG TBIT  = (ULONG)1 << (BITS2 - 1);

		public const int FLG_MALLOCED    = 0x01;
		public const int FLG_STATIC_DATA = 0x02;

		/*
		 * avoid leaking exponent information through timing,
		 * BN_mod_exp_mont() will call BN_mod_exp_mont_consttime,
		 * BN_div() will call BN_div_no_branch,
		 * BN_mod_inverse() will call bn_mod_inverse_no_branch.
		 */
		public const int FLG_CONSTTIME = 0x04;
		public const int FLG_SECURE    = 0x08;

		/* deprecated name for the flag */
		public const int FLG_EXP_CONSTTIME = FLG_CONSTTIME;
		public const int FLG_FREE          = 0x8000; /* used for debugging */
		
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_set_flags")]
		public extern static void set_flags(BIGNUM* b, int n);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_flags")]
		public extern static int get_flags(BIGNUM* b, int n);

		/* Values for |top| in BN_rand() */
		public const int RAND_TOP_ANY = -1;
		public const int RAND_TOP_ONE = 0;
		public const int RAND_TOP_TWO = 1;

		/* Values for |bottom| in BN_rand() */
		public const int RAND_BOTTOM_ANY = 0;
		public const int RAND_BOTTOM_ODD = 1;
		
		/*
		 * get a clone of a BIGNUM with changed flags, for *temporary* use only (the
		 * two BIGNUMs cannot be used in parallel!). Also only for *read only* use. The
		 * value |dest| should be a newly allocated BIGNUM obtained via BN_new() that
		 * has not been otherwise initialised or used.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_with_flags")]
		public extern static void with_flags(BIGNUM* dest, BIGNUM* b, int flags);

		/* Wrapper function to make using BN_GENCB easier */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_flags")]
		public extern static int BN_GENCB_call(GENCB* cb, int a, int b);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GENCB_new")]
		public extern static GENCB* GENCB_new();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GENCB_free")]
		public extern static void GENCB_free(GENCB* cb);

		/* Populate a BN_GENCB structure with an "old"-style callback */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GENCB_set_old")]
		public extern static void GENCB_set_old(GENCB* gencb, function void(int, int, void*) callback, void* cb_arg);

		/* Populate a BN_GENCB structure with a "new"-style callback */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GENCB_set")]
		public extern static void GENCB_set(GENCB* gencb, function int(int, int, GENCB*) callback, void* cb_arg);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GENCB_get_arg")]
		public extern static void* GENCB_get_arg(GENCB* cb);

		public const int prime_checks = 0; /* default: select number of iterations based on the size of the number */

		/*
		 * BN_prime_checks_for_size() returns the number of Miller-Rabin iterations
		 * that will be done for checking that a random number is probably prime. The
		 * error rate for accepting a composite number as prime depends on the size of
		 * the prime |b|. The error rates used are for calculating an RSA key with 2 primes,
		 * and so the level is what you would expect for a key of double the size of the
		 * prime.
		 *
		 * This table is generated using the algorithm of FIPS PUB 186-4
		 * Digital Signature Standard (DSS), section F.1, page 117.
		 * (https://dx.doi.org/10.6028/NIST.FIPS.186-4)
		 *
		 * The following magma script was used to generate the output:
		 * securitybits:=125;
		 * k:=1024;
		 * for t:=1 to 65 do
		 *   for M:=3 to Floor(2*Sqrt(k-1)-1) do
		 *     S:=0;
		 *     // Sum over m
		 *     for m:=3 to M do
		 *       s:=0;
		 *       // Sum over j
		 *       for j:=2 to m do
		 *         s+:=(RealField(32)!2)^-(j+(k-1)/j);
		 *       end for;
		 *       S+:=2^(m-(m-1)*t)*s;
		 *     end for;
		 *     A:=2^(k-2-M*t);
		 *     B:=8*(Pi(RealField(32))^2-6)/3*2^(k-2)*S;
		 *     pkt:=2.00743*Log(2)*k*2^-k*(A+B);
		 *     seclevel:=Floor(-Log(2,pkt));
		 *     if seclevel ge securitybits then
		 *       printf "k: %5o, security: %o bits  (t: %o, M: %o)\n",k,seclevel,t,M;
		 *       break;
		 *     end if;
		 *   end for;
		 *   if seclevel ge securitybits then break; end if;
		 * end for;
		 *
		 * It can be run online at:
		 * http://magma.maths.usyd.edu.au/calc
		 *
		 * And will output:
		 * k:  1024, security: 129 bits  (t: 6, M: 23)
		 *
		 * k is the number of bits of the prime, securitybits is the level we want to
		 * reach.
		 *
		 * prime length | RSA key size | # MR tests | security level
		 * -------------+--------------|------------+---------------
		 *  (b) >= 6394 |     >= 12788 |          3 |        256 bit
		 *  (b) >= 3747 |     >=  7494 |          3 |        192 bit
		 *  (b) >= 1345 |     >=  2690 |          4 |        128 bit
		 *  (b) >= 1080 |     >=  2160 |          5 |        128 bit
		 *  (b) >=  852 |     >=  1704 |          5 |        112 bit
		 *  (b) >=  476 |     >=   952 |          5 |         80 bit
		 *  (b) >=  400 |     >=   800 |          6 |         80 bit
		 *  (b) >=  347 |     >=   694 |          7 |         80 bit
		 *  (b) >=  308 |     >=   616 |          8 |         80 bit
		 *  (b) >=   55 |     >=   110 |         27 |         64 bit
		 *  (b) >=    6 |     >=    12 |         34 |         64 bit
		 */

		[Inline]
		public static int prime_checks_for_size(int b) => b >= 3747 ? 3 :
			b >= 1345 ? 4 :
				b >= 476 ? 5 :
					b >= 400 ? 6 :
						b >= 347 ? 7 :
							b >= 308 ? 8 :
								b >= 55 ? 27 :
									/* b >= 6 */ 34;
		
		[Inline]
		public static int num_bytes(BIGNUM* a) => (num_bits(a) + 7) / 8;

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_abs_is_word")]
		public extern static int abs_is_word(BIGNUM* a, ULONG w);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_zero")]
		public extern static int is_zero(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_one")]
		public extern static int is_one(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_word")]
		public extern static int is_word(BIGNUM* a, ULONG w);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_odd")]
		public extern static int is_odd(BIGNUM* a);

		[Inline]
		public static int one(BIGNUM* a) => set_word(a, 1);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_zero_ex")]
		public extern static void zero_ex(BIGNUM* a);

		// #if OPENSSL_API_COMPAT >= 0x00908000L
		// public static int zero(BIGNUM* a) => zero_ex(a);
		// #else
		public static int BN_zero(BIGNUM* a) => set_word(a, 0);
		// #endif

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_value_one")]
		public extern static BIGNUM* value_one();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_options")]
		public extern static char8* options();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_CTX_new")]
		public extern static CTX* CTX_new();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_CTX_secure_new")]
		public extern static CTX* CTX_secure_new();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_CTX_free")]
		public extern static void CTX_free(CTX* c);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_CTX_start")]
		public extern static void CTX_start(CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_CTX_get")]
		public extern static BIGNUM* CTX_get(CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_CTX_end")]
		public extern static void CTX_end(CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_rand")]
		public extern static int rand(BIGNUM* rnd, int bits, int top, int bottom);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_priv_rand")]
		public extern static int priv_rand(BIGNUM* rnd, int bits, int top, int bottom);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_rand_range")]
		public extern static int rand_range(BIGNUM* rnd, BIGNUM* range);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_priv_rand_range")]
		public extern static int priv_rand_range(BIGNUM* rnd, BIGNUM* range);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_pseudo_rand")]
		public extern static int pseudo_rand(BIGNUM* rnd, int bits, int top, int bottom);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_pseudo_rand_range")]
		public extern static int pseudo_rand_range(BIGNUM* rnd, BIGNUM* range);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_num_bits")]
		public extern static int num_bits(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_num_bits_word")]
		public extern static int num_bits_word(ULONG l);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_security_bits")]
		public extern static int security_bits(int L, int N);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_new")]
		public extern static BIGNUM* new_();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_secure_new")]
		public extern static BIGNUM* secure_new();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_clear_free")]
		public extern static void clear_free(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_copy")]
		public extern static BIGNUM* copy(BIGNUM* a, BIGNUM* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_swap")]
		public extern static void swap(BIGNUM* a, BIGNUM* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_bin2bn")]
		public extern static BIGNUM* bin2bn(uint8* s, int len, BIGNUM* ret);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_bn2bin")]
		public extern static int bn2bin(BIGNUM* a, uint8* to);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_bn2binpad")]
		public extern static int bn2binpad(BIGNUM* a, uint8* to, int tolen);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_lebin2bn")]
		public extern static BIGNUM* lebin2bn(uint8* s, int len, BIGNUM* ret);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_bn2lebinpad")]
		public extern static int bn2lebinpad(BIGNUM* a, uint8* to, int tolen);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mpi2bn")]
		public extern static BIGNUM* mpi2bn(uint8* s, int len, BIGNUM* ret);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_bn2mpi")]
		public extern static int bn2mpi(BIGNUM* a, uint8* to);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_sub")]
		public extern static int sub(BIGNUM* r, BIGNUM* a, BIGNUM* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_usub")]
		public extern static int usub(BIGNUM* r, BIGNUM* a, BIGNUM* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_uadd")]
		public extern static int uadd(BIGNUM* r, BIGNUM* a, BIGNUM* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_add")]
		public extern static int add(BIGNUM* r, BIGNUM* a, BIGNUM* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mul")]
		public extern static int mul(BIGNUM* r, BIGNUM* a, BIGNUM* b, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_sqr")]
		public extern static int sqr(BIGNUM* r, BIGNUM* a, CTX* ctx);
		/** BN_set_negative sets sign of a BIGNUM
		 * \param  b  pointer to the BIGNUM object
		 * \param  n  0 if the BIGNUM b should be positive and a value != 0 otherwise
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_set_negative")]
		public extern static void set_negative(BIGNUM* b, int n);
		/** BN_is_negative returns 1 if the BIGNUM is negative
		 * \param  b  pointer to the BIGNUM object
		 * \return 1 if a < 0 and 0 otherwise
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_negative")]
		public extern static int is_negative(BIGNUM* b);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_div")]
		public extern static int div(BIGNUM* dv, BIGNUM* rem, BIGNUM* m, BIGNUM* d, CTX* ctx);
		//# define BN_mod(rem,m,d,ctx) BN_div(NULL,(rem),(m),(d),(ctx))
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_nnmod")]
		public extern static int nnmod(BIGNUM* r, BIGNUM* m, BIGNUM* d, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_add")]
		public extern static int mod_add(BIGNUM* r, BIGNUM* a, BIGNUM* b, BIGNUM* m, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_add_quick")]
		public extern static int mod_add_quick(BIGNUM* r, BIGNUM* a, BIGNUM* b, BIGNUM* m);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_sub")]
		public extern static int mod_sub(BIGNUM* r, BIGNUM* a, BIGNUM* b, BIGNUM* m, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_sub_quick")]
		public extern static int mod_sub_quick(BIGNUM* r, BIGNUM* a, BIGNUM* b, BIGNUM* m);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_mul")]
		public extern static int mod_mul(BIGNUM* r, BIGNUM* a, BIGNUM* b, BIGNUM* m, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_sqr")]
		public extern static int mod_sqr(BIGNUM* r, BIGNUM* a, BIGNUM* m, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_lshift1")]
		public extern static int mod_lshift1(BIGNUM* r, BIGNUM* a, BIGNUM* m, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_lshift1_quick")]
		public extern static int mod_lshift1_quick(BIGNUM* r, BIGNUM* a, BIGNUM* m);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_lshift")]
		public extern static int mod_lshift(BIGNUM* r, BIGNUM* a, int n, BIGNUM* m, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_lshift_quick")]
		public extern static int mod_lshift_quick(BIGNUM* r, BIGNUM* a, int n, BIGNUM* m);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_word")]
		public extern static ULONG mod_word(BIGNUM* a, ULONG w);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_div_word")]
		public extern static ULONG div_word(BIGNUM* a, ULONG w);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mul_word")]
		public extern static int mul_word(BIGNUM* a, ULONG w);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_add_word")]
		public extern static int add_word(BIGNUM* a, ULONG w);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_sub_word")]
		public extern static int sub_word(BIGNUM* a, ULONG w);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_set_word")]
		public extern static int set_word(BIGNUM* a, ULONG w);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_word")]
		public extern static ULONG get_word(BIGNUM* a);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_cmp")]
		public extern static int cmp(BIGNUM* a, BIGNUM* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_free")]
		public extern static void free(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_bit_set")]
		public extern static int is_bit_set(BIGNUM* a, int n);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_lshift")]
		public extern static int lshift(BIGNUM* r, BIGNUM* a, int n);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_lshift1")]
		public extern static int lshift1(BIGNUM* r, BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_exp")]
		public extern static int exp(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_exp")]
		public extern static int mod_exp(BIGNUM* r, BIGNUM* a, BIGNUM* p, BIGNUM* m, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_exp_mont")]
		public extern static int mod_exp_mont(BIGNUM* r, BIGNUM* a, BIGNUM* p, BIGNUM* m, CTX* ctx, MONT_CTX* m_ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_exp_mont_consttime")]
		public extern static int mod_exp_mont_consttime(BIGNUM* rr, BIGNUM* a, BIGNUM* p, BIGNUM* m, CTX* ctx, MONT_CTX* in_mont);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_exp_mont_word")]
		public extern static int mod_exp_mont_word(BIGNUM* r, ULONG a, BIGNUM* p, BIGNUM* m, CTX* ctx, MONT_CTX* m_ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_exp2_mont")]
		public extern static int mod_exp2_mont(BIGNUM* r, BIGNUM* a1, BIGNUM* p1, BIGNUM* a2, BIGNUM* p2, BIGNUM* m, CTX* ctx, MONT_CTX* m_ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_exp_simple")]
		public extern static int mod_exp_simple(BIGNUM* r, BIGNUM* a, BIGNUM* p, BIGNUM* m, CTX* ctx);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mask_bits")]
		public extern static int mask_bits(BIGNUM* a, int n);
#if !OPENSSL_NO_STDIO
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_print_fp")]
		public extern static int print_fp(Platform.BfpFile* fp, BIGNUM* a);
		[Inline]
		public static int print_fp(StringView filename, BIGNUM* a)
		{
			Platform.BfpFileResult fileResult = .Ok;
			Platform.BfpFile* fp = Platform.BfpFile_Create(
				filename.ToScopeCStr!(128),
				.CreateAlways,
				.Read | .Write | .Append,
				.Normal,
				&fileResult
			);

			if (fp == null || fileResult != .Ok) {
				switch (fileResult) {
					case .ShareError:
						return -3;
					case .NotFound:
						return -2;
					default:
						return -1;
				}
			}

			int res = print_fp(fp, a);
			Platform.BfpFile_Release(fp);
			return res;
		}
#endif
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_print")]
		public extern static int print(BIO_C.bio_st* bio, BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_reciprocal")]
		public extern static int reciprocal(BIGNUM* r, BIGNUM* m, int len, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_rshift")]
		public extern static int rshift(BIGNUM* r, BIGNUM* a, int n);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_rshift1")]
		public extern static int rshift1(BIGNUM* r, BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_clear")]
		public extern static void clear(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_dup")]
		public extern static BIGNUM* dup(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_ucmp")]
		public extern static int ucmp(BIGNUM* a, BIGNUM* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_set_bit")]
		public extern static int set_bit(BIGNUM* a, int n);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_clear_bit")]
		public extern static int clear_bit(BIGNUM* a, int n);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_bn2hex")]
		public extern static char8* bn2hex(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_bn2dec")]
		public extern static char8* bn2dec(BIGNUM* a);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_hex2bn")]
		public extern static int hex2bn(BIGNUM** a, char8* str);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_dec2bn")]
		public extern static int dec2bn(BIGNUM** a, char8* str);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_asc2bn")]
		public extern static int asc2bn(BIGNUM** a, char8* str);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_gcd")]
		public extern static int gcd(BIGNUM* r, BIGNUM* a, BIGNUM* b, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_kronecker")]
		public extern static int kronecker(BIGNUM* a, BIGNUM* b, CTX* ctx); /* returns -2 for error */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_inverse")]
		public extern static BIGNUM* mod_inverse(BIGNUM* ret, BIGNUM* a, BIGNUM* n, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_sqrt")]
		public extern static BIGNUM* mod_sqrt(BIGNUM* ret, BIGNUM* a, BIGNUM* n, CTX* ctx);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_consttime_swap")]
		public extern static void consttime_swap(ULONG swap, BIGNUM* a, BIGNUM* b, int nwords);

		/* Deprecated versions */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_generate_prime")]
		public extern static BIGNUM* generate_prime(BIGNUM* ret, int bits, int safe, BIGNUM* add, BIGNUM* rem, function void(int, int, void*) callback, void* cb_arg);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_prime")]
		public extern static int is_prime(BIGNUM* p, int nchecks, function void(int, int, void*) callback, CTX* ctx, void* cb_arg);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_prime_fasttest")]
		public extern static int is_prime_fasttest(BIGNUM* p, int nchecks, function void(int, int, void*) callback, CTX* ctx, void* cb_arg, int do_trial_division);

		/* Newer versions */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_generate_prime_ex")]
		public extern static int generate_prime_ex(BIGNUM* ret, int bits, int safe, BIGNUM* add, BIGNUM* rem, GENCB* cb);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_prime_ex")]
		public extern static int is_prime_ex(BIGNUM* p, int nchecks, CTX* ctx, GENCB* cb);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_is_prime_fasttest_ex")]
		public extern static int is_prime_fasttest_ex(BIGNUM* p, int nchecks, CTX* ctx, int do_trial_division, GENCB* cb);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_X931_generate_Xpq")]
		public extern static int X931_generate_Xpq(BIGNUM* Xp, BIGNUM* Xq, int nbits, CTX* ctx);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_X931_derive_prime_ex")]
		public extern static int X931_derive_prime_ex(BIGNUM* p, BIGNUM* p1, BIGNUM* p2, BIGNUM* Xp, BIGNUM* Xp1, BIGNUM* Xp2, BIGNUM* e, CTX* ctx, GENCB* cb);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_X931_generate_prime_ex")]
		public extern static int X931_generate_prime_ex(BIGNUM* p, BIGNUM* p1, BIGNUM* p2, BIGNUM* Xp1, BIGNUM* Xp2, BIGNUM* Xp, BIGNUM* e, CTX* ctx, GENCB* cb);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_MONT_CTX_new")]
		public extern static MONT_CTX* MONT_CTX_new();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_mul_montgomery")]
		public extern static int mod_mul_montgomery(BIGNUM* r, BIGNUM* a, BIGNUM* b, MONT_CTX* mont, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_to_montgomery")]
		public extern static int to_montgomery(BIGNUM* r, BIGNUM* a, MONT_CTX* mont, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_from_montgomery")]
		public extern static int from_montgomery(BIGNUM* r, BIGNUM* a, MONT_CTX* mont, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_MONT_CTX_free")]
		public extern static void MONT_CTX_free(MONT_CTX* mont);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_MONT_CTX_set")]
		public extern static int MONT_CTX_set(MONT_CTX* mont, BIGNUM* mod, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_MONT_CTX_copy")]
		public extern static MONT_CTX* MONT_CTX_copy(MONT_CTX* to, MONT_CTX* from);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_MONT_CTX_set_locked")]
		public extern static MONT_CTX* MONT_CTX_set_locked(MONT_CTX** pmont, Crypto.RWLOCK* lock, BIGNUM* mod, CTX* ctx);

		/* BN_BLINDING flags */
		public const int BLINDING_NO_UPDATE   = 0x00000001;
		public const int BLINDING_NO_RECREATE = 0x00000002;

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_new")]
		public extern static BLINDING* BLINDING_new(BIGNUM* A, BIGNUM* Ai, BIGNUM* mod);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_free")]
		public extern static void BLINDING_free(BLINDING* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_update")]
		public extern static int BLINDING_update(BLINDING* b, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_convert")]
		public extern static int BLINDING_convert(BIGNUM* n, BLINDING* b, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_invert")]
		public extern static int BLINDING_invert(BIGNUM* n, BLINDING* b, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_convert_ex")]
		public extern static int BLINDING_convert_ex(BIGNUM* n, BIGNUM* r, BLINDING* b, CTX* c);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_invert_ex")]
		public extern static int BLINDING_invert_ex(BIGNUM* n, BIGNUM* r, BLINDING* b, CTX* c);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_is_current_thread")]
		public extern static int BLINDING_is_current_thread(BLINDING* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_set_current_thread")]
		public extern static void BLINDING_set_current_thread(BLINDING* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_lock")]
		public extern static int BLINDING_lock(BLINDING* b);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_unlock")]
		public extern static int BLINDING_unlock(BLINDING* b);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_get_flags")]
		public extern static uint BLINDING_get_flags(BLINDING* flags);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_set_flags")]
		public extern static void BLINDING_set_flags(BLINDING* flag, uint val);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_BLINDING_create_param")]
		public extern static BLINDING* BLINDING_create_param(BLINDING* b, BIGNUM* e, BIGNUM* m, CTX* ctx,
			function int(BIGNUM* r, BIGNUM* a, BIGNUM* p, BIGNUM* m, CTX* ctx, MONT_CTX* m_ctx) mod_exp, MONT_CTX* m_ctx);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_set_params")]
		public extern static void set_params(int mul, int high, int low, int mont);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_params")]
		public extern static int get_params(int which); /* 0, mul, 1 high, 2 low, 3 mont */

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_RECP_CTX_new")]
		public extern static RECP_CTX* RECP_CTX_new();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_RECP_CTX_free")]
		public extern static void RECP_CTX_free(RECP_CTX* recp);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_RECP_CTX_set")]
		public extern static int RECP_CTX_set(RECP_CTX* recp, BIGNUM* rdiv, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_mul_reciprocal")]
		public extern static int mod_mul_reciprocal(BIGNUM* r, BIGNUM* x, BIGNUM* y, RECP_CTX* recp, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_mod_exp_recp")]
		public extern static int mod_exp_recp(BIGNUM* r, BIGNUM* a, BIGNUM* p, BIGNUM* m, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_div_recp")]
		public extern static int div_recp(BIGNUM* dv, BIGNUM* rem, BIGNUM* m, RECP_CTX* recp, CTX* ctx);

#if !OPENSSL_NO_EC2M
		/*
		 * Functions for arithmetic over binary polynomials represented by BIGNUMs.
		 * The BIGNUM::neg property of BIGNUMs representing binary polynomials is
		 * ignored. Note that input arguments are not const so that their bit arrays
		 * can be expanded to the appropriate size if needed.
		 */

		/*
		 * r = a + b
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_add")]
		public extern static int GF2m_add(BIGNUM* r, BIGNUM* a, BIGNUM* b);
		[Inline]
		public static int GF2m_sub(BIGNUM* r, BIGNUM* a, BIGNUM* b) => GF2m_add(r, a, b);
		/*
		 * r=a mod p
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod")]
		public extern static int GF2m_mod(BIGNUM* r, BIGNUM* a, BIGNUM* p);
		/* r = (a * b) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_mul")]
		public extern static int GF2m_mod_mul(BIGNUM* r, BIGNUM* a, BIGNUM* b, BIGNUM* p, CTX* ctx);
		/* r = (a * a) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_sqr")]
		public extern static int GF2m_mod_sqr(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);
		/* r = (1 / b) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_inv")]
		public extern static int GF2m_mod_inv(BIGNUM* r, BIGNUM* b, BIGNUM* p, CTX* ctx);
		/* r = (a / b) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_div")]
		public extern static int GF2m_mod_div(BIGNUM* r, BIGNUM* a, BIGNUM* b, BIGNUM* p, CTX* ctx);
		/* r = (a ^ b) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_exp")]
		public extern static int GF2m_mod_exp(BIGNUM* r, BIGNUM* a, BIGNUM* b, BIGNUM* p, CTX* ctx);
		/* r = sqrt(a) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_sqrt")]
		public extern static int GF2m_mod_sqrt(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);
		/* r^2 + r = a mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_solve_quad")]
		public extern static int GF2m_mod_solve_quad(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);
		[Inline]
		public static int GF2m_cmp(BIGNUM* a, BIGNUM* b) => ucmp(a, b);
		/*-
		 * Some functions allow for representation of the irreducible polynomials
		 * as an unsigned int[], say p.  The irreducible f(t) is then of the form:
		 *     t^p[0] + t^p[1] + ... + t^p[k]
		 * where m = p[0] > p[1] > ... > p[k] = 0.
		 */
		/* r = a mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_arr")]
		public extern static int GF2m_mod_arr(BIGNUM* r, BIGNUM* a, int[] p);
		/* r = (a * b) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_mul_arr")]
		public extern static int GF2m_mod_mul_arr(BIGNUM* r, BIGNUM* a, BIGNUM* b, int[] p, CTX* ctx);
		/* r = (a * a) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_sqr_arr")]
		public extern static int GF2m_mod_sqr_arr(BIGNUM* r, BIGNUM* a, int[] p, CTX* ctx);
		/* r = (1 / b) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_inv_arr")]
		public extern static int GF2m_mod_inv_arr(BIGNUM* r, BIGNUM* b, int[] p, CTX* ctx);
		/* r = (a / b) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_div_arr")]
		public extern static int GF2m_mod_div_arr(BIGNUM* r, BIGNUM* a, BIGNUM* b, int[] p, CTX* ctx);
		/* r = (a ^ b) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_exp_arr")]
		public extern static int GF2m_mod_exp_arr(BIGNUM* r, BIGNUM* a, BIGNUM* b, int[] p, CTX* ctx);
		/* r = sqrt(a) mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_sqrt_arr")]
		public extern static int GF2m_mod_sqrt_arr(BIGNUM* r, BIGNUM* a, int[] p, CTX* ctx);
		/* r^2 + r = a mod p */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_mod_solve_quad_arr")]
		public extern static int GF2m_mod_solve_quad_arr(BIGNUM* r, BIGNUM* a, int[] p, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_poly2arr")]
		public extern static int GF2m_poly2arr(BIGNUM* a, int[] p, int max);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_GF2m_arr2poly")]
		public extern static int GF2m_arr2poly(int[] p, BIGNUM* a);
#endif

		/*
		 * faster mod functions for the 'NIST primes' 0 <= a < p^2
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_nist_mod_192")]
		public extern static int nist_mod_192(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_nist_mod_224")]
		public extern static int nist_mod_224(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_nist_mod_256")]
		public extern static int nist_mod_256(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_nist_mod_384")]
		public extern static int nist_mod_384(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_nist_mod_521")]
		public extern static int nist_mod_521(BIGNUM* r, BIGNUM* a, BIGNUM* p, CTX* ctx);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get0_nist_prime_192")]
		public extern static BIGNUM* get0_nist_prime_192();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get0_nist_prime_224")]
		public extern static BIGNUM* get0_nist_prime_224();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get0_nist_prime_256")]
		public extern static BIGNUM* get0_nist_prime_256();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get0_nist_prime_384")]
		public extern static BIGNUM* get0_nist_prime_384();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get0_nist_prime_521")]
		public extern static BIGNUM* get0_nist_prime_521();

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_nist_mod_func")]
		public extern static function int(BIGNUM* p) nist_mod_func(BIGNUM* r, BIGNUM* a, BIGNUM* field, CTX* ctx);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_generate_dsa_nonce")]
		public extern static int generate_dsa_nonce(BIGNUM* outVal, BIGNUM* range, BIGNUM* priv, uint8* message, uint message_len, CTX* ctx);

		/* Primes from RFC 2409 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_rfc2409_prime_768")]
		public extern static BIGNUM* get_rfc2409_prime_768(BIGNUM* bn);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_rfc2409_prime_1024")]
		public extern static BIGNUM* get_rfc2409_prime_1024(BIGNUM* bn);

		/* Primes from RFC 3526 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_rfc3526_prime_1536")]
		public extern static BIGNUM* get_rfc3526_prime_1536(BIGNUM* bn);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_rfc3526_prime_2048")]
		public extern static BIGNUM* get_rfc3526_prime_2048(BIGNUM* bn);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_rfc3526_prime_3072")]
		public extern static BIGNUM* get_rfc3526_prime_3072(BIGNUM* bn);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_rfc3526_prime_4096")]
		public extern static BIGNUM* get_rfc3526_prime_4096(BIGNUM* bn);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_rfc3526_prime_6144")]
		public extern static BIGNUM* get_rfc3526_prime_6144(BIGNUM* bn);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_get_rfc3526_prime_8192")]
		public extern static BIGNUM* get_rfc3526_prime_8192(BIGNUM* bn);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("BN_bntest_rand")]
		public extern static int bntest_rand(BIGNUM* rnd, int bits, int top, int bottom);
	}
}