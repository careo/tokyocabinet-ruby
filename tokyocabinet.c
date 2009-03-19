/*************************************************************************************************
 * Ruby binding of Tokyo Cabinet
 *                                                      Copyright (C) 2006-2009 Mikio Hirabayashi
 * This file is part of Tokyo Cabinet.
 * Tokyo Cabinet is free software; you can redistribute it and/or modify it under the terms of
 * the GNU Lesser General Public License as published by the Free Software Foundation; either
 * version 2.1 of the License or any later version.  Tokyo Cabinet is distributed in the hope
 * that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 * You should have received a copy of the GNU Lesser General Public License along with Tokyo
 * Cabinet; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA.
 *************************************************************************************************/


#include "ruby.h"
#include <tcutil.h>
#include <tchdb.h>
#include <tcbdb.h>
#include <tcfdb.h>
#include <tctdb.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#include <math.h>

#define HDBVNDATA      "@hdb"
#define BDBVNDATA      "@bdb"
#define BDBCURVNDATA   "@bdbcur"
#define FDBVNDATA      "@fdb"
#define TDBVNDATA      "@tdb"
#define TDBQRYVNDATA   "@tdbqry"
#define NUMBUFSIZ      32

#if !defined(RSTRING_PTR)
#define RSTRING_PTR(TC_s) (RSTRING(TC_s)->ptr)
#endif
#if !defined(RSTRING_LEN)
#define RSTRING_LEN(TC_s) (RSTRING(TC_s)->len)
#endif
#if !defined(RARRAY_LEN)
#define RARRAY_LEN(TC_a) (RARRAY(TC_a)->len)
#endif


/* private function prototypes */
static VALUE StringValueEx(VALUE vobj);
static TCLIST *varytolist(VALUE vary);
static VALUE listtovary(TCLIST *list);
static TCMAP *vhashtomap(VALUE vhash);
static VALUE maptovhash(TCMAP *map);
static void hdb_init(void);
static VALUE hdb_initialize(VALUE vself);
static VALUE hdb_errmsg(int argc, VALUE *argv, VALUE vself);
static VALUE hdb_ecode(VALUE vself);
static VALUE hdb_tune(int argc, VALUE *argv, VALUE vself);
static VALUE hdb_setcache(int argc, VALUE *argv, VALUE vself);
static VALUE hdb_setxmsiz(int argc, VALUE *argv, VALUE vself);
static VALUE hdb_open(int argc, VALUE *argv, VALUE vself);
static VALUE hdb_close(VALUE vself);
static VALUE hdb_put(VALUE vself, VALUE vkey, VALUE vval);
static VALUE hdb_putkeep(VALUE vself, VALUE vkey, VALUE vval);
static VALUE hdb_putcat(VALUE vself, VALUE vkey, VALUE vval);
static VALUE hdb_putasync(VALUE vself, VALUE vkey, VALUE vval);
static VALUE hdb_out(VALUE vself, VALUE vkey);
static VALUE hdb_get(VALUE vself, VALUE vkey);
static VALUE hdb_vsiz(VALUE vself, VALUE vkey);
static VALUE hdb_iterinit(VALUE vself);
static VALUE hdb_iternext(VALUE vself);
static VALUE hdb_fwmkeys(int argc, VALUE *argv, VALUE vself);
static VALUE hdb_addint(VALUE vself, VALUE vkey, VALUE vnum);
static VALUE hdb_adddouble(VALUE vself, VALUE vkey, VALUE vnum);
static VALUE hdb_sync(VALUE vself);
static VALUE hdb_optimize(int argc, VALUE *argv, VALUE vself);
static VALUE hdb_vanish(VALUE vself);
static VALUE hdb_copy(VALUE vself, VALUE vpath);
static VALUE hdb_tranbegin(VALUE vself);
static VALUE hdb_trancommit(VALUE vself);
static VALUE hdb_tranabort(VALUE vself);
static VALUE hdb_path(VALUE vself);
static VALUE hdb_rnum(VALUE vself);
static VALUE hdb_fsiz(VALUE vself);
static VALUE hdb_fetch(int argc, VALUE *argv, VALUE vself);
static VALUE hdb_check(VALUE vself, VALUE vkey);
static VALUE hdb_check_value(VALUE vself, VALUE vval);
static VALUE hdb_get_reverse(VALUE vself, VALUE vval);
static VALUE hdb_empty(VALUE vself);
static VALUE hdb_each(VALUE vself);
static VALUE hdb_each_key(VALUE vself);
static VALUE hdb_each_value(VALUE vself);
static VALUE hdb_keys(VALUE vself);
static VALUE hdb_values(VALUE vself);
static void bdb_init(void);
static int bdb_cmpobj(const char *aptr, int asiz, const char *bptr, int bsiz, VALUE vcmp);
static VALUE bdb_initialize(VALUE vself);
static VALUE bdb_errmsg(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_ecode(VALUE vself);
static VALUE bdb_setcmpfunc(VALUE vself, VALUE vcmp);
static VALUE bdb_tune(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_setcache(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_setxmsiz(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_open(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_close(VALUE vself);
static VALUE bdb_put(VALUE vself, VALUE vkey, VALUE vval);
static VALUE bdb_putkeep(VALUE vself, VALUE vkey, VALUE vval);
static VALUE bdb_putcat(VALUE vself, VALUE vkey, VALUE vval);
static VALUE bdb_putdup(VALUE vself, VALUE vkey, VALUE vval);
static VALUE bdb_putlist(VALUE vself, VALUE vkey, VALUE vvals);
static VALUE bdb_out(VALUE vself, VALUE vkey);
static VALUE bdb_outlist(VALUE vself, VALUE vkey);
static VALUE bdb_get(VALUE vself, VALUE vkey);
static VALUE bdb_getlist(VALUE vself, VALUE vkey);
static VALUE bdb_vnum(VALUE vself, VALUE vkey);
static VALUE bdb_vsiz(VALUE vself, VALUE vkey);
static VALUE bdb_range(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_fwmkeys(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_addint(VALUE vself, VALUE vkey, VALUE vnum);
static VALUE bdb_adddouble(VALUE vself, VALUE vkey, VALUE vnum);
static VALUE bdb_sync(VALUE vself);
static VALUE bdb_optimize(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_vanish(VALUE vself);
static VALUE bdb_copy(VALUE vself, VALUE vpath);
static VALUE bdb_tranbegin(VALUE vself);
static VALUE bdb_trancommit(VALUE vself);
static VALUE bdb_tranabort(VALUE vself);
static VALUE bdb_path(VALUE vself);
static VALUE bdb_rnum(VALUE vself);
static VALUE bdb_fsiz(VALUE vself);
static VALUE bdb_fetch(int argc, VALUE *argv, VALUE vself);
static VALUE bdb_check(VALUE vself, VALUE vkey);
static VALUE bdb_check_value(VALUE vself, VALUE vval);
static VALUE bdb_get_reverse(VALUE vself, VALUE vval);
static VALUE bdb_empty(VALUE vself);
static VALUE bdb_each(VALUE vself);
static VALUE bdb_each_key(VALUE vself);
static VALUE bdb_each_value(VALUE vself);
static VALUE bdb_keys(VALUE vself);
static VALUE bdb_values(VALUE vself);
static void bdbcur_init(void);
static VALUE bdbcur_initialize(VALUE vself, VALUE vbdb);
static VALUE bdbcur_first(VALUE vself);
static VALUE bdbcur_last(VALUE vself);
static VALUE bdbcur_jump(VALUE vself, VALUE vkey);
static VALUE bdbcur_prev(VALUE vself);
static VALUE bdbcur_next(VALUE vself);
static VALUE bdbcur_put(int argc, VALUE *argv, VALUE vself);
static VALUE bdbcur_out(VALUE vself);
static VALUE bdbcur_key(VALUE vself);
static VALUE bdbcur_val(VALUE vself);
static void fdb_init(void);
static VALUE fdb_initialize(VALUE vself);
static VALUE fdb_errmsg(int argc, VALUE *argv, VALUE vself);
static VALUE fdb_ecode(VALUE vself);
static VALUE fdb_tune(int argc, VALUE *argv, VALUE vself);
static VALUE fdb_open(int argc, VALUE *argv, VALUE vself);
static VALUE fdb_close(VALUE vself);
static VALUE fdb_put(VALUE vself, VALUE vkey, VALUE vval);
static VALUE fdb_putkeep(VALUE vself, VALUE vkey, VALUE vval);
static VALUE fdb_putcat(VALUE vself, VALUE vkey, VALUE vval);
static VALUE fdb_out(VALUE vself, VALUE vkey);
static VALUE fdb_get(VALUE vself, VALUE vkey);
static VALUE fdb_vsiz(VALUE vself, VALUE vkey);
static VALUE fdb_iterinit(VALUE vself);
static VALUE fdb_iternext(VALUE vself);
static VALUE fdb_range(int argc, VALUE *argv, VALUE vself);
static VALUE fdb_addint(VALUE vself, VALUE vkey, VALUE vnum);
static VALUE fdb_adddouble(VALUE vself, VALUE vkey, VALUE vnum);
static VALUE fdb_sync(VALUE vself);
static VALUE fdb_optimize(int argc, VALUE *argv, VALUE vself);
static VALUE fdb_vanish(VALUE vself);
static VALUE fdb_copy(VALUE vself, VALUE vpath);
static VALUE fdb_path(VALUE vself);
static VALUE fdb_rnum(VALUE vself);
static VALUE fdb_fsiz(VALUE vself);
static VALUE fdb_fetch(int argc, VALUE *argv, VALUE vself);
static VALUE fdb_check(VALUE vself, VALUE vkey);
static VALUE fdb_check_value(VALUE vself, VALUE vval);
static VALUE fdb_get_reverse(VALUE vself, VALUE vval);
static VALUE fdb_empty(VALUE vself);
static VALUE fdb_each(VALUE vself);
static VALUE fdb_each_key(VALUE vself);
static VALUE fdb_each_value(VALUE vself);
static VALUE fdb_keys(VALUE vself);
static VALUE fdb_values(VALUE vself);
static void tdb_init(void);
static VALUE tdb_initialize(VALUE vself);
static VALUE tdb_errmsg(int argc, VALUE *argv, VALUE vself);
static VALUE tdb_ecode(VALUE vself);
static VALUE tdb_tune(int argc, VALUE *argv, VALUE vself);
static VALUE tdb_setcache(int argc, VALUE *argv, VALUE vself);
static VALUE tdb_setxmsiz(int argc, VALUE *argv, VALUE vself);
static VALUE tdb_open(int argc, VALUE *argv, VALUE vself);
static VALUE tdb_close(VALUE vself);
static VALUE tdb_put(VALUE vself, VALUE vkey, VALUE vcols);
static VALUE tdb_putkeep(VALUE vself, VALUE vkey, VALUE vcols);
static VALUE tdb_putcat(VALUE vself, VALUE vkey, VALUE vcols);
static VALUE tdb_out(VALUE vself, VALUE vkey);
static VALUE tdb_get(VALUE vself, VALUE vkey);
static VALUE tdb_vsiz(VALUE vself, VALUE vkey);
static VALUE tdb_iterinit(VALUE vself);
static VALUE tdb_iternext(VALUE vself);
static VALUE tdb_fwmkeys(int argc, VALUE *argv, VALUE vself);
static VALUE tdb_addint(VALUE vself, VALUE vkey, VALUE vnum);
static VALUE tdb_adddouble(VALUE vself, VALUE vkey, VALUE vnum);
static VALUE tdb_sync(VALUE vself);
static VALUE tdb_optimize(int argc, VALUE *argv, VALUE vself);
static VALUE tdb_vanish(VALUE vself);
static VALUE tdb_copy(VALUE vself, VALUE vpath);
static VALUE tdb_tranbegin(VALUE vself);
static VALUE tdb_trancommit(VALUE vself);
static VALUE tdb_tranabort(VALUE vself);
static VALUE tdb_path(VALUE vself);
static VALUE tdb_rnum(VALUE vself);
static VALUE tdb_fsiz(VALUE vself);
static VALUE tdb_setindex(VALUE vself, VALUE vname, VALUE vtype);
static VALUE tdb_genuid(VALUE vself);
static VALUE tdb_fetch(int argc, VALUE *argv, VALUE vself);
static VALUE tdb_check(VALUE vself, VALUE vkey);
static VALUE tdb_empty(VALUE vself);
static VALUE tdb_each(VALUE vself);
static VALUE tdb_each_key(VALUE vself);
static VALUE tdb_each_value(VALUE vself);
static VALUE tdb_keys(VALUE vself);
static VALUE tdb_values(VALUE vself);
static void tdbqry_init(void);
static int tdbqry_procrec(const void *pkbuf, int pksiz, TCMAP *cols, void *opq);
static VALUE tdbqry_initialize(VALUE vself, VALUE vtdb);
static VALUE tdbqry_addcond(VALUE vself, VALUE vname, VALUE vop, VALUE vexpr);
static VALUE tdbqry_setorder(VALUE vself, VALUE vname, VALUE vtype);
static VALUE tdbqry_setlimit(int argc, VALUE *argv, VALUE vself);
static VALUE tdbqry_search(VALUE vself);
static VALUE tdbqry_searchout(VALUE vself);
static VALUE tdbqry_proc(VALUE vself, VALUE vproc);
static VALUE tdbqry_hint(VALUE vself);



/*************************************************************************************************
 * public objects
 *************************************************************************************************/


VALUE mod_tokyocabinet;
VALUE cls_hdb;
VALUE cls_hdb_data;
VALUE cls_bdb;
VALUE cls_bdb_data;
VALUE cls_bdbcur;
VALUE cls_bdbcur_data;
ID bdb_cmp_call_mid;
VALUE cls_fdb;
VALUE cls_fdb_data;
VALUE cls_tdb;
VALUE cls_tdb_data;
VALUE cls_tdbqry;
VALUE cls_tdbqry_data;


int Init_tokyocabinet(void){
  mod_tokyocabinet = rb_define_module("TokyoCabinet");
  rb_define_const(mod_tokyocabinet, "VERSION", rb_str_new2(tcversion));
  hdb_init();
  bdb_init();
  bdbcur_init();
  fdb_init();
  tdb_init();
  tdbqry_init();
  return 0;
}



/*************************************************************************************************
 * private objects
 *************************************************************************************************/


static VALUE StringValueEx(VALUE vobj){
  char kbuf[NUMBUFSIZ];
  int ksiz;
  switch(TYPE(vobj)){
  case T_FIXNUM:
    ksiz = sprintf(kbuf, "%d", (int)FIX2INT(vobj));
    return rb_str_new(kbuf, ksiz);
  case T_BIGNUM:
    ksiz = sprintf(kbuf, "%lld", (long long)NUM2LL(vobj));
    return rb_str_new(kbuf, ksiz);
  case T_TRUE:
    ksiz = sprintf(kbuf, "true");
    return rb_str_new(kbuf, ksiz);
  case T_FALSE:
    ksiz = sprintf(kbuf, "false");
    return rb_str_new(kbuf, ksiz);
  case T_NIL:
    ksiz = sprintf(kbuf, "nil");
    return rb_str_new(kbuf, ksiz);
  }
  return StringValue(vobj);
}


static TCLIST *varytolist(VALUE vary){
  VALUE vval;
  TCLIST *list;
  int i, num;
  num = RARRAY_LEN(vary);
  list = tclistnew2(num);
  for(i = 0; i < num; i++){
    vval = rb_ary_entry(vary, i);
    vval = StringValueEx(vval);
    tclistpush(list, RSTRING_PTR(vval), RSTRING_LEN(vval));
  }
  return list;
}


static VALUE listtovary(TCLIST *list){
  VALUE vary;
  const char *vbuf;
  int i, num, vsiz;
  num = tclistnum(list);
  vary = rb_ary_new2(num);
  for(i = 0; i < num; i++){
    vbuf = tclistval(list, i, &vsiz);
    rb_ary_push(vary, rb_str_new(vbuf, vsiz));
  }
  return vary;
}


static TCMAP *vhashtomap(VALUE vhash){
  VALUE vkeys, vkey, vval;
  TCMAP *map;
  int i, num;
  map = tcmapnew2(31);
  vkeys = rb_funcall(vhash, rb_intern("keys"), 0);
  num = RARRAY_LEN(vkeys);
  for(i = 0; i < num; i++){
    vkey = rb_ary_entry(vkeys, i);
    vval = rb_hash_aref(vhash, vkey);
    vkey = StringValueEx(vkey);
    vval = StringValueEx(vval);
    tcmapput(map, RSTRING_PTR(vkey), RSTRING_LEN(vkey), RSTRING_PTR(vval), RSTRING_LEN(vval));
  }
  return map;
}


static VALUE maptovhash(TCMAP *map){
  const char *kbuf, *vbuf;
  int ksiz, vsiz;
  VALUE vhash;
  vhash = rb_hash_new();
  tcmapiterinit(map);
  while((kbuf = tcmapiternext(map, &ksiz)) != NULL){
    vbuf = tcmapiterval(kbuf, &vsiz);
    rb_hash_aset(vhash, rb_str_new(kbuf, ksiz), rb_str_new(vbuf, vsiz));
  }
  return vhash;
}


static void hdb_init(void){
  cls_hdb = rb_define_class_under(mod_tokyocabinet, "HDB", rb_cObject);
  cls_hdb_data = rb_define_class_under(mod_tokyocabinet, "HDB_data", rb_cObject);
  rb_define_const(cls_hdb, "ESUCCESS", INT2NUM(TCESUCCESS));
  rb_define_const(cls_hdb, "ETHREAD", INT2NUM(TCETHREAD));
  rb_define_const(cls_hdb, "EINVALID", INT2NUM(TCEINVALID));
  rb_define_const(cls_hdb, "ENOFILE", INT2NUM(TCENOFILE));
  rb_define_const(cls_hdb, "ENOPERM", INT2NUM(TCENOPERM));
  rb_define_const(cls_hdb, "EMETA", INT2NUM(TCEMETA));
  rb_define_const(cls_hdb, "ERHEAD", INT2NUM(TCERHEAD));
  rb_define_const(cls_hdb, "EOPEN", INT2NUM(TCEOPEN));
  rb_define_const(cls_hdb, "ECLOSE", INT2NUM(TCECLOSE));
  rb_define_const(cls_hdb, "ETRUNC", INT2NUM(TCETRUNC));
  rb_define_const(cls_hdb, "ESYNC", INT2NUM(TCESYNC));
  rb_define_const(cls_hdb, "ESTAT", INT2NUM(TCESTAT));
  rb_define_const(cls_hdb, "ESEEK", INT2NUM(TCESEEK));
  rb_define_const(cls_hdb, "EREAD", INT2NUM(TCEREAD));
  rb_define_const(cls_hdb, "EWRITE", INT2NUM(TCEWRITE));
  rb_define_const(cls_hdb, "EMMAP", INT2NUM(TCEMMAP));
  rb_define_const(cls_hdb, "ELOCK", INT2NUM(TCELOCK));
  rb_define_const(cls_hdb, "EUNLINK", INT2NUM(TCEUNLINK));
  rb_define_const(cls_hdb, "ERENAME", INT2NUM(TCERENAME));
  rb_define_const(cls_hdb, "EMKDIR", INT2NUM(TCEMKDIR));
  rb_define_const(cls_hdb, "ERMDIR", INT2NUM(TCERMDIR));
  rb_define_const(cls_hdb, "EKEEP", INT2NUM(TCEKEEP));
  rb_define_const(cls_hdb, "ENOREC", INT2NUM(TCENOREC));
  rb_define_const(cls_hdb, "EMISC", INT2NUM(TCEMISC));
  rb_define_const(cls_hdb, "TLARGE", INT2NUM(HDBTLARGE));
  rb_define_const(cls_hdb, "TDEFLATE", INT2NUM(HDBTDEFLATE));
  rb_define_const(cls_hdb, "TBZIP", INT2NUM(HDBTBZIP));
  rb_define_const(cls_hdb, "TTCBS", INT2NUM(HDBTTCBS));
  rb_define_const(cls_hdb, "OREADER", INT2NUM(HDBOREADER));
  rb_define_const(cls_hdb, "OWRITER", INT2NUM(HDBOWRITER));
  rb_define_const(cls_hdb, "OCREAT", INT2NUM(HDBOCREAT));
  rb_define_const(cls_hdb, "OTRUNC", INT2NUM(HDBOTRUNC));
  rb_define_const(cls_hdb, "ONOLCK", INT2NUM(HDBONOLCK));
  rb_define_const(cls_hdb, "OLCKNB", INT2NUM(HDBOLCKNB));
  rb_define_const(cls_hdb, "OTSYNC", INT2NUM(HDBOTSYNC));
  rb_define_private_method(cls_hdb, "initialize", hdb_initialize, 0);
  rb_define_method(cls_hdb, "errmsg", hdb_errmsg, -1);
  rb_define_method(cls_hdb, "ecode", hdb_ecode, 0);
  rb_define_method(cls_hdb, "tune", hdb_tune, -1);
  rb_define_method(cls_hdb, "setcache", hdb_setcache, -1);
  rb_define_method(cls_hdb, "setxmsiz", hdb_setxmsiz, -1);
  rb_define_method(cls_hdb, "open", hdb_open, -1);
  rb_define_method(cls_hdb, "close", hdb_close, 0);
  rb_define_method(cls_hdb, "put", hdb_put, 2);
  rb_define_method(cls_hdb, "putkeep", hdb_putkeep, 2);
  rb_define_method(cls_hdb, "putcat", hdb_putcat, 2);
  rb_define_method(cls_hdb, "putasync", hdb_putasync, 2);
  rb_define_method(cls_hdb, "out", hdb_out, 1);
  rb_define_method(cls_hdb, "get", hdb_get, 1);
  rb_define_method(cls_hdb, "vsiz", hdb_vsiz, 1);
  rb_define_method(cls_hdb, "iterinit", hdb_iterinit, 0);
  rb_define_method(cls_hdb, "iternext", hdb_iternext, 0);
  rb_define_method(cls_hdb, "fwmkeys", hdb_fwmkeys, -1);
  rb_define_method(cls_hdb, "addint", hdb_addint, 2);
  rb_define_method(cls_hdb, "adddouble", hdb_adddouble, 2);
  rb_define_method(cls_hdb, "sync", hdb_sync, 0);
  rb_define_method(cls_hdb, "optimize", hdb_optimize, -1);
  rb_define_method(cls_hdb, "vanish", hdb_vanish, 0);
  rb_define_method(cls_hdb, "copy", hdb_copy, 1);
  rb_define_method(cls_hdb, "tranbegin", hdb_tranbegin, 0);
  rb_define_method(cls_hdb, "trancommit", hdb_trancommit, 0);
  rb_define_method(cls_hdb, "tranabort", hdb_tranabort, 0);
  rb_define_method(cls_hdb, "path", hdb_path, 0);
  rb_define_method(cls_hdb, "rnum", hdb_rnum, 0);
  rb_define_method(cls_hdb, "fsiz", hdb_fsiz, 0);
  rb_define_method(cls_hdb, "[]", hdb_get, 1);
  rb_define_method(cls_hdb, "[]=", hdb_put, 2);
  rb_define_method(cls_hdb, "store", hdb_put, 2);
  rb_define_method(cls_hdb, "delete", hdb_out, 1);
  rb_define_method(cls_hdb, "fetch", hdb_fetch, -1);
  rb_define_method(cls_hdb, "has_key?", hdb_check, 1);
  rb_define_method(cls_hdb, "key?", hdb_check, 1);
  rb_define_method(cls_hdb, "include?", hdb_check, 1);
  rb_define_method(cls_hdb, "member?", hdb_check, 1);
  rb_define_method(cls_hdb, "has_value?", hdb_check_value, 1);
  rb_define_method(cls_hdb, "value?", hdb_check_value, 1);
  rb_define_method(cls_hdb, "key", hdb_get_reverse, 1);
  rb_define_method(cls_hdb, "clear", hdb_vanish, 0);
  rb_define_method(cls_hdb, "size", hdb_rnum, 0);
  rb_define_method(cls_hdb, "length", hdb_rnum, 0);
  rb_define_method(cls_hdb, "empty?", hdb_empty, 0);
  rb_define_method(cls_hdb, "each", hdb_each, 0);
  rb_define_method(cls_hdb, "each_pair", hdb_each, 0);
  rb_define_method(cls_hdb, "each_key", hdb_each_key, 0);
  rb_define_method(cls_hdb, "each_value", hdb_each_value, 0);
  rb_define_method(cls_hdb, "keys", hdb_keys, 0);
  rb_define_method(cls_hdb, "values", hdb_values, 0);
}


static VALUE hdb_initialize(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  hdb = tchdbnew();
  tchdbsetmutex(hdb);
  vhdb = Data_Wrap_Struct(cls_hdb_data, 0, tchdbdel, hdb);
  rb_iv_set(vself, HDBVNDATA, vhdb);
  return Qnil;
}


static VALUE hdb_errmsg(int argc, VALUE *argv, VALUE vself){
  VALUE vhdb, vecode;
  TCHDB *hdb;
  const char *msg;
  int ecode;
  rb_scan_args(argc, argv, "01", &vecode);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  ecode = (vecode == Qnil) ? tchdbecode(hdb) : NUM2INT(vecode);
  msg = tchdberrmsg(ecode);
  return rb_str_new2(msg);
}


static VALUE hdb_ecode(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return INT2NUM(tchdbecode(hdb));
}


static VALUE hdb_tune(int argc, VALUE *argv, VALUE vself){
  VALUE vhdb, vbnum, vapow, vfpow, vopts;
  TCHDB *hdb;
  int apow, fpow, opts;
  int64_t bnum;
  rb_scan_args(argc, argv, "04", &vbnum, &vapow, &vfpow, &vopts);
  bnum = (vbnum == Qnil) ? -1 : NUM2LL(vbnum);
  apow = (vapow == Qnil) ? -1 : NUM2INT(vapow);
  fpow = (vfpow == Qnil) ? -1 : NUM2INT(vfpow);
  opts = (vopts == Qnil) ? 0 : NUM2INT(vopts);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbtune(hdb, bnum, apow, fpow, opts) ? Qtrue : Qfalse;
}


static VALUE hdb_setcache(int argc, VALUE *argv, VALUE vself){
  VALUE vhdb, vrcnum;
  TCHDB *hdb;
  int rcnum;
  rb_scan_args(argc, argv, "01", &vrcnum);
  rcnum = (vrcnum == Qnil) ? -1 : NUM2INT(vrcnum);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbsetcache(hdb, rcnum) ? Qtrue : Qfalse;
}


static VALUE hdb_setxmsiz(int argc, VALUE *argv, VALUE vself){
  VALUE vhdb, vxmsiz;
  TCHDB *hdb;
  int64_t xmsiz;
  rb_scan_args(argc, argv, "01", &vxmsiz);
  xmsiz = (vxmsiz == Qnil) ? -1 : NUM2LL(vxmsiz);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbsetxmsiz(hdb, xmsiz) ? Qtrue : Qfalse;
}


static VALUE hdb_open(int argc, VALUE *argv, VALUE vself){
  VALUE vhdb, vpath, vomode;
  TCHDB *hdb;
  int omode;
  rb_scan_args(argc, argv, "11", &vpath, &vomode);
  Check_Type(vpath, T_STRING);
  omode = (vomode == Qnil) ? HDBOREADER : NUM2INT(vomode);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbopen(hdb, RSTRING_PTR(vpath), omode) ? Qtrue : Qfalse;
}


static VALUE hdb_close(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbclose(hdb) ? Qtrue : Qfalse;
}


static VALUE hdb_put(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vhdb;
  TCHDB *hdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbput(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey),
		  RSTRING_PTR(vval), RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE hdb_putkeep(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vhdb;
  TCHDB *hdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbputkeep(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey),
		      RSTRING_PTR(vval), RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE hdb_putcat(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vhdb;
  TCHDB *hdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbputcat(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey),
		     RSTRING_PTR(vval), RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE hdb_putasync(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vhdb;
  TCHDB *hdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbputasync(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey),
		       RSTRING_PTR(vval), RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE hdb_out(VALUE vself, VALUE vkey){
  VALUE vhdb;
  TCHDB *hdb;
  vkey = StringValueEx(vkey);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbout(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)) ? Qtrue : Qfalse;
}


static VALUE hdb_get(VALUE vself, VALUE vkey){
  VALUE vhdb, vval;
  TCHDB *hdb;
  char *vbuf;
  int vsiz;
  vkey = StringValueEx(vkey);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  if(!(vbuf = tchdbget(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), &vsiz))) return Qnil;
  vval = rb_str_new(vbuf, vsiz);
  tcfree(vbuf);
  return vval;
}


static VALUE hdb_vsiz(VALUE vself, VALUE vkey){
  VALUE vhdb;
  TCHDB *hdb;
  vkey = StringValueEx(vkey);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return INT2NUM(tchdbvsiz(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)));
}


static VALUE hdb_iterinit(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbiterinit(hdb) ? Qtrue : Qfalse;
}


static VALUE hdb_iternext(VALUE vself){
  VALUE vhdb, vval;
  TCHDB *hdb;
  char *vbuf;
  int vsiz;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  if(!(vbuf = tchdbiternext(hdb, &vsiz))) return Qnil;
  vval = rb_str_new(vbuf, vsiz);
  tcfree(vbuf);
  return vval;
}


static VALUE hdb_fwmkeys(int argc, VALUE *argv, VALUE vself){
  VALUE vhdb, vprefix, vmax, vary;
  TCHDB *hdb;
  TCLIST *keys;
  int max;
  rb_scan_args(argc, argv, "11", &vprefix, &vmax);
  vprefix = StringValueEx(vprefix);
  max = (vmax == Qnil) ? -1 : NUM2INT(vmax);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  keys = tchdbfwmkeys(hdb, RSTRING_PTR(vprefix), RSTRING_LEN(vprefix), max);
  vary = listtovary(keys);
  tclistdel(keys);
  return vary;
}


static VALUE hdb_addint(VALUE vself, VALUE vkey, VALUE vnum){
  VALUE vhdb;
  TCHDB *hdb;
  int num;
  vkey = StringValueEx(vkey);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  num = tchdbaddint(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), NUM2INT(vnum));
  return num == INT_MIN ? Qnil : INT2NUM(num);
}


static VALUE hdb_adddouble(VALUE vself, VALUE vkey, VALUE vnum){
  VALUE vhdb;
  TCHDB *hdb;
  double num;
  vkey = StringValueEx(vkey);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  num = tchdbadddouble(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), NUM2DBL(vnum));
  return isnan(num) ? Qnil : rb_float_new(num);
}


static VALUE hdb_sync(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbsync(hdb) ? Qtrue : Qfalse;
}


static VALUE hdb_optimize(int argc, VALUE *argv, VALUE vself){
  VALUE vhdb, vbnum, vapow, vfpow, vopts;
  TCHDB *hdb;
  int apow, fpow, opts;
  int64_t bnum;
  rb_scan_args(argc, argv, "04", &vbnum, &vapow, &vfpow, &vopts);
  bnum = (vbnum == Qnil) ? -1 : NUM2LL(vbnum);
  apow = (vapow == Qnil) ? -1 : NUM2INT(vapow);
  fpow = (vfpow == Qnil) ? -1 : NUM2INT(vfpow);
  opts = (vopts == Qnil) ? UINT8_MAX : NUM2INT(vopts);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdboptimize(hdb, bnum, apow, fpow, opts) ? Qtrue : Qfalse;
}


static VALUE hdb_vanish(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbvanish(hdb) ? Qtrue : Qfalse;
}


static VALUE hdb_copy(VALUE vself, VALUE vpath){
  VALUE vhdb;
  TCHDB *hdb;
  Check_Type(vpath, T_STRING);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbcopy(hdb, RSTRING_PTR(vpath)) ? Qtrue : Qfalse;
}


static VALUE hdb_tranbegin(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbtranbegin(hdb) ? Qtrue : Qfalse;
}


static VALUE hdb_trancommit(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbtrancommit(hdb) ? Qtrue : Qfalse;
}


static VALUE hdb_tranabort(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbtranabort(hdb) ? Qtrue : Qfalse;
}


static VALUE hdb_path(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  const char *path;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  if(!(path = tchdbpath(hdb))) return Qnil;
  return rb_str_new2(path);
}


static VALUE hdb_rnum(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return LL2NUM(tchdbrnum(hdb));
}


static VALUE hdb_fsiz(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return LL2NUM(tchdbfsiz(hdb));
}


static VALUE hdb_fetch(int argc, VALUE *argv, VALUE vself){
  VALUE vhdb, vkey, vdef, vval;
  TCHDB *hdb;
  char *vbuf;
  int vsiz;
  rb_scan_args(argc, argv, "11", &vkey, &vdef);
  vkey = StringValueEx(vkey);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  if((vbuf = tchdbget(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), &vsiz)) != NULL){
    vval = rb_str_new(vbuf, vsiz);
    tcfree(vbuf);
  } else {
    vval = vdef;
  }
  return vval;
}


static VALUE hdb_check(VALUE vself, VALUE vkey){
  VALUE vhdb;
  TCHDB *hdb;
  vkey = StringValueEx(vkey);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbvsiz(hdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)) >= 0 ? Qtrue : Qfalse;
}


static VALUE hdb_check_value(VALUE vself, VALUE vval){
  VALUE vhdb;
  TCHDB *hdb;
  TCXSTR *kxstr, *vxstr;
  int hit;
  vval = StringValueEx(vval);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  hit = 0;
  kxstr = tcxstrnew();
  vxstr = tcxstrnew();
  tchdbiterinit(hdb);
  while(tchdbiternext3(hdb, kxstr, vxstr)){
    if(tcxstrsize(vxstr) == RSTRING_LEN(vval) &&
       memcmp(tcxstrptr(vxstr), RSTRING_PTR(vval), RSTRING_LEN(vval)) == 0){
      hit = 1;
      break;
    }
  }
  tcxstrdel(vxstr);
  tcxstrdel(kxstr);
  return hit ? Qtrue : Qfalse;
}


static VALUE hdb_get_reverse(VALUE vself, VALUE vval){
  VALUE vhdb, vrv;
  TCHDB *hdb;
  TCXSTR *kxstr, *vxstr;
  vval = StringValueEx(vval);
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  vrv = Qnil;
  kxstr = tcxstrnew();
  vxstr = tcxstrnew();
  tchdbiterinit(hdb);
  while(tchdbiternext3(hdb, kxstr, vxstr)){
    if(tcxstrsize(vxstr) == RSTRING_LEN(vval) &&
       memcmp(tcxstrptr(vxstr), RSTRING_PTR(vval), RSTRING_LEN(vval)) == 0){
      vrv = rb_str_new(tcxstrptr(kxstr), tcxstrsize(kxstr));
      break;
    }
  }
  tcxstrdel(vxstr);
  tcxstrdel(kxstr);
  return vrv;
}


static VALUE hdb_empty(VALUE vself){
  VALUE vhdb;
  TCHDB *hdb;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  return tchdbrnum(hdb) < 1 ? Qtrue : Qfalse;
}


static VALUE hdb_each(VALUE vself){
  VALUE vhdb, vrv;
  TCHDB *hdb;
  TCXSTR *kxstr, *vxstr;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  vrv = Qnil;
  kxstr = tcxstrnew();
  vxstr = tcxstrnew();
  tchdbiterinit(hdb);
  while(tchdbiternext3(hdb, kxstr, vxstr)){
    vrv = rb_yield_values(2, rb_str_new(tcxstrptr(kxstr), tcxstrsize(kxstr)),
                          rb_str_new(tcxstrptr(vxstr), tcxstrsize(vxstr)));
  }
  tcxstrdel(vxstr);
  tcxstrdel(kxstr);
  return vrv;
}


static VALUE hdb_each_key(VALUE vself){
  VALUE vhdb, vrv;
  TCHDB *hdb;
  TCXSTR *kxstr, *vxstr;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  vrv = Qnil;
  kxstr = tcxstrnew();
  vxstr = tcxstrnew();
  tchdbiterinit(hdb);
  while(tchdbiternext3(hdb, kxstr, vxstr)){
    vrv = rb_yield(rb_str_new(tcxstrptr(kxstr), tcxstrsize(kxstr)));
  }
  tcxstrdel(vxstr);
  tcxstrdel(kxstr);
  return vrv;
}


static VALUE hdb_each_value(VALUE vself){
  VALUE vhdb, vrv;
  TCHDB *hdb;
  TCXSTR *kxstr, *vxstr;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  vrv = Qnil;
  kxstr = tcxstrnew();
  vxstr = tcxstrnew();
  tchdbiterinit(hdb);
  while(tchdbiternext3(hdb, kxstr, vxstr)){
    vrv = rb_yield(rb_str_new(tcxstrptr(vxstr), tcxstrsize(vxstr)));
  }
  tcxstrdel(vxstr);
  tcxstrdel(kxstr);
  return vrv;
}


static VALUE hdb_keys(VALUE vself){
  VALUE vhdb, vary;
  TCHDB *hdb;
  TCXSTR *kxstr, *vxstr;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  vary = rb_ary_new2(tchdbrnum(hdb));
  kxstr = tcxstrnew();
  vxstr = tcxstrnew();
  tchdbiterinit(hdb);
  while(tchdbiternext3(hdb, kxstr, vxstr)){
    rb_ary_push(vary, rb_str_new(tcxstrptr(kxstr), tcxstrsize(kxstr)));
  }
  tcxstrdel(vxstr);
  tcxstrdel(kxstr);
  return vary;
}


static VALUE hdb_values(VALUE vself){
  VALUE vhdb, vary;
  TCHDB *hdb;
  TCXSTR *kxstr, *vxstr;
  vhdb = rb_iv_get(vself, HDBVNDATA);
  Data_Get_Struct(vhdb, TCHDB, hdb);
  vary = rb_ary_new2(tchdbrnum(hdb));
  kxstr = tcxstrnew();
  vxstr = tcxstrnew();
  tchdbiterinit(hdb);
  while(tchdbiternext3(hdb, kxstr, vxstr)){
    rb_ary_push(vary, rb_str_new(tcxstrptr(vxstr), tcxstrsize(vxstr)));
  }
  tcxstrdel(vxstr);
  tcxstrdel(kxstr);
  return vary;
}


static void bdb_init(void){
  cls_bdb = rb_define_class_under(mod_tokyocabinet, "BDB", rb_cObject);
  cls_bdb_data = rb_define_class_under(mod_tokyocabinet, "BDB_data", rb_cObject);
  bdb_cmp_call_mid = rb_intern("call");
  rb_define_const(cls_bdb, "ESUCCESS", INT2NUM(TCESUCCESS));
  rb_define_const(cls_bdb, "ETHREAD", INT2NUM(TCETHREAD));
  rb_define_const(cls_bdb, "EINVALID", INT2NUM(TCEINVALID));
  rb_define_const(cls_bdb, "ENOFILE", INT2NUM(TCENOFILE));
  rb_define_const(cls_bdb, "ENOPERM", INT2NUM(TCENOPERM));
  rb_define_const(cls_bdb, "EMETA", INT2NUM(TCEMETA));
  rb_define_const(cls_bdb, "ERHEAD", INT2NUM(TCERHEAD));
  rb_define_const(cls_bdb, "EOPEN", INT2NUM(TCEOPEN));
  rb_define_const(cls_bdb, "ECLOSE", INT2NUM(TCECLOSE));
  rb_define_const(cls_bdb, "ETRUNC", INT2NUM(TCETRUNC));
  rb_define_const(cls_bdb, "ESYNC", INT2NUM(TCESYNC));
  rb_define_const(cls_bdb, "ESTAT", INT2NUM(TCESTAT));
  rb_define_const(cls_bdb, "ESEEK", INT2NUM(TCESEEK));
  rb_define_const(cls_bdb, "EREAD", INT2NUM(TCEREAD));
  rb_define_const(cls_bdb, "EWRITE", INT2NUM(TCEWRITE));
  rb_define_const(cls_bdb, "EMMAP", INT2NUM(TCEMMAP));
  rb_define_const(cls_bdb, "ELOCK", INT2NUM(TCELOCK));
  rb_define_const(cls_bdb, "EUNLINK", INT2NUM(TCEUNLINK));
  rb_define_const(cls_bdb, "ERENAME", INT2NUM(TCERENAME));
  rb_define_const(cls_bdb, "EMKDIR", INT2NUM(TCEMKDIR));
  rb_define_const(cls_bdb, "ERMDIR", INT2NUM(TCERMDIR));
  rb_define_const(cls_bdb, "EKEEP", INT2NUM(TCEKEEP));
  rb_define_const(cls_bdb, "ENOREC", INT2NUM(TCENOREC));
  rb_define_const(cls_bdb, "EMISC", INT2NUM(TCEMISC));
  rb_define_const(cls_bdb, "CMPLEXICAL", rb_str_new2("CMPLEXICAL"));
  rb_define_const(cls_bdb, "CMPDECIMAL", rb_str_new2("CMPDECIMAL"));
  rb_define_const(cls_bdb, "CMPINT32", rb_str_new2("CMPINT32"));
  rb_define_const(cls_bdb, "CMPINT64", rb_str_new2("CMPINT64"));
  rb_define_const(cls_bdb, "TLARGE", INT2NUM(BDBTLARGE));
  rb_define_const(cls_bdb, "TDEFLATE", INT2NUM(BDBTDEFLATE));
  rb_define_const(cls_bdb, "TBZIP", INT2NUM(BDBTBZIP));
  rb_define_const(cls_bdb, "TTCBS", INT2NUM(BDBTTCBS));
  rb_define_const(cls_bdb, "OREADER", INT2NUM(BDBOREADER));
  rb_define_const(cls_bdb, "OWRITER", INT2NUM(BDBOWRITER));
  rb_define_const(cls_bdb, "OCREAT", INT2NUM(BDBOCREAT));
  rb_define_const(cls_bdb, "OTRUNC", INT2NUM(BDBOTRUNC));
  rb_define_const(cls_bdb, "ONOLCK", INT2NUM(BDBONOLCK));
  rb_define_const(cls_bdb, "OLCKNB", INT2NUM(BDBOLCKNB));
  rb_define_const(cls_bdb, "OTSYNC", INT2NUM(BDBOTSYNC));
  rb_define_private_method(cls_bdb, "initialize", bdb_initialize, 0);
  rb_define_method(cls_bdb, "errmsg", bdb_errmsg, -1);
  rb_define_method(cls_bdb, "ecode", bdb_ecode, 0);
  rb_define_method(cls_bdb, "setcmpfunc", bdb_setcmpfunc, 1);
  rb_define_method(cls_bdb, "tune", bdb_tune, -1);
  rb_define_method(cls_bdb, "setcache", bdb_setcache, -1);
  rb_define_method(cls_bdb, "setxmsiz", bdb_setxmsiz, -1);
  rb_define_method(cls_bdb, "open", bdb_open, -1);
  rb_define_method(cls_bdb, "close", bdb_close, 0);
  rb_define_method(cls_bdb, "put", bdb_put, 2);
  rb_define_method(cls_bdb, "putkeep", bdb_putkeep, 2);
  rb_define_method(cls_bdb, "putcat", bdb_putcat, 2);
  rb_define_method(cls_bdb, "putdup", bdb_putdup, 2);
  rb_define_method(cls_bdb, "putlist", bdb_putlist, 2);
  rb_define_method(cls_bdb, "out", bdb_out, 1);
  rb_define_method(cls_bdb, "outlist", bdb_outlist, 1);
  rb_define_method(cls_bdb, "get", bdb_get, 1);
  rb_define_method(cls_bdb, "getlist", bdb_getlist, 1);
  rb_define_method(cls_bdb, "vnum", bdb_vnum, 1);
  rb_define_method(cls_bdb, "vsiz", bdb_vsiz, 1);
  rb_define_method(cls_bdb, "range", bdb_range, -1);
  rb_define_method(cls_bdb, "fwmkeys", bdb_fwmkeys, -1);
  rb_define_method(cls_bdb, "addint", bdb_addint, 2);
  rb_define_method(cls_bdb, "adddouble", bdb_adddouble, 2);
  rb_define_method(cls_bdb, "sync", bdb_sync, 0);
  rb_define_method(cls_bdb, "optimize", bdb_optimize, -1);
  rb_define_method(cls_bdb, "vanish", bdb_vanish, 0);
  rb_define_method(cls_bdb, "copy", bdb_copy, 1);
  rb_define_method(cls_bdb, "tranbegin", bdb_tranbegin, 0);
  rb_define_method(cls_bdb, "trancommit", bdb_trancommit, 0);
  rb_define_method(cls_bdb, "tranabort", bdb_tranabort, 0);
  rb_define_method(cls_bdb, "path", bdb_path, 0);
  rb_define_method(cls_bdb, "rnum", bdb_rnum, 0);
  rb_define_method(cls_bdb, "fsiz", bdb_fsiz, 0);
  rb_define_method(cls_bdb, "[]", bdb_get, 1);
  rb_define_method(cls_bdb, "[]=", bdb_put, 2);
  rb_define_method(cls_bdb, "store", bdb_put, 2);
  rb_define_method(cls_bdb, "delete", bdb_out, 1);
  rb_define_method(cls_bdb, "fetch", bdb_fetch, -1);
  rb_define_method(cls_bdb, "has_key?", bdb_check, 1);
  rb_define_method(cls_bdb, "key?", bdb_check, 1);
  rb_define_method(cls_bdb, "include?", bdb_check, 1);
  rb_define_method(cls_bdb, "member?", bdb_check, 1);
  rb_define_method(cls_bdb, "has_value?", bdb_check_value, 1);
  rb_define_method(cls_bdb, "value?", bdb_check_value, 1);
  rb_define_method(cls_bdb, "key", bdb_get_reverse, 1);
  rb_define_method(cls_bdb, "clear", bdb_vanish, 0);
  rb_define_method(cls_bdb, "size", bdb_rnum, 0);
  rb_define_method(cls_bdb, "length", bdb_rnum, 0);
  rb_define_method(cls_bdb, "empty?", bdb_empty, 0);
  rb_define_method(cls_bdb, "each", bdb_each, 0);
  rb_define_method(cls_bdb, "each_pair", bdb_each, 0);
  rb_define_method(cls_bdb, "each_key", bdb_each_key, 0);
  rb_define_method(cls_bdb, "each_value", bdb_each_value, 0);
  rb_define_method(cls_bdb, "keys", bdb_keys, 0);
  rb_define_method(cls_bdb, "values", bdb_values, 0);
}


static int bdb_cmpobj(const char *aptr, int asiz, const char *bptr, int bsiz, VALUE vcmp){
  VALUE vrv;
  vrv = rb_funcall(vcmp, bdb_cmp_call_mid, 2, rb_str_new(aptr, asiz), rb_str_new(bptr, bsiz));
  return (vrv == Qnil) ? 0 : NUM2INT(vrv);
}


static VALUE bdb_initialize(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  bdb = tcbdbnew();
  tcbdbsetmutex(bdb);
  vbdb = Data_Wrap_Struct(cls_bdb_data, 0, tcbdbdel, bdb);
  rb_iv_set(vself, BDBVNDATA, vbdb);
  return Qnil;
}


static VALUE bdb_errmsg(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vecode;
  TCBDB *bdb;
  const char *msg;
  int ecode;
  rb_scan_args(argc, argv, "01", &vecode);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  ecode = (vecode == Qnil) ? tcbdbecode(bdb) : NUM2INT(vecode);
  msg = tcbdberrmsg(ecode);
  return rb_str_new2(msg);
}


static VALUE bdb_ecode(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return INT2NUM(tcbdbecode(bdb));
}


static VALUE bdb_setcmpfunc(VALUE vself, VALUE vcmp){
  VALUE vbdb;
  TCBDB *bdb;
  TCCMP cmp;
  cmp = (TCCMP)bdb_cmpobj;
  if(TYPE(vcmp) == T_STRING){
    if(!strcmp(RSTRING_PTR(vcmp), "CMPLEXICAL")){
      cmp = tccmplexical;
    } else if(!strcmp(RSTRING_PTR(vcmp), "CMPDECIMAL")){
      cmp = tccmpdecimal;
    } else if(!strcmp(RSTRING_PTR(vcmp), "CMPINT32")){
      cmp = tccmpint32;
    } else if(!strcmp(RSTRING_PTR(vcmp), "CMPINT64")){
      cmp = tccmpint64;
    } else {
      rb_raise(rb_eArgError, "unknown comparison function: %s", RSTRING_PTR(vcmp));
    }
  } else if(!rb_respond_to(vcmp, bdb_cmp_call_mid)){
    rb_raise(rb_eArgError, "call method is not implemented");
  }
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbsetcmpfunc(bdb, cmp, (void *)(intptr_t)vcmp);
}


static VALUE bdb_tune(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vlmemb, vnmemb, vbnum, vapow, vfpow, vopts;
  TCBDB *bdb;
  int lmemb, nmemb, apow, fpow, opts;
  int64_t bnum;
  rb_scan_args(argc, argv, "06", &vlmemb, &vnmemb, &vbnum, &vapow, &vfpow, &vopts);
  lmemb = (vlmemb == Qnil) ? -1 : NUM2INT(vlmemb);
  nmemb = (vnmemb == Qnil) ? -1 : NUM2INT(vnmemb);
  bnum = (vbnum == Qnil) ? -1 : NUM2LL(vbnum);
  apow = (vapow == Qnil) ? -1 : NUM2INT(vapow);
  fpow = (vfpow == Qnil) ? -1 : NUM2INT(vfpow);
  opts = (vopts == Qnil) ? 0 : NUM2INT(vopts);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbtune(bdb, lmemb, nmemb, bnum, apow, fpow, opts) ? Qtrue : Qfalse;
}


static VALUE bdb_setcache(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vlcnum, vncnum;
  TCBDB *bdb;
  int lcnum, ncnum;
  rb_scan_args(argc, argv, "02", &vlcnum, &vncnum);
  lcnum = (vlcnum == Qnil) ? -1 : NUM2INT(vlcnum);
  ncnum = (vncnum == Qnil) ? -1 : NUM2INT(vncnum);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbsetcache(bdb, lcnum, ncnum);
}


static VALUE bdb_setxmsiz(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vxmsiz;
  TCBDB *bdb;
  int64_t xmsiz;
  rb_scan_args(argc, argv, "01", &vxmsiz);
  xmsiz = (vxmsiz == Qnil) ? -1 : NUM2LL(vxmsiz);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbsetxmsiz(bdb, xmsiz) ? Qtrue : Qfalse;
}


static VALUE bdb_open(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vpath, vomode;
  TCBDB *bdb;
  int omode;
  rb_scan_args(argc, argv, "11", &vpath, &vomode);
  Check_Type(vpath, T_STRING);
  omode = (vomode == Qnil) ? BDBOREADER : NUM2INT(vomode);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbopen(bdb, RSTRING_PTR(vpath), omode) ? Qtrue : Qfalse;
}


static VALUE bdb_close(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbclose(bdb) ? Qtrue : Qfalse;
}


static VALUE bdb_put(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbput(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), RSTRING_PTR(vval),
		  RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE bdb_putkeep(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbputkeep(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), RSTRING_PTR(vval),
		      RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE bdb_putcat(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbputcat(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), RSTRING_PTR(vval),
		     RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE bdb_putdup(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbputdup(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), RSTRING_PTR(vval),
		     RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE bdb_putlist(VALUE vself, VALUE vkey, VALUE vvals){
  VALUE vbdb;
  TCBDB *bdb;
  TCLIST *tvals;
  bool err;
  vkey = StringValueEx(vkey);
  Check_Type(vvals, T_ARRAY);
  tvals = varytolist(vvals);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  err = false;
  if(!tcbdbputdup3(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), tvals)) err = true;
  tclistdel(tvals);
  return err ? Qfalse : Qtrue;
}


static VALUE bdb_out(VALUE vself, VALUE vkey){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbout(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)) ? Qtrue : Qfalse;
}


static VALUE bdb_outlist(VALUE vself, VALUE vkey){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbout3(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)) ? Qtrue : Qfalse;
}


static VALUE bdb_get(VALUE vself, VALUE vkey){
  VALUE vbdb;
  TCBDB *bdb;
  const char *vbuf;
  int vsiz;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  if(!(vbuf = tcbdbget3(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), &vsiz))) return Qnil;
  return rb_str_new(vbuf, vsiz);
}


static VALUE bdb_getlist(VALUE vself, VALUE vkey){
  VALUE vbdb, vary;
  TCBDB *bdb;
  TCLIST *vals;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  if(!(vals = tcbdbget4(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)))) return Qnil;
  vary = listtovary(vals);
  tclistdel(vals);
  return vary;
}


static VALUE bdb_vnum(VALUE vself, VALUE vkey){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return INT2NUM(tcbdbvnum(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)));
}


static VALUE bdb_vsiz(VALUE vself, VALUE vkey){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return INT2NUM(tcbdbvsiz(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)));
}


static VALUE bdb_range(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vbkey, vbinc, vekey, veinc, vmax, vary;
  TCBDB *bdb;
  TCLIST *keys;
  const char *bkbuf, *ekbuf;
  int bksiz, eksiz, max;
  bool binc, einc;
  rb_scan_args(argc, argv, "05", &vbkey, &vbinc, &vekey, &veinc, &vmax);
  if(vbkey != Qnil) vbkey = StringValueEx(vbkey);
  if(vekey != Qnil) vekey = StringValueEx(vekey);
  binc = (vbinc != Qnil && vbinc != Qfalse);
  einc = (veinc != Qnil && veinc != Qfalse);
  max = (vmax == Qnil) ? -1 : NUM2INT(vmax);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  if(vbkey != Qnil){
    bkbuf = RSTRING_PTR(vbkey);
    bksiz = RSTRING_LEN(vbkey);
  } else {
    bkbuf = NULL;
    bksiz = -1;
  }
  if(vekey != Qnil){
    ekbuf = RSTRING_PTR(vekey);
    eksiz = RSTRING_LEN(vekey);
  } else {
    ekbuf = NULL;
    eksiz = -1;
  }
  keys = tcbdbrange(bdb, bkbuf, bksiz, binc, ekbuf, eksiz, einc, max);
  vary = listtovary(keys);
  tclistdel(keys);
  return vary;
}


static VALUE bdb_fwmkeys(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vprefix, vmax, vary;
  TCBDB *bdb;
  TCLIST *keys;
  int max;
  rb_scan_args(argc, argv, "11", &vprefix, &vmax);
  vprefix = StringValueEx(vprefix);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  max = (vmax == Qnil) ? -1 : NUM2INT(vmax);
  keys = tcbdbfwmkeys(bdb, RSTRING_PTR(vprefix), RSTRING_LEN(vprefix), max);
  vary = listtovary(keys);
  tclistdel(keys);
  return vary;
}


static VALUE bdb_addint(VALUE vself, VALUE vkey, VALUE vnum){
  VALUE vbdb;
  TCBDB *bdb;
  int num;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  num = tcbdbaddint(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), NUM2INT(vnum));
  return num == INT_MIN ? Qnil : INT2NUM(num);
}


static VALUE bdb_adddouble(VALUE vself, VALUE vkey, VALUE vnum){
  VALUE vbdb;
  TCBDB *bdb;
  double num;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  num = tcbdbadddouble(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), NUM2DBL(vnum));
  return isnan(num) ? Qnil : rb_float_new(num);
}


static VALUE bdb_sync(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbsync(bdb) ? Qtrue : Qfalse;
}


static VALUE bdb_optimize(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vlmemb, vnmemb, vbnum, vapow, vfpow, vopts;
  TCBDB *bdb;
  int lmemb, nmemb, apow, fpow, opts;
  int64_t bnum;
  rb_scan_args(argc, argv, "06", &vlmemb, &vnmemb, &vbnum, &vapow, &vfpow, &vopts);
  lmemb = (vlmemb == Qnil) ? -1 : NUM2INT(vlmemb);
  nmemb = (vnmemb == Qnil) ? -1 : NUM2INT(vnmemb);
  bnum = (vbnum == Qnil) ? -1 : NUM2LL(vbnum);
  apow = (vapow == Qnil) ? -1 : NUM2INT(vapow);
  fpow = (vfpow == Qnil) ? -1 : NUM2INT(vfpow);
  opts = (vopts == Qnil) ? UINT8_MAX : NUM2INT(vopts);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdboptimize(bdb, lmemb, nmemb, bnum, apow, fpow, opts) ? Qtrue : Qfalse;
}


static VALUE bdb_vanish(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbvanish(bdb) ? Qtrue : Qfalse;
}


static VALUE bdb_copy(VALUE vself, VALUE vpath){
  VALUE vbdb;
  TCBDB *bdb;
  Check_Type(vpath, T_STRING);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbcopy(bdb, RSTRING_PTR(vpath)) ? Qtrue : Qfalse;
}


static VALUE bdb_tranbegin(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbtranbegin(bdb) ? Qtrue : Qfalse;
}


static VALUE bdb_trancommit(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbtrancommit(bdb) ? Qtrue : Qfalse;
}


static VALUE bdb_tranabort(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbtranabort(bdb) ? Qtrue : Qfalse;
}


static VALUE bdb_path(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  const char *path;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  if(!(path = tcbdbpath(bdb))) return Qnil;
  return rb_str_new2(path);
}


static VALUE bdb_rnum(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return LL2NUM(tcbdbrnum(bdb));
}


static VALUE bdb_fsiz(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return LL2NUM(tcbdbfsiz(bdb));
}


static VALUE bdb_fetch(int argc, VALUE *argv, VALUE vself){
  VALUE vbdb, vkey, vdef, vval;
  TCBDB *bdb;
  char *vbuf;
  int vsiz;
  rb_scan_args(argc, argv, "11", &vkey, &vdef);
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  if((vbuf = tcbdbget(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), &vsiz)) != NULL){
    vval = rb_str_new(vbuf, vsiz);
    tcfree(vbuf);
  } else {
    vval = vdef;
  }
  return vval;
}


static VALUE bdb_check(VALUE vself, VALUE vkey){
  VALUE vbdb;
  TCBDB *bdb;
  vkey = StringValueEx(vkey);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbvsiz(bdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)) >= 0 ? Qtrue : Qfalse;
}


static VALUE bdb_check_value(VALUE vself, VALUE vval){
  VALUE vbdb;
  TCBDB *bdb;
  BDBCUR *cur;
  const char *tvbuf;
  int tvsiz, hit;
  vval = StringValueEx(vval);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  hit = 0;
  cur = tcbdbcurnew(bdb);
  tcbdbcurfirst(cur);
  while((tvbuf = tcbdbcurval3(cur, &tvsiz)) != NULL){
    if(tvsiz == RSTRING_LEN(vval) && memcmp(tvbuf, RSTRING_PTR(vval), RSTRING_LEN(vval)) == 0){
      hit = 1;
      break;
    }
    tcbdbcurnext(cur);
  }
  tcbdbcurdel(cur);
  return hit ? Qtrue : Qfalse;
}


static VALUE bdb_get_reverse(VALUE vself, VALUE vval){
  VALUE vbdb, vrv;
  TCBDB *bdb;
  BDBCUR *cur;
  const char *tvbuf, *tkbuf;
  int tvsiz, tksiz;
  vval = StringValueEx(vval);
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  vrv = Qnil;
  cur = tcbdbcurnew(bdb);
  tcbdbcurfirst(cur);
  while((tvbuf = tcbdbcurval3(cur, &tvsiz)) != NULL){
    if(tvsiz == RSTRING_LEN(vval) && memcmp(tvbuf, RSTRING_PTR(vval), RSTRING_LEN(vval)) == 0){
      if((tkbuf = tcbdbcurkey3(cur, &tksiz)) != NULL)
        vrv = rb_str_new(tkbuf, tksiz);
      break;
    }
    tcbdbcurnext(cur);
  }
  tcbdbcurdel(cur);
  return vrv;
}


static VALUE bdb_empty(VALUE vself){
  VALUE vbdb;
  TCBDB *bdb;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  return tcbdbrnum(bdb) < 1 ? Qtrue : Qfalse;
}


static VALUE bdb_each(VALUE vself){
  VALUE vbdb, vrv;
  TCBDB *bdb;
  BDBCUR *cur;
  TCXSTR *kxstr, *vxstr;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  vrv = Qnil;
  kxstr = tcxstrnew();
  vxstr = tcxstrnew();
  cur = tcbdbcurnew(bdb);
  tcbdbcurfirst(cur);
  while(tcbdbcurrec(cur, kxstr, vxstr)){
    vrv = rb_yield_values(2, rb_str_new(tcxstrptr(kxstr), tcxstrsize(kxstr)),
                          rb_str_new(tcxstrptr(vxstr), tcxstrsize(vxstr)));
    tcbdbcurnext(cur);
  }
  tcbdbcurdel(cur);
  tcxstrdel(vxstr);
  tcxstrdel(kxstr);
  return vrv;
}


static VALUE bdb_each_key(VALUE vself){
  VALUE vbdb, vrv;
  TCBDB *bdb;
  BDBCUR *cur;
  const char *kbuf;
  int ksiz;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  vrv = Qnil;
  cur = tcbdbcurnew(bdb);
  tcbdbcurfirst(cur);
  while((kbuf = tcbdbcurkey3(cur, &ksiz)) != NULL){
    vrv = rb_yield(rb_str_new(kbuf, ksiz));
    tcbdbcurnext(cur);
  }
  tcbdbcurdel(cur);
  return vrv;
}


static VALUE bdb_each_value(VALUE vself){
  VALUE vbdb, vrv;
  TCBDB *bdb;
  BDBCUR *cur;
  const char *vbuf;
  int vsiz;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  vrv = Qnil;
  cur = tcbdbcurnew(bdb);
  tcbdbcurfirst(cur);
  while((vbuf = tcbdbcurval3(cur, &vsiz)) != NULL){
    vrv = rb_yield(rb_str_new(vbuf, vsiz));
    tcbdbcurnext(cur);
  }
  tcbdbcurdel(cur);
  return vrv;
}


static VALUE bdb_keys(VALUE vself){
  VALUE vbdb, vary;
  TCBDB *bdb;
  BDBCUR *cur;
  const char *kbuf;
  int ksiz;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  vary = rb_ary_new2(tcbdbrnum(bdb));
  cur = tcbdbcurnew(bdb);
  tcbdbcurfirst(cur);
  while((kbuf = tcbdbcurkey3(cur, &ksiz)) != NULL){
    rb_ary_push(vary, rb_str_new(kbuf, ksiz));
    tcbdbcurnext(cur);
  }
  tcbdbcurdel(cur);
  return vary;
}


static VALUE bdb_values(VALUE vself){
  VALUE vbdb, vary;
  TCBDB *bdb;
  BDBCUR *cur;
  const char *vbuf;
  int vsiz;
  vbdb = rb_iv_get(vself, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  vary = rb_ary_new2(tcbdbrnum(bdb));
  cur = tcbdbcurnew(bdb);
  tcbdbcurfirst(cur);
  while((vbuf = tcbdbcurval3(cur, &vsiz)) != NULL){
    rb_ary_push(vary, rb_str_new(vbuf, vsiz));
    tcbdbcurnext(cur);
  }
  tcbdbcurdel(cur);
  return vary;
}


static void bdbcur_init(void){
  cls_bdbcur = rb_define_class_under(mod_tokyocabinet, "BDBCUR", rb_cObject);
  cls_bdbcur_data = rb_define_class_under(mod_tokyocabinet, "BDBCUR_data", rb_cObject);
  rb_define_const(cls_bdbcur, "CPCURRENT", INT2NUM(BDBCPCURRENT));
  rb_define_const(cls_bdbcur, "CPBEFORE", INT2NUM(BDBCPBEFORE));
  rb_define_const(cls_bdbcur, "CPAFTER", INT2NUM(BDBCPAFTER));
  rb_define_private_method(cls_bdbcur, "initialize", bdbcur_initialize, 1);
  rb_define_method(cls_bdbcur, "first", bdbcur_first, 0);
  rb_define_method(cls_bdbcur, "last", bdbcur_last, 0);
  rb_define_method(cls_bdbcur, "jump", bdbcur_jump, 1);
  rb_define_method(cls_bdbcur, "prev", bdbcur_prev, 0);
  rb_define_method(cls_bdbcur, "next", bdbcur_next, 0);
  rb_define_method(cls_bdbcur, "put", bdbcur_put, -1);
  rb_define_method(cls_bdbcur, "out", bdbcur_out, 0);
  rb_define_method(cls_bdbcur, "key", bdbcur_key, 0);
  rb_define_method(cls_bdbcur, "val", bdbcur_val, 0);
}


static VALUE bdbcur_initialize(VALUE vself, VALUE vbdb){
  VALUE vcur;
  TCBDB *bdb;
  BDBCUR *cur;
  Check_Type(vbdb, T_OBJECT);
  vbdb = rb_iv_get(vbdb, BDBVNDATA);
  Data_Get_Struct(vbdb, TCBDB, bdb);
  cur = tcbdbcurnew(bdb);
  vcur = Data_Wrap_Struct(cls_bdbcur_data, 0, tcbdbcurdel, cur);
  rb_iv_set(vself, BDBCURVNDATA, vcur);
  rb_iv_set(vself, BDBVNDATA, vbdb);
  return Qnil;
}


static VALUE bdbcur_first(VALUE vself){
  VALUE vcur;
  BDBCUR *cur;
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  return tcbdbcurfirst(cur) ? Qtrue : Qfalse;
}


static VALUE bdbcur_last(VALUE vself){
  VALUE vcur;
  BDBCUR *cur;
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  return tcbdbcurlast(cur) ? Qtrue : Qfalse;
}


static VALUE bdbcur_jump(VALUE vself, VALUE vkey){
  VALUE vcur;
  BDBCUR *cur;
  vkey = StringValueEx(vkey);
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  return tcbdbcurjump(cur, RSTRING_PTR(vkey), RSTRING_LEN(vkey)) ? Qtrue : Qfalse;
}


static VALUE bdbcur_prev(VALUE vself){
  VALUE vcur;
  BDBCUR *cur;
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  return tcbdbcurprev(cur) ? Qtrue : Qfalse;
}


static VALUE bdbcur_next(VALUE vself){
  VALUE vcur;
  BDBCUR *cur;
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  return tcbdbcurnext(cur) ? Qtrue : Qfalse;
}


static VALUE bdbcur_put(int argc, VALUE *argv, VALUE vself){
  VALUE vcur, vval, vcpmode;
  BDBCUR *cur;
  int cpmode;
  rb_scan_args(argc, argv, "11", &vval, &vcpmode);
  vval = StringValueEx(vval);
  cpmode = (vcpmode == Qnil) ? BDBCPCURRENT : NUM2INT(vcpmode);
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  return tcbdbcurput(cur, RSTRING_PTR(vval), RSTRING_LEN(vval), cpmode) ? Qtrue : Qfalse;
}


static VALUE bdbcur_out(VALUE vself){
  VALUE vcur;
  BDBCUR *cur;
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  return tcbdbcurout(cur) ? Qtrue : Qfalse;
}


static VALUE bdbcur_key(VALUE vself){
  VALUE vcur, vkey;
  BDBCUR *cur;
  char *kbuf;
  int ksiz;
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  if(!(kbuf = tcbdbcurkey(cur, &ksiz))) return Qnil;
  vkey = rb_str_new(kbuf, ksiz);
  tcfree(kbuf);
  return vkey;
}


static VALUE bdbcur_val(VALUE vself){
  VALUE vcur, vval;
  BDBCUR *cur;
  char *vbuf;
  int vsiz;
  vcur = rb_iv_get(vself, BDBCURVNDATA);
  Data_Get_Struct(vcur, BDBCUR, cur);
  if(!(vbuf = tcbdbcurval(cur, &vsiz))) return Qnil;
  vval = rb_str_new(vbuf, vsiz);
  tcfree(vbuf);
  return vval;
}


static void fdb_init(void){
  cls_fdb = rb_define_class_under(mod_tokyocabinet, "FDB", rb_cObject);
  cls_fdb_data = rb_define_class_under(mod_tokyocabinet, "FDB_data", rb_cObject);
  rb_define_const(cls_fdb, "ESUCCESS", INT2NUM(TCESUCCESS));
  rb_define_const(cls_fdb, "ETHREAD", INT2NUM(TCETHREAD));
  rb_define_const(cls_fdb, "EINVALID", INT2NUM(TCEINVALID));
  rb_define_const(cls_fdb, "ENOFILE", INT2NUM(TCENOFILE));
  rb_define_const(cls_fdb, "ENOPERM", INT2NUM(TCENOPERM));
  rb_define_const(cls_fdb, "EMETA", INT2NUM(TCEMETA));
  rb_define_const(cls_fdb, "ERHEAD", INT2NUM(TCERHEAD));
  rb_define_const(cls_fdb, "EOPEN", INT2NUM(TCEOPEN));
  rb_define_const(cls_fdb, "ECLOSE", INT2NUM(TCECLOSE));
  rb_define_const(cls_fdb, "ETRUNC", INT2NUM(TCETRUNC));
  rb_define_const(cls_fdb, "ESYNC", INT2NUM(TCESYNC));
  rb_define_const(cls_fdb, "ESTAT", INT2NUM(TCESTAT));
  rb_define_const(cls_fdb, "ESEEK", INT2NUM(TCESEEK));
  rb_define_const(cls_fdb, "EREAD", INT2NUM(TCEREAD));
  rb_define_const(cls_fdb, "EWRITE", INT2NUM(TCEWRITE));
  rb_define_const(cls_fdb, "EMMAP", INT2NUM(TCEMMAP));
  rb_define_const(cls_fdb, "ELOCK", INT2NUM(TCELOCK));
  rb_define_const(cls_fdb, "EUNLINK", INT2NUM(TCEUNLINK));
  rb_define_const(cls_fdb, "ERENAME", INT2NUM(TCERENAME));
  rb_define_const(cls_fdb, "EMKDIR", INT2NUM(TCEMKDIR));
  rb_define_const(cls_fdb, "ERMDIR", INT2NUM(TCERMDIR));
  rb_define_const(cls_fdb, "EKEEP", INT2NUM(TCEKEEP));
  rb_define_const(cls_fdb, "ENOREC", INT2NUM(TCENOREC));
  rb_define_const(cls_fdb, "EMISC", INT2NUM(TCEMISC));
  rb_define_const(cls_fdb, "OREADER", INT2NUM(FDBOREADER));
  rb_define_const(cls_fdb, "OWRITER", INT2NUM(FDBOWRITER));
  rb_define_const(cls_fdb, "OCREAT", INT2NUM(FDBOCREAT));
  rb_define_const(cls_fdb, "OTRUNC", INT2NUM(FDBOTRUNC));
  rb_define_const(cls_fdb, "ONOLCK", INT2NUM(FDBONOLCK));
  rb_define_const(cls_fdb, "OLCKNB", INT2NUM(FDBOLCKNB));
  rb_define_private_method(cls_fdb, "initialize", fdb_initialize, 0);
  rb_define_method(cls_fdb, "errmsg", fdb_errmsg, -1);
  rb_define_method(cls_fdb, "ecode", fdb_ecode, 0);
  rb_define_method(cls_fdb, "tune", fdb_tune, -1);
  rb_define_method(cls_fdb, "open", fdb_open, -1);
  rb_define_method(cls_fdb, "close", fdb_close, 0);
  rb_define_method(cls_fdb, "put", fdb_put, 2);
  rb_define_method(cls_fdb, "putkeep", fdb_putkeep, 2);
  rb_define_method(cls_fdb, "putcat", fdb_putcat, 2);
  rb_define_method(cls_fdb, "out", fdb_out, 1);
  rb_define_method(cls_fdb, "get", fdb_get, 1);
  rb_define_method(cls_fdb, "vsiz", fdb_vsiz, 1);
  rb_define_method(cls_fdb, "iterinit", fdb_iterinit, 0);
  rb_define_method(cls_fdb, "iternext", fdb_iternext, 0);
  rb_define_method(cls_fdb, "range", fdb_range, -1);
  rb_define_method(cls_fdb, "addint", fdb_addint, 2);
  rb_define_method(cls_fdb, "adddouble", fdb_adddouble, 2);
  rb_define_method(cls_fdb, "sync", fdb_sync, 0);
  rb_define_method(cls_fdb, "optimize", fdb_optimize, -1);
  rb_define_method(cls_fdb, "vanish", fdb_vanish, 0);
  rb_define_method(cls_fdb, "copy", fdb_copy, 1);
  rb_define_method(cls_fdb, "path", fdb_path, 0);
  rb_define_method(cls_fdb, "rnum", fdb_rnum, 0);
  rb_define_method(cls_fdb, "fsiz", fdb_fsiz, 0);
  rb_define_method(cls_fdb, "[]", fdb_get, 1);
  rb_define_method(cls_fdb, "[]=", fdb_put, 2);
  rb_define_method(cls_fdb, "store", fdb_put, 2);
  rb_define_method(cls_fdb, "delete", fdb_out, 1);
  rb_define_method(cls_fdb, "fetch", fdb_fetch, -1);
  rb_define_method(cls_fdb, "has_key?", fdb_check, 1);
  rb_define_method(cls_fdb, "key?", fdb_check, 1);
  rb_define_method(cls_fdb, "include?", fdb_check, 1);
  rb_define_method(cls_fdb, "member?", fdb_check, 1);
  rb_define_method(cls_fdb, "has_value?", fdb_check_value, 1);
  rb_define_method(cls_fdb, "value?", fdb_check_value, 1);
  rb_define_method(cls_fdb, "key", fdb_get_reverse, 1);
  rb_define_method(cls_fdb, "clear", fdb_vanish, 0);
  rb_define_method(cls_fdb, "size", fdb_rnum, 0);
  rb_define_method(cls_fdb, "length", fdb_rnum, 0);
  rb_define_method(cls_fdb, "empty?", fdb_empty, 0);
  rb_define_method(cls_fdb, "each", fdb_each, 0);
  rb_define_method(cls_fdb, "each_pair", fdb_each, 0);
  rb_define_method(cls_fdb, "each_key", fdb_each_key, 0);
  rb_define_method(cls_fdb, "each_value", fdb_each_value, 0);
  rb_define_method(cls_fdb, "keys", fdb_keys, 0);
  rb_define_method(cls_fdb, "values", fdb_values, 0);
}


static VALUE fdb_initialize(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  fdb = tcfdbnew();
  tcfdbsetmutex(fdb);
  vfdb = Data_Wrap_Struct(cls_fdb_data, 0, tcfdbdel, fdb);
  rb_iv_set(vself, FDBVNDATA, vfdb);
  return Qnil;
}


static VALUE fdb_errmsg(int argc, VALUE *argv, VALUE vself){
  VALUE vfdb, vecode;
  TCFDB *fdb;
  const char *msg;
  int ecode;
  rb_scan_args(argc, argv, "01", &vecode);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  ecode = (vecode == Qnil) ? tcfdbecode(fdb) : NUM2INT(vecode);
  msg = tcfdberrmsg(ecode);
  return rb_str_new2(msg);
}


static VALUE fdb_ecode(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return INT2NUM(tcfdbecode(fdb));
}


static VALUE fdb_tune(int argc, VALUE *argv, VALUE vself){
  VALUE vfdb, vwidth, vlimsiz;
  TCFDB *fdb;
  int width;
  int64_t limsiz;
  rb_scan_args(argc, argv, "02", &vwidth, &vlimsiz);
  width = (vwidth == Qnil) ? -1 : NUM2INT(vwidth);
  limsiz = (vlimsiz == Qnil) ? -1 : NUM2LL(vlimsiz);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbtune(fdb, width, limsiz) ? Qtrue : Qfalse;
}


static VALUE fdb_open(int argc, VALUE *argv, VALUE vself){
  VALUE vfdb, vpath, vomode;
  TCFDB *fdb;
  int omode;
  rb_scan_args(argc, argv, "11", &vpath, &vomode);
  Check_Type(vpath, T_STRING);
  omode = (vomode == Qnil) ? FDBOREADER : NUM2INT(vomode);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbopen(fdb, RSTRING_PTR(vpath), omode) ? Qtrue : Qfalse;
}


static VALUE fdb_close(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbclose(fdb) ? Qtrue : Qfalse;
}


static VALUE fdb_put(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vfdb;
  TCFDB *fdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbput2(fdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey),
		   RSTRING_PTR(vval), RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE fdb_putkeep(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vfdb;
  TCFDB *fdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbputkeep2(fdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey),
		       RSTRING_PTR(vval), RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE fdb_putcat(VALUE vself, VALUE vkey, VALUE vval){
  VALUE vfdb;
  TCFDB *fdb;
  vkey = StringValueEx(vkey);
  vval = StringValueEx(vval);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbputcat2(fdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey),
		      RSTRING_PTR(vval), RSTRING_LEN(vval)) ? Qtrue : Qfalse;
}


static VALUE fdb_out(VALUE vself, VALUE vkey){
  VALUE vfdb;
  TCFDB *fdb;
  vkey = StringValueEx(vkey);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbout2(fdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)) ? Qtrue : Qfalse;
}


static VALUE fdb_get(VALUE vself, VALUE vkey){
  VALUE vfdb, vval;
  TCFDB *fdb;
  char *vbuf;
  int vsiz;
  vkey = StringValueEx(vkey);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  if(!(vbuf = tcfdbget2(fdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), &vsiz))) return Qnil;
  vval = rb_str_new(vbuf, vsiz);
  tcfree(vbuf);
  return vval;
}


static VALUE fdb_vsiz(VALUE vself, VALUE vkey){
  VALUE vfdb;
  TCFDB *fdb;
  vkey = StringValueEx(vkey);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return INT2NUM(tcfdbvsiz2(fdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)));
}


static VALUE fdb_iterinit(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbiterinit(fdb) ? Qtrue : Qfalse;
}


static VALUE fdb_iternext(VALUE vself){
  VALUE vfdb, vval;
  TCFDB *fdb;
  char *vbuf;
  int vsiz;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  if(!(vbuf = tcfdbiternext2(fdb, &vsiz))) return Qnil;
  vval = rb_str_new(vbuf, vsiz);
  tcfree(vbuf);
  return vval;
}


static VALUE fdb_range(int argc, VALUE *argv, VALUE vself){
  VALUE vfdb, vinterval, vmax, vary;
  TCFDB *fdb;
  TCLIST *keys;
  int max;
  rb_scan_args(argc, argv, "11", &vinterval, &vmax);
  vinterval = StringValueEx(vinterval);
  max = (vmax == Qnil) ? -1 : NUM2INT(vmax);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  keys = tcfdbrange4(fdb, RSTRING_PTR(vinterval), RSTRING_LEN(vinterval), max);
  vary = listtovary(keys);
  tclistdel(keys);
  return vary;
}


static VALUE fdb_addint(VALUE vself, VALUE vkey, VALUE vnum){
  VALUE vfdb;
  TCFDB *fdb;
  int num;
  vkey = StringValueEx(vkey);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  num = tcfdbaddint(fdb, tcfdbkeytoid(RSTRING_PTR(vkey), RSTRING_LEN(vkey)), NUM2INT(vnum));
  return num == INT_MIN ? Qnil : INT2NUM(num);
}


static VALUE fdb_adddouble(VALUE vself, VALUE vkey, VALUE vnum){
  VALUE vfdb;
  TCFDB *fdb;
  double num;
  vkey = StringValueEx(vkey);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  num = tcfdbadddouble(fdb, tcfdbkeytoid(RSTRING_PTR(vkey), RSTRING_LEN(vkey)), NUM2DBL(vnum));
  return isnan(num) ? Qnil : rb_float_new(num);
}


static VALUE fdb_sync(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbsync(fdb) ? Qtrue : Qfalse;
}


static VALUE fdb_optimize(int argc, VALUE *argv, VALUE vself){
  VALUE vfdb, vwidth, vlimsiz;
  TCFDB *fdb;
  int width;
  int64_t limsiz;
  rb_scan_args(argc, argv, "02", &vwidth, &vlimsiz);
  width = (vwidth == Qnil) ? -1 : NUM2INT(vwidth);
  limsiz = (vlimsiz == Qnil) ? -1 : NUM2LL(vlimsiz);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdboptimize(fdb, width, limsiz) ? Qtrue : Qfalse;
}


static VALUE fdb_vanish(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbvanish(fdb) ? Qtrue : Qfalse;
}


static VALUE fdb_copy(VALUE vself, VALUE vpath){
  VALUE vfdb;
  TCFDB *fdb;
  Check_Type(vpath, T_STRING);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbcopy(fdb, RSTRING_PTR(vpath)) ? Qtrue : Qfalse;
}


static VALUE fdb_path(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  const char *path;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  if(!(path = tcfdbpath(fdb))) return Qnil;
  return rb_str_new2(path);
}


static VALUE fdb_rnum(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return LL2NUM(tcfdbrnum(fdb));
}


static VALUE fdb_fsiz(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return LL2NUM(tcfdbfsiz(fdb));
}


static VALUE fdb_fetch(int argc, VALUE *argv, VALUE vself){
  VALUE vfdb, vkey, vdef, vval;
  TCFDB *fdb;
  char *vbuf;
  int vsiz;
  rb_scan_args(argc, argv, "11", &vkey, &vdef);
  vkey = StringValueEx(vkey);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  if((vbuf = tcfdbget2(fdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey), &vsiz)) != NULL){
    vval = rb_str_new(vbuf, vsiz);
    tcfree(vbuf);
  } else {
    vval = vdef;
  }
  return vval;
}


static VALUE fdb_check(VALUE vself, VALUE vkey){
  VALUE vfdb;
  TCFDB *fdb;
  vkey = StringValueEx(vkey);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbvsiz2(fdb, RSTRING_PTR(vkey), RSTRING_LEN(vkey)) >= 0 ? Qtrue : Qfalse;
}


static VALUE fdb_check_value(VALUE vself, VALUE vval){
  VALUE vfdb;
  TCFDB *fdb;
  char *tvbuf;
  int tvsiz, hit;
  uint64_t id;
  vval = StringValueEx(vval);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  hit = 0;
  tcfdbiterinit(fdb);
  while((id = tcfdbiternext(fdb)) > 0){
    tvbuf = tcfdbget(fdb, id, &tvsiz);
    if(tvbuf && tvsiz == RSTRING_LEN(vval) &&
       memcmp(tvbuf, RSTRING_PTR(vval), RSTRING_LEN(vval)) == 0){
      tcfree(tvbuf);
      hit = 1;
      break;
    }
    tcfree(tvbuf);
  }
  return hit ? Qtrue : Qfalse;
}


static VALUE fdb_get_reverse(VALUE vself, VALUE vval){
  VALUE vfdb, vrv;
  TCFDB *fdb;
  char *tvbuf, kbuf[NUMBUFSIZ];
  int tvsiz, ksiz;
  uint64_t id;
  vval = StringValueEx(vval);
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  vrv = Qnil;
  tcfdbiterinit(fdb);
  while((id = tcfdbiternext(fdb)) > 0){
    tvbuf = tcfdbget(fdb, id, &tvsiz);
    if(tvbuf && tvsiz == RSTRING_LEN(vval) &&
       memcmp(tvbuf, RSTRING_PTR(vval), RSTRING_LEN(vval)) == 0){
      tcfree(tvbuf);
      ksiz = sprintf(kbuf, "%llu", (unsigned long long)id);
      vrv = rb_str_new(kbuf, ksiz);
      break;
    }
    tcfree(tvbuf);
  }
  return vrv;
}


static VALUE fdb_empty(VALUE vself){
  VALUE vfdb;
  TCFDB *fdb;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  return tcfdbrnum(fdb) < 1 ? Qtrue : Qfalse;
}


static VALUE fdb_each(VALUE vself){
  VALUE vfdb, vrv;
  TCFDB *fdb;
  char *vbuf, kbuf[NUMBUFSIZ];
  int vsiz, ksiz;
  uint64_t id;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  vrv = Qnil;
  tcfdbiterinit(fdb);
  while((id = tcfdbiternext(fdb)) > 0){
    vbuf = tcfdbget(fdb, id, &vsiz);
    if(vbuf){
      ksiz = sprintf(kbuf, "%llu", (unsigned long long)id);
      vrv = rb_yield_values(2, rb_str_new(kbuf, ksiz), rb_str_new(vbuf, vsiz));
    }
    tcfree(vbuf);
  }
  return vrv;
}


static VALUE fdb_each_key(VALUE vself){
  VALUE vfdb, vrv;
  TCFDB *fdb;
  char kbuf[NUMBUFSIZ];
  int ksiz;
  uint64_t id;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  vrv = Qnil;
  tcfdbiterinit(fdb);
  while((id = tcfdbiternext(fdb)) > 0){
    ksiz = sprintf(kbuf, "%llu", (unsigned long long)id);
    vrv = rb_yield(rb_str_new(kbuf, ksiz));
  }
  return vrv;
}


static VALUE fdb_each_value(VALUE vself){
  VALUE vfdb, vrv;
  TCFDB *fdb;
  char *vbuf;
  int vsiz;
  uint64_t id;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  vrv = Qnil;
  tcfdbiterinit(fdb);
  while((id = tcfdbiternext(fdb)) > 0){
    vbuf = tcfdbget(fdb, id, &vsiz);
    if(vbuf){
      vrv = rb_yield(rb_str_new(vbuf, vsiz));
    }
    free(vbuf);
  }
  return vrv;
}


static VALUE fdb_keys(VALUE vself){
  VALUE vfdb, vary;
  TCFDB *fdb;
  char kbuf[NUMBUFSIZ];
  int ksiz;
  uint64_t id;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  vary = rb_ary_new2(tcfdbrnum(fdb));
  tcfdbiterinit(fdb);
  while((id = tcfdbiternext(fdb)) > 0){
    ksiz = sprintf(kbuf, "%llu", (unsigned long long)id);
    rb_ary_push(vary, rb_str_new(kbuf, ksiz));
  }
  return vary;
}


static VALUE fdb_values(VALUE vself){
  VALUE vfdb, vary;
  TCFDB *fdb;
  char *vbuf;
  int vsiz;
  uint64_t id;
  vfdb = rb_iv_get(vself, FDBVNDATA);
  Data_Get_Struct(vfdb, TCFDB, fdb);
  vary = rb_ary_new2(tcfdbrnum(fdb));
  tcfdbiterinit(fdb);
  while((id = tcfdbiternext(fdb)) > 0){
    vbuf = tcfdbget(fdb, id, &vsiz);
    if(vbuf){
      rb_ary_push(vary, rb_str_new(vbuf, vsiz));
    }
    free(vbuf);
  }
  return vary;
}


static void tdb_init(void){
  cls_tdb = rb_define_class_under(mod_tokyocabinet, "TDB", rb_cObject);
  cls_tdb_data = rb_define_class_under(mod_tokyocabinet, "TDB_data", rb_cObject);
  rb_define_const(cls_tdb, "ESUCCESS", INT2NUM(TCESUCCESS));
  rb_define_const(cls_tdb, "ETHREAD", INT2NUM(TCETHREAD));
  rb_define_const(cls_tdb, "EINVALID", INT2NUM(TCEINVALID));
  rb_define_const(cls_tdb, "ENOFILE", INT2NUM(TCENOFILE));
  rb_define_const(cls_tdb, "ENOPERM", INT2NUM(TCENOPERM));
  rb_define_const(cls_tdb, "EMETA", INT2NUM(TCEMETA));
  rb_define_const(cls_tdb, "ERHEAD", INT2NUM(TCERHEAD));
  rb_define_const(cls_tdb, "EOPEN", INT2NUM(TCEOPEN));
  rb_define_const(cls_tdb, "ECLOSE", INT2NUM(TCECLOSE));
  rb_define_const(cls_tdb, "ETRUNC", INT2NUM(TCETRUNC));
  rb_define_const(cls_tdb, "ESYNC", INT2NUM(TCESYNC));
  rb_define_const(cls_tdb, "ESTAT", INT2NUM(TCESTAT));
  rb_define_const(cls_tdb, "ESEEK", INT2NUM(TCESEEK));
  rb_define_const(cls_tdb, "EREAD", INT2NUM(TCEREAD));
  rb_define_const(cls_tdb, "EWRITE", INT2NUM(TCEWRITE));
  rb_define_const(cls_tdb, "EMMAP", INT2NUM(TCEMMAP));
  rb_define_const(cls_tdb, "ELOCK", INT2NUM(TCELOCK));
  rb_define_const(cls_tdb, "EUNLINK", INT2NUM(TCEUNLINK));
  rb_define_const(cls_tdb, "ERENAME", INT2NUM(TCERENAME));
  rb_define_const(cls_tdb, "EMKDIR", INT2NUM(TCEMKDIR));
  rb_define_const(cls_tdb, "ERMDIR", INT2NUM(TCERMDIR));
  rb_define_const(cls_tdb, "EKEEP", INT2NUM(TCEKEEP));
  rb_define_const(cls_tdb, "ENOREC", INT2NUM(TCENOREC));
  rb_define_const(cls_tdb, "EMISC", INT2NUM(TCEMISC));
  rb_define_const(cls_tdb, "TLARGE", INT2NUM(TDBTLARGE));
  rb_define_const(cls_tdb, "TDEFLATE", INT2NUM(TDBTDEFLATE));
  rb_define_const(cls_tdb, "TBZIP", INT2NUM(TDBTBZIP));
  rb_define_const(cls_tdb, "TTCBS", INT2NUM(TDBTTCBS));
  rb_define_const(cls_tdb, "OREADER", INT2NUM(TDBOREADER));
  rb_define_const(cls_tdb, "OWRITER", INT2NUM(TDBOWRITER));
  rb_define_const(cls_tdb, "OCREAT", INT2NUM(TDBOCREAT));
  rb_define_const(cls_tdb, "OTRUNC", INT2NUM(TDBOTRUNC));
  rb_define_const(cls_tdb, "ONOLCK", INT2NUM(TDBONOLCK));
  rb_define_const(cls_tdb, "OLCKNB", INT2NUM(TDBOLCKNB));
  rb_define_const(cls_tdb, "OTSYNC", INT2NUM(TDBOTSYNC));
  rb_define_const(cls_tdb, "ITLEXICAL", INT2NUM(TDBITLEXICAL));
  rb_define_const(cls_tdb, "ITDECIMAL", INT2NUM(TDBITDECIMAL));
  rb_define_const(cls_tdb, "ITVOID", INT2NUM(TDBITVOID));
  rb_define_const(cls_tdb, "ITKEEP", INT2NUM(TDBITKEEP));
  rb_define_private_method(cls_tdb, "initialize", tdb_initialize, 0);
  rb_define_method(cls_tdb, "errmsg", tdb_errmsg, -1);
  rb_define_method(cls_tdb, "ecode", tdb_ecode, 0);
  rb_define_method(cls_tdb, "tune", tdb_tune, -1);
  rb_define_method(cls_tdb, "setcache", tdb_setcache, -1);
  rb_define_method(cls_tdb, "setxmsiz", tdb_setxmsiz, -1);
  rb_define_method(cls_tdb, "open", tdb_open, -1);
  rb_define_method(cls_tdb, "close", tdb_close, 0);
  rb_define_method(cls_tdb, "put", tdb_put, 2);
  rb_define_method(cls_tdb, "putkeep", tdb_putkeep, 2);
  rb_define_method(cls_tdb, "putcat", tdb_putcat, 2);
  rb_define_method(cls_tdb, "out", tdb_out, 1);
  rb_define_method(cls_tdb, "get", tdb_get, 1);
  rb_define_method(cls_tdb, "vsiz", tdb_vsiz, 1);
  rb_define_method(cls_tdb, "iterinit", tdb_iterinit, 0);
  rb_define_method(cls_tdb, "iternext", tdb_iternext, 0);
  rb_define_method(cls_tdb, "fwmkeys", tdb_fwmkeys, -1);
  rb_define_method(cls_tdb, "addint", tdb_addint, 2);
  rb_define_method(cls_tdb, "adddouble", tdb_adddouble, 2);
  rb_define_method(cls_tdb, "sync", tdb_sync, 0);
  rb_define_method(cls_tdb, "optimize", tdb_optimize, -1);
  rb_define_method(cls_tdb, "vanish", tdb_vanish, 0);
  rb_define_method(cls_tdb, "copy", tdb_copy, 1);
  rb_define_method(cls_tdb, "tranbegin", tdb_tranbegin, 0);
  rb_define_method(cls_tdb, "trancommit", tdb_trancommit, 0);
  rb_define_method(cls_tdb, "tranabort", tdb_tranabort, 0);
  rb_define_method(cls_tdb, "path", tdb_path, 0);
  rb_define_method(cls_tdb, "rnum", tdb_rnum, 0);
  rb_define_method(cls_tdb, "fsiz", tdb_fsiz, 0);
  rb_define_method(cls_tdb, "setindex", tdb_setindex, 2);
  rb_define_method(cls_tdb, "genuid", tdb_genuid, 0);
  rb_define_method(cls_tdb, "[]", tdb_get, 1);
  rb_define_method(cls_tdb, "[]=", tdb_put, 2);
  rb_define_method(cls_tdb, "store", tdb_put, 2);
  rb_define_method(cls_tdb, "delete", tdb_out, 1);
  rb_define_method(cls_tdb, "fetch", tdb_fetch, -1);
  rb_define_method(cls_tdb, "has_key?", tdb_check, 1);
  rb_define_method(cls_tdb, "key?", tdb_check, 1);
  rb_define_method(cls_tdb, "include?", tdb_check, 1);
  rb_define_method(cls_tdb, "member?", tdb_check, 1);
  rb_define_method(cls_tdb, "clear", tdb_vanish, 0);
  rb_define_method(cls_tdb, "size", tdb_rnum, 0);
  rb_define_method(cls_tdb, "length", tdb_rnum, 0);
  rb_define_method(cls_tdb, "empty?", tdb_empty, 0);
  rb_define_method(cls_tdb, "each", tdb_each, 0);
  rb_define_method(cls_tdb, "each_pair", tdb_each, 0);
  rb_define_method(cls_tdb, "each_key", tdb_each_key, 0);
  rb_define_method(cls_tdb, "each_value", tdb_each_value, 0);
  rb_define_method(cls_tdb, "keys", tdb_keys, 0);
  rb_define_method(cls_tdb, "values", tdb_values, 0);
}


static VALUE tdb_initialize(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  tdb = tctdbnew();
  tctdbsetmutex(tdb);
  vtdb = Data_Wrap_Struct(cls_tdb_data, 0, tctdbdel, tdb);
  rb_iv_set(vself, TDBVNDATA, vtdb);
  return Qnil;
}


static VALUE tdb_errmsg(int argc, VALUE *argv, VALUE vself){
  VALUE vtdb, vecode;
  TCTDB *tdb;
  const char *msg;
  int ecode;
  rb_scan_args(argc, argv, "01", &vecode);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  ecode = (vecode == Qnil) ? tctdbecode(tdb) : NUM2INT(vecode);
  msg = tctdberrmsg(ecode);
  return rb_str_new2(msg);
}


static VALUE tdb_ecode(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return INT2NUM(tctdbecode(tdb));
}


static VALUE tdb_tune(int argc, VALUE *argv, VALUE vself){
  VALUE vtdb, vbnum, vapow, vfpow, vopts;
  TCTDB *tdb;
  int apow, fpow, opts;
  int64_t bnum;
  rb_scan_args(argc, argv, "04", &vbnum, &vapow, &vfpow, &vopts);
  bnum = (vbnum == Qnil) ? -1 : NUM2LL(vbnum);
  apow = (vapow == Qnil) ? -1 : NUM2INT(vapow);
  fpow = (vfpow == Qnil) ? -1 : NUM2INT(vfpow);
  opts = (vopts == Qnil) ? 0 : NUM2INT(vopts);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbtune(tdb, bnum, apow, fpow, opts) ? Qtrue : Qfalse;
}


static VALUE tdb_setcache(int argc, VALUE *argv, VALUE vself){
  VALUE vtdb, vrcnum, vlcnum, vncnum;
  TCTDB *tdb;
  int rcnum, lcnum, ncnum;
  rb_scan_args(argc, argv, "03", &vrcnum, &vlcnum, &vncnum);
  rcnum = (vrcnum == Qnil) ? -1 : NUM2INT(vrcnum);
  lcnum = (vlcnum == Qnil) ? -1 : NUM2INT(vlcnum);
  ncnum = (vncnum == Qnil) ? -1 : NUM2INT(vncnum);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbsetcache(tdb, rcnum, lcnum, ncnum) ? Qtrue : Qfalse;
}


static VALUE tdb_setxmsiz(int argc, VALUE *argv, VALUE vself){
  VALUE vtdb, vxmsiz;
  TCTDB *tdb;
  int64_t xmsiz;
  rb_scan_args(argc, argv, "01", &vxmsiz);
  xmsiz = (vxmsiz == Qnil) ? -1 : NUM2LL(vxmsiz);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbsetxmsiz(tdb, xmsiz) ? Qtrue : Qfalse;
}


static VALUE tdb_open(int argc, VALUE *argv, VALUE vself){
  VALUE vtdb, vpath, vomode;
  TCTDB *tdb;
  int omode;
  rb_scan_args(argc, argv, "11", &vpath, &vomode);
  Check_Type(vpath, T_STRING);
  omode = (vomode == Qnil) ? TDBOREADER : NUM2INT(vomode);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbopen(tdb, RSTRING_PTR(vpath), omode) ? Qtrue : Qfalse;
}


static VALUE tdb_close(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbclose(tdb) ? Qtrue : Qfalse;
}


static VALUE tdb_put(VALUE vself, VALUE vpkey, VALUE vcols){
  VALUE vtdb, vrv;
  TCTDB *tdb;
  TCMAP *cols;
  vpkey = StringValueEx(vpkey);
  Check_Type(vcols, T_HASH);
  cols = vhashtomap(vcols);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  vrv = tctdbput(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey), cols) ? Qtrue : Qfalse;
  tcmapdel(cols);
  return vrv;
}


static VALUE tdb_putkeep(VALUE vself, VALUE vpkey, VALUE vcols){
  VALUE vtdb, vrv;
  TCTDB *tdb;
  TCMAP *cols;
  vpkey = StringValueEx(vpkey);
  Check_Type(vcols, T_HASH);
  cols = vhashtomap(vcols);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  vrv = tctdbputkeep(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey), cols) ? Qtrue : Qfalse;
  tcmapdel(cols);
  return vrv;
}


static VALUE tdb_putcat(VALUE vself, VALUE vpkey, VALUE vcols){
  VALUE vtdb, vrv;
  TCTDB *tdb;
  TCMAP *cols;
  vpkey = StringValueEx(vpkey);
  Check_Type(vcols, T_HASH);
  cols = vhashtomap(vcols);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  vrv = tctdbputcat(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey), cols) ? Qtrue : Qfalse;
  tcmapdel(cols);
  return vrv;
}


static VALUE tdb_out(VALUE vself, VALUE vpkey){
  VALUE vtdb;
  TCTDB *tdb;
  vpkey = StringValueEx(vpkey);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbout(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey)) ? Qtrue : Qfalse;
}


static VALUE tdb_get(VALUE vself, VALUE vpkey){
  VALUE vtdb, vcols;
  TCTDB *tdb;
  TCMAP *cols;
  vpkey = StringValueEx(vpkey);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  if(!(cols = tctdbget(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey)))) return Qnil;
  vcols = maptovhash(cols);
  tcmapdel(cols);
  return vcols;
}


static VALUE tdb_vsiz(VALUE vself, VALUE vpkey){
  VALUE vtdb;
  TCTDB *tdb;
  vpkey = StringValueEx(vpkey);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return INT2NUM(tctdbvsiz(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey)));
}


static VALUE tdb_iterinit(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbiterinit(tdb) ? Qtrue : Qfalse;
}


static VALUE tdb_iternext(VALUE vself){
  VALUE vtdb, vval;
  TCTDB *tdb;
  char *vbuf;
  int vsiz;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  if(!(vbuf = tctdbiternext(tdb, &vsiz))) return Qnil;
  vval = rb_str_new(vbuf, vsiz);
  tcfree(vbuf);
  return vval;
}


static VALUE tdb_fwmkeys(int argc, VALUE *argv, VALUE vself){
  VALUE vtdb, vprefix, vmax, vary;
  TCTDB *tdb;
  TCLIST *pkeys;
  int max;
  rb_scan_args(argc, argv, "11", &vprefix, &vmax);
  vprefix = StringValueEx(vprefix);
  max = (vmax == Qnil) ? -1 : NUM2INT(vmax);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  pkeys = tctdbfwmkeys(tdb, RSTRING_PTR(vprefix), RSTRING_LEN(vprefix), max);
  vary = listtovary(pkeys);
  tclistdel(pkeys);
  return vary;
}


static VALUE tdb_addint(VALUE vself, VALUE vpkey, VALUE vnum){
  VALUE vtdb;
  TCTDB *tdb;
  int num;
  vpkey = StringValueEx(vpkey);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  num = tctdbaddint(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey), NUM2INT(vnum));
  return num == INT_MIN ? Qnil : INT2NUM(num);
}


static VALUE tdb_adddouble(VALUE vself, VALUE vpkey, VALUE vnum){
  VALUE vtdb;
  TCTDB *tdb;
  double num;
  vpkey = StringValueEx(vpkey);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  num = tctdbadddouble(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey), NUM2DBL(vnum));
  return isnan(num) ? Qnil : rb_float_new(num);
}


static VALUE tdb_sync(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbsync(tdb) ? Qtrue : Qfalse;
}


static VALUE tdb_optimize(int argc, VALUE *argv, VALUE vself){
  VALUE vtdb, vbnum, vapow, vfpow, vopts;
  TCTDB *tdb;
  int apow, fpow, opts;
  int64_t bnum;
  rb_scan_args(argc, argv, "04", &vbnum, &vapow, &vfpow, &vopts);
  bnum = (vbnum == Qnil) ? -1 : NUM2LL(vbnum);
  apow = (vapow == Qnil) ? -1 : NUM2INT(vapow);
  fpow = (vfpow == Qnil) ? -1 : NUM2INT(vfpow);
  opts = (vopts == Qnil) ? UINT8_MAX : NUM2INT(vopts);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdboptimize(tdb, bnum, apow, fpow, opts) ? Qtrue : Qfalse;
}


static VALUE tdb_vanish(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbvanish(tdb) ? Qtrue : Qfalse;
}


static VALUE tdb_copy(VALUE vself, VALUE vpath){
  VALUE vtdb;
  TCTDB *tdb;
  Check_Type(vpath, T_STRING);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbcopy(tdb, RSTRING_PTR(vpath)) ? Qtrue : Qfalse;
}


static VALUE tdb_tranbegin(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbtranbegin(tdb) ? Qtrue : Qfalse;
}


static VALUE tdb_trancommit(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbtrancommit(tdb) ? Qtrue : Qfalse;
}


static VALUE tdb_tranabort(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbtranabort(tdb) ? Qtrue : Qfalse;
}


static VALUE tdb_path(VALUE vself){
  VALUE vtdb, vpath;
  TCTDB *tdb;
  const char *path;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  if(!(path = tctdbpath(tdb))) return Qnil;
  vpath = rb_str_new2(path);
  return vpath;
}


static VALUE tdb_rnum(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return LL2NUM(tctdbrnum(tdb));
}


static VALUE tdb_fsiz(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return LL2NUM(tctdbfsiz(tdb));
}


static VALUE tdb_setindex(VALUE vself, VALUE vname, VALUE vtype){
  VALUE vtdb;
  TCTDB *tdb;
  Check_Type(vname, T_STRING);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbsetindex(tdb, RSTRING_PTR(vname), NUM2INT(vtype)) ? Qtrue : Qfalse;
}


static VALUE tdb_genuid(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return LL2NUM(tctdbgenuid(tdb));
}


static VALUE tdb_fetch(int argc, VALUE *argv, VALUE vself){
  VALUE vtdb, vpkey, vdef, vcols;
  TCTDB *tdb;
  TCMAP *cols;
  rb_scan_args(argc, argv, "11", &vpkey, &vdef);
  vpkey = StringValueEx(vpkey);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  if((cols = tctdbget(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey))) != NULL){
    vcols = maptovhash(cols);
    tcmapdel(cols);
  } else {
    vcols = vdef;
  }
  return vcols;
}


static VALUE tdb_check(VALUE vself, VALUE vpkey){
  VALUE vtdb;
  TCTDB *tdb;
  vpkey = StringValueEx(vpkey);
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbvsiz(tdb, RSTRING_PTR(vpkey), RSTRING_LEN(vpkey)) >= 0 ? Qtrue : Qfalse;
}


static VALUE tdb_empty(VALUE vself){
  VALUE vtdb;
  TCTDB *tdb;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  return tctdbrnum(tdb) < 1 ? Qtrue : Qfalse;
}


static VALUE tdb_each(VALUE vself){
  VALUE vtdb, vrv;
  TCTDB *tdb;
  TCMAP *cols;
  char *kbuf;
  int ksiz;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  vrv = Qnil;
  tctdbiterinit(tdb);
  while((kbuf = tctdbiternext(tdb, &ksiz)) != NULL){
    if((cols = tctdbget(tdb, kbuf, ksiz)) != NULL){
      vrv = rb_yield_values(2, rb_str_new(kbuf, ksiz), maptovhash(cols));
      tcmapdel(cols);
    }
    tcfree(kbuf);
  }
  return vrv;
}


static VALUE tdb_each_key(VALUE vself){
  VALUE vtdb, vrv;
  TCTDB *tdb;
  char *kbuf;
  int ksiz;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  vrv = Qnil;
  tctdbiterinit(tdb);
  while((kbuf = tctdbiternext(tdb, &ksiz)) != NULL){
    vrv = rb_yield(rb_str_new(kbuf, ksiz));
    tcfree(kbuf);
  }
  return vrv;
}


static VALUE tdb_each_value(VALUE vself){
  VALUE vtdb, vrv;
  TCTDB *tdb;
  TCMAP *cols;
  char *kbuf;
  int ksiz;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  vrv = Qnil;
  tctdbiterinit(tdb);
  while((kbuf = tctdbiternext(tdb, &ksiz)) != NULL){
    if((cols = tctdbget(tdb, kbuf, ksiz)) != NULL){
      vrv = rb_yield(maptovhash(cols));
      tcmapdel(cols);
    }
    tcfree(kbuf);
  }
  return vrv;
}


static VALUE tdb_keys(VALUE vself){
  VALUE vtdb, vary;
  TCTDB *tdb;
  char *kbuf;
  int ksiz;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  vary = rb_ary_new2(tctdbrnum(tdb));
  tctdbiterinit(tdb);
  while((kbuf = tctdbiternext(tdb, &ksiz)) != NULL){
    rb_ary_push(vary, rb_str_new(kbuf, ksiz));
    tcfree(kbuf);
  }
  return vary;
}


static VALUE tdb_values(VALUE vself){
  VALUE vtdb, vary;
  TCTDB *tdb;
  TCMAP *cols;
  char *kbuf;
  int ksiz;
  vtdb = rb_iv_get(vself, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  vary = rb_ary_new2(tctdbrnum(tdb));
  tctdbiterinit(tdb);
  while((kbuf = tctdbiternext(tdb, &ksiz)) != NULL){
    if((cols = tctdbget(tdb, kbuf, ksiz)) != NULL){
      rb_ary_push(vary, maptovhash(cols));
      tcmapdel(cols);
    }
    tcfree(kbuf);
  }
  return vary;
}


static void tdbqry_init(void){
  cls_tdbqry = rb_define_class_under(mod_tokyocabinet, "TDBQRY", rb_cObject);
  cls_tdbqry_data = rb_define_class_under(mod_tokyocabinet, "TDBQRY_data", rb_cObject);
  rb_define_const(cls_tdbqry, "QCSTREQ", INT2NUM(TDBQCSTREQ));
  rb_define_const(cls_tdbqry, "QCSTRINC", INT2NUM(TDBQCSTRINC));
  rb_define_const(cls_tdbqry, "QCSTRBW", INT2NUM(TDBQCSTRBW));
  rb_define_const(cls_tdbqry, "QCSTREW", INT2NUM(TDBQCSTREW));
  rb_define_const(cls_tdbqry, "QCSTRAND", INT2NUM(TDBQCSTRAND));
  rb_define_const(cls_tdbqry, "QCSTROR", INT2NUM(TDBQCSTROR));
  rb_define_const(cls_tdbqry, "QCSTROREQ", INT2NUM(TDBQCSTROREQ));
  rb_define_const(cls_tdbqry, "QCSTRRX", INT2NUM(TDBQCSTRRX));
  rb_define_const(cls_tdbqry, "QCNUMEQ", INT2NUM(TDBQCNUMEQ));
  rb_define_const(cls_tdbqry, "QCNUMGT", INT2NUM(TDBQCNUMGT));
  rb_define_const(cls_tdbqry, "QCNUMGE", INT2NUM(TDBQCNUMGE));
  rb_define_const(cls_tdbqry, "QCNUMLT", INT2NUM(TDBQCNUMLT));
  rb_define_const(cls_tdbqry, "QCNUMLE", INT2NUM(TDBQCNUMLE));
  rb_define_const(cls_tdbqry, "QCNUMBT", INT2NUM(TDBQCNUMBT));
  rb_define_const(cls_tdbqry, "QCNUMOREQ", INT2NUM(TDBQCNUMOREQ));
  rb_define_const(cls_tdbqry, "QCNEGATE", INT2NUM(TDBQCNEGATE));
  rb_define_const(cls_tdbqry, "QCNOIDX", INT2NUM(TDBQCNOIDX));
  rb_define_const(cls_tdbqry, "QOSTRASC", INT2NUM(TDBQOSTRASC));
  rb_define_const(cls_tdbqry, "QOSTRDESC", INT2NUM(TDBQOSTRDESC));
  rb_define_const(cls_tdbqry, "QONUMASC", INT2NUM(TDBQONUMASC));
  rb_define_const(cls_tdbqry, "QONUMDESC", INT2NUM(TDBQONUMDESC));
  rb_define_const(cls_tdbqry, "QPPUT", INT2NUM(TDBQPPUT));
  rb_define_const(cls_tdbqry, "QPOUT", INT2NUM(TDBQPOUT));
  rb_define_const(cls_tdbqry, "QPSTOP", INT2NUM(TDBQPSTOP));
  rb_define_private_method(cls_tdbqry, "initialize", tdbqry_initialize, 1);
  rb_define_method(cls_tdbqry, "addcond", tdbqry_addcond, 3);
  rb_define_method(cls_tdbqry, "setorder", tdbqry_setorder, 2);
  rb_define_method(cls_tdbqry, "setlimit", tdbqry_setlimit, -1);
  rb_define_method(cls_tdbqry, "setmax", tdbqry_setlimit, -1);
  rb_define_method(cls_tdbqry, "search", tdbqry_search, 0);
  rb_define_method(cls_tdbqry, "searchout", tdbqry_searchout, 0);
  rb_define_method(cls_tdbqry, "proc", tdbqry_proc, 0);
  rb_define_method(cls_tdbqry, "hint", tdbqry_hint, 0);
}


static int tdbqry_procrec(const void *pkbuf, int pksiz, TCMAP *cols, void *opq){
  VALUE vpkey, vcols, vrv, vkeys, vkey, vval;
  int i, rv, num;
  vpkey = rb_str_new(pkbuf, pksiz);
  vcols = maptovhash(cols);
  vrv = rb_yield_values(2, vpkey, vcols);
  rv = (vrv == Qnil) ? 0 : NUM2INT(vrv);
  if(rv & TDBQPPUT){
    tcmapclear(cols);
    vkeys = rb_funcall(vcols, rb_intern("keys"), 0);
    num = RARRAY_LEN(vkeys);
    for(i = 0; i < num; i++){
      vkey = rb_ary_entry(vkeys, i);
      vval = rb_hash_aref(vcols, vkey);
      vkey = StringValueEx(vkey);
      vval = StringValueEx(vval);
      tcmapput(cols, RSTRING_PTR(vkey), RSTRING_LEN(vkey), RSTRING_PTR(vval), RSTRING_LEN(vval));
    }
  }
  return rv;
}


static VALUE tdbqry_initialize(VALUE vself, VALUE vtdb){
  VALUE vqry;
  TCTDB *tdb;
  TDBQRY *qry;
  Check_Type(vtdb, T_OBJECT);
  vtdb = rb_iv_get(vtdb, TDBVNDATA);
  Data_Get_Struct(vtdb, TCTDB, tdb);
  qry = tctdbqrynew(tdb);
  vqry = Data_Wrap_Struct(cls_tdbqry_data, 0, tctdbqrydel, qry);
  rb_iv_set(vself, TDBQRYVNDATA, vqry);
  rb_iv_set(vself, TDBVNDATA, vtdb);
  return Qnil;
}


static VALUE tdbqry_addcond(VALUE vself, VALUE vname, VALUE vop, VALUE vexpr){
  VALUE vqry;
  TDBQRY *qry;
  vname = StringValueEx(vname);
  vexpr = StringValueEx(vexpr);
  vqry = rb_iv_get(vself, TDBQRYVNDATA);
  Data_Get_Struct(vqry, TDBQRY, qry);
  tctdbqryaddcond(qry, RSTRING_PTR(vname), NUM2INT(vop), RSTRING_PTR(vexpr));
  return Qnil;
}


static VALUE tdbqry_setorder(VALUE vself, VALUE vname, VALUE vtype){
  VALUE vqry;
  TDBQRY *qry;
  vname = StringValueEx(vname);
  vqry = rb_iv_get(vself, TDBQRYVNDATA);
  Data_Get_Struct(vqry, TDBQRY, qry);
  tctdbqrysetorder(qry, RSTRING_PTR(vname), NUM2INT(vtype));
  return Qnil;
}


static VALUE tdbqry_setlimit(int argc, VALUE *argv, VALUE vself){
  VALUE vqry, vmax, vskip;
  TDBQRY *qry;
  int max, skip;
  rb_scan_args(argc, argv, "02", &vmax, &vskip);
  max = (vmax == Qnil) ? -1 : NUM2INT(vmax);
  skip = (vskip == Qnil) ? -1 : NUM2INT(vskip);
  vqry = rb_iv_get(vself, TDBQRYVNDATA);
  Data_Get_Struct(vqry, TDBQRY, qry);
  tctdbqrysetlimit(qry, max, skip);
  return Qnil;
}


static VALUE tdbqry_search(VALUE vself){
  VALUE vqry, vary;
  TDBQRY *qry;
  TCLIST *res;
  vqry = rb_iv_get(vself, TDBQRYVNDATA);
  Data_Get_Struct(vqry, TDBQRY, qry);
  res = tctdbqrysearch(qry);
  vary = listtovary(res);
  tclistdel(res);
  return vary;
}


static VALUE tdbqry_searchout(VALUE vself){
  VALUE vqry;
  TDBQRY *qry;
  vqry = rb_iv_get(vself, TDBQRYVNDATA);
  Data_Get_Struct(vqry, TDBQRY, qry);
  return tctdbqrysearchout(qry) ? Qtrue : Qfalse;
}


static VALUE tdbqry_proc(VALUE vself, VALUE vproc){
  VALUE vqry;
  TDBQRY *qry;
  if(rb_block_given_p() != Qtrue) rb_raise(rb_eArgError, "no block given");
  vqry = rb_iv_get(vself, TDBQRYVNDATA);
  Data_Get_Struct(vqry, TDBQRY, qry);
  return tctdbqryproc(qry, (TDBQRYPROC)tdbqry_procrec, NULL) ? Qtrue : Qfalse;
}


static VALUE tdbqry_hint(VALUE vself){
  VALUE vqry;
  TDBQRY *qry;
  vqry = rb_iv_get(vself, TDBQRYVNDATA);
  Data_Get_Struct(vqry, TDBQRY, qry);
  return rb_str_new2(tctdbqryhint(qry));
}



/* END OF FILE */
