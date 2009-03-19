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
