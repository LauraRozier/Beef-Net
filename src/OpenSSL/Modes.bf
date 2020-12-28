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
	sealed abstract class Modes
	{
		public function void block128_f(uint8[16] inVal, uint8[16] outVal, void* key);
		public function void cbc128_f(uint8* inVal, uint8* outVal, uint len, void* key, uint8[16] ivec, int enc);
		public function void ctr128_f(uint8* inVal, uint8* outVal, uint blocks, void* key, uint8[16] ivec);
		public function void ccm128_f(uint8* inVal, uint8* outVal, uint blocks, void* key, uint8[16] ivec, uint8[16] cmac);

		[CRepr]
		public struct u128
		{
		    public uint64 hi;
			public uint64 lo;
		}

		[CRepr]
		public struct gcm128_context
		{
		    /* Following 6 names follow names in GCM specification */
		    public internal_struct Yi;
			public internal_struct EKi;
			public internal_struct EK0;
			public internal_struct len;
			public internal_struct Xi;
			public internal_struct H;
		    /* Relative position of Xi, H and pre-computed Htable is used in some assembler modules, i.e. don't change the order! */
		    public u128[16] Htable;
		    public function void(uint64[2] Xi, u128[16] Htable) gmult;
		    public function void(uint64[2] Xi, u128[16] Htable, uint8* inp, uint len) ghash;
		    public uint mres;
			public uint ares;
		    public block128_f block;
		    public void* key;
#if !OPENSSL_SMALL_FOOTPRINT
		    public uint8[48] Xn;
#endif

			[CRepr, Union]
			public struct internal_struct
			{
		        public uint64[2] u;
		        public uint32[4] d;
		        public uint8[16] c;
		        public uint[16 / sizeof(uint)] t;
			}
		}
		public typealias GCM128_CONTEXT = gcm128_context;

		[CRepr]
		public struct ccm128_context
		{
		    public internal_struct nonce;
			public internal_struct cmac;
		    public uint64 blocks;
		    public block128_f block;
		    public void* key;

			[CRepr, Union]
			public struct internal_struct
			{
		        public uint64[2] u;
		        public uint8[16] c;
			}
		}
		public typealias CCM128_CONTEXT = ccm128_context;

		[CRepr]
		public struct xts128_context
		{
		    public void* key1;
			public void* key2;
		    public block128_f block1;
			public block128_f block2;
		}
		public typealias XTS128_CONTEXT = xts128_context;

#if !OPENSSL_NO_OCB
		[CRepr, Union]
		public struct BLOCK
		{
		    public uint64[2] a;
		    public uint8[16] c;
		}

		[CRepr]
		public struct ocb128_context
		{
		    /* Need both encrypt and decrypt key schedules for decryption */
		    public block128_f encrypt;
		    public block128_f decrypt;
		    public void* keyenc;
		    public void* keydec;
		    public ocb128_f stream;    /* direction dependent */
		    /* Key dependent variables. Can be reused if key remains the same */
		    public uint l_index;
		    public uint max_l_index;
		    public BLOCK l_star;
		    public BLOCK l_dollar;
		    public BLOCK* l;
		    /* Must be reset for each session */
			public sess_struct sess;

			[CRepr, Union]
		    public struct sess_struct
			{
		        public uint64 blocks_hashed;
		        public uint64 blocks_processed;
		        public BLOCK offset_aad;
		        public BLOCK sum;
		        public BLOCK offset;
		        public BLOCK checksum;
		    }
		}
		public typealias OCB128_CONTEXT = ocb128_context;

		public function void ocb128_f(uint8* inVal, uint8* outVal, uint blocks, void* key, uint start_block_num, uint8[16] offset_i, uint8[][16] L_, uint8[16] checksum);
#endif
	}
}
