#! /bin/sh

LANG=C
LC_ALL=C
PATH="$PATH:/usr/local/bin:$HOME/bin:.:.."
export LANG LC_ALL PATH

if [ -f Makefile ]
then
  make distclean
fi

rm -rf casket casket* *~ *.tmp *.gem hoge moge

name="${PWD##*/}"
cd ..
if [ -d "$name" ]
then
  tar zcvf "$name.tar.gz" "$name"
fi
