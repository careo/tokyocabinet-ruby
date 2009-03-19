#! /usr/bin/ruby -w

#-------------------------------------------------------------------------------------------------
# The test cases of the fixed-length database API
#                                                       Copyright (C) 2006-2009 Mikio Hirabayashi
# This file is part of Tokyo Cabinet.
# Tokyo Cabinet is free software; you can redistribute it and/or modify it under the terms of
# the GNU Lesser General Public License as published by the Free Software Foundation; either
# version 2.1 of the License or any later version.  Tokyo Cabinet is distributed in the hope
# that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.
# You should have received a copy of the GNU Lesser General Public License along with Tokyo
# Cabinet; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA 02111-1307 USA.
#-------------------------------------------------------------------------------------------------


require 'tokyocabinet'
include TokyoCabinet


# main routine
def main
  ARGV.length >= 1 || usage
  if ARGV[0] == "write"
    rv = runwrite
  elsif ARGV[0] == "read"
    rv = runread
  elsif ARGV[0] == "remove"
    rv = runremove
  elsif ARGV[0] == "misc"
    rv = runmisc
  else
    usage
  end
  GC.start
  return rv
end


# print the usage and exit
def usage
  STDERR.printf("%s: test cases of the fixed-length database API\n", $progname)
  STDERR.printf("\n")
  STDERR.printf("usage:\n")
  STDERR.printf("  %s write [-nl|-nb] path rnum [width [limsiz]]\n", $progname)
  STDERR.printf("  %s read [-nl|-nb] path\n", $progname)
  STDERR.printf("  %s remove [-nl|-nb] path\n", $progname)
  STDERR.printf("  %s misc [-nl|-nb] path rnum\n", $progname)
  STDERR.printf("\n")
  exit(1)
end


# print error message of fixed-length database
def eprint(fdb, func)
  path = fdb.path
  STDERR.printf("%s: %s: %s: %s\n", $progname, path ? path : "-", func, fdb.errmsg)
end


# parse arguments of write command
def runwrite
  path = nil
  rnum = nil
  width = nil
  limsiz = nil
  omode = 0
  i = 1
  while i < ARGV.length
    if !path && ARGV[i] =~ /^-/
      if ARGV[i] == "-nl"
        omode |= FDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= FDB::OLCKNB
      else
        usage
      end
    elsif !path
      path = ARGV[i]
    elsif !rnum
      rnum = ARGV[i].to_i
    elsif !width
      width = ARGV[i].to_i
    elsif !limsiz
      limsiz = ARGV[i].to_i
    else
      usage
    end
    i += 1
  end
  usage if !path || !rnum || rnum < 1
  width = width ? width : -1
  limsiz = limsiz ? limsiz : -1
  rv = procwrite(path, rnum, width, limsiz, omode)
  return rv
end


# parse arguments of read command
def runread
  path = nil
  omode = 0
  i = 1
  while i < ARGV.length
    if !path && ARGV[i] =~ /^-/
      if ARGV[i] == "-nl"
        omode |= FDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= FDB::OLCKNB
      else
        usage
      end
    elsif !path
      path = ARGV[i]
    else
      usage
    end
    i += 1
  end
  usage if !path
  rv = procread(path, omode)
  return rv
end


# parse arguments of remove command
def runremove
  path = nil
  omode = 0
  i = 1
  while i < ARGV.length
    if !path && ARGV[i] =~ /^-/
      if ARGV[i] == "-nl"
        omode |= FDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= FDB::OLCKNB
      else
        usage
      end
    elsif !path
      path = ARGV[i]
    else
      usage
    end
    i += 1
  end
  usage if !path
  rv = procremove(path, omode)
  return rv
end


# parse arguments of misc command
def runmisc
  path = nil
  rnum = nil
  omode = 0
  i = 1
  while i < ARGV.length
    if !path && ARGV[i] =~ /^-/
      if ARGV[i] == "-nl"
        omode |= FDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= FDB::OLCKNB
      else
        usage
      end
    elsif !path
      path = ARGV[i]
    elsif !rnum
      rnum = ARGV[i].to_i
    else
      usage
    end
    i += 1
  end
  usage if !path || !rnum || rnum < 1
  rv = procmisc(path, rnum, omode)
  return rv
end


# perform write command
def procwrite(path, rnum, width, limsiz, omode)
  printf("<Writing Test>\n  path=%s  rnum=%d  width=%d  limsiz=%d  omode=%d\n\n",
         path, rnum, width, limsiz, omode)
  err = false
  stime = Time.now
  fdb = FDB::new
  if !fdb.tune(width, limsiz)
    eprint(fdb, "tune")
    err = true
  end
  if !fdb.open(path, FDB::OWRITER | FDB::OCREAT | FDB::OTRUNC | omode)
    eprint(fdb, "open")
    err = true
  end
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !fdb.put(buf, buf)
      eprint(fdb, "put")
      err = true
      break
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf("record number: %d\n", fdb.rnum)
  printf("size: %d\n", fdb.fsiz)
  if !fdb.close
    eprint(fdb, "close")
    err = true
  end
  printf("time: %.3f\n", Time.now - stime)
  printf("%s\n\n", err ? "error" : "ok")
  return err ? 1 : 0
end


# perform read command
def procread(path, omode)
  printf("<Reading Test>\n  path=%s  omode=%d\n\n", path, omode)
  err = false
  stime = Time.now
  fdb = FDB::new
  if !fdb.open(path, FDB::OREADER | omode)
    eprint(fdb, "open")
    err = true
  end
  rnum = fdb.rnum
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !fdb.get(buf)
      eprint(fdb, "get")
      err = true
      break
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf("record number: %d\n", fdb.rnum)
  printf("size: %d\n", fdb.fsiz)
  if !fdb.close
    eprint(fdb, "close")
    err = true
  end
  printf("time: %.3f\n", Time.now - stime)
  printf("%s\n\n", err ? "error" : "ok")
  return err ? 1 : 0
end


# perform remove command
def procremove(path, omode)
  printf("<Removing Test>\n  path=%s  omode=%d\n\n", path, omode)
  err = false
  stime = Time.now
  fdb = FDB::new
  if !fdb.open(path, FDB::OWRITER | omode)
    eprint(fdb, "open")
    err = true
  end
  rnum = fdb.rnum
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !fdb.out(buf)
      eprint(fdb, "out")
      err = true
      break
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf("record number: %d\n", fdb.rnum)
  printf("size: %d\n", fdb.fsiz)
  if !fdb.close
    eprint(fdb, "close")
    err = true
  end
  printf("time: %.3f\n", Time.now - stime)
  printf("%s\n\n", err ? "error" : "ok")
  return err ? 1 : 0
end


# perform misc command
def procmisc(path, rnum, omode)
  printf("<Miscellaneous Test>\n  path=%s  rnum=%d  omode=%d\n\n", path, rnum, omode)
  err = false
  stime = Time.now
  fdb = FDB::new
  if !fdb.tune(10, 1024 + 32 * rnum)
    eprint(fdb, "tune")
    err = true
  end
  if !fdb.open(path, FDB::OWRITER | FDB::OCREAT | FDB::OTRUNC | omode)
    eprint(fdb, "open")
    err = true
  end
  printf("writing:\n")
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !fdb.put(buf, buf)
      eprint(fdb, "put")
      err = true
      break
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf("reading:\n")
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !fdb.get(buf)
      eprint(fdb, "get")
      err = true
      break
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf("removing:\n")
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if rand(2) == 0 && !fdb.out(buf)
      eprint(fdb, "out")
      err = true
      break
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf("checking iterator:\n")
  if !fdb.iterinit
    eprint(fdb, "iterinit")
    err = true
  end
  inum = 0
  while key = fdb.iternext
    value = fdb.get(key)
    if !value
      eprint(fdb, "get")
      err = true
    end
    if inum > 0 && rnum > 250 && inum % (rnum / 250) == 0
      print('.')
      if inum == rnum || inum % (rnum / 10) == 0
        printf(" (%08d)\n", inum)
      end
    end
    inum += 1
  end
  printf(" (%08d)\n", inum) if rnum > 250
  if fdb.ecode != FDB::ENOREC || inum != fdb.rnum
    eprint(fdb, "(validation)")
    err = true
  end
  keys = fdb.range("[min,max]", 10)
  if fdb.rnum >= 10 && keys.size != 10
    eprint(fdb, "range")
    err = true
  end
  printf("checking counting:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum) + 1)
    if rand(2) == 0
      if !fdb.addint(buf, 1) && fdb.ecode != FDB::EKEEP
        eprint(fdb, "addint")
        err = true
        break
      end
    else
      if !fdb.adddouble(buf, 1) && fdb.ecode != FDB::EKEEP
        eprint(fdb, "adddouble")
        err = true
        break
      end
    end
    if i > 0 && rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  if !fdb.sync
    eprint(fdb, "sync")
    err = true
  end
  if !fdb.optimize
    eprint(fdb, "optimize")
    err = true
  end
  npath = path + "-tmp"
  if !fdb.copy(npath)
    eprint(fdb, "copy")
    err = true
  end
  File::unlink(npath)
  if !fdb.vanish
    eprint(fdb, "vanish")
    err = true
  end
  printf("checking hash-like updating:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum))
    rnd = rand(4)
    if rnd == 0
      fdb[buf] = buf
    elsif rnd == 1
      value = fdb[buf]
    elsif rnd == 2
      res = fdb.key?(buf)
    elsif rnd == 3
      fdb.delete(buf)
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf("checking hash-like iterator:\n")
  inum = 0
  fdb.each do |tkey, tvalue|
    if inum > 0 && rnum > 250 && inum % (rnum / 250) == 0
      print('.')
      if inum == rnum || inum % (rnum / 10) == 0
        printf(" (%08d)\n", inum)
      end
    end
    inum += 1
  end
  printf(" (%08d)\n", inum) if rnum > 250
  fdb.clear
  printf("record number: %d\n", fdb.rnum)
  printf("size: %d\n", fdb.fsiz)
  if !fdb.close
    eprint(fdb, "close")
    err = true
  end
  printf("time: %.3f\n", Time.now - stime)
  printf("%s\n\n", err ? "error" : "ok")
  return err ? 1 : 0
end


# execute main
STDOUT.sync = true
$progname = $0.dup
$progname.gsub!(/.*\//, "")
srand
exit(main)



# END OF FILE
