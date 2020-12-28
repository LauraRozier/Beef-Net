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
	sealed abstract class SRP
	{
#if !OPENSSL_NO_SRP
		[CRepr]
		public struct gN_cache_st {
		    public char8* b64_bn;
		    public BN.BIGNUM* bn;
		}
		public typealias gN_cache = gN_cache_st;

		[CRepr]
		public struct user_pwd_st
		{
		    /* Owned by us. */
		    public char8* id;
		    public BN.BIGNUM* s;
		    public BN.BIGNUM* v;
		    /* Not owned by us. */
		    public BN.BIGNUM* g;
		    public BN.BIGNUM* N;
		    /* Owned by us. */
		    public char8* info;
		}
		public typealias user_pwd = user_pwd_st;

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_user_pwd_free")
		]
		public extern static void user_pwd_free(user_pwd* user_pwd);

		[CRepr]
		public struct VBASE_st {
		    public user_pwd* users_pwd;
		    public gN_cache* gN_cache;
			/* to simulate a user */
		    public char8* seed_key;
		    public BN.BIGNUM* default_g;
		    public BN.BIGNUM* default_N;
		}
		public typealias VBASE = VBASE_st;

		/*
		 * Internal structure storing N and g pair
		 */
		[CRepr]
		public struct gN_st {
		    public char8* id;
		    public BN.BIGNUM* g;
		    public BN.BIGNUM* N;
		}
		public typealias gN = gN_st;

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_VBASE_new")
		]
		public extern static VBASE* VBASE_new(char8* seed_key);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_VBASE_free")
		]
		public extern static void VBASE_free(VBASE* vb);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_VBASE_init")
		]
		public extern static int VBASE_init(VBASE* vb, char8* verifier_file);

		/* This method ignores the configured seed and fails for an unknown user. */
		//DEPRECATEDIN_1_1_0(SRP_user_pwd *SRP_VBASE_get_by_user(SRP_VBASE *vb, char *username))
		/* NOTE: unlike in SRP_VBASE_get_by_user, caller owns the returned pointer.*/
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_VBASE_get1_by_user")
		]
		public extern static user_pwd* VBASE_get1_by_user(VBASE* vb, char8* username);

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_create_verifier")
		]
		public extern static char8* create_verifier(char8* user, char8* pass, char8** salt, char8** verifier, char8* N, char8* g);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_create_verifier_BN")
		]
		public extern static int create_verifier_BN(char8* user, char8* pass, BN.BIGNUM** salt, BN.BIGNUM** verifier, BN.BIGNUM* N, BN.BIGNUM* g);

		public const int NO_ERROR                  = 0;
		public const int ERR_VBASE_INCOMPLETE_FILE = 1;
		public const int ERR_VBASE_BN_LIB          = 2;
		public const int ERR_OPEN_FILE             = 3;
		public const int ERR_MEMORY                = 4;

		public const int DB_srptype     = 0;
		public const int DB_srpverifier = 1;
		public const int DB_srpsalt     = 2;
		public const int DB_srpid       = 3;
		public const int DB_srpgN       = 4;
		public const int DB_srpinfo     = 5;
		public const int DB_NUMBER      = 6;

		public const char8 DB_SRP_INDEX   = 'I';
		public const char8 DB_SRP_VALID   = 'V';
		public const char8 DB_SRP_REVOKED = 'R';
		public const char8 DB_SRP_MODIF   = 'v';

		/* see srp.c */
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_check_known_gN_param")
		]
		public extern static char8* check_known_gN_param(BN.BIGNUM* g, BN.BIGNUM* N);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_get_default_gN")
		]
		public extern static gN* get_default_gN(char8* id);

		/* server side .... */
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_Calc_server_key")
		]
		public extern static BN.BIGNUM* Calc_server_key(BN.BIGNUM* A, BN.BIGNUM* v, BN.BIGNUM* u, BN.BIGNUM* b, BN.BIGNUM* N);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_Calc_B")
		]
		public extern static BN.BIGNUM* Calc_B(BN.BIGNUM* b, BN.BIGNUM* N, BN.BIGNUM* g, BN.BIGNUM* v);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_Verify_A_mod_N")
		]
		public extern static int Verify_A_mod_N(BN.BIGNUM* A, BN.BIGNUM* N);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_Calc_u")
		]
		public extern static BN.BIGNUM* Calc_u(BN.BIGNUM* A, BN.BIGNUM* B, BN.BIGNUM* N);

		/* client side .... */
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_Calc_x")
		]
		public extern static BN.BIGNUM* Calc_x(BN.BIGNUM* s, char8* user, char8* pass);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_Calc_A")
		]
		public extern static BN.BIGNUM* Calc_A(BN.BIGNUM* a, BN.BIGNUM* N, BN.BIGNUM* g);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_Calc_client_key")
		]
		public extern static BN.BIGNUM* Calc_client_key(BN.BIGNUM* N, BN.BIGNUM* B, BN.BIGNUM* g, BN.BIGNUM* x, BN.BIGNUM* a, BN.BIGNUM* u);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SRP_Verify_B_mod_N")
		]
		public extern static int Verify_B_mod_N(BN.BIGNUM* B, BN.BIGNUM* N);

		public const int MINIMAL_N = 1024;
#endif
		
		/*
		** MOVED for convenience
		** libssl-1_1.dll
		**	  26   19 00001474 SRP_Calc_A_param
		*/
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_SSL),
#endif
			LinkName("SRP_Calc_A_param")
		]
		public extern static int Calc_A_param(SSL.ssl_st* s);

	}
}
