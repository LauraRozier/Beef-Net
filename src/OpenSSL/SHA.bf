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
	sealed abstract class SHA
	{
		/*-
		 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		 * ! SHA_LONG has to be at least 32 bits wide.                    !
		 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		 */
		public const int LBLOCK        = 16;
		public const int CBLOCK        = LBLOCK * 4; // SHA treats input data as a contiguous array of 32 bit wide big-endian values.
		public const int LAST_BLOCK    = CBLOCK - 8;
		public const int DIGEST_LENGTH = 20;

		public typealias LONG   = uint;
		public typealias LONG64 = uint64;

		[CRepr]
		public struct state_st
		{
		    public LONG h0, h1, h2, h3, h4;
		    public LONG Nl, Nh;
		    public LONG[LBLOCK] data;
		    public uint num;
		}
		public typealias CTX = state_st;
		
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA1_Init")
		]
		public extern static int Init(CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA1_Update")
		]
		public extern static int Update(CTX* c, void* data, uint len);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA1_Final")
		]
		public extern static int Final(uint8* md, CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static uint8* SHA1(uint8* d, uint n, uint8* md);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA1_Transform")
		]
		public extern static void Transform(CTX* c, uint8* data);
	}
	
	[AlwaysInclude]
	sealed abstract class SHA224
	{
		public const int DIGEST_LENGTH = 28;

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA224_Init")
		]
		public extern static int Init(SHA256.CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA224_Update")
		]
		public extern static int Update(SHA256.CTX* c, void* data, uint len);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA224_Final")
		]
		public extern static int Final(uint8* md, SHA256.CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static uint8* SHA224(uint8* d, uint n, uint8* md);
	}
	
	[AlwaysInclude]
	sealed abstract class SHA256
	{
		/*
		 * SHA-256 treats input data as a contiguous array of 32 bit wide big-endian values.
		 */
		public const int CBLOCK        = SHA.LBLOCK * 4;
		public const int DIGEST_LENGTH = 32;

		[CRepr]
		public struct state_st
		{
		    public SHA.LONG[8] h;
		    public SHA.LONG Nl, Nh;
		    public SHA.LONG[SHA.LBLOCK] data;
		    public uint num, md_len;
		}
		public typealias CTX = state_st;

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA256_Init")
		]
		public extern static int Init(CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA256_Update")
		]
		public extern static int Update(CTX* c, void* data, uint len);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA256_Final")
		]
		public extern static int Final(uint8* md, CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static uint8* SHA256(uint8* d, uint n, uint8* md);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA256_Transform")
		]
		public extern static void Transform(CTX* c, uint8* data);
	}
	
	[AlwaysInclude]
	sealed abstract class SHA384
	{
		public const int DIGEST_LENGTH = 48;

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA384_Init")
		]
		public extern static int Init(SHA512.CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA384_Update")
		]
		public extern static int Update(SHA512.CTX* c, void* data, uint len);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA384_Final")
		]
		public extern static int Final(uint8* md, SHA512.CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static uint8* SHA384(uint8* d, uint n, uint8* md);
	}
	
	[AlwaysInclude]
	sealed abstract class SHA512
	{
		/*
		 * Unlike 32-bit digest algorithms, SHA-512 *relies* on SHA_LONG64 being exactly 64-bit wide.
		 * See Implementation Notes in sha512.c for further details.
		 *
		 * SHA-512 treats input data as a contiguous array of 64 bit wide big-endian values.
		 */
		public const int CBLOCK        = SHA.LBLOCK * 8;
		public const int DIGEST_LENGTH = 64;

		[CRepr]
		public struct state_st
		{
		    public SHA.LONG64[8] h;
		    public SHA.LONG64 Nl, Nh;
		    public data_struct u;
		    public uint num, md_len;

			[Union, CRepr]
			public struct data_struct {
		        SHA.LONG64[SHA.LBLOCK] d;
		        uint8[CBLOCK] p;
			}
		}
		public typealias CTX = state_st;

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA512_Init")
		]
		public extern static int Init(CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA512_Update")
		]
		public extern static int Update(CTX* c, void* data, uint len);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA512_Final")
		]
		public extern static int Final(uint8* md, CTX* c);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static uint8* SHA512(uint8* d, uint n, uint8* md);
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			LinkName("SHA512_Transform")
		]
		public extern static void Transform(CTX* c, uint8* data);
	}
}
