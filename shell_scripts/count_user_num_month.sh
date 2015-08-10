#!/bin/sh
last | cut -d ' ' -f 1 | sort | uniq | grep -v 'wtmp' | grep -v '^$' | grep '.' | tee /tmp/count.tmp | grep '.'
echo -e "total users: `cat /tmp/count.tmp | wc -l`"
rm -f /tmp/count.tmp
