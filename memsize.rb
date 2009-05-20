#! /usr/bin/ruby

require 'tokyocabinet'
include TokyoCabinet

def memoryusage()
  status = `cat /proc/#{$$}/status`
  lines = status.split("\n")
  lines.each do |line|
    if line =~ /^VmRSS:/
      line.gsub!(/.*:\s*(\d+).*/, '\1')
      return line.to_i / 1024.0
    end
  end
  return -1;
end

rnum = 1000000;
if ARGV.length > 0
  rnum = ARGV[0].to_i
end

if ARGV.length > 1
  hash = ADB::new
  hash.open(ARGV[1]) || raise("open failed")
else
  hash = Hash.new
end

stime = Time.now
(0...rnum).each do |i|
  buf = sprintf("%08d", i)
  hash[buf] = buf
end
etime = Time.now

printf("Time: %.3f sec.\n", etime - stime)
printf("Usage: %.3f MB\n", memoryusage)
