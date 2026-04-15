#!/bin/bash

set -ouex pipefail

dnf5 autoremove -y
dnf5 clean all
rm -rf /var/lib/dnf
