#!/bin/bash

source debian/vars.sh

set -x

# NOTE: absolutely none of the configuration and install make clauses work
# as in nothing is configurable on Ubuntu

cat <<EOF > mod_maxminddb.conf
### Load the module
LoadModule maxminddb_module modules/mod_maxminddb.so

EOF

install -Dp -m0755 src/.libs/mod_maxminddb.so $DEB_INSTALL_ROOT/etc/apache2/modules/mod_maxminddb.so
install -Dp -m0644 mod_maxminddb.conf $DEB_INSTALL_ROOT/etc/apache2/conf.d/mod_maxminddb.conf

