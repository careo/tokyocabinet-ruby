#! /usr/bin/ruby -w

#-------------------------------------------------------------------------------------------------
# The test cases of the B+ tree database API
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
  STDERR.printf("%s: test cases of the B+ tree database API\n", $progname)
  STDERR.printf("\n")
  STDERR.printf("usage:\n")
  STDERR.printf("  %s write [-tl] [-td|-tb|-tt] [-nl|-nb] path rnum" +
                " [lmemb [nmemb [bnum [apow [fpow]]]]]\n", $progname)
  STDERR.printf("  %s read [-nl|-nb] path\n", $progname)
  STDERR.printf("  %s remove [-nl|-nb] path\n", $progname)
  STDERR.printf("  %s misc [-tl] [-td|-tb|-tt] [-nl|-nb] path rnum\n", $progname)
  STDERR.printf("\n")
  exit(1)
end


# print error message of B+ tree database
def eprint(bdb, func)
  path = bdb.path
  STDERR.printf("%s: %s: %s: %s\n", $progname, path ? path : "-", func, bdb.errmsg)
end


# parse arguments of write command
def runwrite
  path = nil
  rnum = nil
  lmemb = nil
  nmemb = nil
  bnum = nil
  apow = nil
  fpow = nil
  opts = 0
  omode = 0
  i = 1
  while i < ARGV.length
    if !path && ARGV[i] =~ /^-/
      if ARGV[i] == "-tl"
        opts |= BDB::TLARGE
      elsif ARGV[i] == "-td"
        opts |= BDB::TDEFLATE
      elsif ARGV[i] == "-tb"
        opts |= BDB::TBZIP
      elsif ARGV[i] == "-tt"
        opts |= BDB::TTCBS
      elsif ARGV[i] == "-nl"
        omode |= BDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= BDB::OLCKNB
      else
        usage
      end
    elsif !path
      path = ARGV[i]
    elsif !rnum
      rnum = ARGV[i].to_i
    elsif !lmemb
      lmemb = ARGV[i].to_i
    elsif !nmemb
      nmemb = ARGV[i].to_i
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
  lmemb = lmemb ? lmemb : -1
  nmemb = nmemb ? nmemb : -1
  bnum = bnum ? bnum : -1
  apow = apow ? apow : -1
  fpow = fpow ? fpow : -1
  rv = procwrite(path, rnum, lmemb, nmemb, bnum, apow, fpow, opts, omode)
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
        omode |= BDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= BDB::OLCKNB
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
        omode |= BDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= BDB::OLCKNB
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
        opts |= BDB::TLARGE
      elsif ARGV[i] == "-td"
        opts |= BDB::TDEFLATE
      elsif ARGV[i] == "-tb"
        opts |= BDB::TBZIP
      elsif ARGV[i] == "-tt"
        opts |= BDB::TTCBS
      elsif ARGV[i] == "-nl"
        omode |= BDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= BDB::OLCKNB
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
def procwrite(path, rnum, lmemb, nmemb, bnum, apow, fpow, opts, omode)
  printf("<Writing Test>\n  path=%s  rnum=%d  lmemb=%d  nmemb=%d  bnum=%d  apow=%d  fpow=%d" +
         "  opts=%d  omode=%d\n\n",
         path, rnum, lmemb, nmemb, bnum, apow, fpow, opts, omode)
  err = false
  stime = Time.now
  bdb = BDB::new
  if !bdb.tune(lmemb, nmemb, bnum, apow, fpow, opts)
    eprint(bdb, "tune")
    err = true
  end
  if !bdb.open(path, BDB::OWRITER | BDB::OCREAT | BDB::OTRUNC | omode)
    eprint(bdb, "open")
    err = true
  end
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !bdb.put(buf, buf)
      eprint(bdb, "put")
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
  printf("record number: %d\n", bdb.rnum)
  printf("size: %d\n", bdb.fsiz)
  if !bdb.close
    eprint(bdb, "close")
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
  bdb = BDB::new
  if !bdb.open(path, BDB::OREADER | omode)
    eprint(bdb, "open")
    err = true
  end
  rnum = bdb.rnum
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !bdb.get(buf)
      eprint(bdb, "get")
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
  printf("record number: %d\n", bdb.rnum)
  printf("size: %d\n", bdb.fsiz)
  if !bdb.close
    eprint(bdb, "close")
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
  bdb = BDB::new
  if !bdb.open(path, BDB::OWRITER | omode)
    eprint(bdb, "open")
    err = true
  end
  rnum = bdb.rnum
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !bdb.out(buf)
      eprint(bdb, "out")
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
  printf("record number: %d\n", bdb.rnum)
  printf("size: %d\n", bdb.fsiz)
  if !bdb.close
    eprint(bdb, "close")
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
  bdb = BDB::new
  if !bdb.tune(10, 10, rnum / 50, 2, -1, opts)
    eprint(bdb, "tune")
    err = true
  end
  if !bdb.setcache(128, 256)
    eprint(bdb, "setcache")
    err = true
  end
  if !bdb.open(path, BDB::OWRITER | BDB::OCREAT | BDB::OTRUNC | omode)
    eprint(bdb, "open")
    err = true
  end
  printf("writing:\n")
  for i in 1..rnum
    buf = sprintf("%08d", i)
    if !bdb.put(buf, buf)
      eprint(bdb, "put")
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
    if !bdb.get(buf)
      eprint(bdb, "get")
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
    if rand(2) == 0 && !bdb.out(buf)
      eprint(bdb, "out")
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
  printf("checking cursor:\n")
  cur = BDBCUR::new(bdb)
  if !cur.first && bdb.ecode != BDB::ENOREC
    eprint(bdb, "cur::first")
    err = true
  end
  inum = 0
  while key = cur.key
    value = cur.val
    if !value
      eprint(bdb, "cur::val")
      err = true
    end
    cur.next
    if inum > 0 && rnum > 250 && inum % (rnum / 250) == 0
      print('.')
      if inum == rnum || inum % (rnum / 10) == 0
        printf(" (%08d)\n", inum)
      end
    end
    inum += 1
  end
  printf(" (%08d)\n", inum) if rnum > 250
  if bdb.ecode != BDB::ENOREC || inum != bdb.rnum
    eprint(bdb, "(validation)")
    err = true
  end
  keys = bdb.fwmkeys("0", 10)
  if bdb.rnum >= 10 && keys.size != 10
    eprint(bdb, "fwmkeys")
    err = true
  end
  printf("checking counting:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum))
    if rand(2) == 0
      if !bdb.addint(buf, 1) && bdb.ecode != BDB::EKEEP
        eprint(bdb, "addint")
        err = true
        break
      end
    else
      if !bdb.adddouble(buf, 1) && bdb.ecode != BDB::EKEEP
        eprint(bdb, "adddouble")
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
  if !bdb.sync
    eprint(bdb, "sync")
    err = true
  end
  if !bdb.optimize
    eprint(bdb, "optimize")
    err = true
  end
  npath = path + "-tmp"
  if !bdb.copy(npath)
    eprint(bdb, "copy")
    err = true
  end
  File::unlink(npath)
  if !bdb.vanish
    eprint(bdb, "vanish")
    err = true
  end
  printf("random writing:\n")
  for i in 1..rnum
    buf = sprintf("%08d", rand(i))
    if !bdb.putdup(buf, buf)
      eprint(bdb, "putdup")
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
  printf("cursor updating:\n")
  for i in 1..rnum
    if rand(10) == 0
      buf = sprintf("%08d", rand(rnum))
      cur.jump(buf)
      for j in 1..10
        key = cur.key
        break if !key
        if rand(3) == 0
          cur.out
        else
          cpmode = BDBCUR::CPCURRENT + rand(3)
          cur.put(buf, cpmode)
        end
        cur.next
        j += 1
      end
    end
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  if !bdb.tranbegin
    eprint(bdb, "tranbegin")
    err = true
  end
  bdb.putdup("::1", "1")
  bdb.putdup("::2", "2a")
  bdb.putdup("::2", "2b")
  bdb.putdup("::3", "3")
  cur.jump("::2")
  cur.put("2A")
  cur.put("2-", BDBCUR::CPBEFORE)
  cur.put("2+")
  cur.next
  cur.next
  cur.put("mid", BDBCUR::CPBEFORE)
  cur.put("2C", BDBCUR::CPAFTER)
  cur.prev
  cur.out
  vals = bdb.getlist("::2")
  if !vals || vals.size != 4
    eprint(bdb, "getlist")
    err = true
  end
  pvals = [ "hop", "step", "jump" ]
  if !bdb.putlist("::1", pvals)
    eprint(bdb, "putlist")
    err = true
  end
  if !bdb.outlist("::1")
    eprint(bdb, "outlist")
    err = true
  end
  if !bdb.trancommit
    eprint(bdb, "trancommit")
    err = true
  end
  if !bdb.tranbegin || !bdb.tranabort
    eprint(bdb, "tranbegin")
    err = true
  end
  printf("checking hash-like updating:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum))
    rnd = rand(4)
    if rnd == 0
      bdb[buf] = buf + "hoge"
    elsif rnd == 1
      value = bdb[buf]
    elsif rnd == 2
      res = bdb.key?(buf)
    elsif rnd == 3
      bdb.delete(buf)
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
  bdb.each do |tkey, tvalue|
    if inum > 0 && rnum > 250 && inum % (rnum / 250) == 0
      print('.')
      if inum == rnum || inum % (rnum / 10) == 0
        printf(" (%08d)\n", inum)
      end
    end
    inum += 1
  end
  printf(" (%08d)\n", inum) if rnum > 250
  bdb.clear
  printf("record number: %d\n", bdb.rnum)
  printf("size: %d\n", bdb.fsiz)
  if !bdb.close
    eprint(bdb, "close")
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
