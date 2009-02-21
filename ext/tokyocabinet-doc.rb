#--
# Ruby binding of Tokyo Cabinet
#                                                       Copyright (C) 2006-2009 Mikio Hirabayashi
#  This file is part of Tokyo Cabinet.
#  Tokyo Cabinet is free software; you can redistribute it and/or modify it under the terms of
#  the GNU Lesser General Public License as published by the Free Software Foundation; either
#  version 2.1 of the License or any later version.  Tokyo Cabinet is distributed in the hope
#  that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
#  License for more details.
#  You should have received a copy of the GNU Lesser General Public License along with Tokyo
#  Cabinet; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
#  Boston, MA 02111-1307 USA.
#++
#:include:overview.rd


module TokyoCabinet
  # the version information
  VERSION = "x.y.z"
  # Hash database is a file containing a hash table and is handled with the hash database API.  Before operations to store or retrieve records, it is necessary to open a database file and connect the hash database object to it.  To avoid data missing or corruption, it is important to close every database file when it is no longer in use.%%
  # Except for the interface below, methods compatible with the `Hash' class are also provided; `[]', `[]=', `store', `delete', `fetch', `has_key?', `has_value?', `key', `clear', `size', `empty?', `each', `each_key', `each_value', and `keys'.%%
  class HDB
    # error code: success
    ESUCCESS = 0
    # error code: threading error
    ETHREAD = 1
    # error code: invalid operation
    EINVALID = 2
    # error code: file not found
    ENOFILE = 3
    # error code: no permission
    ENOPERM = 4
    # error code: invalid meta data
    EMETA = 5
    # error code: invalid record header
    ERHEAD = 6
    # error code: open error
    EOPEN = 7
    # error code: close error
    ECLOSE = 8
    # error code: trunc error
    ETRUNC = 9
    # error code: sync error
    ESYNC = 10
    # error code: stat error
    ESTAT = 11
    # error code: seek error
    ESEEK = 12
    # error code: read error
    EREAD = 13
    # error code: write error
    EWRITE = 14
    # error code: mmap error
    EMMAP = 15
    # error code: lock error
    ELOCK = 16
    # error code: unlink error
    EUNLINK = 17
    # error code: rename error
    ERENAME = 18
    # error code: mkdir error
    EMKDIR = 19
    # error code: rmdir error
    ERMDIR = 20
    # error code: existing record
    EKEEP = 21
    # error code: no record found
    ENOREC = 22
    # error code: miscellaneous error
    EMISC = 9999
    # tuning option: use 64-bit bucket array
    TLARGE = 1 << 0
    # tuning option: compress each record with Deflate
    TDEFLATE = 1 << 1
    # tuning option: compress each record with BZIP2
    TBZIP = 1 << 2
    # tuning option: compress each record with TCBS
    TTCBS = 1 << 3
    # open mode: open as a reader
    OREADER = 1 << 0
    # open mode: open as a writer
    OWRITER = 1 << 1
    # open mode: writer creating
    OCREAT = 1 << 2
    # open mode: writer truncating
    OTRUNC = 1 << 3
    # open mode: open without locking
    ONOLCK = 1 << 4
    # open mode: lock without blocking
    OLCKNB = 1 << 5
    # open mode: synchronize every transaction
    OTSYNC = 1 << 6
    # Create a hash database object.%%
    # The return value is the new hash database object.%%
    def initialize()
      # (native code)
    end
    # Get the message string corresponding to an error code.%%
    # `<i>ecode</i>' specifies the error code.  If it is not defined or negative, the last happened error code is specified.%%
    # The return value is the message string of the error code.%%
    def errmsg(ecode)
      # (native code)
    end
    # Get the last happened error code.%%
    # The return value is the last happened error code.%%
    # The following error codes are defined: `TokyoCabinet::HDB::ESUCCESS' for success, `TokyoCabinet::HDB::ETHREAD' for threading error, `TokyoCabinet::HDB::EINVALID' for invalid operation, `TokyoCabinet::HDB::ENOFILE' for file not found, `TokyoCabinet::HDB::ENOPERM' for no permission, `TokyoCabinet::HDB::EMETA' for invalid meta data, `TokyoCabinet::HDB::ERHEAD' for invalid record header, `TokyoCabinet::HDB::EOPEN' for open error, `TokyoCabinet::HDB::ECLOSE' for close error, `TokyoCabinet::HDB::ETRUNC' for trunc error, `TokyoCabinet::HDB::ESYNC' for sync error, `TokyoCabinet::HDB::ESTAT' for stat error, `TokyoCabinet::HDB::ESEEK' for seek error, `TokyoCabinet::HDB::EREAD' for read error, `TokyoCabinet::HDB::EWRITE' for write error, `TokyoCabinet::HDB::EMMAP' for mmap error, `TokyoCabinet::HDB::ELOCK' for lock error, `TokyoCabinet::HDB::EUNLINK' for unlink error, `TokyoCabinet::HDB::ERENAME' for rename error, `TokyoCabinet::HDB::EMKDIR' for mkdir error, `TokyoCabinet::HDB::ERMDIR' for rmdir error, `TokyoCabinet::HDB::EKEEP' for existing record, `TokyoCabinet::HDB::ENOREC' for no record found, and `TokyoCabinet::HDB::EMISC' for miscellaneous error.%%
    def ecode()
      # (native code)
    end
    # Set the tuning parameters.%%
    # `<i>bnum</i>' specifies the number of elements of the bucket array.  If it is not defined or not more than 0, the default value is specified.  The default value is 131071.  Suggested size of the bucket array is about from 0.5 to 4 times of the number of all records to be stored.%%
    # `<i>apow</i>' specifies the size of record alignment by power of 2.  If it is not defined or negative, the default value is specified.  The default value is 4 standing for 2^4=16.%%
    # `<i>fpow</i>' specifies the maximum number of elements of the free block pool by power of 2.  If it is not defined or negative, the default value is specified.  The default value is 10 standing for 2^10=1024.%%
    # `<i>opts</i>' specifies options by bitwise or: `TokyoCabinet::HDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, `TokyoCabinet::HDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, `TokyoCabinet::HDB::TDBZIP' specifies that each record is compressed with BZIP2 encoding, `TokyoCabinet::HDB::TTCBS' specifies that each record is compressed with TCBS encoding.  If it is not defined, no option is specified.%%
    # If successful, the return value is true, else, it is false.  Note that the tuning parameters of the database should be set before the database is opened.%%
    def tune(bnum, apow, fpow, opts)
      # (native code)
    end
    # Set the caching parameters.%%
    # `<i>rcnum</i>' specifies the maximum number of records to be cached.  If it is not defined or not more than 0, the record cache is disabled. It is disabled by default.%%
    # If successful, the return value is true, else, it is false.%%
    # Note that the caching parameters of the database should be set before the database is opened.%%
    def setcache(rcnum)
      # (native code)
    end
    # Set the size of the extra mapped memory.%%
    # `<i>xmsiz</i>' specifies the size of the extra mapped memory.  If it is not defined or not more than 0, the extra mapped memory is disabled.  The default size is 67108864.%%
    # If successful, the return value is true, else, it is false.%%
    # Note that the mapping parameters should be set before the database is opened.%%
    def setxmsiz(xmsiz)
      # (native code)
    end
    # Open a database file.%%
    # `<i>path</i>' specifies the path of the database file.%%
    # `<i>omode</i>' specifies the connection mode: `TokyoCabinet::HDB::OWRITER' as a writer, `TokyoCabinet::HDB::OREADER' as a reader.  If the mode is `TokyoCabinet::HDB::OWRITER', the following may be added by bitwise or: `TokyoCabinet::HDB::OCREAT', which means it creates a new database if not exist, `TokyoCabinet::HDB::OTRUNC', which means it creates a new database regardless if one exists, `TokyoCabinet::HDB::OTSYNC', which means every transaction synchronizes updated contents with the device.  Both of `TokyoCabinet::HDB::OREADER' and `TokyoCabinet::HDB::OWRITER' can be added to by bitwise or: `TokyoCabinet::HDB::ONOLCK', which means it opens the database file without file locking, or `TokyoCabinet::HDB::OLCKNB', which means locking is performed without blocking.  If it is not defined, `TokyoCabinet::HDB::OREADER' is specified.%%
    # If successful, the return value is true, else, it is false.%%
    def open(path, omode)
      # (native code)
    end
    # Close the database file.%%
    # If successful, the return value is true, else, it is false.%%
    # Update of a database is assured to be written when the database is closed.  If a writer opens a database but does not close it appropriately, the database will be broken.%%
    def close()
      # (native code)
    end
    # Store a record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, it is overwritten.%%
    def put(key, value)
      # (native code)
    end
    # Store a new record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, this method has no effect.%%
    def putkeep(key, value)
      # (native code)
    end
    # Concatenate a value at the end of the existing record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If there is no corresponding record, a new record is created.%%
    def putcat(key, value)
      # (native code)
    end
    # Store a record in asynchronous fashion.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, it is overwritten.  Records passed to this method are accumulated into the inner buffer and wrote into the file at a blast.%%
    def putasync(key, value)
      # (native code)
    end
    # Remove a record.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is true, else, it is false.%%
    def out(key)
      # (native code)
    end
    # Retrieve a record.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is the value of the corresponding record.  `nil' is returned if no record corresponds.%%
    def get(key)
      # (native code)
    end
    # Get the size of the value of a record.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is the size of the value of the corresponding record, else, it is -1.%%
    def vsiz(key)
      # (native code)
    end
    # Initialize the iterator.%%
    # If successful, the return value is true, else, it is false.%%
    # The iterator is used in order to access the key of every record stored in a database.%%
    def iterinit()
      # (native code)
    end
    # Get the next key of the iterator.%%
    # If successful, the return value is the next key, else, it is `nil'.  `nil' is returned when no record is to be get out of the iterator.%%
    # It is possible to access every record by iteration of calling this method.  It is allowed to update or remove records whose keys are fetched while the iteration.  However, it is not assured if updating the database is occurred while the iteration.  Besides, the order of this traversal access method is arbitrary, so it is not assured that the order of storing matches the one of the traversal access.%%
    def iternext()
      # (native code)
    end
    # Get forward matching keys.%%
    # `<i>prefix</i>' specifies the prefix of the corresponding keys.%%
    # `<i>max</i>' specifies the maximum number of keys to be fetched.  If it is not defined or negative, no limit is specified.%%
    # The return value is a list object of the keys of the corresponding records.  This method does never fail and return an empty list even if no record corresponds.%%
    # Note that this function may be very slow because every key in the database is scanned.%%
    def fwmkeys(prefix, max)
      # (native code)
    end
    # Add an integer to a record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>num</i>' specifies the additional value.%%
    # If successful, the return value is the summation value, else, it is `nil'.%%
    # If the corresponding record exists, the value is treated as an integer and is added to.  If no record corresponds, a new record of the additional value is stored.  Because records are stored in binary format, they should be processed with the `unpack' method with the `i' operator after retrieval.%%
    def addint(key, num)
      # (native code)
    end
    # Add a real number to a record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>num</i>' specifies the additional value.%%
    # If successful, the return value is the summation value, else, it is `nil'.%%
    # If the corresponding record exists, the value is treated as a real number and is added to.  If no record corresponds, a new record of the additional value is stored.  Because records are stored in binary format, they should be processed with the `unpack' method with the `d' operator after retrieval.%%
    def adddouble(key, num)
      # (native code)
    end
    # Synchronize updated contents with the file and the device.%%
    # If successful, the return value is true, else, it is false.%%
    # This method is useful when another process connects the same database file.%%
    def sync()
      # (native code)
    end
    # Optimize the database file.%%
    # `<i>bnum</i>' specifies the number of elements of the bucket array.  If it is not defined or not more than 0, the default value is specified.  The default value is two times of the number of records.%%
    # `<i>apow</i>' specifies the size of record alignment by power of 2.  If it is not defined or negative, the current setting is not changed.%%
    # `<i>fpow</i>' specifies the maximum number of elements of the free block pool by power of 2.  If it is not defined or negative, the current setting is not changed.%%
    # `<i>opts</i>' specifies options by bitwise or: `TokyoCabinet::HDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, `TokyoCabinet::HDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, `TokyoCabinet::HDB::TBZIP' specifies that each record is compressed with BZIP2 encoding, `TokyoCabinet::HDB::TTCBS' specifies that each record is compressed with TCBS encoding.  If it is not defined or 0xff, the current setting is not changed.%%
    # If successful, the return value is true, else, it is false.%%
    # This method is useful to reduce the size of the database file with data fragmentation by successive updating.%%
    def optimize(bnum, apow, fpow, opts)
      # (native code)
    end
    # Remove all records.%%
    # If successful, the return value is true, else, it is false.%%
    def vanish()
      # (native code)
    end
    # Copy the database file.%%
    # `<i>path</i>' specifies the path of the destination file.  If it begins with `@', the trailing substring is executed as a command line.%%
    # If successful, the return value is true, else, it is false.  False is returned if the executed command returns non-zero code.%%
    # The database file is assured to be kept synchronized and not modified while the copying or executing operation is in progress.  So, this method is useful to create a backup file of the database file.%%
    def copy(path)
      # (native code)
    end
    # Begin the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # The database is locked by the thread while the transaction so that only one transaction can be activated with a database object at the same time.  Thus, the serializable isolation level is assumed if every database operation is performed in the transaction.  All updated regions are kept track of by write ahead logging while the transaction.  If the database is closed during transaction, the transaction is aborted implicitly.%%
    def tranbegin()
      # (native code)
    end
    # Commit the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # Update in the transaction is fixed when it is committed successfully.%%
    def trancommit()
      # (native code)
    end
    # Abort the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # Update in the transaction is discarded when it is aborted.  The state of the database is rollbacked to before transaction.%%
    def tranabort()
      # (native code)
    end
    # Get the path of the database file.%%
    # The return value is the path of the database file or `nil' if the object does not connect to any database file.%%
    def path()
      # (native code)
    end
    # Get the number of records.%%
    # The return value is the number of records or 0 if the object does not connect to any database file.%%
    def rnum()
      # (native code)
    end
    # Get the size of the database file.%%
    # The return value is the size of the database file or 0 if the object does not connect to any database file.%%
    def fsiz()
      # (native code)
    end
  end
  # B+ tree database is a file containing a B+ tree and is handled with the B+ tree database API.  Before operations to store or retrieve records, it is necessary to open a database file and connect the B+ tree database object to it.  To avoid data missing or corruption, it is important to close every database file when it is no longer in use.%%
  # Except for the interface below, methods compatible with the `Hash' class are also provided; `[]', `[]=', `store', `delete', `fetch', `has_key?', `has_value?', `key', `clear', `size', `empty?', `each', `each_key', `each_value', and `keys'.%%
  class BDB
    # error code: success
    ESUCCESS = 0
    # error code: threading error
    ETHREAD = 1
    # error code: invalid operation
    EINVALID = 2
    # error code: file not found
    ENOFILE = 3
    # error code: no permission
    ENOPERM = 4
    # error code: invalid meta data
    EMETA = 5
    # error code: invalid record header
    ERHEAD = 6
    # error code: open error
    EOPEN = 7
    # error code: close error
    ECLOSE = 8
    # error code: trunc error
    ETRUNC = 9
    # error code: sync error
    ESYNC = 10
    # error code: stat error
    ESTAT = 11
    # error code: seek error
    ESEEK = 12
    # error code: read error
    EREAD = 13
    # error code: write error
    EWRITE = 14
    # error code: mmap error
    EMMAP = 15
    # error code: lock error
    ELOCK = 16
    # error code: unlink error
    EUNLINK = 17
    # error code: rename error
    ERENAME = 18
    # error code: mkdir error
    EMKDIR = 19
    # error code: rmdir error
    ERMDIR = 20
    # error code: existing record
    EKEEP = 21
    # error code: no record found
    ENOREC = 22
    # error code: miscellaneous error
    EMISC = 9999
    # comparison function: by lexical order
    CMPLEXICAL = "CMPLEXICAL"
    # comparison function: as decimal strings of real numbers
    CMPDECIMAL = "CMPDECIMAL"
    # comparison function: as 32-bit integers in the native byte order
    CMPINT32 = "CMPINT32"
    # comparison function: as 64-bit integers in the native byte order
    CMPINT64 = "CMPINT64"
    # tuning option: use 64-bit bucket array
    TLARGE = 1 << 0
    # tuning option: compress each record with Deflate
    TDEFLATE = 1 << 1
    # tuning option: compress each record with BZIP2
    TBZIP = 1 << 2
    # tuning option: compress each record with TCBS
    TTCBS = 1 << 3
    # open mode: open as a reader
    OREADER = 1 << 0
    # open mode: open as a writer
    OWRITER = 1 << 1
    # open mode: writer creating
    OCREAT = 1 << 2
    # open mode: writer truncating
    OTRUNC = 1 << 3
    # open mode: open without locking
    ONOLCK = 1 << 4
    # open mode: lock without blocking
    OLCKNB = 1 << 5
    # open mode: synchronize every transaction
    OTSYNC = 1 << 6
    # Create a B+ tree database object.%%
    # The return value is the new B+ tree database object.%%
    def initialize()
      # (native code)
    end
    # Get the message string corresponding to an error code.%%
    # `<i>ecode</i>' specifies the error code.  If it is not defined or negative, the last happened error code is specified.%%
    # The return value is the message string of the error code.%%
    def errmsg(ecode)
      # (native code)
    end
    # Get the last happened error code.%%
    # The return value is the last happened error code.%%
    # The following error codes are defined: `TokyoCabinet::BDB::ESUCCESS' for success, `TokyoCabinet::BDB::ETHREAD' for threading error, `TokyoCabinet::BDB::EINVALID' for invalid operation, `TokyoCabinet::BDB::ENOFILE' for file not found, `TokyoCabinet::BDB::ENOPERM' for no permission, `TokyoCabinet::BDB::EMETA' for invalid meta data, `TokyoCabinet::BDB::ERHEAD' for invalid record header, `TokyoCabinet::BDB::EOPEN' for open error, `TokyoCabinet::BDB::ECLOSE' for close error, `TokyoCabinet::BDB::ETRUNC' for trunc error, `TokyoCabinet::BDB::ESYNC' for sync error, `TokyoCabinet::BDB::ESTAT' for stat error, `TokyoCabinet::BDB::ESEEK' for seek error, `TokyoCabinet::BDB::EREAD' for read error, `TokyoCabinet::BDB::EWRITE' for write error, `TokyoCabinet::BDB::EMMAP' for mmap error, `TokyoCabinet::BDB::ELOCK' for lock error, `TokyoCabinet::BDB::EUNLINK' for unlink error, `TokyoCabinet::BDB::ERENAME' for rename error, `TokyoCabinet::BDB::EMKDIR' for mkdir error, `TokyoCabinet::BDB::ERMDIR' for rmdir error, `TokyoCabinet::BDB::EKEEP' for existing record, `TokyoCabinet::BDB::ENOREC' for no record found, and `TokyoCabinet::BDB::EMISC' for miscellaneous error.%%
    def ecode()
      # (native code)
    end
    # Set the custom comparison function.%%
    # `<i>cmp</i>' specifies the custom comparison function.  It should be an instance of the class `Proc'.%%
    # If successful, the return value is true, else, it is false.%%
    # The default comparison function compares keys of two records by lexical order.  The constants `TokyoCabinet::BDB::CMPLEXICAL' (dafault), `TokyoCabinet::BDB::CMPDECIMAL', `TokyoCabinet::BDB::CMPINT32', and `TokyoCabinet::BDB::CMPINT64' are built-in.  Note that the comparison function should be set before the database is opened.  Moreover, user-defined comparison functions should be set every time the database is being opened.%%
    def setcmpfunc(cmp)
      # (native code)
    end
    # Set the tuning parameters.%%
    # `<i>lmemb</i>' specifies the number of members in each leaf page.  If it is not defined or not more than 0, the default value is specified.  The default value is 128.%%
    # `<i>nmemb</i>' specifies the number of members in each non-leaf page.  If it is not defined or not more than 0, the default value is specified.  The default value is 256.%%
    # `<i>bnum</i>' specifies the number of elements of the bucket array.  If it is not defined or not more than 0, the default value is specified.  The default value is 32749.  Suggested size of the bucket array is about from 1 to 4 times of the number of all pages to be stored.%%
    # `<i>apow</i>' specifies the size of record alignment by power of 2.  If it is not defined or negative, the default value is specified.  The default value is 4 standing for 2^8=256.%%
    # `<i>fpow</i>' specifies the maximum number of elements of the free block pool by power of 2.  If it is not defined or negative, the default value is specified.  The default value is 10 standing for 2^10=1024.%%
    # `<i>opts</i>' specifies options by bitwise or: `TokyoCabinet::BDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, `TokyoCabinet::BDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, `TokyoCabinet::BDB::TBZIP' specifies that each record is compressed with BZIP2 encoding, `TokyoCabinet::BDB::TTCBS' specifies that each record is compressed with TCBS encoding.  If it is not defined, no option is specified.%%
    # If successful, the return value is true, else, it is false.  Note that the tuning parameters of the database should be set before the database is opened.%%
    def tune(lmemb, nmemb, bnum, apow, fpow, opts)
      # (native code)
    end
    # Set the caching parameters.%%
    # `<i>lcnum</i>' specifies the maximum number of leaf nodes to be cached.  If it is not defined or not more than 0, the default value is specified.  The default value is 1024.%%
    # `<i>ncnum</i>' specifies the maximum number of non-leaf nodes to be cached.  If it is not defined or not more than 0, the default value is specified.  The default value is 512.%%
    # If successful, the return value is true, else, it is false.%%
    # Note that the tuning parameters of the database should be set before the database is opened.%%
    def setcache(lcnum, ncnum)
      # (native code)
    end
    # Set the size of the extra mapped memory.%%
    # `<i>xmsiz</i>' specifies the size of the extra mapped memory.  If it is not defined or not more than 0, the extra mapped memory is disabled.  It is disabled by default.%%
    # If successful, the return value is true, else, it is false.%%
    # Note that the mapping parameters should be set before the database is opened.%%
    def setxmsiz(xmsiz)
      # (native code)
    end
    # Open a database file.%%
    # `<i>path</i>' specifies the path of the database file.%%
    # `<i>omode</i>' specifies the connection mode: `TokyoCabinet::BDB::OWRITER' as a writer, `TokyoCabinet::BDB::OREADER' as a reader.  If the mode is `TokyoCabinet::BDB::OWRITER', the following may be added by bitwise or: `TokyoCabinet::BDB::OCREAT', which means it creates a new database if not exist, `TokyoCabinet::BDB::OTRUNC', which means it creates a new database regardless if one exists, `TokyoCabinet::BDB::OTSYNC', which means every transaction synchronizes updated contents with the device.  Both of `TokyoCabinet::BDB::OREADER' and `TokyoCabinet::BDB::OWRITER' can be added to by bitwise or: `TokyoCabinet::BDB::ONOLCK', which means it opens the database file without file locking, or `TokyoCabinet::BDB::OLCKNB', which means locking is performed without blocking.  If it is not defined, `TokyoCabinet::BDB::OREADER' is specified.%%
    # If successful, the return value is true, else, it is false.%%
    def open(path, omode)
      # (native code)
    end
    # Close the database file.%%
    # If successful, the return value is true, else, it is false.%%
    # Update of a database is assured to be written when the database is closed.  If a writer opens a database but does not close it appropriately, the database will be broken.%%
    def close()
      # (native code)
    end
    # Store a record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, it is overwritten.%%
    def put(key, value)
      # (native code)
    end
    # Store a new record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, this method has no effect.%%
    def putkeep(key, value)
      # (native code)
    end
    # Concatenate a value at the end of the existing record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If there is no corresponding record, a new record is created.%%
    def putcat(key, value)
      # (native code)
    end
    # Store a record with allowing duplication of keys.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, the new record is placed after the existing one.%%
    def putdup(key, value)
      # (native code)
    end
    # Store records with allowing duplication of keys.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>values</i>' specifies an array of the values.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, the new records are placed after the existing one.%%
    def putlist(key, values)
      # (native code)
    end
    # Remove a record.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is true, else, it is false.%%
    # If the key of duplicated records is specified, the value of the first one is selected.%%
    def out(key)
      # (native code)
    end
    # Remove records.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is true, else, it is false.%%
    # If the key of duplicated records is specified, all of them are removed.%%
    def outlist(key)
      # (native code)
    end
    # Retrieve a record.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is the value of the corresponding record.  `nil' is returned if no record corresponds.%%
    # If the key of duplicated records is specified, the value of the first one is selected.%%
    def get(key)
      # (native code)
    end
    # Retrieve records.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is a list object of the values of the corresponding records.  `nil' is returned if no record corresponds.%%
    def getlist(key)
      # (native code)
    end
    # Get the number of records corresponding a key.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is the number of the corresponding records, else, it is 0.%%
    def vnum(key)
      # (native code)
    end
    # Get the size of the value of a record.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is the size of the value of the corresponding record, else, it is -1.%%
    # If the key of duplicated records is specified, the value of the first one is selected.%%
    def vsiz(key)
      # (native code)
    end
    # Get keys of ranged records.%%
    # `<i>bkey</i>' specifies the key of the beginning border.  If it is not defined, the first record is specified.%%
    # `<i>binc</i>' specifies whether the beginning border is inclusive or not.  If it is not defined, false is specified.%%
    # `<i>ekey</i>' specifies the key of the ending border.  If it is not defined, the last record is specified.%%
    # `<i>einc</i>' specifies whether the ending border is inclusive or not.  If it is not defined, false is specified.%%
    # `<i>max</i>' specifies the maximum number of keys to be fetched.  If it is not defined or negative, no limit is specified.%%
    # The return value is a list object of the keys of the corresponding records.  This method does never fail and return an empty list even if no record corresponds.%%
    def range(bkey, binc, ekey, einc, max)
      # (native code)
    end
    # Get forward matching keys.%%
    # `<i>prefix</i>' specifies the prefix of the corresponding keys.%%
    # `<i>max</i>' specifies the maximum number of keys to be fetched.  If it is not defined or negative, no limit is specified.%%
    # The return value is a list object of the keys of the corresponding records.  This method does never fail and return an empty list even if no record corresponds.%%
    def fwmkeys(prefix, max)
      # (native code)
    end
    # Add an integer to a record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>num</i>' specifies the additional value.%%
    # If successful, the return value is the summation value, else, it is `nil'.%%
    # If the corresponding record exists, the value is treated as an integer and is added to.  If no record corresponds, a new record of the additional value is stored.  Because records are stored in binary format, they should be processed with the `unpack' method with the `i' operator after retrieval.%%
    def addint(key, num)
      # (native code)
    end
    # Add a real number to a record.%%
    # `<i>key</i>' specifies the key.%%
    # `<i>num</i>' specifies the additional value.%%
    # If successful, the return value is the summation value, else, it is `nil'.%%
    # If the corresponding record exists, the value is treated as a real number and is added to.  If no record corresponds, a new record of the additional value is stored.  Because records are stored in binary format, they should be processed with the `unpack' method with the `d' operator after retrieval.%%
    def adddouble(key, num)
      # (native code)
    end
    # Synchronize updated contents with the file and the device.%%
    # If successful, the return value is true, else, it is false.%%
    # This method is useful when another process connects the same database file.%%
    def sync()
      # (native code)
    end
    # Optimize the database file.%%
    # `<i>lmemb</i>' specifies the number of members in each leaf page.  If it is not defined or not more than 0, the default value is specified.  The default value is 128.%%
    # `<i>nmemb</i>' specifies the number of members in each non-leaf page.  If it is not defined or not more than 0, the default value is specified.  The default value is 256.%%
    # `<i>bnum</i>' specifies the number of elements of the bucket array.  If it is not defined or not more than 0, the default value is specified.  The default value is two times of the number of pages.%%
    # `<i>apow</i>' specifies the size of record alignment by power of 2.  If it is not defined or negative, the current setting is not changed.%%
    # `<i>fpow</i>' specifies the maximum number of elements of the free block pool by power of 2.  If it is not defined or negative, the current setting is not changed.%%
    # `<i>opts</i>' specifies options by bitwise or: `TokyoCabinet::BDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, `TokyoCabinet::BDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, `TokyoCabinet::BDB::TBZIP' specifies that each record is compressed with BZIP2 encoding, `TokyoCabinet::BDB::TTCBS' specifies that each record is compressed with TCBS encoding.  If it is not defined or 0xff, the current setting is not changed.%%
    # If successful, the return value is true, else, it is false.%%
    # This method is useful to reduce the size of the database file with data fragmentation by successive updating.%%
    def optimize(lmemb, nmemb, bnum, apow, fpow, opts)
      # (native code)
    end
    # Remove all records.%%
    # If successful, the return value is true, else, it is false.%%
    def vanish()
      # (native code)
    end
    # Copy the database file.%%
    # `<i>path</i>' specifies the path of the destination file.  If it begins with `@', the trailing substring is executed as a command line.%%
    # If successful, the return value is true, else, it is false.  False is returned if the executed command returns non-zero code.%%
    # The database file is assured to be kept synchronized and not modified while the copying or executing operation is in progress.  So, this method is useful to create a backup file of the database file.%%
    def copy(path)
      # (native code)
    end
    # Begin the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # The database is locked by the thread while the transaction so that only one transaction can be activated with a database object at the same time.  Thus, the serializable isolation level is assumed if every database operation is performed in the transaction.  Because all pages are cached on memory while the transaction, the amount of referred records is limited by the memory capacity.  If the database is closed during transaction, the transaction is aborted implicitly.%%
    def tranbegin()
      # (native code)
    end
    # Commit the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # Update in the transaction is fixed when it is committed successfully.%%
    def trancommit()
      # (native code)
    end
    # Abort the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # Update in the transaction is discarded when it is aborted.  The state of the database is rollbacked to before transaction.%%
    def tranabort()
      # (native code)
    end
    # Get the path of the database file.%%
    # The return value is the path of the database file or `nil' if the object does not connect to any database file.%%
    def path()
      # (native code)
    end
    # Get the number of records.%%
    # The return value is the number of records or 0 if the object does not connect to any database file.%%
    def rnum()
      # (native code)
    end
    # Get the size of the database file.%%
    # The return value is the size of the database file or 0 if the object does not connect to any database file.%%
    def fsiz()
      # (native code)
    end
  end
  # Cursor is a mechanism to access each record of B+ tree database in ascending or descending order.%%
  class BDBCUR
    # cursor put mode: current
    CPCURRENT = 0
    # cursor put mode: before
    CPBEFORE = 1
    # cursor put mode: after
    CPAFTER = 2
    # Create a cursor object.%%
    # `<i>bdb</i>' specifies the B+ tree database object.%%
    # The return value is the new cursor object.%%
    # Note that the cursor is available only after initialization with the `first' or the `jump' methods and so on.  Moreover, the position of the cursor will be indefinite when the database is updated after the initialization of the cursor.%%
    def initialize(bdb)
      # (native code)
    end
    # Move the cursor to the first record.%%
    # If successful, the return value is true, else, it is false.  False is returned if there is no record in the database.%%
    def first()
      # (native code)
    end
    # Move the cursor to the last record.%%
    # If successful, the return value is true, else, it is false.  False is returned if there is no record in the database.%%
    def last()
      # (native code)
    end
    # Move the cursor to the front of records corresponding a key.%%
    # `<i>key</i>' specifies the key.%%
    # If successful, the return value is true, else, it is false.  False is returned if there is no record corresponding the condition.%%
    # The cursor is set to the first record corresponding the key or the next substitute if completely matching record does not exist.%%
    def jump(key)
      # (native code)
    end
    # Move the cursor to the previous record.%%
    # If successful, the return value is true, else, it is false.  False is returned if there is no previous record.%%
    def prev()
      # (native code)
    end
    # Move the cursor to the next record.%%
    # If successful, the return value is true, else, it is false.  False is returned if there is no next record.%%
    def next()
      # (native code)
    end
    # Insert a record around the cursor.%%
    # `<i>value</i>' specifies the value.%%
    # `<i>cpmode</i>' specifies detail adjustment: `TokyoCabinet::BDBCUR::CPCURRENT', which means that the value of the current record is overwritten, `TokyoCabinet::BDBCUR::CPBEFORE', which means that the new record is inserted before the current record, `TokyoCabinet::BDBCUR::CPAFTER', which means that the new record is inserted after the current record.%%
    # If successful, the return value is true, else, it is false.  False is returned when the cursor is at invalid position.%%
    # After insertion, the cursor is moved to the inserted record.%%
    def put(value, cpmode)
      # (native code)
    end
    # Remove the record where the cursor is.%%
    # If successful, the return value is true, else, it is false.  False is returned when the cursor is at invalid position.%%
    # After deletion, the cursor is moved to the next record if possible.%%
    def out()
      # (native code)
    end
    # Get the key of the record where the cursor is.%%
    # If successful, the return value is the key, else, it is `nil'.  'nil' is returned when the cursor is at invalid position.%%
    def key()
      # (native code)
    end
    # Get the value of the record where the cursor is.%%
    # If successful, the return value is the value, else, it is `nil'.  'nil' is returned when the cursor is at invalid position.%%
    def val()
      # (native code)
    end
  end
  # Fixed-Length database is a file containing a fixed-length table and is handled with the fixed-length database API.  Before operations to store or retrieve records, it is necessary to open a database file and connect the fixed-length database object to it.  To avoid data missing or corruption, it is important to close every database file when it is no longer in use.%%
  # Except for the interface below, methods compatible with the `Hash' class are also provided; `[]', `[]=', `store', `delete', `fetch', `has_key?', `has_value?', `key', `clear', `size', `empty?', `each', `each_key', `each_value', and `keys'.%%
  class FDB
    # error code: success
    ESUCCESS = 0
    # error code: threading error
    ETHREAD = 1
    # error code: invalid operation
    EINVALID = 2
    # error code: file not found
    ENOFILE = 3
    # error code: no permission
    ENOPERM = 4
    # error code: invalid meta data
    EMETA = 5
    # error code: invalid record header
    ERHEAD = 6
    # error code: open error
    EOPEN = 7
    # error code: close error
    ECLOSE = 8
    # error code: trunc error
    ETRUNC = 9
    # error code: sync error
    ESYNC = 10
    # error code: stat error
    ESTAT = 11
    # error code: seek error
    ESEEK = 12
    # error code: read error
    EREAD = 13
    # error code: write error
    EWRITE = 14
    # error code: mmap error
    EMMAP = 15
    # error code: lock error
    ELOCK = 16
    # error code: unlink error
    EUNLINK = 17
    # error code: rename error
    ERENAME = 18
    # error code: mkdir error
    EMKDIR = 19
    # error code: rmdir error
    ERMDIR = 20
    # error code: existing record
    EKEEP = 21
    # error code: no record found
    ENOREC = 22
    # error code: miscellaneous error
    EMISC = 9999
    # open mode: open as a reader
    OREADER = 1 << 0
    # open mode: open as a writer
    OWRITER = 1 << 1
    # open mode: writer creating
    OCREAT = 1 << 2
    # open mode: writer truncating
    OTRUNC = 1 << 3
    # open mode: open without locking
    ONOLCK = 1 << 4
    # open mode: lock without blocking
    OLCKNB = 1 << 5
    # Create a fixed-length database object.%%
    # The return value is the new fixed-length database object.%%
    def initialize()
      # (native code)
    end
    # Get the message string corresponding to an error code.%%
    # `<i>ecode</i>' specifies the error code.  If it is not defined or negative, the last happened error code is specified.%%
    # The return value is the message string of the error code.%%
    def errmsg(ecode)
      # (native code)
    end
    # Get the last happened error code.%%
    # The return value is the last happened error code.%%
    # The following error codes are defined: `TokyoCabinet::FDB::ESUCCESS' for success, `TokyoCabinet::FDB::ETHREAD' for threading error, `TokyoCabinet::FDB::EINVALID' for invalid operation, `TokyoCabinet::FDB::ENOFILE' for file not found, `TokyoCabinet::FDB::ENOPERM' for no permission, `TokyoCabinet::FDB::EMETA' for invalid meta data, `TokyoCabinet::FDB::ERHEAD' for invalid record header, `TokyoCabinet::FDB::EOPEN' for open error, `TokyoCabinet::FDB::ECLOSE' for close error, `TokyoCabinet::FDB::ETRUNC' for trunc error, `TokyoCabinet::FDB::ESYNC' for sync error, `TokyoCabinet::FDB::ESTAT' for stat error, `TokyoCabinet::FDB::ESEEK' for seek error, `TokyoCabinet::FDB::EREAD' for read error, `TokyoCabinet::FDB::EWRITE' for write error, `TokyoCabinet::FDB::EMMAP' for mmap error, `TokyoCabinet::FDB::ELOCK' for lock error, `TokyoCabinet::FDB::EUNLINK' for unlink error, `TokyoCabinet::FDB::ERENAME' for rename error, `TokyoCabinet::FDB::EMKDIR' for mkdir error, `TokyoCabinet::FDB::ERMDIR' for rmdir error, `TokyoCabinet::FDB::EKEEP' for existing record, `TokyoCabinet::FDB::ENOREC' for no record found, and `TokyoCabinet::FDB::EMISC' for miscellaneous error.%%
    def ecode()
      # (native code)
    end
    # Set the tuning parameters.%%
    # `<i>width</i>' specifies the width of the value of each record.  If it is not defined or not more than 0, the default value is specified.  The default value is 255.%%
    # `<i>limsiz</i>' specifies the limit size of the database file.  If it is not defined or not more than 0, the default value is specified.  The default value is 268435456.%%
    # If successful, the return value is true, else, it is false.  Note that the tuning parameters of the database should be set before the database is opened.%%
    def tune(bnum, width, limsiz)
      # (native code)
    end
    # Open a database file.%%
    # `<i>path</i>' specifies the path of the database file.%%
    # `<i>omode</i>' specifies the connection mode: `TokyoCabinet::FDB::OWRITER' as a writer, `TokyoCabinet::FDB::OREADER' as a reader.  If the mode is `TokyoCabinet::FDB::OWRITER', the following may be added by bitwise or: `TokyoCabinet::FDB::OCREAT', which means it creates a new database if not exist, `TokyoCabinet::FDB::OTRUNC', which means it creates a new database regardless if one exists.  Both of `TokyoCabinet::FDB::OREADER' and `TokyoCabinet::FDB::OWRITER' can be added to by bitwise or: `TokyoCabinet::FDB::ONOLCK', which means it opens the database file without file locking, or `TokyoCabinet::FDB::OLCKNB', which means locking is performed without blocking.  If it is not defined, `TokyoCabinet::FDB::OREADER' is specified.%%
    # If successful, the return value is true, else, it is false.%%
    def open(path, omode)
      # (native code)
    end
    # Close the database file.%%
    # If successful, the return value is true, else, it is false.%%
    # Update of a database is assured to be written when the database is closed.  If a writer opens a database but does not close it appropriately, the database will be broken.%%
    def close()
      # (native code)
    end
    # Store a record.%%
    # `<i>key</i>' specifies the key.  It should be more than 0.  If it is "min", the minimum ID number of existing records is specified.  If it is "prev", the number less by one than the minimum ID number of existing records is specified.  If it is "max", the maximum ID number of existing records is specified.  If it is "next", the number greater by one than the maximum ID number of existing records is specified.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, it is overwritten.%%
    def put(key, value)
      # (native code)
    end
    # Store a new record.%%
    # `<i>key</i>' specifies the key.  It should be more than 0.  If it is "min", the minimum ID number of existing records is specified.  If it is "prev", the number less by one than the minimum ID number of existing records is specified.  If it is "max", the maximum ID number of existing records is specified.  If it is "next", the number greater by one than the maximum ID number of existing records is specified.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, this method has no effect.%%
    def putkeep(key, value)
      # (native code)
    end
    # Concatenate a value at the end of the existing record.%%
    # `<i>key</i>' specifies the key.  It should be more than 0.  If it is "min", the minimum ID number of existing records is specified.  If it is "prev", the number less by one than the minimum ID number of existing records is specified.  If it is "max", the maximum ID number of existing records is specified.  If it is "next", the number greater by one than the maximum ID number of existing records is specified.%%
    # `<i>value</i>' specifies the value.%%
    # If successful, the return value is true, else, it is false.%%
    # If there is no corresponding record, a new record is created.%%
    def putcat(key, value)
      # (native code)
    end
    # Remove a record.%%
    # `<i>key</i>' specifies the key.  It should be more than 0.  If it is `FDBIDMIN', the minimum ID number of existing records is specified.  If it is `FDBIDMAX', the maximum ID number of existing records is specified.%%
    # If successful, the return value is true, else, it is false.%%
    def out(key)
      # (native code)
    end
    # Retrieve a record.%%
    # `<i>key</i>' specifies the key.  It should be more than 0.  If it is `FDBIDMIN', the minimum ID number of existing records is specified.  If it is `FDBIDMAX', the maximum ID number of existing records is specified.%%
    # If successful, the return value is the value of the corresponding record.  `nil' is returned if no record corresponds.%%
    def get(key)
      # (native code)
    end
    # Get the size of the value of a record.%%
    # `<i>key</i>' specifies the key.  It should be more than 0.  If it is `FDBIDMIN', the minimum ID number of existing records is specified.  If it is `FDBIDMAX', the maximum ID number of existing records is specified.%%
    # If successful, the return value is the size of the value of the corresponding record, else, it is -1.%%
    def vsiz(key)
      # (native code)
    end
    # Initialize the iterator.%%
    # If successful, the return value is true, else, it is false.%%
    # The iterator is used in order to access the key of every record stored in a database.%%
    def iterinit()
      # (native code)
    end
    # Get the next key of the iterator.%%
    # If successful, the return value is the next key, else, it is `nil'.  `nil' is returned when no record is to be get out of the iterator.%%
    # It is possible to access every record by iteration of calling this function.  It is allowed to update or remove records whose keys are fetched while the iteration.  The order of this traversal access method is ascending of the ID number.%%
    def iternext()
      # (native code)
    end
    # Get keys with an interval notation.%%
    # `<i>interval</i>' specifies the interval notation.%%
    # `<i>max</i>' specifies the maximum number of keys to be fetched.  If it is not defined or negative, no limit is specified.%%
    # The return value is a list object of the keys of the corresponding records.  This method does never fail and return an empty list even if no record corresponds.%%
    def range(interval, max)
      # (native code)
    end
    # Add an integer to a record.%%
    # `<i>key</i>' specifies the key.  It should be more than 0.  If it is "min", the minimum ID number of existing records is specified.  If it is "prev", the number less by one than the minimum ID number of existing records is specified.  If it is "max", the maximum ID number of existing records is specified.  If it is "next", the number greater by one than the maximum ID number of existing records is specified.%%
    # `<i>num</i>' specifies the additional value.%%
    # If successful, the return value is the summation value, else, it is `nil'.%%
    # If the corresponding record exists, the value is treated as an integer and is added to.  If no record corresponds, a new record of the additional value is stored.  Because records are stored in binary format, they should be processed with the `unpack' method with the `i' operator after retrieval.%%
    def addint(key, num)
      # (native code)
    end
    # Add a real number to a record.%%
    # `<i>key</i>' specifies the key.  It should be more than 0.  If it is "min", the minimum ID number of existing records is specified.  If it is "prev", the number less by one than the minimum ID number of existing records is specified.  If it is "max", the maximum ID number of existing records is specified.  If it is "next", the number greater by one than the maximum ID number of existing records is specified.%%
    # `<i>num</i>' specifies the additional value.%%
    # If successful, the return value is the summation value, else, it is `nil'.%%
    # If the corresponding record exists, the value is treated as a real number and is added to.  If no record corresponds, a new record of the additional value is stored.  Because records are stored in binary format, they should be processed with the `unpack' method with the `d' operator after retrieval.%%
    def adddouble(key, num)
      # (native code)
    end
    # Synchronize updated contents with the file and the device.%%
    # If successful, the return value is true, else, it is false.%%
    # This method is useful when another process connects the same database file.%%
    def sync()
      # (native code)
    end
    # Optimize the database file.%%
    # `width' specifies the width of the value of each record.  If it is not defined or not more than 0, the current setting is not changed.%%
    # `limsiz' specifies the limit size of the database file.  If it is not defined or not more than 0, the current setting is not changed.%%
    # If successful, the return value is true, else, it is false.%%
    def optimize(bnum, width, limsiz)
      # (native code)
    end
    # Remove all records.%%
    # If successful, the return value is true, else, it is false.%%
    def vanish()
      # (native code)
    end
    # Copy the database file.%%
    # `<i>path</i>' specifies the path of the destination file.  If it begins with `@', the trailing substring is executed as a command line.%%
    # If successful, the return value is true, else, it is false.  False is returned if the executed command returns non-zero code.%%
    # The database file is assured to be kept synchronized and not modified while the copying or executing operation is in progress.  So, this method is useful to create a backup file of the database file.%%
    def copy(path)
      # (native code)
    end
    # Get the path of the database file.%%
    # The return value is the path of the database file or `nil' if the object does not connect to any database file.%%
    def path()
      # (native code)
    end
    # Get the number of records.%%
    # The return value is the number of records or 0 if the object does not connect to any database file.%%
    def rnum()
      # (native code)
    end
    # Get the size of the database file.%%
    # The return value is the size of the database file or 0 if the object does not connect to any database file.%%
    def fsiz()
      # (native code)
    end
  end
  # Table database is a file containing records composed of the primary keys and arbitrary columns and is handled with the table database API.  Before operations to store or retrieve records, it is necessary to open a database file and connect the table database object to it.  To avoid data missing or corruption, it is important to close every database file when it is no longer in use.%%
  # Except for the interface below, methods compatible with the `Hash' class are also provided; `[]', `[]=', `store', `delete', `fetch', `has_key?', `clear', `size', `empty?', `each', `each_key', `each_value', and `keys'.%%
  class TDB
    # error code: success
    ESUCCESS = 0
    # error code: threading error
    ETHREAD = 1
    # error code: invalid operation
    EINVALID = 2
    # error code: file not found
    ENOFILE = 3
    # error code: no permission
    ENOPERM = 4
    # error code: invalid meta data
    EMETA = 5
    # error code: invalid record header
    ERHEAD = 6
    # error code: open error
    EOPEN = 7
    # error code: close error
    ECLOSE = 8
    # error code: trunc error
    ETRUNC = 9
    # error code: sync error
    ESYNC = 10
    # error code: stat error
    ESTAT = 11
    # error code: seek error
    ESEEK = 12
    # error code: read error
    EREAD = 13
    # error code: write error
    EWRITE = 14
    # error code: mmap error
    EMMAP = 15
    # error code: lock error
    ELOCK = 16
    # error code: unlink error
    EUNLINK = 17
    # error code: rename error
    ERENAME = 18
    # error code: mkdir error
    EMKDIR = 19
    # error code: rmdir error
    ERMDIR = 20
    # error code: existing record
    EKEEP = 21
    # error code: no record found
    ENOREC = 22
    # error code: miscellaneous error
    EMISC = 9999
    # tuning option: use 64-bit bucket array
    TLARGE = 1 << 0
    # tuning option: compress each record with Deflate
    TDEFLATE = 1 << 1
    # tuning option: compress each record with BZIP2
    TBZIP = 1 << 2
    # tuning option: compress each record with TCBS
    TTCBS = 1 << 3
    # open mode: open as a reader
    OREADER = 1 << 0
    # open mode: open as a writer
    OWRITER = 1 << 1
    # open mode: writer creating
    OCREAT = 1 << 2
    # open mode: writer truncating
    OTRUNC = 1 << 3
    # open mode: open without locking
    ONOLCK = 1 << 4
    # open mode: lock without blocking
    OLCKNB = 1 << 5
    # open mode: synchronize every transaction
    OTSYNC = 1 << 6
    # index type: lexical string
    ITLEXICAL = 0
    # index type: decimal string
    ITDECIMAL = 1
    # index type: void
    ITVOID = 9999
    # index type: keep existing index
    ITKEEP = 1 << 24
    # Create a table database object.%%
    # The return value is the new table database object.%%
    def initialize()
      # (native code)
    end
    # Get the message string corresponding to an error code.%%
    # `<i>ecode</i>' specifies the error code.  If it is not defined or negative, the last happened error code is specified.%%
    # The return value is the message string of the error code.%%
    def errmsg(ecode)
      # (native code)
    end
    # Get the last happened error code.%%
    # The return value is the last happened error code.%%
    # The following error codes are defined: `TokyoCabinet::TDB::ESUCCESS' for success, `TokyoCabinet::TDB::ETHREAD' for threading error, `TokyoCabinet::TDB::EINVALID' for invalid operation, `TokyoCabinet::TDB::ENOFILE' for file not found, `TokyoCabinet::TDB::ENOPERM' for no permission, `TokyoCabinet::TDB::EMETA' for invalid meta data, `TokyoCabinet::TDB::ERHEAD' for invalid record header, `TokyoCabinet::TDB::EOPEN' for open error, `TokyoCabinet::TDB::ECLOSE' for close error, `TokyoCabinet::TDB::ETRUNC' for trunc error, `TokyoCabinet::TDB::ESYNC' for sync error, `TokyoCabinet::TDB::ESTAT' for stat error, `TokyoCabinet::TDB::ESEEK' for seek error, `TokyoCabinet::TDB::EREAD' for read error, `TokyoCabinet::TDB::EWRITE' for write error, `TokyoCabinet::TDB::EMMAP' for mmap error, `TokyoCabinet::TDB::ELOCK' for lock error, `TokyoCabinet::TDB::EUNLINK' for unlink error, `TokyoCabinet::TDB::ERENAME' for rename error, `TokyoCabinet::TDB::EMKDIR' for mkdir error, `TokyoCabinet::TDB::ERMDIR' for rmdir error, `TokyoCabinet::TDB::EKEEP' for existing record, `TokyoCabinet::TDB::ENOREC' for no record found, and `TokyoCabinet::TDB::EMISC' for miscellaneous error.%%
    def ecode()
      # (native code)
    end
    # Set the tuning parameters.%%
    # `<i>bnum</i>' specifies the number of elements of the bucket array.  If it is not defined or not more than 0, the default value is specified.  The default value is 131071.  Suggested size of the bucket array is about from 0.5 to 4 times of the number of all records to be stored.%%
    # `<i>apow</i>' specifies the size of record alignment by power of 2.  If it is not defined or negative, the default value is specified.  The default value is 4 standing for 2^4=16.%%
    # `<i>fpow</i>' specifies the maximum number of elements of the free block pool by power of 2.  If it is not defined or negative, the default value is specified.  The default value is 10 standing for 2^10=1024.%%
    # `<i>opts</i>' specifies options by bitwise or: `TokyoCabinet::TDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, `TokyoCabinet::TDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, `TokyoCabinet::TDB::TDBZIP' specifies that each record is compressed with BZIP2 encoding, `TokyoCabinet::TDB::TTCBS' specifies that each record is compressed with TCBS encoding.  If it is not defined, no option is specified.%%
    # If successful, the return value is true, else, it is false.  Note that the tuning parameters of the database should be set before the database is opened.%%
    def tune(bnum, apow, fpow, opts)
      # (native code)
    end
    # Set the caching parameters.%%
    # `<i>rcnum</i>' specifies the maximum number of records to be cached.  If it is not defined or not more than 0, the record cache is disabled. It is disabled by default.%%
    # `<i>lcnum</i>' specifies the maximum number of leaf nodes to be cached.  If it is not defined or not more than 0, the default value is specified.  The default value is 2048.%%
    # `<i>ncnum</i>' specifies the maximum number of non-leaf nodes to be cached.  If it is not defined or not more than 0, the default value is specified.  The default value is 512.%%
    # If successful, the return value is true, else, it is false.%%
    # Note that the caching parameters of the database should be set before the database is opened.%%
    def setcache(rcnum, lcnum, ncnum)
      # (native code)
    end
    # Set the size of the extra mapped memory.%%
    # `<i>xmsiz</i>' specifies the size of the extra mapped memory.  If it is not defined or not more than 0, the extra mapped memory is disabled.  The default size is 67108864.%%
    # If successful, the return value is true, else, it is false.%%
    # Note that the mapping parameters should be set before the database is opened.%%
    def setxmsiz(xmsiz)
      # (native code)
    end
    # Open a database file.%%
    # `<i>path</i>' specifies the path of the database file.%%
    # `<i>omode</i>' specifies the connection mode: `TokyoCabinet::TDB::OWRITER' as a writer, `TokyoCabinet::TDB::OREADER' as a reader.  If the mode is `TokyoCabinet::TDB::OWRITER', the following may be added by bitwise or: `TokyoCabinet::TDB::OCREAT', which means it creates a new database if not exist, `TokyoCabinet::TDB::OTRUNC', which means it creates a new database regardless if one exists, `TokyoCabinet::TDB::OTSYNC', which means every transaction synchronizes updated contents with the device.  Both of `TokyoCabinet::TDB::OREADER' and `TokyoCabinet::TDB::OWRITER' can be added to by bitwise or: `TokyoCabinet::TDB::ONOLCK', which means it opens the database file without file locking, or `TokyoCabinet::TDB::OLCKNB', which means locking is performed without blocking.  If it is not defined, `TokyoCabinet::TDB::OREADER' is specified.%%
    # If successful, the return value is true, else, it is false.%%
    def open(path, omode)
      # (native code)
    end
    # Close the database file.%%
    # If successful, the return value is true, else, it is false.%%
    # Update of a database is assured to be written when the database is closed.  If a writer opens a database but does not close it appropriately, the database will be broken.%%
    def close()
      # (native code)
    end
    # Store a record.%%
    # `<i>pkey</i>' specifies the primary key.%%
    # `<i>cols</i>' specifies a hash containing columns.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, it is overwritten.%%
    def put(pkey, cols)
      # (native code)
    end
    # Store a new record.%%
    # `<i>pkey</i>' specifies the primary key.%%
    # `<i>cols</i>' specifies a hash containing columns.%%
    # If successful, the return value is true, else, it is false.%%
    # If a record with the same key exists in the database, this method has no effect.%%
    def putkeep(pkey, cols)
      # (native code)
    end
    # Concatenate columns of the existing record.%%
    # `<i>pkey</i>' specifies the primary key.%%
    # `<i>cols</i>' specifies a hash containing columns.%%
    # If successful, the return value is true, else, it is false.%%
    # If there is no corresponding record, a new record is created.%%
    def putcat(pkey, value)
      # (native code)
    end
    # Remove a record.%%
    # `<i>pkey</i>' specifies the primary key.%%
    # If successful, the return value is true, else, it is false.%%
    def out(pkey)
      # (native code)
    end
    # Retrieve a record.%%
    # `<i>pkey</i>' specifies the primary key.%%
    # If successful, the return value is a hash of the columns of the corresponding record.  `nil' is returned if no record corresponds.%%
    def get(pkey)
      # (native code)
    end
    # Get the size of the value of a record.%%
    # `<i>pkey</i>' specifies the primary key.%%
    # If successful, the return value is the size of the value of the corresponding record, else, it is -1.%%
    def vsiz(pkey)
      # (native code)
    end
    # Initialize the iterator.%%
    # If successful, the return value is true, else, it is false.%%
    # The iterator is used in order to access the primary key of every record stored in a database.%%
    def iterinit()
      # (native code)
    end
    # Get the next primary key of the iterator.%%
    # If successful, the return value is the next primary key, else, it is `nil'.  `nil' is returned when no record is to be get out of the iterator.%%
    # It is possible to access every record by iteration of calling this method.  It is allowed to update or remove records whose keys are fetched while the iteration.  However, it is not assured if updating the database is occurred while the iteration.  Besides, the order of this traversal access method is arbitrary, so it is not assured that the order of storing matches the one of the traversal access.%%
    def iternext()
      # (native code)
    end
    # Get forward matching primary keys.%%
    # `<i>prefix</i>' specifies the prefix of the corresponding keys.%%
    # `<i>max</i>' specifies the maximum number of keys to be fetched.  If it is not defined or negative, no limit is specified.%%
    # The return value is a list object of the keys of the corresponding records.  This method does never fail and return an empty list even if no record corresponds.%%
    # Note that this function may be very slow because every key in the database is scanned.%%
    def fwmkeys(prefix, max)
      # (native code)
    end
    # Add an integer to a record.%%
    # `<i>pkey</i>' specifies the primary key.%%
    # `<i>num</i>' specifies the additional value.%%
    # If successful, the return value is the summation value, else, it is `nil'.%%
    # If the corresponding record exists, the value is treated as an integer and is added to.  If no record corresponds, a new record of the additional value is stored.  Because records are stored in binary format, they should be processed with the `unpack' method with the `i' operator after retrieval.%%
    def addint(pkey, num)
      # (native code)
    end
    # Add a real number to a record.%%
    # `<i>key</i>' specifies the primary key.%%
    # `<i>num</i>' specifies the additional value.%%
    # If successful, the return value is the summation value, else, it is `nil'.%%
    # If the corresponding record exists, the value is treated as a real number and is added to.  If no record corresponds, a new record of the additional value is stored.  Because records are stored in binary format, they should be processed with the `unpack' method with the `d' operator after retrieval.%%
    def adddouble(pkey, num)
      # (native code)
    end
    # Synchronize updated contents with the file and the device.%%
    # If successful, the return value is true, else, it is false.%%
    # This method is useful when another process connects the same database file.%%
    def sync()
      # (native code)
    end
    # Optimize the database file.%%
    # `<i>bnum</i>' specifies the number of elements of the bucket array.  If it is not defined or not more than 0, the default value is specified.  The default value is two times of the number of records.%%
    # `<i>apow</i>' specifies the size of record alignment by power of 2.  If it is not defined or negative, the current setting is not changed.%%
    # `<i>fpow</i>' specifies the maximum number of elements of the free block pool by power of 2.  If it is not defined or negative, the current setting is not changed.%%
    # `<i>opts</i>' specifies options by bitwise or: `TokyoCabinet::TDB::TLARGE' specifies that the size of the database can be larger than 2GB by using 64-bit bucket array, `TokyoCabinet::TDB::TDEFLATE' specifies that each record is compressed with Deflate encoding, `TokyoCabinet::TDB::TBZIP' specifies that each record is compressed with BZIP2 encoding, `TokyoCabinet::TDB::TTCBS' specifies that each record is compressed with TCBS encoding.  If it is not defined or 0xff, the current setting is not changed.%%
    # If successful, the return value is true, else, it is false.%%
    # This method is useful to reduce the size of the database file with data fragmentation by successive updating.%%
    def optimize(bnum, apow, fpow, opts)
      # (native code)
    end
    # Remove all records.%%
    # If successful, the return value is true, else, it is false.%%
    def vanish()
      # (native code)
    end
    # Copy the database file.%%
    # `<i>path</i>' specifies the path of the destination file.  If it begins with `@', the trailing substring is executed as a command line.%%
    # If successful, the return value is true, else, it is false.  False is returned if the executed command returns non-zero code.%%
    # The database file is assured to be kept synchronized and not modified while the copying or executing operation is in progress.  So, this method is useful to create a backup file of the database file.%%
    def copy(path)
      # (native code)
    end
    # Begin the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # The database is locked by the thread while the transaction so that only one transaction can be activated with a database object at the same time.  Thus, the serializable isolation level is assumed if every database operation is performed in the transaction.  All updated regions are kept track of by write ahead logging while the transaction.  If the database is closed during transaction, the transaction is aborted implicitly.%%
    def tranbegin()
      # (native code)
    end
    # Commit the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # Update in the transaction is fixed when it is committed successfully.%%
    def trancommit()
      # (native code)
    end
    # Abort the transaction.%%
    # If successful, the return value is true, else, it is false.%%
    # Update in the transaction is discarded when it is aborted.  The state of the database is rollbacked to before transaction.%%
    def tranabort()
      # (native code)
    end
    # Get the path of the database file.%%
    # The return value is the path of the database file or `nil' if the object does not connect to any database file.%%
    def path()
      # (native code)
    end
    # Get the number of records.%%
    # The return value is the number of records or 0 if the object does not connect to any database file.%%
    def rnum()
      # (native code)
    end
    # Get the size of the database file.%%
    # The return value is the size of the database file or 0 if the object does not connect to any database file.%%
    def fsiz()
      # (native code)
    end
    # Set a column index.%%
    # `<i>name</i>' specifies the name of a column.  If the name of an existing index is specified, the index is rebuilt.  An empty string means the primary key.%%
    # `<i>type</i>' specifies the index type: `TokyoCabinet::TDB::ITLEXICAL' for lexical string, `TokyoCabinet::TDB::ITDECIMAL' for decimal string.  If it is `TokyoCabinet::TDB::ITVOID', the index is removed.  If `TokyoCabinet::TDB::ITKEEP' is added by bitwise or and the index exists, this method merely returns failure.%%
# If successful, the return value is true, else, it is false.%%
    def setindex(name, type)
      # (native code)
    end
    # Generate a unique ID number.%%
    # The return value is the new unique ID number or -1 on failure.%%
    def genuid()
      # (native code)
    end
  end
  # Query is a mechanism to search for and retrieve records corresponding conditions from table database.%%
  class TDBQRY
    # query condition: string is equal to
    QCSTREQ = 1
    # query condition: string is included in
    QCSTRINC = 2
    # query condition: string begins with
    QCSTRBW = 3
    # query condition: string ends with
    QCSTREW = 4
    # query condition: string includes all tokens in
    QCSTRAND = 5
    # query condition: string includes at least one token in
    QCSTROR = 6
    # query condition: string is equal to at least one token in
    QCSTROREQ = 7
    # query condition: string matches regular expressions of
    QCSTRRX = 8
    # query condition: number is equal to
    QCNUMEQ = 9
    # query condition: number is greater than
    QCNUMGT = 10
    # query condition: number is greater than or equal to
    QCNUMGE = 11
    # query condition: number is less than
    QCNUMLT = 12
    # query condition: number is less than or equal to
    QCNUMLE = 13
    # query condition: number is between two tokens of
    QCNUMBT = 14
    # query condition: number is equal to at least one token in
    QCNUMOREQ = 15
    # query condition: negation flag
    QCNEGATE = 1 << 24
    # query condition: no index flag
    QCNOIDX = 1 << 25
    # order type: string ascending
    QOSTRASC = 1
    # order type: string descending
    QOSTRDESC = 2
    # order type: number ascending
    QONUMASC = 3
    # order type: number descending
    QONUMDESC = 4
    # post treatment: modify the record
    QPPUT = 1 << 0
    # post treatment: remove the record
    QPOUT = 1 << 1
    # post treatment: stop the iteration
    QPSTOP = 1 << 24
    # Create a query object.%%
    # `<i>tdb</i>' specifies the table database object.%%
    # The return value is the new query object.%%
    def initialize(tdb)
      # (native code)
    end
    # Add a narrowing condition.%%
    # `<i>name</i>' specifies the name of a column.  An empty string means the primary key.%%
    # `<i>op</i>' specifies an operation type: `TokyoCabinet::TDBQRY::QCSTREQ' for string which is equal to the expression, `TokyoCabinet::TDBQRY::QCSTRINC' for string which is included in the expression, `TokyoCabinet::TDBQRY::QCSTRBW' for string which begins with the expression, `TokyoCabinet::TDBQRY::QCSTREW' for string which ends with the expression, `TokyoCabinet::TDBQRY::QCSTRAND' for string which includes all tokens in the expression, `TokyoCabinet::TDBQRY::QCSTROR' for string which includes at least one token in the expression, `TokyoCabinet::TDBQRY::QCSTROREQ' for string which is equal to at least one token in the expression, `TokyoCabinet::TDBQRY::QCSTRRX' for string which matches regular expressions of the expression, `TokyoCabinet::TDBQRY::QCNUMEQ' for number which is equal to the expression, `TokyoCabinet::TDBQRY::QCNUMGT' for number which is greater than the expression, `TokyoCabinet::TDBQRY::QCNUMGE' for number which is greater than or equal to the expression, `TokyoCabinet::TDBQRY::QCNUMLT' for number which is less than the expression, `TokyoCabinet::TDBQRY::QCNUMLE' for number which is less than or equal to the expression, `TokyoCabinet::TDBQRY::QCNUMBT' for number which is between two tokens of the expression, `TokyoCabinet::TDBQRY::QCNUMOREQ' for number which is equal to at least one token in the expression.  All operations can be flagged by bitwise or: `TokyoCabinet::TDBQRY::QCNEGATE' for negation, `TokyoCabinet::TDBQRY::QCNOIDX' for using no index.%%
    # `<i>expr</i>' specifies an operand exression.%%
    # The return value is always `nil'.%%
    def addcond(name, op, expr)
      # (native code)
    end
    # Set the order of the result.%%
    # `<i>name</i>' specifies the name of a column.  An empty string means the primary key.%%
    # `<i>type</i>' specifies the order type: `TokyoCabinet::TDBQRY::QOSTRASC' for string ascending, `TokyoCabinet::TDBQRY::QOSTRDESC' for string descending, `TokyoCabinet::TDBQRY::QONUMASC' for number ascending, `TokyoCabinet::TDBQRY::QONUMDESC' for number descending.%%
    # The return value is always `nil'.%%
    def setorder(name, type)
      # (native code)
    end
    # Set the maximum number of records of the result.%%
    # `<i>max</i>' specifies the maximum number of records of the result.%%
    # The return value is always `nil'.%%
    def setmax(max)
      # (native code)
    end
    # Execute the search.%%
    # The return value is an array of the primary keys of the corresponding records.  This method does never fail and return an empty array even if no record corresponds.%%
    def search()
      # (native code)
    end
    # Remove each corresponding record.%%
    # If successful, the return value is true, else, it is false.%%
    def searchout()
      # (native code)
    end
    # Process each corresponding record.%%
    # This function needs a block parameter of the iterator called for each record.  The block receives two parameters.  The first parameter is the primary key.  The second parameter is a hash containing columns.  It returns flags of the post treatment by bitwise or: `TokyoCabinet::TDBQRY::QPPUT' to modify the record, `TokyoCabinet::TDBQRY::QPOUT' to remove the record, `TokyoCabinet::TDBQRY::QPSTOP' to stop the iteration.%%
    # If successful, the return value is true, else, it is false.%%
    def proc()
      # (native code)
    end
    # Get the hint of a query object.%%
    # The return value is the hint string.%%
    def hint()
      # (native code)
    end
  end
end
