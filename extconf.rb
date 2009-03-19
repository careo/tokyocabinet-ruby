require "mkmf"

dir_config('tokyocabinet')

home = ENV["HOME"]
ENV["PATH"] = ENV["PATH"] + ":/usr/local/bin:$home/bin:.:..:../.."
tccflags = `tcucodec conf -i 2>/dev/null`.chomp
tcldflags = `tcucodec conf -l 2>/dev/null`.chomp
tcldflags = tcldflags.gsub(/-l[\S]+/, "").strip
tclibs = `tcucodec conf -l 2>/dev/null`.chomp
tclibs = tclibs.gsub(/-L[\S]+/, "").strip

tccflags = "-I/usr/local/include" if(tccflags.length < 1)
tcldflags = "-L/usr/local/lib" if(tcldflags.length < 1)
tclibs = "-ltokyocabinet -lz -lbz2 -lpthread -lm -lc" if(tclibs.length < 1)

$CFLAGS = "-I. -I.. -I../.. #{tccflags} -Wall #{$CFLAGS} -O2"
$LDFLAGS = "#{$LDFLAGS} -L. -L.. -L../.. #{tcldflags}"
$libs = "#{$libs} #{tclibs}"

printf("setting variables ...\n")
printf("  \$CFLAGS = %s\n", $CFLAGS)
printf("  \$LDFLAGS = %s\n", $LDFLAGS)
printf("  \$libs = %s\n", $libs)

if have_header('tcutil.h')
  create_makefile('tokyocabinet')
end
