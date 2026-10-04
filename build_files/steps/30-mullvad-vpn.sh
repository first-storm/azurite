#!/bin/bash

set -ouex pipefail

# Avoid api.github.com (anonymous rate limit): scrape the release asset list page.
repo_url="https://github.com/first-storm/mullvad-autobuild"
tag="autobuild-stable-x86_64"

rpm_href="$(curl -fsSL --retry 3 --retry-delay 5 "${repo_url}/releases/expanded_assets/${tag}" \
    | grep -oP 'href="\K/[^"]+\.rpm' | head -1 || true)"

if [[ -z "${rpm_href}" ]]; then
    echo "No .rpm asset found in Mullvad autobuild stable release" >&2
    exit 1
fi
rpm_url="https://github.com${rpm_href}"

rpm_path="/tmp/${rpm_url##*/}"
curl -fL --retry 3 --retry-delay 5 "${rpm_url}" -o "${rpm_path}"
dnf5 install -y "${rpm_path}"
rm -f "${rpm_path}"
