#!/bin/bash
set -ouex pipefail

# Clash Verge Rev — GUI proxy client built on Clash Meta
# https://github.com/clash-verge-rev/clash-verge-rev

repo_url="https://github.com/clash-verge-rev/clash-verge-rev"
temp_dir="$(mktemp -d)"

trap 'rm -rf "${temp_dir}"' EXIT

rpm_arch="$(rpm --eval '%{_arch}')"

# Avoid api.github.com (anonymous rate limit, 403 on shared CI runners):
# resolve the latest tag via the redirect, then scrape the asset list page.
latest_url="$(curl -fsSL --retry 3 --retry-delay 5 -o /dev/null -w '%{url_effective}' "${repo_url}/releases/latest")"
tag="${latest_url##*/}"

# Find the RPM download URL for the current architecture from the release assets
rpm_path_href="$(curl -fsSL --retry 3 --retry-delay 5 "${repo_url}/releases/expanded_assets/${tag}" \
    | grep -oP 'href="\K/[^"]+\.rpm' | grep "${rpm_arch}" | head -1 || true)"
rpm_url="${rpm_path_href:+https://github.com${rpm_path_href}}"

if [[ -z "${rpm_url}" ]]; then
    echo "No RPM found for architecture: ${rpm_arch}" >&2
    exit 1
fi

rpm_filename="$(basename "${rpm_url}")"
rpm_path="${temp_dir}/${rpm_filename}"

curl -fsSL --retry 3 --retry-delay 5 "${rpm_url}" -o "${rpm_path}"
dnf5 install -y "${rpm_path}"
