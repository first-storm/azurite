#!/bin/bash

set -ouex pipefail

dnf5 install -y rpm-build

topdir="$(mktemp -d)"
trap 'rm -rf "${topdir}"' EXIT

mkdir -p "${topdir}"/{SPECS,RPMS,BUILD,SRPMS,SOURCES}

cat > "${topdir}/SPECS/dummy-webkit2gtk3.spec" << 'EOF'
Name:           dummy-webkit2gtk3
Version:        0
Release:        1%{?dist}
Summary:        Dummy package providing webkit2gtk3
License:        MIT
Provides:       webkit2gtk3
BuildArch:      noarch

%description
Dummy package that provides webkit2gtk3 virtual dependency.

%prep

%build

%install

%files

%changelog
EOF

rpmbuild -bb --define "_topdir ${topdir}" "${topdir}/SPECS/dummy-webkit2gtk3.spec"
dnf5 install -y "${topdir}"/RPMS/noarch/dummy-webkit2gtk3-*.noarch.rpm

dnf5 remove -y rpm-build