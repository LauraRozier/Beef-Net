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
	sealed abstract class EBCDIC
	{
		/** TODO: Once BeefLang is able to handle extern vars/consts these can be ported. **/
		// public extern const unsigned char os_toascii[256];
		// public extern const unsigned char os_toebcdic[256];

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static void* ebcdic2ascii(void* dest, void* srce, uint count);
		[Inline]
		public static void* _openssl_ebcdic2ascii(void* dest, void* srce, uint count) => ebcdic2ascii(dest, srce, count);

		[
#if !OPENSSL_LINK_STATIC
			Import(OPENSSL_LIB_CRYPTO),
#endif
			CLink
		]
		public extern static void* ascii2ebcdic(void* dest, void* srce, uint count);
		[Inline]
		public static void* _openssl_ascii2ebcdic(void* dest, void* srce, uint count) => ascii2ebcdic(dest, srce, count);
	}
}
