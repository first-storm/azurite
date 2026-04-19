#!/bin/bash

set -ouex pipefail

release_api_url="https://api.github.com/repos/first-storm/mullvad-autobuild/releases/tags/autobuild-stable-x86_64"

rpm_url="$(
    curl -fsSL "${release_api_url}" \
        | python3 -c '
import json
import sys

release = json.load(sys.stdin)
for asset in release.get("assets", []):
    url = asset.get("browser_download_url", "")
    if url.endswith(".rpm"):
        print(url)
        break
else:
    sys.exit("No .rpm asset found in Mullvad autobuild stable release")
'
)"

rpm_path="/tmp/${rpm_url##*/}"
curl -fL --retry 3 --retry-delay 5 "${rpm_url}" -o "${rpm_path}"
dnf5 install -y "${rpm_path}"
rm -f "${rpm_path}"
