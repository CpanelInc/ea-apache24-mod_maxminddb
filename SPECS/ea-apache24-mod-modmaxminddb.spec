%global ns_name ea-apache24
%global upstream_name mod_maxminddb
%global _httpd_apxs %{_root_bindir}/apxs

Name: %{ns_name}-%{upstream_name}
Version: 1.2.0
Summary: This module allows you to query MaxMind DB files from Apache 2.2+ using the libmaxminddb library.
# Doing release_prefix this way for Release allows for OBS-proof versioning, See EA-4556 for more details
%define release_prefix 1
Release: %{release_prefix}%{?dist}.cpanel
License: Apache License, Version 2.0
Group: System Environment/Daemons
Vendor: cPanel, Inc.
URL: https://github.com/maxmind/mod_maxminddb
Source: https://github.com/maxmind/mod_maxminddb/archive/1.2.0.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires: ea-apache24-devel
BuildRequires: ea-apr
BuildRequires: ea-apr-devel
BuildRequires: ea-apr-util
BuildRequires: ea-apr-util-devel

BuildRequires: libmaxminddb libmaxminddb-devel
Requires: libmaxminddb

Requires: ea-apache24

%description
A WSGI compliant interface for hosting Python based web applications on top of the Apache web server

%prep
%setup -q -n %{upstream_name}-%{version}

%build

# NOTE: mod_maxminddb is very uncooperative, none of the normal mod configs work
# I was able to get some of them to work on CentOS, but none working on Ubuntu

set -x

export PKG_CONFIG_PATH=/usr/share/pkgconfig:$PKG_CONFIG_PATH

./bootstrap
./configure --prefix=/etc/apache2 --exec-prefix=/etc
make

%install
set -x

echo `pwd`
ls -ld src/.libs/*

cat <<EOF > mod_maxminddb.conf
### Load the module
LoadModule maxminddb_module modules/mod_maxminddb.so

EOF

export prefix=/etc/apache2
export exec_prefix=/etc

# NOTE: I cannot use make install at all, the target location is not configurable

install -Dp -m0755 src/.libs/mod_maxminddb.so %{buildroot}/etc/apache2/modules/mod_maxminddb.so
install -Dp -m0644 mod_maxminddb.conf %{buildroot}/etc/apache2/conf.d/mod_maxminddb.conf

%clean
rm -rf %{buildroot}

%files
%attr(755,root,root) /etc/apache2/modules/mod_maxminddb.so
%config(noreplace) %{_sysconfdir}/apache2/conf.d/mod_maxminddb.conf

%changelog
* Fri Jul 26 2024 Julian Brown <julian.brown@cpanel.net> - 1.2.0-1
- ZC-4789: mod_maxminddb

