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
