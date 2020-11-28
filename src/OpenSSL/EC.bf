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
	sealed abstract class EC
	{
#if !OPENSSL_NO_EC
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static int ERR_load_EC_strings();
		
		/*
		 * EC function codes.
		 */
		public const int F_BN_TO_FELEM                                  = 224;
		public const int F_D2I_ECPARAMETERS                             = 144;
		public const int F_D2I_ECPKPARAMETERS                           = 145;
		public const int F_D2I_ECPRIVATEKEY                             = 146;
		public const int F_DO_EC_KEY_PRINT                              = 221;
		public const int F_ECDH_CMS_DECRYPT                             = 238;
		public const int F_ECDH_CMS_SET_SHARED_INFO                     = 239;
		public const int F_ECDH_COMPUTE_KEY                             = 246;
		public const int F_ECDH_SIMPLE_COMPUTE_KEY                      = 257;
		public const int F_ECDSA_DO_SIGN_EX                             = 251;
		public const int F_ECDSA_DO_VERIFY                              = 252;
		public const int F_ECDSA_SIGN_EX                                = 254;
		public const int F_ECDSA_SIGN_SETUP                             = 248;
		public const int F_ECDSA_SIG_NEW                                = 265;
		public const int F_ECDSA_VERIFY                                 = 253;
		public const int F_ECD_ITEM_VERIFY                              = 270;
		public const int F_ECKEY_PARAM2TYPE                             = 223;
		public const int F_ECKEY_PARAM_DECODE                           = 212;
		public const int F_ECKEY_PRIV_DECODE                            = 213;
		public const int F_ECKEY_PRIV_ENCODE                            = 214;
		public const int F_ECKEY_PUB_DECODE                             = 215;
		public const int F_ECKEY_PUB_ENCODE                             = 216;
		public const int F_ECKEY_TYPE2PARAM                             = 220;
		public const int F_ECPARAMETERS_PRINT                           = 147;
		public const int F_ECPARAMETERS_PRINT_FP                        = 148;
		public const int F_ECPKPARAMETERS_PRINT                         = 149;
		public const int F_ECPKPARAMETERS_PRINT_FP                      = 150;
		public const int F_ECP_NISTZ256_GET_AFFINE                      = 240;
		public const int F_ECP_NISTZ256_INV_MOD_ORD                     = 275;
		public const int F_ECP_NISTZ256_MULT_PRECOMPUTE                 = 243;
		public const int F_ECP_NISTZ256_POINTS_MUL                      = 241;
		public const int F_ECP_NISTZ256_PRE_COMP_NEW                    = 244;
		public const int F_ECP_NISTZ256_WINDOWED_MUL                    = 242;
		public const int F_ECX_KEY_OP                                   = 266;
		public const int F_ECX_PRIV_ENCODE                              = 267;
		public const int F_ECX_PUB_ENCODE                               = 268;
		public const int F_EC_ASN1_GROUP2CURVE                          = 153;
		public const int F_EC_ASN1_GROUP2FIELDID                        = 154;
		public const int F_EC_GF2M_MONTGOMERY_POINT_MULTIPLY            = 208;
		public const int F_EC_GF2M_SIMPLE_FIELD_INV                     = 296;
		public const int F_EC_GF2M_SIMPLE_GROUP_CHECK_DISCRIMINANT      = 159;
		public const int F_EC_GF2M_SIMPLE_GROUP_SET_CURVE               = 195;
		public const int F_EC_GF2M_SIMPLE_LADDER_POST                   = 285;
		public const int F_EC_GF2M_SIMPLE_LADDER_PRE                    = 288;
		public const int F_EC_GF2M_SIMPLE_OCT2POINT                     = 160;
		public const int F_EC_GF2M_SIMPLE_POINT2OCT                     = 161;
		public const int F_EC_GF2M_SIMPLE_POINTS_MUL                    = 289;
		public const int F_EC_GF2M_SIMPLE_POINT_GET_AFFINE_COORDINATES  = 162;
		public const int F_EC_GF2M_SIMPLE_POINT_SET_AFFINE_COORDINATES  = 163;
		public const int F_EC_GF2M_SIMPLE_SET_COMPRESSED_COORDINATES    = 164;
		public const int F_EC_GFP_MONT_FIELD_DECODE                     = 133;
		public const int F_EC_GFP_MONT_FIELD_ENCODE                     = 134;
		public const int F_EC_GFP_MONT_FIELD_INV                        = 297;
		public const int F_EC_GFP_MONT_FIELD_MUL                        = 131;
		public const int F_EC_GFP_MONT_FIELD_SET_TO_ONE                 = 209;
		public const int F_EC_GFP_MONT_FIELD_SQR                        = 132;
		public const int F_EC_GFP_MONT_GROUP_SET_CURVE                  = 189;
		public const int F_EC_GFP_NISTP224_GROUP_SET_CURVE              = 225;
		public const int F_EC_GFP_NISTP224_POINTS_MUL                   = 228;
		public const int F_EC_GFP_NISTP224_POINT_GET_AFFINE_COORDINATES = 226;
		public const int F_EC_GFP_NISTP256_GROUP_SET_CURVE              = 230;
		public const int F_EC_GFP_NISTP256_POINTS_MUL                   = 231;
		public const int F_EC_GFP_NISTP256_POINT_GET_AFFINE_COORDINATES = 232;
		public const int F_EC_GFP_NISTP521_GROUP_SET_CURVE              = 233;
		public const int F_EC_GFP_NISTP521_POINTS_MUL                   = 234;
		public const int F_EC_GFP_NISTP521_POINT_GET_AFFINE_COORDINATES = 235;
		public const int F_EC_GFP_NIST_FIELD_MUL                        = 200;
		public const int F_EC_GFP_NIST_FIELD_SQR                        = 201;
		public const int F_EC_GFP_NIST_GROUP_SET_CURVE                  = 202;
		public const int F_EC_GFP_SIMPLE_BLIND_COORDINATES              = 287;
		public const int F_EC_GFP_SIMPLE_FIELD_INV                      = 298;
		public const int F_EC_GFP_SIMPLE_GROUP_CHECK_DISCRIMINANT       = 165;
		public const int F_EC_GFP_SIMPLE_GROUP_SET_CURVE                = 166;
		public const int F_EC_GFP_SIMPLE_MAKE_AFFINE                    = 102;
		public const int F_EC_GFP_SIMPLE_OCT2POINT                      = 103;
		public const int F_EC_GFP_SIMPLE_POINT2OCT                      = 104;
		public const int F_EC_GFP_SIMPLE_POINTS_MAKE_AFFINE             = 137;
		public const int F_EC_GFP_SIMPLE_POINT_GET_AFFINE_COORDINATES   = 167;
		public const int F_EC_GFP_SIMPLE_POINT_SET_AFFINE_COORDINATES   = 168;
		public const int F_EC_GFP_SIMPLE_SET_COMPRESSED_COORDINATES     = 169;
		public const int F_EC_GROUP_CHECK                               = 170;
		public const int F_EC_GROUP_CHECK_DISCRIMINANT                  = 171;
		public const int F_EC_GROUP_COPY                                = 106;
		public const int F_EC_GROUP_GET_CURVE                           = 291;
		public const int F_EC_GROUP_GET_CURVE_GF2M                      = 172;
		public const int F_EC_GROUP_GET_CURVE_GFP                       = 130;
		public const int F_EC_GROUP_GET_DEGREE                          = 173;
		public const int F_EC_GROUP_GET_ECPARAMETERS                    = 261;
		public const int F_EC_GROUP_GET_ECPKPARAMETERS                  = 262;
		public const int F_EC_GROUP_GET_PENTANOMIAL_BASIS               = 193;
		public const int F_EC_GROUP_GET_TRINOMIAL_BASIS                 = 194;
		public const int F_EC_GROUP_NEW                                 = 108;
		public const int F_EC_GROUP_NEW_BY_CURVE_NAME                   = 174;
		public const int F_EC_GROUP_NEW_FROM_DATA                       = 175;
		public const int F_EC_GROUP_NEW_FROM_ECPARAMETERS               = 263;
		public const int F_EC_GROUP_NEW_FROM_ECPKPARAMETERS             = 264;
		public const int F_EC_GROUP_SET_CURVE                           = 292;
		public const int F_EC_GROUP_SET_CURVE_GF2M                      = 176;
		public const int F_EC_GROUP_SET_CURVE_GFP                       = 109;
		public const int F_EC_GROUP_SET_GENERATOR                       = 111;
		public const int F_EC_GROUP_SET_SEED                            = 286;
		public const int F_EC_KEY_CHECK_KEY                             = 177;
		public const int F_EC_KEY_COPY                                  = 178;
		public const int F_EC_KEY_GENERATE_KEY                          = 179;
		public const int F_EC_KEY_NEW                                   = 182;
		public const int F_EC_KEY_NEW_METHOD                            = 245;
		public const int F_EC_KEY_OCT2PRIV                              = 255;
		public const int F_EC_KEY_PRINT                                 = 180;
		public const int F_EC_KEY_PRINT_FP                              = 181;
		public const int F_EC_KEY_PRIV2BUF                              = 279;
		public const int F_EC_KEY_PRIV2OCT                              = 256;
		public const int F_EC_KEY_SET_PUBLIC_KEY_AFFINE_COORDINATES     = 229;
		public const int F_EC_KEY_SIMPLE_CHECK_KEY                      = 258;
		public const int F_EC_KEY_SIMPLE_OCT2PRIV                       = 259;
		public const int F_EC_KEY_SIMPLE_PRIV2OCT                       = 260;
		public const int F_EC_PKEY_CHECK                                = 273;
		public const int F_EC_PKEY_PARAM_CHECK                          = 274;
		public const int F_EC_POINTS_MAKE_AFFINE                        = 136;
		public const int F_EC_POINTS_MUL                                = 290;
		public const int F_EC_POINT_ADD                                 = 112;
		public const int F_EC_POINT_BN2POINT                            = 280;
		public const int F_EC_POINT_CMP                                 = 113;
		public const int F_EC_POINT_COPY                                = 114;
		public const int F_EC_POINT_DBL                                 = 115;
		public const int F_EC_POINT_GET_AFFINE_COORDINATES              = 293;
		public const int F_EC_POINT_GET_AFFINE_COORDINATES_GF2M         = 183;
		public const int F_EC_POINT_GET_AFFINE_COORDINATES_GFP          = 116;
		public const int F_EC_POINT_GET_JPROJECTIVE_COORDINATES_GFP     = 117;
		public const int F_EC_POINT_INVERT                              = 210;
		public const int F_EC_POINT_IS_AT_INFINITY                      = 118;
		public const int F_EC_POINT_IS_ON_CURVE                         = 119;
		public const int F_EC_POINT_MAKE_AFFINE                         = 120;
		public const int F_EC_POINT_NEW                                 = 121;
		public const int F_EC_POINT_OCT2POINT                           = 122;
		public const int F_EC_POINT_POINT2BUF                           = 281;
		public const int F_EC_POINT_POINT2OCT                           = 123;
		public const int F_EC_POINT_SET_AFFINE_COORDINATES              = 294;
		public const int F_EC_POINT_SET_AFFINE_COORDINATES_GF2M         = 185;
		public const int F_EC_POINT_SET_AFFINE_COORDINATES_GFP          = 124;
		public const int F_EC_POINT_SET_COMPRESSED_COORDINATES          = 295;
		public const int F_EC_POINT_SET_COMPRESSED_COORDINATES_GF2M     = 186;
		public const int F_EC_POINT_SET_COMPRESSED_COORDINATES_GFP      = 125;
		public const int F_EC_POINT_SET_JPROJECTIVE_COORDINATES_GFP     = 126;
		public const int F_EC_POINT_SET_TO_INFINITY                     = 127;
		public const int F_EC_PRE_COMP_NEW                              = 196;
		public const int F_EC_SCALAR_MUL_LADDER                         = 284;
		public const int F_EC_WNAF_MUL                                  = 187;
		public const int F_EC_WNAF_PRECOMPUTE_MULT                      = 188;
		public const int F_I2D_ECPARAMETERS                             = 190;
		public const int F_I2D_ECPKPARAMETERS                           = 191;
		public const int F_I2D_ECPRIVATEKEY                             = 192;
		public const int F_I2O_ECPUBLICKEY                              = 151;
		public const int F_NISTP224_PRE_COMP_NEW                        = 227;
		public const int F_NISTP256_PRE_COMP_NEW                        = 236;
		public const int F_NISTP521_PRE_COMP_NEW                        = 237;
		public const int F_O2I_ECPUBLICKEY                              = 152;
		public const int F_OLD_EC_PRIV_DECODE                           = 222;
		public const int F_OSSL_ECDH_COMPUTE_KEY                        = 247;
		public const int F_OSSL_ECDSA_SIGN_SIG                          = 249;
		public const int F_OSSL_ECDSA_VERIFY_SIG                        = 250;
		public const int F_PKEY_ECD_CTRL                                = 271;
		public const int F_PKEY_ECD_DIGESTSIGN                          = 272;
		public const int F_PKEY_ECD_DIGESTSIGN25519                     = 276;
		public const int F_PKEY_ECD_DIGESTSIGN448                       = 277;
		public const int F_PKEY_ECX_DERIVE                              = 269;
		public const int F_PKEY_EC_CTRL                                 = 197;
		public const int F_PKEY_EC_CTRL_STR                             = 198;
		public const int F_PKEY_EC_DERIVE                               = 217;
		public const int F_PKEY_EC_INIT                                 = 282;
		public const int F_PKEY_EC_KDF_DERIVE                           = 283;
		public const int F_PKEY_EC_KEYGEN                               = 199;
		public const int F_PKEY_EC_PARAMGEN                             = 219;
		public const int F_PKEY_EC_SIGN                                 = 218;
		public const int F_VALIDATE_ECX_DERIVE                          = 278;
		
		/*
		 * EC reason codes.
		 */
		public const int R_ASN1_ERROR                                   = 115;
		public const int R_BAD_SIGNATURE                                = 156;
		public const int R_BIGNUM_OUT_OF_RANGE                          = 144;
		public const int R_BUFFER_TOO_SMALL                             = 100;
		public const int R_CANNOT_INVERT                                = 165;
		public const int R_COORDINATES_OUT_OF_RANGE                     = 146;
		public const int R_CURVE_DOES_NOT_SUPPORT_ECDH                  = 160;
		public const int R_CURVE_DOES_NOT_SUPPORT_SIGNING               = 159;
		public const int R_D2I_ECPKPARAMETERS_FAILURE                   = 117;
		public const int R_DECODE_ERROR                                 = 142;
		public const int R_DISCRIMINANT_IS_ZERO                         = 118;
		public const int R_EC_GROUP_NEW_BY_NAME_FAILURE                 = 119;
		public const int R_FIELD_TOO_LARGE                              = 143;
		public const int R_GF2M_NOT_SUPPORTED                           = 147;
		public const int R_GROUP2PKPARAMETERS_FAILURE                   = 120;
		public const int R_I2D_ECPKPARAMETERS_FAILURE                   = 121;
		public const int R_INCOMPATIBLE_OBJECTS                         = 101;
		public const int R_INVALID_ARGUMENT                             = 112;
		public const int R_INVALID_COMPRESSED_POINT                     = 110;
		public const int R_INVALID_COMPRESSION_BIT                      = 109;
		public const int R_INVALID_CURVE                                = 141;
		public const int R_INVALID_DIGEST                               = 151;
		public const int R_INVALID_DIGEST_TYPE                          = 138;
		public const int R_INVALID_ENCODING                             = 102;
		public const int R_INVALID_FIELD                                = 103;
		public const int R_INVALID_FORM                                 = 104;
		public const int R_INVALID_GROUP_ORDER                          = 122;
		public const int R_INVALID_KEY                                  = 116;
		public const int R_INVALID_OUTPUT_LENGTH                        = 161;
		public const int R_INVALID_PEER_KEY                             = 133;
		public const int R_INVALID_PENTANOMIAL_BASIS                    = 132;
		public const int R_INVALID_PRIVATE_KEY                          = 123;
		public const int R_INVALID_TRINOMIAL_BASIS                      = 137;
		public const int R_KDF_PARAMETER_ERROR                          = 148;
		public const int R_KEYS_NOT_SET                                 = 140;
		public const int R_LADDER_POST_FAILURE                          = 136;
		public const int R_LADDER_PRE_FAILURE                           = 153;
		public const int R_LADDER_STEP_FAILURE                          = 162;
		public const int R_MISSING_OID                                  = 167;
		public const int R_MISSING_PARAMETERS                           = 124;
		public const int R_MISSING_PRIVATE_KEY                          = 125;
		public const int R_NEED_NEW_SETUP_VALUES                        = 157;
		public const int R_NOT_A_NIST_PRIME                             = 135;
		public const int R_NOT_IMPLEMENTED                              = 126;
		public const int R_NOT_INITIALIZED                              = 111;
		public const int R_NO_PARAMETERS_SET                            = 139;
		public const int R_NO_PRIVATE_VALUE                             = 154;
		public const int R_OPERATION_NOT_SUPPORTED                      = 152;
		public const int R_PASSED_NULL_PARAMETER                        = 134;
		public const int R_PEER_KEY_ERROR                               = 149;
		public const int R_PKPARAMETERS2GROUP_FAILURE                   = 127;
		public const int R_POINT_ARITHMETIC_FAILURE                     = 155;
		public const int R_POINT_AT_INFINITY                            = 106;
		public const int R_POINT_COORDINATES_BLIND_FAILURE              = 163;
		public const int R_POINT_IS_NOT_ON_CURVE                        = 107;
		public const int R_RANDOM_NUMBER_GENERATION_FAILED              = 158;
		public const int R_SHARED_INFO_ERROR                            = 150;
		public const int R_SLOT_FULL                                    = 108;
		public const int R_UNDEFINED_GENERATOR                          = 113;
		public const int R_UNDEFINED_ORDER                              = 128;
		public const int R_UNKNOWN_COFACTOR                             = 164;
		public const int R_UNKNOWN_GROUP                                = 129;
		public const int R_UNKNOWN_ORDER                                = 114;
		public const int R_UNSUPPORTED_FIELD                            = 131;
		public const int R_WRONG_CURVE_PARAMETERS                       = 145;
		public const int R_WRONG_ORDER                                  = 130;
#endif
	}

	[AlwaysInclude]
	sealed abstract class ECX
	{
#if !OPENSSL_NO_EC
		public const int X25519_KEYLEN = 32;
		public const int X448_KEYLEN   = 56;
		public const int ED448_KEYLEN  = 57;
		public const int MAX_KEYLEN    = ED448_KEYLEN;

		[CRepr]
		public struct key_st
		{
		    public uint8[MAX_KEYLEN] pubkey;
		    public uint8* privkey;
		}
		public typealias KEY = key_st;
#endif
	}
	
	[AlwaysInclude]
	sealed abstract class ECDH
	{
#if !OPENSSL_NO_EC
#endif
	}
	
	[AlwaysInclude]
	sealed abstract class ECDSA
	{
#if !OPENSSL_NO_EC
		[CRepr]
		public struct SIG_st {
		    public BN.BIGNUM* r;
		    public BN.BIGNUM* s;
		}
		public typealias SIG = SIG_st;
#endif
	}
}
