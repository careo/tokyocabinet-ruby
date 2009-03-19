#! /bin/sh

LANG=C
LC_ALL=C
PATH="$PATH:/usr/local/bin:$HOME/bin:.:.."
export LANG LC_ALL PATH

rm -rf doc

rdoc --title "Tokyo Cabinet" -o doc tokyocabinet-doc.rb
find doc -type f -name '*.html' |
while read file
do
  fgrep -v '<a href="http://validator.w3.org/check/referer">[Validate]</a>' "$file" |
    sed -e "s/&#8217;/'/g" -e 's/%%/<br\/>/g' > tmp.html
  mv -f tmp.html "$file"
done
rm -f tmp.html
