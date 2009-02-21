= Ruby Binding of Tokyo Cabinet

Tokyo Cabinet: a modern implementation of DBM

== INTRODUCTION

Tokyo Cabinet is a library of routines for managing a database.  The database is a simple data file containing records, each is a pair of a key and a value.  Every key and value is serial bytes with variable length.  Both binary data and character string can be used as a key and a value.  There is neither concept of data tables nor data types.  Records are organized in hash table, B+ tree, or fixed-length array.

As for database of hash table, each key must be unique within a database, so it is impossible to store two or more records with a key overlaps.  The following access methods are provided to the database: storing a record with a key and a value, deleting a record by a key, retrieving a record by a key.  Moreover, traversal access to every key are provided, although the order is arbitrary.  These access methods are similar to ones of DBM (or its followers: NDBM and GDBM) library defined in the UNIX standard.  Tokyo Cabinet is an alternative for DBM because of its higher performance.

As for database of B+ tree, records whose keys are duplicated can be stored.  Access methods of storing, deleting, and retrieving are provided as with the database of hash table.  Records are stored in order by a comparison function assigned by a user.  It is possible to access each record with the cursor in ascending or descending order.  According to this mechanism, forward matching search for strings and range search for integers are realized.

As for database of fixed-length array, records are stored with unique natural numbers.  It is impossible to store two or more records with a key overlaps.  Moreover, the length of each record is limited by the specified length.  Provided operations are the same as ones of hash database.

Table database is also provided as a variant of hash database.  Each record is identified by the primary key and has a set of named columns.  Although there is no concept of data schema, it is possible to search for records with complex conditions efficiently by using indexes of arbitrary columns.

=== Setting

Install the latest version of Tokyo Cabinet beforehand and get the package of the Ruby binding of Tokyo Cabinet.

Enter the directory of the extracted package then perform installation.

 ruby extconf.rb
 make
 su
 make install

The package `tokyocabinet' should be loaded in each source file of application programs.

 require 'tokyocabinet'

All symbols of Tokyo Cabinet are defined in the module `TokyoCabinet'.  You can access them without any prefix by including the module.

 include TokyoCabinet


= EXAMPLE

The following code is an example to use a hash database.

 require 'tokyocabinet'
 include TokyoCabinet
 
 # create the object
 hdb = HDB::new
 
 # open the database
 if !hdb.open("casket.tch", HDB::OWRITER | HDB::OCREAT)
   ecode = hdb.ecode
   STDERR.printf("open error: %s\n", hdb.errmsg(ecode))
 end
 
 # store records
 if !hdb.put("foo", "hop") ||
     !hdb.put("bar", "step") ||
     !hdb.put("baz", "jump")
   ecode = hdb.ecode
   STDERR.printf("put error: %s\n", hdb.errmsg(ecode))
 end
 
 # retrieve records
 value = hdb.get("foo")
 if value
   printf("%s\n", value)
 else
   ecode = hdb.ecode
   STDERR.printf("get error: %s\n", hdb.errmsg(ecode))
 end
 
 # traverse records
 hdb.iterinit
 while key = hdb.iternext
   value = hdb.get(key)
   if value
     printf("%s:%s\n", key, value)
   end
 end
 
 # hash-like usage
 hdb["quux"] = "touchdown"
 printf("%s\n", hdb["quux"])
 hdb.each do |key, value|
   printf("%s:%s\n", key, value)
 end
 
 # close the database
 if !hdb.close
   ecode = hdb.ecode
   STDERR.printf("close error: %s\n", hdb.errmsg(ecode))
 end

The following code is an example to use a B+ tree database.

 require 'tokyocabinet'
 include TokyoCabinet
 
 # create the object
 bdb = BDB::new
 
 # open the database
 if !bdb.open("casket.tcb", BDB::OWRITER | BDB::OCREAT)
   ecode = bdb.ecode
   STDERR.printf("open error: %s\n", bdb.errmsg(ecode))
 end
 
 # store records
 if !bdb.put("foo", "hop") ||
     !bdb.put("bar", "step") ||
     !bdb.put("baz", "jump")
   ecode = bdb.ecode
   STDERR.printf("put error: %s\n", bdb.errmsg(ecode))
 end
 
 # retrieve records
 value = bdb.get("foo")
 if value
   printf("%s\n", value)
 else
   ecode = bdb.ecode
   STDERR.printf("get error: %s\n", bdb.errmsg(ecode))
 end
 
 # traverse records
 cur = BDBCUR::new(bdb)
 cur.first
 while key = cur.key
   value = cur.val
   if value
     printf("%s:%s\n", key, value)
   end
   cur.next
 end
 
 # hash-like usage
 bdb["quux"] = "touchdown"
 printf("%s\n", bdb["quux"])
 bdb.each do |key, value|
   printf("%s:%s\n", key, value)
 end
 
 # close the database
 if !bdb.close
   ecode = bdb.ecode
   STDERR.printf("close error: %s\n", bdb.errmsg(ecode))
 end

The following code is an example to use a fixed-length database.

 require 'tokyocabinet'
 include TokyoCabinet
 
 # create the object
 fdb = FDB::new
 
 # open the database
 if !fdb.open("casket.tcf", FDB::OWRITER | FDB::OCREAT)
   ecode = fdb.ecode
   STDERR.printf("open error: %s\n", fdb.errmsg(ecode))
 end
 
 # store records
 if !fdb.put(1, "one") ||
     !fdb.put(12, "twelve") ||
     !fdb.put(144, "one forty four")
   ecode = fdb.ecode
   STDERR.printf("put error: %s\n", fdb.errmsg(ecode))
 end
 
 # retrieve records
 value = fdb.get(1)
 if value
   printf("%s\n", value)
 else
   ecode = fdb.ecode
   STDERR.printf("get error: %s\n", fdb.errmsg(ecode))
 end
 
 # traverse records
 fdb.iterinit
 while key = fdb.iternext
   value = fdb.get(key)
   if value
     printf("%s:%s\n", key, value)
   end
 end
 
 # hash-like usage
 fdb[1728] = "seventeen twenty eight"
 printf("%s\n", fdb[1728])
 fdb.each do |key, value|
   printf("%s:%s\n", key, value)
 end
 
 # close the database
 if !fdb.close
   ecode = fdb.ecode
   STDERR.printf("close error: %s\n", fdb.errmsg(ecode))
 end

The following code is an example to use a table database.

 require 'tokyocabinet'
 include TokyoCabinet
 
 # create the object
 tdb = TDB::new
 
 # open the database
 if !tdb.open("casket.tct", TDB::OWRITER | TDB::OCREAT)
   ecode = tdb.ecode
   STDERR.printf("open error: %s\n", tdb.errmsg(ecode))
 end
 
 # store a record
 pkey = tdb.genuid
 cols = { "name" => "mikio", "age" => "30", "lang" => "ja,en,c" }
 if !tdb.put(pkey, cols)
   ecode = tdb.ecode
   STDERR.printf("get error: %s\n", tdb.errmsg(ecode))
 end
 
 # store another record
 cols = { "name" => "falcon", "age" => "31", "lang" => "ja", "skill" => "cook,blog" }
 if !tdb.put("x12345", cols)
   ecode = tdb.ecode
   STDERR.printf("get error: %s\n", tdb.errmsg(ecode))
 end
 
 # search for records
 qry = TDBQRY::new(tdb)
 qry.addcond("age", TDBQRY::QCNUMGE, "20")
 qry.addcond("lang", TDBQRY::QCSTROR, "ja,en")
 qry.setorder("name", TDBQRY::QOSTRASC)
 qry.setmax(10)
 res = qry.search
 res.each do |rkey|
   rcols = tdb.get(rkey)
   printf("name:%s\n", rcols["name"])
 end
 
 # hash-like usage
 tdb["joker"] = { "name" => "ozma", "lang" => "en", "skill" => "song,dance" }
 printf("%s\n", tdb["joker"]["name"])
 tdb.each do |key, value|
   printf("%s:%s\n", key, value["name"])
 end
 
 # close the database
 if !tdb.close
   ecode = tdb.ecode
   STDERR.printf("close error: %s\n", tdb.errmsg(ecode))
 end


== LICENSE

 Copyright (C) 2006-2009 Mikio Hirabayashi
 All rights reserved.

Tokyo Cabinet is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License or any later version.  Tokyo Cabinet is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.  You should have received a copy of the GNU Lesser General Public License along with Tokyo Cabinet; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
