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
