#! /usr/bin/ruby -w

#-------------------------------------------------------------------------------------------------
# The test cases of the abstract database API
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
  STDERR.printf("%s: test cases of the abstract database API\n", $progname)
  STDERR.printf("\n")
  STDERR.printf("usage:\n")
  STDERR.printf("  %s write name rnum\n", $progname)
  STDERR.printf("  %s read name\n", $progname)
  STDERR.printf("  %s remove name\n", $progname)
  STDERR.printf("  %s misc name rnum\n", $progname)
  STDERR.printf("\n")
  exit(1)
end


# print error message of abstract database
def eprint(adb, func)
  path = adb.path
  STDERR.printf("%s: %s: %s: error\n", $progname, path ? path : "-", func)
end


# parse arguments of write command
def runwrite
  name = nil
  rnum = nil
  i = 1
  while i < ARGV.length
    if !name && ARGV[i] =~ /^-/
      usage
    elsif !name
      name = ARGV[i]
    elsif !rnum
      rnum = ARGV[i].to_i
    else
      usage
    end
    i += 1
  end
  usage if !name || !rnum || rnum < 1
  rv = procwrite(name, rnum)
  return rv
end


# parse arguments of read command
def runread
  name = nil
  i = 1
  while i < ARGV.length
    if !name && ARGV[i] =~ /^-/
      usage
    elsif !name
      name = ARGV[i]
    else
      usage
    end
    i += 1
  end
  usage if !name
  rv = procread(name)
  return rv
end


# parse arguments of remove command
def runremove
  name = nil
  i = 1
  while i < ARGV.length
    if !name && ARGV[i] =~ /^-/
      usage
    elsif !name
      name = ARGV[i]
    else
      usage
    end
    i += 1
  end
  usage if !name
  rv = procremove(name)
  return rv
end


# parse arguments of misc command
def runmisc
  name = nil
  rnum = nil
  i = 1
  while i < ARGV.length
    if !name && ARGV[i] =~ /^-/
      usage
    elsif !name
      name = ARGV[i]
    elsif !rnum
      rnum = ARGV[i].to_i
    else
      usage
    end
    i += 1
  end
  usage if !name || !rnum || rnum < 1
  rv = procmisc(name, rnum)
  return rv
end


# perform write command
def procwrite(name, rnum)
  printf("<Writing Test>\n  name=%s  rnum=%d\n\n", name, rnum)
  err = false
  stime = Time.now
  adb = ADB::new
  if !adb.open(name)
    eprint(adb, "open")
    err = true
  end
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !adb.put(buf, buf)
      eprint(adb, "put")
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
  printf("record number: %d\n", adb.rnum)
  printf("size: %d\n", adb.size)
  if !adb.close
    eprint(adb, "close")
    err = true
  end
  printf("time: %.3f\n", Time.now - stime)
  printf("%s\n\n", err ? "error" : "ok")
  return err ? 1 : 0
end


# perform read command
def procread(name)
  printf("<Reading Test>\n  name=%s\n\n", name)
  err = false
  stime = Time.now
  adb = ADB::new
  if !adb.open(name)
    eprint(adb, "open")
    err = true
  end
  rnum = adb.rnum
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !adb.get(buf)
      eprint(adb, "get")
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
  printf("record number: %d\n", adb.rnum)
  printf("size: %d\n", adb.size)
  if !adb.close
    eprint(adb, "close")
    err = true
  end
  printf("time: %.3f\n", Time.now - stime)
  printf("%s\n\n", err ? "error" : "ok")
  return err ? 1 : 0
end


# perform remove command
def procremove(name)
  printf("<Removing Test>\n  name=%s\n\n", name)
  err = false
  stime = Time.now
  adb = ADB::new
  if !adb.open(name)
    eprint(adb, "open")
    err = true
  end
  rnum = adb.rnum
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !adb.out(buf)
      eprint(adb, "out")
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
  printf("record number: %d\n", adb.rnum)
  printf("size: %d\n", adb.size)
  if !adb.close
    eprint(adb, "close")
    err = true
  end
  printf("time: %.3f\n", Time.now - stime)
  printf("%s\n\n", err ? "error" : "ok")
  return err ? 1 : 0
end


# perform misc command
def procmisc(name, rnum)
  printf("<Miscellaneous Test>\n  name=%s  rnum=%d\n\n", name, rnum)
  err = false
  stime = Time.now
  adb = ADB::new
  if !adb.open(name)
    eprint(adb, "open")
    err = true
  end
  printf("writing:\n")
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !adb.put(buf, buf)
      eprint(adb, "put")
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
    if !adb.get(buf)
      eprint(adb, "get")
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
    if rand(2) == 0 && !adb.out(buf)
      eprint(adb, "out")
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
  if !adb.iterinit
    eprint(adb, "iterinit")
    err = true
  end
  inum = 0
  while key = adb.iternext
    value = adb.get(key)
    if !value
      eprint(adb, "get")
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
  if inum != adb.rnum
    eprint(adb, "(validation)")
    err = true
  end
  keys = adb.fwmkeys("0", 10)
  if adb.rnum >= 10 && keys.size != 10
    eprint(adb, "fwmkeys")
    err = true
  end
  printf("checking counting:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum))
    if rand(2) == 0
      adb.addint(buf, 1)
    else
      adb.adddouble(buf, 1)
    end
    if i > 0 && rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  if !adb.sync
    eprint(adb, "sync")
    err = true
  end
  if !adb.optimize
    eprint(adb, "optimize")
    err = true
  end
  npath = name + "-tmp"
  if !adb.copy(npath)
    eprint(adb, "copy")
    err = true
  end
  File::unlink(npath)
  if !adb.vanish
    eprint(adb, "vanish")
    err = true
  end
  printf("checking transaction commit:\n")
  if !adb.tranbegin
    eprint(adb, "tranbegin")
    err = true
  end
  for i in 1..rnum
    buf = sprintf("%d", rand(rnum))
    if rand(2) == 0
      if !adb.putcat(buf, buf)
        eprint(adb, "putcat")
        err = true
        break
      end
    else
      adb.out(buf)
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  if !adb.trancommit
    eprint(adb, "trancommit")
    err = true
  end
  printf("checking transaction abort:\n")
  ornum = adb.rnum
  osize = adb.size
  if !adb.tranbegin
    eprint(adb, "tranbegin")
    err = true
  end
  for i in 1..rnum
    buf = sprintf("%d", rand(rnum))
    if rand(2) == 0
      if !adb.putcat(buf, buf)
        eprint(adb, "putcat")
        err = true
        break
      end
    else
      adb.out(buf)
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  if !adb.tranabort
    eprint(adb, "trancommit")
    err = true
  end
  if adb.rnum != ornum || adb.size != osize
    eprint(adb, "(validation)")
    err = true
  end
  printf("checking hash-like updating:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum))
    rnd = rand(4)
    if rnd == 0
      adb[buf] = buf
    elsif rnd == 1
      value = adb[buf]
    elsif rnd == 2
      res = adb.key?(buf)
    elsif rnd == 3
      adb.delete(buf)
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
  adb.each do |tkey, tvalue|
    if inum > 0 && rnum > 250 && inum % (rnum / 250) == 0
      print('.')
      if inum == rnum || inum % (rnum / 10) == 0
        printf(" (%08d)\n", inum)
      end
    end
    inum += 1
  end
  printf(" (%08d)\n", inum) if rnum > 250
  adb.clear
  printf("record number: %d\n", adb.rnum)
  printf("size: %d\n", adb.size)
  if !adb.close
    eprint(adb, "close")
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
