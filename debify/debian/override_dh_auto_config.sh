#!/bin/bash

source debian/vars.sh

# NOTE: absolutely none of the configuration and install make clauses work
# as in nothing is configurable on Ubuntu

mkdir -p debian/tmp/etc/apache2/conf.d

cat <<EOF > debian/tmp/etc/apache2/conf.d/mod_maxminddb.conf
### Load the module
LoadModule maxminddb_module modules/mod_maxminddb.so
EOF

set -x

mkdir my_pkg_config
cd my_pkg_config
cp /usr/share/pkgconfig/ea-apr16-1.pc apr-1.pc
cp /usr/share/pkgconfig/ea-apr16-util-1.pc apr-util-1.pc
cd -

export MY_PKG_CONFIG=`pwd`/my_pkg_config
export PKG_CONFIG_PATH=/usr/share/pkgconfig:$MY_PKG_CONFIG:$PKG_CONFIG_PATH
ls -ld $MY_PKG_CONFIG/*
ls -ld /usr/share/pkgconfig/*

cd src

# I am not sure if the apxs call is necessary or not, but is included
/usr/bin/apxs -c -Wl,-Bsymbolic-functions -Wl,-z,relro -lmaxminddb  -Wc,"-g -O2 -ffile-prefix-map=/usr/src/packages/BUILD=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -std=c99 -fms-extensions"  mod_maxminddb.c

/opt/cpanel/ea-apr16/lib64/apr-1/build/libtool --silent --mode=compile gcc -prefer-pic -O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fstack-protector-strong -m64 -march=x86-64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection  -DLINUX -D_REENTRANT -D_GNU_SOURCE  -I/usr/include/apache2  -I/opt/cpanel/ea-apr16/include/apr-1   -I/opt/cpanel/ea-apr16/include/apr-1  -g -O2 -std=c99 -fms-extensions  -c -o mod_maxminddb.lo mod_maxminddb.c && touch mod_maxminddb.slo
/opt/cpanel/ea-apr16/lib64/apr-1/build/libtool --silent --mode=link gcc -Wl,-z,relro,-z,now   -o mod_maxminddb.la  -lmaxminddb -rpath /usr/lib64/apache2/modules -module -avoid-version    mod_maxminddb.lo

