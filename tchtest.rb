#! /usr/bin/ruby -w

#-------------------------------------------------------------------------------------------------
# The test cases of the hash database API
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
  STDERR.printf("%s: test cases of the hash database API\n", $progname)
  STDERR.printf("\n")
  STDERR.printf("usage:\n")
  STDERR.printf("  %s write [-tl] [-td|-tb|-tt] [-nl|-nb] [-as] path rnum" +
                " [bnum [apow [fpow]]]\n", $progname)
  STDERR.printf("  %s read [-nl|-nb] path\n", $progname)
  STDERR.printf("  %s remove [-nl|-nb] path\n", $progname)
  STDERR.printf("  %s misc [-tl] [-td|-tb|-tt] [-nl|-nb] path rnum\n", $progname)
  STDERR.printf("\n")
  exit(1)
end


# print error message of hash database
def eprint(hdb, func)
  path = hdb.path
  STDERR.printf("%s: %s: %s: %s\n", $progname, path ? path : "-", func, hdb.errmsg)
end


# parse arguments of write command
def runwrite
  path = nil
  rnum = nil
  bnum = nil
  apow = nil
  fpow = nil
  opts = 0
  omode = 0
  as = false
  i = 1
  while i < ARGV.length
    if !path && ARGV[i] =~ /^-/
      if ARGV[i] == "-tl"
        opts |= HDB::TLARGE
      elsif ARGV[i] == "-td"
        opts |= HDB::TDEFLATE
      elsif ARGV[i] == "-tb"
        opts |= HDB::TBZIP
      elsif ARGV[i] == "-tt"
        opts |= HDB::TTCBS
      elsif ARGV[i] == "-nl"
        omode |= HDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= HDB::OLCKNB
      elsif ARGV[i] == "-as"
        as = true
      else
        usage
      end
    elsif !path
      path = ARGV[i]
    elsif !rnum
      rnum = ARGV[i].to_i
    elsif !bnum
      bnum = ARGV[i].to_i
    elsif !apow
      apow = ARGV[i].to_i
    elsif !fpow
      fpow = ARGV[i].to_i
    else
      usage
    end
    i += 1
  end
  usage if !path || !rnum || rnum < 1
  bnum = bnum ? bnum : -1
  apow = apow ? apow : -1
  fpow = fpow ? fpow : -1
  rv = procwrite(path, rnum, bnum, apow, fpow, opts, omode, as)
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
        omode |= HDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= HDB::OLCKNB
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
        omode |= HDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= HDB::OLCKNB
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
  opts = 0
  omode = 0
  i = 1
  while i < ARGV.length
    if !path && ARGV[i] =~ /^-/
      if ARGV[i] == "-tl"
        opts |= HDB::TLARGE
      elsif ARGV[i] == "-td"
        opts |= HDB::TDEFLATE
      elsif ARGV[i] == "-tb"
        opts |= HDB::TBZIP
      elsif ARGV[i] == "-tt"
        opts |= HDB::TTCBS
      elsif ARGV[i] == "-nl"
        omode |= HDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= HDB::OLCKNB
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
  rv = procmisc(path, rnum, opts, omode)
  return rv
end


# perform write command
def procwrite(path, rnum, bnum, apow, fpow, opts, omode, as)
  printf("<Writing Test>\n  path=%s  rnum=%d  bnum=%d  apow=%d  fpow=%d  opts=%d" +
         "  omode=%d  as=%s\n\n", path, rnum, bnum, apow, fpow, opts, omode, as)
  err = false
  stime = Time.now
  hdb = HDB::new
  if !hdb.tune(bnum, apow, fpow, opts)
    eprint(hdb, "tune")
    err = true
  end
  if !hdb.open(path, HDB::OWRITER | HDB::OCREAT | HDB::OTRUNC | omode)
    eprint(hdb, "open")
    err = true
  end
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if as
      if !hdb.putasync(buf, buf)
        eprint(hdb, "putasync")
        err = true
        break
      end
    else
      if !hdb.put(buf, buf)
        eprint(hdb, "put")
        err = true
        break
      end
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf("record number: %d\n", hdb.rnum)
  printf("size: %d\n", hdb.fsiz)
  if !hdb.close
    eprint(hdb, "close")
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
  hdb = HDB::new
  if !hdb.open(path, HDB::OREADER | omode)
    eprint(hdb, "open")
    err = true
  end
  rnum = hdb.rnum
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !hdb.get(buf)
      eprint(hdb, "get")
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
  printf("record number: %d\n", hdb.rnum)
  printf("size: %d\n", hdb.fsiz)
  if !hdb.close
    eprint(hdb, "close")
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
  hdb = HDB::new
  if !hdb.open(path, HDB::OWRITER | omode)
    eprint(hdb, "open")
    err = true
  end
  rnum = hdb.rnum
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !hdb.out(buf)
      eprint(hdb, "out")
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
  printf("record number: %d\n", hdb.rnum)
  printf("size: %d\n", hdb.fsiz)
  if !hdb.close
    eprint(hdb, "close")
    err = true
  end
  printf("time: %.3f\n", Time.now - stime)
  printf("%s\n\n", err ? "error" : "ok")
  return err ? 1 : 0
end


# perform misc command
def procmisc(path, rnum, opts, omode)
  printf("<Miscellaneous Test>\n  path=%s  rnum=%d  opts=%d  omode=%d\n\n",
         path, rnum, opts, omode)
  err = false
  stime = Time.now
  hdb = HDB::new
  if !hdb.tune(rnum / 50, 2, -1, opts)
    eprint(hdb, "tune")
    err = true
  end
  if !hdb.open(path, HDB::OWRITER | HDB::OCREAT | HDB::OTRUNC | omode)
    eprint(hdb, "open")
    err = true
  end
  printf("writing:\n")
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !hdb.put(buf, buf)
      eprint(hdb, "put")
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
    if !hdb.get(buf)
      eprint(hdb, "get")
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
    if rand(2) == 0 && !hdb.out(buf)
      eprint(hdb, "out")
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
  if !hdb.iterinit
    eprint(hdb, "iterinit")
    err = true
  end
  inum = 0
  while key = hdb.iternext
    value = hdb.get(key)
    if !value
      eprint(hdb, "get")
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
  if hdb.ecode != HDB::ENOREC || inum != hdb.rnum
    eprint(hdb, "(validation)")
    err = true
  end
  keys = hdb.fwmkeys("0", 10)
  if hdb.rnum >= 10 && keys.size != 10
    eprint(hdb, "fwmkeys")
    err = true
  end
  printf("checking counting:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum))
    if rand(2) == 0
      if !hdb.addint(buf, 1) && hdb.ecode != HDB::EKEEP
        eprint(hdb, "addint")
        err = true
        break
      end
    else
      if !hdb.adddouble(buf, 1) && hdb.ecode != HDB::EKEEP
        eprint(hdb, "adddouble")
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
  if !hdb.sync
    eprint(hdb, "sync")
    err = true
  end
  if !hdb.optimize
    eprint(hdb, "optimize")
    err = true
  end
  npath = path + "-tmp"
  if !hdb.copy(npath)
    eprint(hdb, "copy")
    err = true
  end
  File::unlink(npath)
  if !hdb.vanish
    eprint(hdb, "vanish")
    err = true
  end
  printf("checking transaction commit:\n")
  if !hdb.tranbegin
    eprint(hdb, "tranbegin")
    err = true
  end
  for i in 1..rnum
    buf = sprintf("%d", rand(rnum))
    if rand(2) == 0
      if !hdb.putcat(buf, buf)
        eprint(hdb, "putcat")
        err = true
        break
      end
    else
      if !hdb.out(buf) && hdb.ecode != HDB::ENOREC
        eprint(hdb, "out")
        err = true
        break
      end
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  if !hdb.trancommit
    eprint(hdb, "trancommit")
    err = true
  end
  printf("checking transaction abort:\n")
  ornum = hdb.rnum
  ofsiz = hdb.fsiz
  if !hdb.tranbegin
    eprint(hdb, "tranbegin")
    err = true
  end
  for i in 1..rnum
    buf = sprintf("%d", rand(rnum))
    if rand(2) == 0
      if !hdb.putcat(buf, buf)
        eprint(hdb, "putcat")
        err = true
        break
      end
    else
      if !hdb.out(buf) && hdb.ecode != HDB::ENOREC
        eprint(hdb, "out")
        err = true
        break
      end
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  if !hdb.tranabort
    eprint(hdb, "trancommit")
    err = true
  end
  if hdb.rnum != ornum || hdb.fsiz != ofsiz
    eprint(hdb, "(validation)")
    err = true
  end
  printf("checking hash-like updating:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum))
    rnd = rand(4)
    if rnd == 0
      hdb[buf] = buf
    elsif rnd == 1
      value = hdb[buf]
    elsif rnd == 2
      res = hdb.key?(buf)
    elsif rnd == 3
      hdb.delete(buf)
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
  hdb.each do |tkey, tvalue|
    if inum > 0 && rnum > 250 && inum % (rnum / 250) == 0
      print('.')
      if inum == rnum || inum % (rnum / 10) == 0
        printf(" (%08d)\n", inum)
      end
    end
    inum += 1
  end
  printf(" (%08d)\n", inum) if rnum > 250
  hdb.clear
  printf("record number: %d\n", hdb.rnum)
  printf("size: %d\n", hdb.fsiz)
  if !hdb.close
    eprint(hdb, "close")
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
