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
	sealed abstract class Stack
	{
		public function int sk_compfunc(void* a, void* b);
		public function void sk_freefunc(void* a);
		public function void* sk_copyfunc(void* a);

		[CRepr]
		public struct stack_st
		{
		    public int num;
		    public void** data;
		    public int sorted;
		    public int num_alloc;
		    public sk_compfunc comp;
		}
		public typealias OPENSSL_STACK = stack_st; /* Use STACK_OF(...) instead */
		
		public struct stack_st_X509_ALGOR {}
		
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_num")]
		public extern static int sk_num(OPENSSL_STACK* st);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_value")]
		public extern static void* sk_value(OPENSSL_STACK* st, int i);
		
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_set")]
		public extern static void* sk_set(OPENSSL_STACK* st, int i, void* data);
		
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_new")]
		public extern static OPENSSL_STACK* sk_new(sk_compfunc cmp);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_new_null")]
		public extern static OPENSSL_STACK* sk_new_null();
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_new_reserve")]
		public extern static OPENSSL_STACK* sk_new_reserve(sk_compfunc c, int n);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_reserve")]
		public extern static int sk_reserve(OPENSSL_STACK* st, int n);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_free")]
		public extern static void sk_free(OPENSSL_STACK* st);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_pop_free")]
		public extern static void sk_pop_free(OPENSSL_STACK* st, function void(void*) func);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_deep_copy")]
		public extern static OPENSSL_STACK* sk_deep_copy(OPENSSL_STACK* st, sk_copyfunc c, sk_freefunc f);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_insert")]
		public extern static int sk_insert(OPENSSL_STACK* sk, void* data, int where_);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_delete")]
		public extern static void* sk_delete(OPENSSL_STACK* st, int loc);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_delete_ptr")]
		public extern static void* sk_delete_ptr(OPENSSL_STACK* st, void* p);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_find")]
		public extern static int sk_find(OPENSSL_STACK* st, void* data);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_find_ex")]
		public extern static int sk_find_ex(OPENSSL_STACK* st, void* data);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_push")]
		public extern static int sk_push(OPENSSL_STACK* st, void* data);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_unshift")]
		public extern static int sk_unshift(OPENSSL_STACK* st, void* data);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_shift")]
		public extern static void* sk_shift(OPENSSL_STACK* st);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_pop")]
		public extern static void* sk_pop(OPENSSL_STACK* st);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_zero")]
		public extern static void sk_zero(OPENSSL_STACK* st);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_set_cmp_func")]
		public extern static sk_compfunc sk_set_cmp_func(OPENSSL_STACK* sk, sk_compfunc cmp);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_dup")]
		public extern static OPENSSL_STACK* sk_dup(OPENSSL_STACK* st);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_sort")]
		public extern static void sk_sort(OPENSSL_STACK* st);
		[Import(OPENSSL_LIB_CRYPTO), LinkName("OPENSSL_sk_is_sorted")]
		public extern static int sk_is_sorted(OPENSSL_STACK* st);
	}
}
