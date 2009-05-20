require 'tokyocabinet'
include TokyoCabinet

# create the object
adb = ADB::new

# open the database
if !adb.open("casket.tch")
  STDERR.printf("open error\n")
end

# store records
if !adb.put("foo", "hop") ||
    !adb.put("bar", "step") ||
    !adb.put("baz", "jump")
  STDERR.printf("put error\n")
end

# retrieve records
value = adb.get("foo")
if value
  printf("%s\n", value)
else
  STDERR.printf("get error\n")
end

# traverse records
adb.iterinit
while key = adb.iternext
  value = adb.get(key)
  if value
    printf("%s:%s\n", key, value)
  end
end

# hash-like usage
adb["quux"] = "touchdown"
printf("%s\n", adb["quux"])
adb.each do |key, value|
  printf("%s:%s\n", key, value)
end

# close the database
if !adb.close
  STDERR.printf("close error\n")
end
