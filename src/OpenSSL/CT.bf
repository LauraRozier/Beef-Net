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
	sealed abstract class CT
	{
#if !OPENSSL_NO_CT
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static int ERR_load_CT_strings();
		
		/*
		 * CT function codes.
		 */
		public const int F_CTLOG_NEW                = 117;
		public const int F_CTLOG_NEW_FROM_BASE64    = 118;
		public const int F_CTLOG_NEW_FROM_CONF      = 119;
		public const int F_CTLOG_STORE_LOAD_CTX_NEW = 122;
		public const int F_CTLOG_STORE_LOAD_FILE    = 123;
		public const int F_CTLOG_STORE_LOAD_LOG     = 130;
		public const int F_CTLOG_STORE_NEW          = 131;
		public const int F_CT_BASE64_DECODE         = 124;
		public const int F_CT_POLICY_EVAL_CTX_NEW   = 133;
		public const int F_CT_V1_LOG_ID_FROM_PKEY   = 125;
		public const int F_I2O_SCT                  = 107;
		public const int F_I2O_SCT_LIST             = 108;
		public const int F_I2O_SCT_SIGNATURE        = 109;
		public const int F_O2I_SCT                  = 110;
		public const int F_O2I_SCT_LIST             = 111;
		public const int F_O2I_SCT_SIGNATURE        = 112;
		public const int F_SCT_CTX_NEW              = 126;
		public const int F_SCT_CTX_VERIFY           = 128;
		public const int F_SCT_NEW                  = 100;
		public const int F_SCT_NEW_FROM_BASE64      = 127;
		public const int F_SCT_SET0_LOG_ID          = 101;
		public const int F_SCT_SET1_EXTENSIONS      = 114;
		public const int F_SCT_SET1_LOG_ID          = 115;
		public const int F_SCT_SET1_SIGNATURE       = 116;
		public const int F_SCT_SET_LOG_ENTRY_TYPE   = 102;
		public const int F_SCT_SET_SIGNATURE_NID    = 103;
		public const int F_SCT_SET_VERSION          = 104;
		
		/*
		 * CT reason codes.
		 */
		public const int R_BASE64_DECODE_ERROR          = 108;
		public const int R_INVALID_LOG_ID_LENGTH        = 100;
		public const int R_LOG_CONF_INVALID             = 109;
		public const int R_LOG_CONF_INVALID_KEY         = 110;
		public const int R_LOG_CONF_MISSING_DESCRIPTION = 111;
		public const int R_LOG_CONF_MISSING_KEY         = 112;
		public const int R_LOG_KEY_INVALID              = 113;
		public const int R_SCT_FUTURE_TIMESTAMP         = 116;
		public const int R_SCT_INVALID                  = 104;
		public const int R_SCT_INVALID_SIGNATURE        = 107;
		public const int R_SCT_LIST_INVALID             = 105;
		public const int R_SCT_LOG_ID_MISMATCH          = 114;
		public const int R_SCT_NOT_SET                  = 106;
		public const int R_SCT_UNSUPPORTED_VERSION      = 115;
		public const int R_UNRECOGNIZED_SIGNATURE_NID   = 101;
		public const int R_UNSUPPORTED_ENTRY_TYPE       = 102;
		public const int R_UNSUPPORTED_VERSION          = 103;

		/* All hashes are SHA256 in v1 of Certificate Transparency */
		public const int V1_HASHLEN = SHA256.DIGEST_LENGTH;

		[CRepr]
		public enum log_entry_type_t
		{
		    CT_LOG_ENTRY_TYPE_NOT_SET = -1,
		    CT_LOG_ENTRY_TYPE_X509    = 0,
		    CT_LOG_ENTRY_TYPE_PRECERT = 1
		}

		/* Context when evaluating whether a Certificate Transparency policy is met */
		[CRepr]
		public struct policy_eval_ctx_st {
		    public X509.x509_st* cert;
		    public X509.x509_st* issuer;
		    public CTLOG.STORE* log_store;
		    /* milliseconds since epoch (to check that SCTs aren't from the future) */
		    public uint64 epoch_time_in_ms;
		}
		public typealias POLICY_EVAL_CTX = policy_eval_ctx_st;

		/******************************************
		 * CT policy evaluation context functions *
		 ******************************************/

		/*
		 * Creates a new, empty policy evaluation context.
		 * The caller is responsible for calling CT_POLICY_EVAL_CTX_free when finished
		 * with the CT_POLICY_EVAL_CTX.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_new")]
		public extern static POLICY_EVAL_CTX* POLICY_EVAL_CTX_new();

		/* Deletes a policy evaluation context and anything it owns. */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_free")]
		public extern static void POLICY_EVAL_CTX_free(POLICY_EVAL_CTX* ctx);

		/* Gets the peer certificate that the SCTs are for */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_get0_cert")]
		public extern static X509.x509_st* POLICY_EVAL_CTX_get0_cert(POLICY_EVAL_CTX* ctx);

		/*
		 * Sets the certificate associated with the received SCTs.
		 * Increments the reference count of cert.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_set1_cert")]
		public extern static int POLICY_EVAL_CTX_set1_cert(POLICY_EVAL_CTX* ctx, X509.x509_st* cert);

		/* Gets the issuer of the aforementioned certificate */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_get0_issuer")]
		public extern static X509* POLICY_EVAL_CTX_get0_issuer(POLICY_EVAL_CTX* ctx);

		/*
		 * Sets the issuer of the certificate associated with the received SCTs.
		 * Increments the reference count of issuer.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_set1_issuer")]
		public extern static int POLICY_EVAL_CTX_set1_issuer(POLICY_EVAL_CTX* ctx, X509.x509_st* issuer);

		/* Gets the CT logs that are trusted sources of SCTs */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_get0_log_store")]
		public extern static CTLOG.STORE* POLICY_EVAL_CTX_get0_log_store(POLICY_EVAL_CTX* ctx);

		/* Sets the log store that is in use. It must outlive the CT_POLICY_EVAL_CTX. */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_set_shared_CTLOG_STORE")]
		public extern static void POLICY_EVAL_CTX_set_shared_CTLOG_STORE(POLICY_EVAL_CTX* ctx, CTLOG.STORE* log_store);

		/*
		 * Gets the time, in milliseconds since the Unix epoch, that will be used as the
		 * current time when checking whether an SCT was issued in the future.
		 * Such SCTs will fail validation, as required by RFC6962.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_get_time")]
		public extern static uint64 POLICY_EVAL_CTX_get_time(POLICY_EVAL_CTX* ctx);

		/*
		 * Sets the time to evaluate SCTs against, in milliseconds since the Unix epoch.
		 * If an SCT's timestamp is after this time, it will be interpreted as having
		 * been issued in the future. RFC6962 states that "TLS clients MUST reject SCTs
		 * whose timestamp is in the future", so an SCT will not validate in this case.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CT_POLICY_EVAL_CTX_set_time")]
		public extern static void POLICY_EVAL_CTX_set_time(POLICY_EVAL_CTX* ctx, uint64 time_in_ms);
#endif
	}

	[AlwaysInclude]
	sealed abstract class CTLOG
	{
#if !OPENSSL_NO_CT
		/* Minimum RSA key size, from RFC6962 */
		public const int SCT_MIN_RSA_BITS = 2048;

		[CRepr]
		public struct ctlog_st {
		    public char8* name;
		    public uint8[CT.V1_HASHLEN] log_id;
		    public EVP.PKEY* public_key;
		}
		public typealias CTLOG = ctlog_st;

		[CRepr]
		public struct store_st {
		    public stack_st_CTLOG* logs;
		}
		public typealias STORE = store_st;

		public struct stack_st_CTLOG {}

		/********************
		 * CT log functions *
		 ********************/
		/*
		 * Creates a new CT log instance with the given |public_key| and |name|.
		 * Takes ownership of |public_key| but copies |name|.
		 * Returns NULL if malloc fails or if |public_key| cannot be converted to DER.
		 * Should be deleted by the caller using CTLOG_free when no longer needed.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_new")]
		public extern static ctlog_st* new_(EVP.PKEY *public_key, char8* name);

		/*
		 * Creates a new CTLOG instance with the base64-encoded SubjectPublicKeyInfo DER
		 * in |pkey_base64|. The |name| is a string to help users identify this log.
		 * Returns 1 on success, 0 on failure.
		 * Should be deleted by the caller using CTLOG_free when no longer needed.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_new_from_base64")]
		public extern static int new_from_base64(ctlog_st** ct_log, char8* pkey_base64, char8* name);

		/*
		 * Deletes a CT log instance and its fields.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_free")]
		public extern static void free(ctlog_st* log);

		/* Gets the name of the CT log */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_get0_name")]
		public extern static char8* get0_name(ctlog_st* log);
		/* Gets the ID of the CT log */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_get0_log_id")]
		public extern static void get0_log_id(ctlog_st* log, uint8** log_id, uint* log_id_len);
		/* Gets the public key of the CT log */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_get0_public_key")]
		public extern static EVP.PKEY* get0_public_key(ctlog_st* log);

		/**************************
		 * CT log store functions *
		 **************************/
		/*
		 * Creates a new CT log store.
		 * Should be deleted by the caller using CTLOG_STORE_free when no longer needed.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_STORE_new")]
		public extern static STORE* STORE_new();

		/*
		 * Deletes a CT log store and all of the CT log instances held within.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_STORE_free")]
		public extern static void STORE_free(STORE* store);

		/*
		 * Finds a CT log in the store based on its log ID.
		 * Returns the CT log, or NULL if no match is found.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_STORE_get0_log_by_id")]
		public extern static ctlog_st* STORE_get0_log_by_id(STORE* store, uint8* log_id, uint log_id_len);

		/*
		 * Loads a CT log list into a |store| from a |file|.
		 * Returns 1 if loading is successful, or 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_STORE_load_file")]
		public extern static int STORE_load_file(STORE* store, char8* file);

		/*
		 * Loads the default CT log list into a |store|.
		 * Returns 1 if loading is successful, or 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CTLOG_STORE_load_default_file")]
		public extern static int STORE_load_default_file(STORE* store);
#endif
	}

	[AlwaysInclude]
	sealed abstract class SCT
	{
#if !OPENSSL_NO_CT
		[CRepr]
		public enum version_t
		{
		    SCT_VERSION_NOT_SET = -1,
		    SCT_VERSION_V1 = 0
		}

		[CRepr]
		public enum source_t
		{
		    SCT_SOURCE_UNKNOWN,
		    SCT_SOURCE_TLS_EXTENSION,
		    SCT_SOURCE_X509V3_EXTENSION,
		    SCT_SOURCE_OCSP_STAPLED_RESPONSE
		}

		[CRepr]
		public enum validation_status_t
		{
		    SCT_VALIDATION_STATUS_NOT_SET,
		    SCT_VALIDATION_STATUS_UNKNOWN_LOG,
		    SCT_VALIDATION_STATUS_VALID,
		    SCT_VALIDATION_STATUS_INVALID,
		    SCT_VALIDATION_STATUS_UNVERIFIED,
		    SCT_VALIDATION_STATUS_UNKNOWN_VERSION
		}

		/* Signed Certificate Timestamp */
		[CRepr]
		public struct sct_st {
		    public version_t version;
		    /* If version is not SCT_VERSION_V1, this contains the encoded SCT */
		    public uint8* sct;
		    public uint sct_len;
		    /* If version is SCT_VERSION_V1, fields below contain components of the SCT */
		    public uint8* log_id;
		    public uint log_id_len;
		    /*
		    * Note, we cannot distinguish between an unset timestamp, and one
		    * that is set to 0.  However since CT didn't exist in 1970, no real
		    * SCT should ever be set as such.
		    */
		    public uint64 timestamp;
		    public uint8* ext;
		    public uint ext_len;
		    public uint8 hash_alg;
		    public uint8 sig_alg;
		    public uint8* sig;
		    public uint sig_len;
		    /* Log entry type */
		    public CT.log_entry_type_t entry_type;
		    /* Where this SCT was found, e.g. certificate, OCSP response, etc. */
		    public source_t source;
		    /* The result of the last attempt to validate this SCT. */
		    public validation_status_t validation_status;
		}
		public typealias SCT = sct_st;

		/* Miscellaneous data that is useful when verifying an SCT  */
		[CRepr]
		public struct ctx_st {
		    /* Public key */
		    public EVP.PKEY* pkey;
		    /* Hash of public key */
		    public uint8* pkeyhash;
		    public uint pkeyhashlen;
		    /* For pre-certificate: issuer public key hash */
		    public uint8* ihash;
		    public uint ihashlen;
		    /* certificate encoding */
		    public uint8* certder;
		    public uint certderlen;
		    /* pre-certificate encoding */
		    public uint8* preder;
		    public uint prederlen;
		    /* milliseconds since epoch (to check that the SCT isn't from the future) */
		    public uint64 epoch_time_in_ms;
		}
		public typealias CTX = ctx_st;

		public struct stack_st_SCT {}

		/*****************
		 * SCT functions *
		 *****************/

		/*
		 * Creates a new, blank SCT.
		 * The caller is responsible for calling SCT_free when finished with the SCT.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_new")]
		public extern static sct_st* new_();

		/*
		 * Creates a new SCT from some base64-encoded strings.
		 * The caller is responsible for calling SCT_free when finished with the SCT.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_new_from_base64")]
		public extern static sct_st* new_from_base64(uint8 version, char8* logid_base64, CT.log_entry_type_t entry_type, uint64 timestamp, char8* extensions_base64, char8* signature_base64);

		/*
		 * Frees the SCT and the underlying data structures.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_free")]
		public extern static void free(sct_st* sct);

		/*
		 * Free a stack of SCTs, and the underlying SCTs themselves.
		 * Intended to be compatible with X509V3_EXT_FREE.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_LIST_free")]
		public extern static void LIST_free(stack_st_SCT* a);

		/*
		 * Returns the version of the SCT.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get_version")]
		public extern static version_t get_version(sct_st* sct);

		/*
		 * Set the version of an SCT.
		 * Returns 1 on success, 0 if the version is unrecognized.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set_version")]
		public extern static int set_version(sct_st* sct, version_t version);

		/*
		 * Returns the log entry type of the SCT.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get_log_entry_type")]
		public extern static CT.log_entry_type_t get_log_entry_type(sct_st* sct);

		/*
		 * Set the log entry type of an SCT.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set_log_entry_type")]
		public extern static int set_log_entry_type(sct_st* sct, CT.log_entry_type_t entry_type);

		/*
		 * Gets the ID of the log that an SCT came from.
		 * Ownership of the log ID remains with the SCT.
		 * Returns the length of the log ID.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get0_log_id")]
		public extern static uint get0_log_id(sct_st* sct, uint8** log_id);

		/*
		 * Set the log ID of an SCT to point directly to the *log_id specified.
		 * The SCT takes ownership of the specified pointer.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set0_log_id")]
		public extern static int set0_log_id(sct_st* sct, uint8* log_id, uint log_id_len);

		/*
		 * Set the log ID of an SCT.
		 * This makes a copy of the log_id.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set1_log_id")]
		public extern static int set1_log_id(sct_st* sct, uint8* log_id, uint log_id_len);

		/*
		 * Returns the timestamp for the SCT (epoch time in milliseconds).
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get_timestamp")]
		public extern static uint64 get_timestamp(sct_st* sct);

		/*
		 * Set the timestamp of an SCT (epoch time in milliseconds).
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set_timestamp")]
		public extern static void set_timestamp(sct_st* sct, uint64 timestamp);

		/*
		 * Return the NID for the signature used by the SCT.
		 * For CT v1, this will be either NID_sha256WithRSAEncryption or
		 * NID_ecdsa_with_SHA256 (or NID_undef if incorrect/unset).
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get_signature_nid")]
		public extern static int get_signature_nid(sct_st* sct);

		/*
		 * Set the signature type of an SCT
		 * For CT v1, this should be either NID_sha256WithRSAEncryption or
		 * NID_ecdsa_with_SHA256.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set_signature_nid")]
		public extern static int set_signature_nid(sct_st* sct, int nid);

		/*
		 * Set *ext to point to the extension data for the SCT. ext must not be NULL.
		 * The SCT retains ownership of this pointer.
		 * Returns length of the data pointed to.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get0_extensions")]
		public extern static uint get0_extensions(sct_st* sct, uint8** ext);

		/*
		 * Set the extensions of an SCT to point directly to the *ext specified.
		 * The SCT takes ownership of the specified pointer.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set0_extensions")]
		public extern static void set0_extensions(sct_st* sct, uint8* ext, uint ext_len);

		/*
		 * Set the extensions of an SCT.
		 * This takes a copy of the ext.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set1_extensions")]
		public extern static int set1_extensions(sct_st* sct, uint8* ext, uint ext_len);

		/*
		 * Set *sig to point to the signature for the SCT. sig must not be NULL.
		 * The SCT retains ownership of this pointer.
		 * Returns length of the data pointed to.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get0_signature")]
		public extern static uint get0_signature(sct_st* sct, uint8** sig);

		/*
		 * Set the signature of an SCT to point directly to the *sig specified.
		 * The SCT takes ownership of the specified pointer.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set0_signature")]
		public extern static void set0_signature(sct_st* sct, uint8* sig, uint sig_len);

		/*
		 * Set the signature of an SCT to be a copy of the *sig specified.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set1_signature")]
		public extern static int set1_signature(sct_st* sct, uint8* sig, uint sig_len);

		/*
		 * The origin of this SCT, e.g. TLS extension, OCSP response, etc.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get_source")]
		public extern static source_t get_source(sct_st* sct);

		/*
		 * Set the origin of this SCT, e.g. TLS extension, OCSP response, etc.
		 * Returns 1 on success, 0 otherwise.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_set_source")]
		public extern static int set_source(sct_st* sct, source_t source);

		/*
		 * Returns a text string describing the validation status of |sct|.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_validation_status_string")]
		public extern static char8* validation_status_string(sct_st* sct);

		/*
		 * Pretty-prints an |sct| to |out|.
		 * It will be indented by the number of spaces specified by |indent|.
		 * If |logs| is not NULL, it will be used to lookup the CT log that the SCT came
		 * from, so that the log name can be printed.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_print")]
		public extern static void print(sct_st* sct, BIO.bio_st* outVal, int indent, CTLOG.STORE* logs);

		/*
		 * Pretty-prints an |sct_list| to |out|.
		 * It will be indented by the number of spaces specified by |indent|.
		 * SCTs will be delimited by |separator|.
		 * If |logs| is not NULL, it will be used to lookup the CT log that each SCT
		 * came from, so that the log names can be printed.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_LIST_print")]
		public extern static void LIST_print(stack_st_SCT* sct_list, BIO.bio_st* outVal, int indent, char8* separator, CTLOG.STORE* logs);

		/*
		 * Gets the last result of validating this SCT.
		 * If it has not been validated yet, returns SCT_VALIDATION_STATUS_NOT_SET.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_get_validation_status")]
		public extern static validation_status_t get_validation_status(sct_st* sct);

		/*
		 * Validates the given SCT with the provided context.
		 * Sets the "validation_status" field of the SCT.
		 * Returns 1 if the SCT is valid and the signature verifies.
		 * Returns 0 if the SCT is invalid or could not be verified.
		 * Returns -1 if an error occurs.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_validate")]
		public extern static int validate(sct_st* sct, CT.POLICY_EVAL_CTX* ctx);

		/*
		 * Validates the given list of SCTs with the provided context.
		 * Sets the "validation_status" field of each SCT.
		 * Returns 1 if there are no invalid SCTs and all signatures verify.
		 * Returns 0 if at least one SCT is invalid or could not be verified.
		 * Returns a negative integer if an error occurs.
		 */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("SCT_LIST_validate")]
		public extern static int LIST_validate(stack_st_SCT* scts, CT.POLICY_EVAL_CTX* ctx);

		/*********************************
		 * SCT parsing and serialisation *
		 *********************************/
		/*
		 * Serialize (to TLS format) a stack of SCTs and return the length.
		 * "a" must not be NULL.
		 * If "pp" is NULL, just return the length of what would have been serialized.
		 * If "pp" is not NULL and "*pp" is null, function will allocate a new pointer
		 * for data that caller is responsible for freeing (only if function returns
		 * successfully).
		 * If "pp" is NULL and "*pp" is not NULL, caller is responsible for ensuring
		 * that "*pp" is large enough to accept all of the serialized data.
		 * Returns < 0 on error, >= 0 indicating bytes written (or would have been)
		 * on success.
		 */
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static int i2o_SCT_LIST(stack_st_SCT* a, uint8** pp);

		/*
		 * Convert TLS format SCT list to a stack of SCTs.
		 * If "a" or "*a" is NULL, a new stack will be created that the caller is
		 * responsible for freeing (by calling SCT_LIST_free).
		 * "**pp" and "*pp" must not be NULL.
		 * Upon success, "*pp" will point to after the last bytes read, and a stack
		 * will be returned.
		 * Upon failure, a NULL pointer will be returned, and the position of "*pp" is
		 * not defined.
		 */
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static stack_st_SCT *o2i_SCT_LIST(stack_st_SCT** a, uint8** pp, uint len);

		/*
		 * Serialize (to DER format) a stack of SCTs and return the length.
		 * "a" must not be NULL.
		 * If "pp" is NULL, just returns the length of what would have been serialized.
		 * If "pp" is not NULL and "*pp" is null, function will allocate a new pointer
		 * for data that caller is responsible for freeing (only if function returns
		 * successfully).
		 * If "pp" is NULL and "*pp" is not NULL, caller is responsible for ensuring
		 * that "*pp" is large enough to accept all of the serialized data.
		 * Returns < 0 on error, >= 0 indicating bytes written (or would have been)
		 * on success.
		 */
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static int i2d_SCT_LIST(stack_st_SCT* a, uint8** pp);

		/*
		 * Parses an SCT list in DER format and returns it.
		 * If "a" or "*a" is NULL, a new stack will be created that the caller is
		 * responsible for freeing (by calling SCT_LIST_free).
		 * "**pp" and "*pp" must not be NULL.
		 * Upon success, "*pp" will point to after the last bytes read, and a stack
		 * will be returned.
		 * Upon failure, a NULL pointer will be returned, and the position of "*pp" is
		 * not defined.
		 */
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static stack_st_SCT* d2i_SCT_LIST(stack_st_SCT** a, uint8** pp, int len);

		/*
		 * Serialize (to TLS format) an |sct| and write it to |out|.
		 * If |out| is null, no SCT will be output but the length will still be returned.
		 * If |out| points to a null pointer, a string will be allocated to hold the
		 * TLS-format SCT. It is the responsibility of the caller to free it.
		 * If |out| points to an allocated string, the TLS-format SCT will be written
		 * to it.
		 * The length of the SCT in TLS format will be returned.
		 */
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static int i2o_SCT(sct_st* sct, uint8** outVal);

		/*
		 * Parses an SCT in TLS format and returns it.
		 * If |psct| is not null, it will end up pointing to the parsed SCT. If it
		 * already points to a non-null pointer, the pointer will be free'd.
		 * |in| should be a pointer to a string containing the TLS-format SCT.
		 * |in| will be advanced to the end of the SCT if parsing succeeds.
		 * |len| should be the length of the SCT in |in|.
		 * Returns NULL if an error occurs.
		 * If the SCT is an unsupported version, only the SCT's 'sct' and 'sct_len'
		 * fields will be populated (with |in| and |len| respectively).
		 */
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static sct_st* o2i_SCT(sct_st** psct, uint8** inVal, uint len);
#endif
	}
}
