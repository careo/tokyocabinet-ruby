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
qry.setlimit(10)
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
