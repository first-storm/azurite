#!/bin/bash

set -ouex pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
files_dir="${script_dir}/../files"

install -Dm644 \
    "${files_dir}/usr/lib/modprobe.d/blacklist-tablet.conf" \
    /usr/lib/modprobe.d/blacklist-tablet.conf

install -Dm644 \
    "${files_dir}/usr/lib/modules-load.d/30-bbr.conf" \
    /usr/lib/modules-load.d/30-bbr.conf

install -Dm644 \
    "${files_dir}/usr/lib/sysctl.d/60-bbr.conf" \
    /usr/lib/sysctl.d/60-bbr.conf

rm -f /usr/lib/NetworkManager/conf.d/20-connectivity-fedora.conf
install -Dm644 \
    "${files_dir}/usr/lib/NetworkManager/conf.d/20-connectivity.conf" \
    /usr/lib/NetworkManager/conf.d/20-connectivity.conf

systemctl enable podman.socket
