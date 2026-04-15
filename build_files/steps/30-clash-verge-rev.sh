#!/bin/bash
set -ouex pipefail

# Clash Verge Rev — GUI proxy client built on Clash Meta
# https://github.com/clash-verge-rev/clash-verge-rev

api_url="https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/latest"
temp_dir="$(mktemp -d)"

trap 'rm -rf "${temp_dir}"' EXIT

rpm_arch="$(rpm --eval '%{_arch}')"

# Find the RPM download URL for the current architecture from the release assets
rpm_url="$(curl -fsSL "${api_url}" | grep -oP 'https://[^"]+\.rpm' | grep "${rpm_arch}" | head -1)"

if [[ -z "${rpm_url}" ]]; then
    echo "No RPM found for architecture: ${rpm_arch}" >&2
    exit 1
fi

rpm_filename="$(basename "${rpm_url}")"
rpm_path="${temp_dir}/${rpm_filename}"

curl -fsSL "${rpm_url}" -o "${rpm_path}"
dnf5 install -y "${rpm_path}"
