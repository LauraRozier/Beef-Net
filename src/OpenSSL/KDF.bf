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
	sealed abstract class KDF
	{
		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static int ERR_load_KDF_strings();
		
		/*
		 * KDF function codes.
		 */
		public const int F_PKEY_HKDF_CTRL_STR      = 03;
		public const int F_PKEY_HKDF_DERIVE        = 02;
		public const int F_PKEY_HKDF_INIT          = 08;
		public const int F_PKEY_SCRYPT_CTRL_STR    = 04;
		public const int F_PKEY_SCRYPT_CTRL_UINT64 = 05;
		public const int F_PKEY_SCRYPT_DERIVE      = 09;
		public const int F_PKEY_SCRYPT_INIT        = 06;
		public const int F_PKEY_SCRYPT_SET_MEMBUF  = 07;
		public const int F_PKEY_TLS1_PRF_CTRL_STR  = 00;
		public const int F_PKEY_TLS1_PRF_DERIVE    = 01;
		public const int F_PKEY_TLS1_PRF_INIT      = 10;
		public const int F_TLS1_PRF_ALG            = 11;
		
		/*
		 * KDF reason codes.
		 */
		public const int R_INVALID_DIGEST          = 00;
		public const int R_MISSING_ITERATION_COUNT = 09;
		public const int R_MISSING_KEY             = 04;
		public const int R_MISSING_MESSAGE_DIGEST  = 05;
		public const int R_MISSING_PARAMETER       = 01;
		public const int R_MISSING_PASS            = 10;
		public const int R_MISSING_SALT            = 11;
		public const int R_MISSING_SECRET          = 07;
		public const int R_MISSING_SEED            = 06;
		public const int R_UNKNOWN_PARAMETER_TYPE  = 03;
		public const int R_VALUE_ERROR             = 08;
		public const int R_VALUE_MISSING           = 02;
	}
}
