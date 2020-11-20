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
	sealed abstract class Blowfish
	{
		public const int ENCRYPT = 1;
		public const int DECRYPT = 0;

		/*-
		 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		 * ! BF_LONG has to be at least 32 bits wide.                     !
		 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		 */
		public typealias LONG = uint;

		public const int ROUNDS = 16;
		public const int BLOCK  = 8;

		[CRepr]
		public struct key_st {
		    LONG[ROUNDS + 2] P;
		    LONG[4 * 256] S;
		}
		public typealias KEY = key_st;

		[Import(OPENSSL_LIB_SSL), LinkName("BF_set_key")]
		public extern static void set_key(KEY* key, int len, uint8* data);

		[Import(OPENSSL_LIB_SSL), LinkName("BF_encrypt")]
		public extern static void encrypt(LONG* data, KEY* key);
		[Import(OPENSSL_LIB_SSL), LinkName("BF_decrypt")]
		public extern static void decrypt(LONG* data, KEY* key);

		[Import(OPENSSL_LIB_SSL), LinkName("BF_ecb_encrypt")]
		public extern static void BF_ecb_encrypt(uint8* inVal, uint8* outVal, KEY* key, int enc);
		[Import(OPENSSL_LIB_SSL), LinkName("BF_cbc_encrypt")]
		public extern static void BF_cbc_encrypt(uint8* inVal, uint8* outVal, int length, KEY* schedule, uint8* ivec, int enc);
		[Import(OPENSSL_LIB_SSL), LinkName("BF_cfb64_encrypt")]
		public extern static void BF_cfb64_encrypt(uint8* inVal, uint8* outVal, int length, KEY* schedule, uint8* ivec, int* num, int enc);
		[Import(OPENSSL_LIB_SSL), LinkName("BF_ofb64_encrypt")]
		public extern static void BF_ofb64_encrypt(uint8* inVal, uint8* outVal, int length, KEY* schedule, uint8* ivec, int* num);
		[Import(OPENSSL_LIB_SSL), LinkName("BF_options")]
		public extern static char8* options();
	}
}