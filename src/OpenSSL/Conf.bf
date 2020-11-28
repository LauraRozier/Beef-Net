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
	sealed abstract class Conf
	{
		[Import(OPENSSL_LIB_CRYPTO), CLink]
		public extern static int ERR_load_CONF_strings();
		
		/*
		 * CONF function codes.
		 */
		public const int F_CONF_DUMP_FP       = 104;
		public const int F_CONF_LOAD          = 100;
		public const int F_CONF_LOAD_FP       = 103;
		public const int F_CONF_PARSE_LIST    = 119;
		public const int F_DEF_LOAD           = 120;
		public const int F_DEF_LOAD_BIO       = 121;
		public const int F_GET_NEXT_FILE      = 107;
		public const int F_MODULE_ADD         = 122;
		public const int F_MODULE_INIT        = 115;
		public const int F_MODULE_LOAD_DSO    = 117;
		public const int F_MODULE_RUN         = 118;
		public const int F_NCONF_DUMP_BIO     = 105;
		public const int F_NCONF_DUMP_FP      = 106;
		public const int F_NCONF_GET_NUMBER_E = 112;
		public const int F_NCONF_GET_SECTION  = 108;
		public const int F_NCONF_GET_STRING   = 109;
		public const int F_NCONF_LOAD         = 113;
		public const int F_NCONF_LOAD_BIO     = 110;
		public const int F_NCONF_LOAD_FP      = 114;
		public const int F_NCONF_NEW          = 111;
		public const int F_PROCESS_INCLUDE    = 116;
		public const int F_SSL_MODULE_INIT    = 123;
		public const int F_STR_COPY           = 101;
		
		/*
		 * CONF reason codes.
		 */
		public const int R_ERROR_LOADING_DSO               = 110;
		public const int R_LIST_CANNOT_BE_NULL             = 115;
		public const int R_MISSING_CLOSE_SQUARE_BRACKET    = 100;
		public const int R_MISSING_EQUAL_SIGN              = 101;
		public const int R_MISSING_INIT_FUNCTION           = 112;
		public const int R_MODULE_INITIALIZATION_ERROR     = 109;
		public const int R_NO_CLOSE_BRACE                  = 102;
		public const int R_NO_CONF                         = 105;
		public const int R_NO_CONF_OR_ENVIRONMENT_VARIABLE = 106;
		public const int R_NO_SECTION                      = 107;
		public const int R_NO_SUCH_FILE                    = 114;
		public const int R_NO_VALUE                        = 108;
		public const int R_NUMBER_TOO_LARGE                = 121;
		public const int R_RECURSIVE_DIRECTORY_INCLUDE     = 111;
		public const int R_SSL_COMMAND_SECTION_EMPTY       = 117;
		public const int R_SSL_COMMAND_SECTION_NOT_FOUND   = 118;
		public const int R_SSL_SECTION_EMPTY               = 119;
		public const int R_SSL_SECTION_NOT_FOUND           = 120;
		public const int R_UNABLE_TO_CREATE_NEW_SECTION    = 103;
		public const int R_UNKNOWN_MODULE_NAME             = 113;
		public const int R_VARIABLE_EXPANSION_TOO_LONG     = 116;
		public const int R_VARIABLE_HAS_NO_VALUE           = 104;

		[CRepr]
		public struct VALUE
		{
		    public char8* section;
		    public char8* name;
		    public char8* value;
		}

		[CRepr]
		public struct method_st
		{
		    public char8* name;
		    public function conf_st*(METHOD* meth) create;
		    public function int(conf_st* conf) init;
		    public function int(conf_st* conf) destroy;
		    public function int(conf_st* conf) destroy_data;
		    public function int(conf_st* conf, BIO.bio_st* bp, int* eline) load_bio;
		    public function int(conf_st* conf, BIO.bio_st* bp) dump;
		    public function int(conf_st* conf, char8 c) is_number;
		    public function int(conf_st* conf, char8 c) to_int;
		    public function int(conf_st* conf, char8* name, int* eline) load;
		}
		public typealias METHOD = method_st;

		/* Module definitions */
		[CRepr]
		public struct imodule_st {
		    public MODULE* pmod;
		    public char8* name;
		    public char8* value;
		    public uint flags;
		    public void* usr_data;
		}
		public typealias IMODULE = imodule_st;

		public struct module_st {
		    /* DSO of this module or NULL if static */
		    public DSO.dso_st* dso;
		    /* Name of the module */
		    public char8* name;
		    /* Init function */
		    public conf_init_func *init;
		    /* Finish function */
		    public conf_finish_func *finish;
		    /* Number of successfully initialized modules */
		    public int links;
		    public void* usr_data;
		}
		public typealias MODULE = module_st;

		public struct stack_st_CONF_VALUE {}
		public struct lhash_st_CONF_VALUE {}

		/* DSO module function typedefs */
		public function int conf_init_func(IMODULE* md, conf_st* cnf);
		public function void conf_finish_func(IMODULE* md);

		public const int MFLAGS_IGNORE_ERRORS       = 0x1;
		public const int MFLAGS_IGNORE_RETURN_CODES = 0x2;
		public const int MFLAGS_SILENT              = 0x4;
		public const int MFLAGS_NO_DSO              = 0x8;
		public const int MFLAGS_IGNORE_MISSING_FILE = 0x10;
		public const int MFLAGS_DEFAULT_SECTION     = 0x20;

		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_set_default_method")]
		public extern static int set_default_method(METHOD* meth);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_set_nconf")]
		public extern static void set_nconf(conf_st* conf, lhash_st_CONF_VALUE* hash);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_load")]
		public extern static lhash_st_CONF_VALUE* load(lhash_st_CONF_VALUE* conf, char8* file, int* eline);
#if !OPENSSL_NO_STDIO
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_load_fp")]
		public extern static lhash_st_CONF_VALUE* load_fp(lhash_st_CONF_VALUE* conf, Platform.BfpFile* fp, int* eline);
#endif
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_load_bio")]
		public extern static lhash_st_CONF_VALUE* load_bio(lhash_st_CONF_VALUE* conf, BIO *bp, int* eline);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_get_section")]
		public extern static stack_st_CONF_VALUE* get_section(lhash_st_CONF_VALUE* conf, char8* section);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_get_string")]
		public extern static char8* get_string(lhash_st_CONF_VALUE* conf, char8* group, char8* name);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_get_number")]
		public extern static int get_number(lhash_st_CONF_VALUE* conf, char8* group, char8* name);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_free")]
		public extern static void free(lhash_st_CONF_VALUE* conf);
#if !OPENSSL_NO_STDIO
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_dump_fp")]
		public extern static int dump_fp(lhash_st_CONF_VALUE* conf, Platform.BfpFile* outVal);
#endif
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_dump_bio")]
		public extern static int dump_bio(lhash_st_CONF_VALUE* conf, BIO.bio_st* outVal);

		/*
		 * New conf code.  The semantics are different from the functions above. If
		 * that wasn't the case, the above functions would have been replaced
		 */
		[CRepr]
		public struct conf_st
		{
		    public METHOD* meth;
		    public void* meth_data;
		    public stack_st_CONF_VALUE* data;
		}
		public typealias CONF = conf_st;

		/* Module functions */

		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_modules_load")]
		public extern static int modules_load(conf_st* cnf, char8* appname, uint flags);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_modules_load_file")]
		public extern static int modules_load_file(char8* filename, char8* appname, uint flags);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_modules_unload")]
		public extern static void modules_unload(int all);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_modules_finish")]
		public extern static void modules_finish();
		[Inline, Obsolete("No longer available, no-op", true)]
		public static void modules_free() { while(false) continue; }
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_module_add")]
		public extern static int module_add(char8* name, conf_init_func* ifunc, conf_finish_func* ffunc);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_imodule_get_name")]
		public extern static char8* imodule_get_name(IMODULE* md);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_imodule_get_value")]
		public extern static char8* imodule_get_value(IMODULE* md);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_imodule_get_usr_data")]
		public extern static void* imodule_get_usr_data(IMODULE* md);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_imodule_set_usr_data")]
		public extern static void imodule_set_usr_data(IMODULE* md, void* usr_data);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_imodule_get_module")]
		public extern static MODULE* imodule_get_module(IMODULE* md);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_imodule_get_flags")]
		public extern static uint imodule_get_flags(IMODULE* md);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_imodule_set_flags")]
		public extern static void imodule_set_flags(IMODULE* md, uint flags);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_module_get_usr_data")]
		public extern static void* module_get_usr_data(MODULE* pmod);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_module_set_usr_data")]
		public extern static void module_set_usr_data(MODULE* pmod, void* usr_data);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_get1_default_config_file")]
		public extern static char8* get1_default_config_file();

		[Import(OPENSSL_LIB_CRYPTO), LinkName("CONF_parse_list")]
		public extern static int parse_list(char8* list, int sep, int nospc, function int(char8* elem, int len, void* usr) list_cb, void* arg);

		/* Up until OpenSSL 0.9.5a, this was new_section */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("_CONF_new_section")]
		public extern static VALUE* new_section(conf_st* conf, char8* section);
		/* Up until OpenSSL 0.9.5a, this was get_section */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("_CONF_get_section")]
		public extern static VALUE* get_section(conf_st* conf, char8* section);
		/* Up until OpenSSL 0.9.5a, this was CONF_get_section */
		[Import(OPENSSL_LIB_CRYPTO), LinkName("_CONF_get_section_values")]
		public extern static stack_st_CONF_VALUE* get_section_values(conf_st* conf, char8* section);
		
		[Import(OPENSSL_LIB_CRYPTO), LinkName("_CONF_add_string")]
		public extern static int add_string(conf_st* conf, VALUE* section, VALUE* value);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("_CONF_get_string")]
		public extern static char8* get_string(conf_st* conf, char8* section, char8* name);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("_CONF_get_number")]
		public extern static int get_number(conf_st* conf, char8* section, char8* name);
		
		[Import(OPENSSL_LIB_CRYPTO), LinkName("_CONF_new_data")]
		public extern static int new_data(conf_st* conf);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("_CONF_free_data")]
		public extern static void free_data(conf_st* conf);
	}

	[AlwaysInclude]
	sealed abstract class NConf
	{
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_new")]
		public extern static Conf.conf_st* new_(Conf.METHOD* meth);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_default")]
		public extern static Conf.METHOD* default_();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_WIN32")]
		public extern static Conf.METHOD* WIN32();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_free")]
		public extern static void free(Conf.conf_st* conf);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_free_data")]
		public extern static void free_data(Conf.conf_st* conf);

		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_load")]
		public extern static int load(Conf.conf_st* conf, char8* file, int* eline);
#if !OPENSSL_NO_STDIO
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_load_fp")]
		public extern static int load_fp(Conf.conf_st* conf, Platform.BfpFile* fp, int* eline);
#endif
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_load_bio")]
		public extern static int load_bio(Conf.conf_st* conf, BIO.bio_st* bp, int* eline);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_get_section")]
		public extern static Conf.stack_st_CONF_VALUE* get_section(Conf.conf_st* conf, char8* section);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_get_string")]
		public extern static char8* get_string(Conf.conf_st* conf, char8* group, char8* name);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_get_number_e")]
		public extern static int get_number_e(Conf.conf_st* conf, char8* group, char8* name, int* result);
#if !OPENSSL_NO_STDIO
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_dump_fp")]
		public extern static int dump_fp(Conf.conf_st* conf, Platform.BfpFile* outVal);
#endif
		[Import(OPENSSL_LIB_CRYPTO), LinkName("NCONF_dump_bio")]
		public extern static int dump_bio(Conf.conf_st* conf, BIO.bio_st* outVal);

		[Inline]
		public static int get_number(Conf.conf_st* conf, char8* group, char8* name, int* result) => get_number_e(conf, group, name, result);
	}
}
