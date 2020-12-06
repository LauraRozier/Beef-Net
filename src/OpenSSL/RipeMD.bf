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
	sealed abstract class RipeMD160
	{
#if !OPENSSL_NO_RMD160
		public typealias LONG = uint;
		
		public const int CBLOCK        = 64;
		public const int LBLOCK        = CBLOCK / 4;
		public const int DIGEST_LENGTH = 20;
		
		[CRepr]
		public struct state_st
		{
		    public LONG A;
		    public LONG B;
		    public LONG C;
		    public LONG D;
		    public LONG E;
		    public LONG Nl;
		    public LONG Nh;
		    public LONG[LBLOCK] data;
		    public uint num;
		}
		public typealias CTX = state_st;
		
		[Import(OPENSSL_LIB_CRYPTO), LinkName("RIPEMD160_Init")]
		public extern static int Init(CTX* c);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("RIPEMD160_Update")]
		public extern static int Update(CTX* c, void* data, uint len);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("RIPEMD160_Final")]
		public extern static int Final(uint8* md, CTX* c);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("RIPEMD160")]
		public extern static uint8* RIPEMD160_(uint8* d, uint n, uint8* md);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("RIPEMD160_Transform")]
		public extern static void Transform(CTX* c, uint8* b);
#endif
	}
}
