#! /usr/bin/ruby -w

#-------------------------------------------------------------------------------------------------
# The test cases of the table database API
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
  STDERR.printf("%s: test cases of the table database API\n", $progname)
  STDERR.printf("\n")
  STDERR.printf("usage:\n")
  STDERR.printf("  %s write [-tl] [-td|-tb|-tt] [-ip|-is|-in|-it|-if] [-nl|-nb] path rnum" +
                " [bnum [apow [fpow]]]\n", $progname)
  STDERR.printf("  %s read [-nl|-nb] path\n", $progname)
  STDERR.printf("  %s remove [-nl|-nb] path\n", $progname)
  STDERR.printf("  %s misc [-tl] [-td|-tb|-tt] [-nl|-nb] path rnum\n", $progname)
  STDERR.printf("\n")
  exit(1)
end


# print error message of table database
def eprint(tdb, func)
  path = tdb.path
  STDERR.printf("%s: %s: %s: %s\n", $progname, path ? path : "-", func, tdb.errmsg)
end


# parse arguments of write command
def runwrite
  path = nil
  rnum = nil
  bnum = nil
  apow = nil
  fpow = nil
  opts = 0
  iflags = 0
  omode = 0
  i = 1
  while i < ARGV.length
    if !path && ARGV[i] =~ /^-/
      if ARGV[i] == "-tl"
        opts |= TDB::TLARGE
      elsif ARGV[i] == "-td"
        opts |= TDB::TDEFLATE
      elsif ARGV[i] == "-tb"
        opts |= TDB::TBZIP
      elsif ARGV[i] == "-tt"
        opts |= TDB::TTCBS
      elsif ARGV[i] == "-ip"
        iflags |= 1 << 0
      elsif ARGV[i] == "-is"
        iflags |= 1 << 1
      elsif ARGV[i] == "-in"
        iflags |= 1 << 2
      elsif ARGV[i] == "-it"
        iflags |= 1 << 3
      elsif ARGV[i] == "-if"
        iflags |= 1 << 4
      elsif ARGV[i] == "-nl"
        omode |= TDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= TDB::OLCKNB
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
  rv = procwrite(path, rnum, bnum, apow, fpow, opts, iflags, omode)
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
        omode |= TDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= TDB::OLCKNB
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
        omode |= TDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= TDB::OLCKNB
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
        opts |= TDB::TLARGE
      elsif ARGV[i] == "-td"
        opts |= TDB::TDEFLATE
      elsif ARGV[i] == "-tb"
        opts |= TDB::TBZIP
      elsif ARGV[i] == "-tt"
        opts |= TDB::TTCBS
      elsif ARGV[i] == "-nl"
        omode |= TDB::ONOLCK
      elsif ARGV[i] == "-nb"
        omode |= TDB::OLCKNB
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
def procwrite(path, rnum, bnum, apow, fpow, opts, iflags, omode)
  printf("<Writing Test>\n  path=%s  rnum=%d  bnum=%d  apow=%d  fpow=%d  opts=%d  iflags=%d" +
         "  omode=%d\n\n", path, rnum, bnum, apow, fpow, opts, iflags, omode)
  err = false
  stime = Time.now
  tdb = TDB::new
  if !tdb.tune(bnum, apow, fpow, opts)
    eprint(tdb, "tune")
    err = true
  end
  if !tdb.open(path, TDB::OWRITER | TDB::OCREAT | TDB::OTRUNC | omode)
    eprint(tdb, "open")
    err = true
  end
  if (iflags & (1 << 0)) != 0 && !tdb.setindex("", TDB::ITDECIMAL)
    eprint(tdb, "setindex")
    err = true
  end
  if (iflags & (1 << 1)) != 0 && !tdb.setindex("str", TDB::ITLEXICAL)
    eprint(tdb, "setindex")
    err = true
  end
  if (iflags & (1 << 2)) != 0 && !tdb.setindex("num", TDB::ITDECIMAL)
    eprint(tdb, "setindex")
    err = true
  end
  if (iflags & (1 << 3)) != 0 && !tdb.setindex("type", TDB::ITDECIMAL)
    eprint(tdb, "setindex")
    err = true
  end
  if (iflags & (1 << 4)) != 0 && !tdb.setindex("flag", TDB::ITLEXICAL)
    eprint(tdb, "setindex")
    err = true
  end
  for i in 1..rnum
    id = tdb.genuid
    cols = {
      "str" => id,
      "num" => rand(id) + 1,
      "type" => rand(32) + 1,
    }
    vbuf = ""
    num = rand(5)
    pt = 0
    for j in 1..num
      pt += rand(5) + 1
      vbuf += "," if vbuf.length > 0
      vbuf += pt.to_s
    end
    cols["flag"] = vbuf if vbuf.length > 0
    if !tdb.put(id, cols)
      eprint(tdb, "put")
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
  printf("record number: %d\n", tdb.rnum)
  printf("size: %d\n", tdb.fsiz)
  if !tdb.close
    eprint(tdb, "close")
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
  tdb = TDB::new
  if !tdb.open(path, TDB::OREADER | omode)
    eprint(tdb, "open")
    err = true
  end
  rnum = tdb.rnum
  for i in 1..rnum
    if !tdb.get(i)
      eprint(tdb, "get")
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
  printf("record number: %d\n", tdb.rnum)
  printf("size: %d\n", tdb.fsiz)
  if !tdb.close
    eprint(tdb, "close")
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
  tdb = TDB::new
  if !tdb.open(path, TDB::OWRITER | omode)
    eprint(tdb, "open")
    err = true
  end
  rnum = tdb.rnum
  for i in 1..rnum
    if !tdb.out(i)
      eprint(tdb, "out")
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
  printf("record number: %d\n", tdb.rnum)
  printf("size: %d\n", tdb.fsiz)
  if !tdb.close
    eprint(tdb, "close")
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
  tdb = TDB::new
  if !tdb.tune(rnum / 50, 2, -1, opts)
    eprint(tdb, "tune")
    err = true
  end
  if !tdb.open(path, TDB::OWRITER | TDB::OCREAT | TDB::OTRUNC | omode)
    eprint(tdb, "open")
    err = true
  end
  if !tdb.setindex("", TDB::ITDECIMAL)
    eprint(tdb, "setindex")
    err = true
  end
  if !tdb.setindex("str", TDB::ITLEXICAL)
    eprint(tdb, "setindex")
    err = true
  end
  if !tdb.setindex("num", TDB::ITDECIMAL)
    eprint(tdb, "setindex")
    err = true
  end
  printf("writing:\n")
  for i in 1..rnum
    id = tdb.genuid
    cols = {
      "str" => id,
      "num" => rand(id) + 1,
      "type" => rand(32) + 1,
    }
    vbuf = ""
    num = rand(5)
    pt = 0
    for j in 1..num
      pt += rand(5) + 1
      vbuf += "," if vbuf.length > 0
      vbuf += pt.to_s
    end
    cols["flag"] = vbuf if vbuf.length > 0
    if !tdb.put(id, cols)
      eprint(tdb, "put")
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
    if !tdb.get(i)
      eprint(tdb, "get")
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
    if rand(2) == 0 && !tdb.out(i)
      eprint(tdb, "out")
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
  if !tdb.iterinit
    eprint(tdb, "iterinit")
    err = true
  end
  inum = 0
  while pkey = tdb.iternext
    inum += 1
    if !tdb.get(pkey)
      eprint(tdb, "get")
      err = true
    end
    if rnum > 250 && inum % (rnum / 250) == 0
      print('.')
      if inum == rnum || inum % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  printf(" (%08d)\n", inum) if rnum > 250
  if tdb.ecode != TDB::ENOREC || inum != tdb.rnum
    eprint(tdb, "(validation)")
    err = true
  end
  keys = tdb.fwmkeys("1", 10)
  printf("checking counting:\n")
  for i in 1..rnum
    buf = sprintf("i:%d", rand(rnum))
    if rand(2) == 0
      if !tdb.addint(buf, 1)
        eprint(tdb, "addint")
        err = true
        break
      end
    else
      if !tdb.adddouble(buf, 1)
        eprint(tdb, "adddouble")
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
  if !tdb.sync
    eprint(tdb, "sync")
    err = true
  end
  if !tdb.optimize
    eprint(tdb, "optimize")
    err = true
  end
  npath = path + "-tmp"
  if !tdb.copy(npath)
    eprint(tdb, "copy")
    err = true
  end
  Dir.glob("#{npath}.idx.*").each do |tpath|
    File.unlink(tpath)
  end
  File.unlink(npath)
  printf("searching:\n")
  qry = TDBQRY::new(tdb)
  names = [ "", "str", "num", "type", "flag", "c1" ]
  ops = [ TDBQRY::QCSTREQ, TDBQRY::QCSTRINC, TDBQRY::QCSTRBW, TDBQRY::QCSTREW, TDBQRY::QCSTRAND,
          TDBQRY::QCSTROR, TDBQRY::QCSTROREQ, TDBQRY::QCSTRRX, TDBQRY::QCNUMEQ, TDBQRY::QCNUMGT,
          TDBQRY::QCNUMGE, TDBQRY::QCNUMLT, TDBQRY::QCNUMLE, TDBQRY::QCNUMBT, TDBQRY::QCNUMOREQ ]
  types = [ TDBQRY::QOSTRASC, TDBQRY::QOSTRDESC, TDBQRY::QONUMASC, TDBQRY::QONUMDESC ]
  for i in 1..rnum
    qry = TDBQRY::new(tdb) if rand(10) > 0
    cnum = rand(4)
    for j in 1..cnum
      name = names[rand(names.length)]
      op = ops[rand(ops.length)]
      op |= TDBQRY::QCNEGATE if rand(20) == 0
      op |= TDBQRY::QCNOIDX if rand(20) == 0
      expr = rand(i).to_s
      expr += "," + rand(i).to_s if rand(10) == 0
      expr += "," + rand(i).to_s if rand(10) == 0
      qry.addcond(name, op, expr)
    end
    if rand(3) != 0
      name = names[rand(names.length)]
      type = types[rand(types.length)]
      qry.setorder(name, type)
    end
    qry.setlimit(rand(i), rand(10)) if rand(3) != 0
    res = qry.search
    if rnum > 250 && i % (rnum / 250) == 0
      print('.')
      if i == rnum || i % (rnum / 10) == 0
        printf(" (%08d)\n", i)
      end
    end
  end
  qry = TDBQRY.new(tdb)
  qry.addcond("", TDBQRY::QCSTRBW, "i:")
  qry.setorder("_num", TDBQRY::QONUMDESC)
  ires = qry.search
  irnum = ires.length
  itnum = tdb.rnum
  icnt = 0
  rv = qry.proc do |pkey, cols|
    icnt += 1
    cols["icnt"] = icnt
    TDBQRY::QPPUT
  end
  if !rv
    eprint(tdb, "qry::proc")
    err = true
  end
  qry.addcond("icnt", TDBQRY::QCNUMGT, 0)
  if !qry.searchout
    eprint(tdb, "qry::searchout")
    err = true
  end
  if tdb.rnum != itnum - irnum
    eprint(tdb, "(validation)")
    err = true
  end
  if !tdb.vanish
    eprint(tdb, "vanish")
    err = true
  end
  printf("checking transaction commit:\n")
  if !tdb.tranbegin
    eprint(tdb, "tranbegin")
    err = true
  end
  for i in 1..rnum
    id = rand(rnum) + 1
    if rand(2) == 0
      if !tdb.addint(id, 1)
        eprint(tdb, "addint")
        err = true
        break
      end
    else
      if !tdb.out(id) && tdb.ecode != TDB::ENOREC
        eprint(tdb, "out")
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
  if !tdb.trancommit
    eprint(tdb, "trancommit")
    err = true
  end
  printf("checking transaction abort:\n")
  ornum = tdb.rnum
  ofsiz = tdb.fsiz
  if !tdb.tranbegin
    eprint(tdb, "tranbegin")
    err = true
  end
  for i in 1..rnum
    id = rand(rnum) + 1
    if rand(2) == 0
      if !tdb.addint(id, 1)
        eprint(tdb, "addint")
        err = true
        break
      end
    else
      if !tdb.out(id) && tdb.ecode != TDB::ENOREC
        eprint(tdb, "out")
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
  if !tdb.tranabort
    eprint(tdb, "tranabort")
    err = true
  end
  if tdb.rnum != ornum || tdb.fsiz != ofsiz
    eprint(tdb, "(validation)")
    err = true
  end
  printf("checking hash-like updating:\n")
  for i in 1..rnum
    buf = sprintf("[%d]", rand(rnum))
    rnd = rand(4)
    if rnd == 0
      cols = {
        "name" => buf,
        "num" => i,
      }
      tdb[buf] = cols
    elsif rnd == 1
      value = tdb[buf]
    elsif rnd == 2
      tdb.key?(buf)
    elsif rnd == 3
      tdb.delete(buf)
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
  tdb.each do |tkey, tvalue|
    if inum > 0 && rnum > 250 && inum % (rnum / 250) == 0
      print('.')
      if inum == rnum || inum % (rnum / 10) == 0
        printf(" (%08d)\n", inum)
      end
    end
    inum += 1
  end
  printf(" (%08d)\n", inum) if rnum > 250
  tdb.clear
  printf("record number: %d\n", tdb.rnum)
  printf("size: %d\n", tdb.fsiz)
  if !tdb.close
    eprint(tdb, "close")
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
