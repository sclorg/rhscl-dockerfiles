#!/bin/bash
git rm -r root test
cp  -r ../centos7.rh-mysql56/test .
cp  -r ../centos7.rh-mysql56/root .
grep -r mysql56 . | cut -d':' -f1 | while read f ; do sed -i -e 's/rh-mariadb100/rh-mariadb100/g' $f ; done
git add root test
