#!/bin/bash
git rm -r contrib
cp  ../centos7.rh-mysql56/run-mysqld* .
cp -r ../centos7.rh-mysql56/contrib contrib
grep -r mysql56 . | cut -d':' -f1 | while read f ; do sed -i -e 's/rh-mysql56/rh-mariadb100/g' $f ; done

