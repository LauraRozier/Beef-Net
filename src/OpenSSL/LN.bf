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
	sealed abstract class LN
	{
		public const String undef                              = "undefined";
		public const String itu_t                              = "itu-t";
		public const String iso                                = "iso";
		public const String joint_iso_itu_t                    = "joint-iso-itu-t";
		public const String member_body                        = "ISO Member Body";
		public const String hmac_md5                           = "hmac-md5";
		public const String hmac_sha1                          = "hmac-sha1";
		public const String x509ExtAdmission                   = "Professional Information or basis for Admission";
		public const String ieee_siswg                         = "IEEE Security in Storage Working Group";
		public const String international_organizations        = "International Organizations";
		public const String selected_attribute_types           = "Selected Attribute Types";
		public const String ISO_US                             = "ISO US Member Body";
		public const String X9_57                              = "X9.57";
		public const String X9cm                               = "X9.57 CM ?";
		public const String ISO_CN                             = "ISO CN Member Body";
		public const String dsa                                = "dsaEncryption";
		public const String dsaWithSHA1                        = "dsaWithSHA1";
		public const String ansi_X9_62                         = "ANSI X9.62";

		public const String cast5_cbc                          = "cast5-cbc";
		public const String cast5_ecb                          = "cast5-ecb";
		public const String cast5_cfb64                        = "cast5-cfb";
		public const String cast5_ofb64                        = "cast5-ofb";

		public const String pbeWithMD5AndCast5_CBC             = "pbeWithMD5AndCast5CBC";

		public const String id_PasswordBasedMAC                = "password based MAC";
		public const String id_DHBasedMac                      = "Diffie-Hellman based MAC";

		public const String rsadsi                             = "RSA Data Security, Inc.";
		public const String pkcs                               = "RSA Data Security, Inc. PKCS";
		
		public const String rsaEncryption                      = "rsaEncryption";

		public const String md2WithRSAEncryption               = "md2WithRSAEncryption";
		public const String md4WithRSAEncryption               = "md4WithRSAEncryption";
		public const String md5WithRSAEncryption               = "md5WithRSAEncryption";
		public const String sha1WithRSAEncryption              = "sha1WithRSAEncryption";

		public const String rsaesOaep                          = "rsaesOaep";
		public const String mgf1                               = "mgf1";
		public const String pSpecified                         = "pSpecified";
		public const String rsassaPss                          = "rsassaPss";

		public const String sha256WithRSAEncryption            = "sha256WithRSAEncryption";
		public const String sha384WithRSAEncryption            = "sha384WithRSAEncryption";
		public const String sha512WithRSAEncryption            = "sha512WithRSAEncryption";
		public const String sha224WithRSAEncryption            = "sha224WithRSAEncryption";
		public const String sha512_224WithRSAEncryption        = "sha512-224WithRSAEncryption";
		public const String sha512_256WithRSAEncryption        = "sha512-256WithRSAEncryption";

		public const String dhKeyAgreement                     = "dhKeyAgreement";

		public const String pbeWithMD2AndDES_CBC               = "pbeWithMD2AndDES-CBC";
		public const String pbeWithMD5AndDES_CBC               = "pbeWithMD5AndDES-CBC";
		public const String pbeWithMD2AndRC2_CBC               = "pbeWithMD2AndRC2-CBC";
		public const String pbeWithMD5AndRC2_CBC               = "pbeWithMD5AndRC2-CBC";
		public const String pbeWithSHA1AndDES_CBC              = "pbeWithSHA1AndDES-CBC";
		public const String pbeWithSHA1AndRC2_CBC              = "pbeWithSHA1AndRC2-CBC";

		public const String id_pbkdf2                          = "PBKDF2";
		public const String pbes2                              = "PBES2";
		public const String pbmac1                             = "PBMAC1";

		public const String pkcs7_data                         = "pkcs7-data";
		public const String pkcs7_signed                       = "pkcs7-signedData";
		public const String pkcs7_enveloped                    = "pkcs7-envelopedData";
		public const String pkcs7_signedAndEnveloped           = "pkcs7-signedAndEnvelopedData";
		public const String pkcs7_digest                       = "pkcs7-digestData";
		public const String pkcs7_encrypted                    = "pkcs7-encryptedData";

		public const String pkcs9_emailAddress                 = "emailAddress";
		public const String pkcs9_unstructuredName             = "unstructuredName";
		public const String pkcs9_contentType                  = "contentType";
		public const String pkcs9_messageDigest                = "messageDigest";
		public const String pkcs9_signingTime                  = "signingTime";
		public const String pkcs9_countersignature             = "countersignature";
		public const String pkcs9_challengePassword            = "challengePassword";
		public const String pkcs9_unstructuredAddress          = "unstructuredAddress";
		public const String pkcs9_extCertAttributes            = "extendedCertificateAttributes";

		public const String ext_req                            = "Extension Request";
		
		public const String SMIMECapabilities                  = "S/MIME Capabilities";
		public const String SMIME                              = "S/MIME";

		public const String friendlyName                       = "friendlyName";
		public const String localKeyID                         = "localKeyID";

		public const String ms_csp_name                        = "Microsoft CSP Name";
		public const String LocalKeySet                        = "Microsoft Local Key set";

		public const String x509Certificate                    = "x509Certificate";
		public const String sdsiCertificate                    = "sdsiCertificate";

		public const String x509Crl                            = "x509Crl";

		public const String pbe_WithSHA1And128BitRC4           = "pbeWithSHA1And128BitRC4";
		public const String pbe_WithSHA1And40BitRC4            = "pbeWithSHA1And40BitRC4";
		public const String pbe_WithSHA1And3_Key_TripleDES_CBC = "pbeWithSHA1And3-KeyTripleDES-CBC";
		public const String pbe_WithSHA1And2_Key_TripleDES_CBC = "pbeWithSHA1And2-KeyTripleDES-CBC";
		public const String pbe_WithSHA1And128BitRC2_CBC       = "pbeWithSHA1And128BitRC2-CBC";
		public const String pbe_WithSHA1And40BitRC2_CBC        = "pbeWithSHA1And40BitRC2-CBC";
		
		public const String keyBag                             = "keyBag";
		public const String pkcs8ShroudedKeyBag                = "pkcs8ShroudedKeyBag";
		public const String certBag                            = "certBag";
		public const String crlBag                             = "crlBag";
		public const String secretBag                          = "secretBag";
		public const String safeContentsBag                    = "safeContentsBag";

		public const String md2                                = "md2";
		public const String md4                                = "md4";
		public const String md5                                = "md5";
		public const String md5_sha1                           = "md5-sha1";

		public const String hmacWithMD5                        = "hmacWithMD5";
		public const String hmacWithSHA1                       = "hmacWithSHA1";

		public const String sm2                                = "sm2";
		public const String sm3                                = "sm3";
		public const String sm3WithRSAEncryption               = "sm3WithRSAEncryption";

		public const String hmacWithSHA224                     = "hmacWithSHA224";
		public const String hmacWithSHA256                     = "hmacWithSHA256";
		public const String hmacWithSHA384                     = "hmacWithSHA384";
		public const String hmacWithSHA512                     = "hmacWithSHA512";
		public const String hmacWithSHA512_224                 = "hmacWithSHA512-224";
		public const String hmacWithSHA512_256                 = "hmacWithSHA512-256";

		public const String rc2_cbc                            = "rc2-cbc";
		public const String rc2_ecb                            = "rc2-ecb";
		public const String rc2_cfb64                          = "rc2-cfb";
		public const String rc2_ofb64                          = "rc2-ofb";
		public const String rc2_40_cbc                         = "rc2-40-cbc";
		public const String rc2_64_cbc                         = "rc2-64-cbc";
		public const String rc4                                = "rc4";
		public const String rc4_40                             = "rc4-40";
		public const String des_ede3_cbc                       = "des-ede3-cbc";
		public const String rc5_cbc                            = "rc5-cbc";
		public const String rc5_ecb                            = "rc5-ecb";
		public const String rc5_cfb64                          = "rc5-cfb";
		public const String rc5_ofb64                          = "rc5-ofb";

		public const String ms_ext_req                         = "Microsoft Extension Request";
		public const String ms_code_ind                        = "Microsoft Individual Code Signing";
		public const String ms_code_com                        = "Microsoft Commercial Code Signing";
		public const String ms_ctl_sign                        = "Microsoft Trust List Signing";
		public const String ms_sgc                             = "Microsoft Server Gated Crypto";
		public const String ms_efs                             = "Microsoft Encrypted File System";
		public const String ms_smartcard_login                 = "Microsoft Smartcard Login";
		public const String ms_upn                             = "Microsoft User Principal Name";

		public const String idea_cbc                           = "idea-cbc";
		public const String idea_ecb                           = "idea-ecb";
		public const String idea_cfb64                         = "idea-cfb";
		public const String idea_ofb64                         = "idea-ofb";

		public const String bf_cbc                             = "bf-cbc";
		public const String bf_ecb                             = "bf-ecb";
		public const String bf_cfb64                           = "bf-cfb";
		public const String bf_ofb64                           = "bf-ofb";
	}
}
