#!/bin/bash

set -ouex pipefail

target_repo_files=(
    /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo
    /etc/yum.repos.d/fedora-cisco-openh264.repo
    /etc/yum.repos.d/rpmfusion-nonfree-nvidia-driver.repo
    /etc/yum.repos.d/rpmfusion-nonfree-steam.repo
)

fallback_repo_ids=(
    _copr:copr.fedorainfracloud.org:phracek:PyCharm
    fedora-cisco-openh264
    rpmfusion-nonfree-nvidia-driver
    rpmfusion-nonfree-steam
)

repo_ids=()
for repo_file in "${target_repo_files[@]}"; do
    if [[ -f "${repo_file}" ]]; then
        repo_id="$(sed -n 's/^\[\(.*\)\]$/\1/p' "${repo_file}" | head -n 1)"
        if [[ -n "${repo_id}" ]]; then
            repo_ids+=("${repo_id}")
        fi
    fi
done

if [[ "${#repo_ids[@]}" -eq 0 ]]; then
    repo_ids=("${fallback_repo_ids[@]}")
fi

mapfile -t repo_installed_packages < <(
    dnf5 repoquery --installed --qf '%{name} %{from_repo}' \
        | awk -v repo_list="$(printf '%s\n' "${repo_ids[@]}")" '
            BEGIN {
                split(repo_list, repos, "\n")
                for (i in repos) {
                    if (repos[i] != "") {
                        target[repos[i]] = 1
                    }
                }
            }
            target[$2] { print $1 }
        ' \
        | sort -u
)

if [[ "${#repo_installed_packages[@]}" -gt 0 ]]; then
    dnf5 remove -y "${repo_installed_packages[@]}"
fi

rm -f "${target_repo_files[@]}"

fedora_version="$(rpm -E %fedora)"
dnf5 install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"

dnf5 install -y \
    --releasever="${fedora_version}" \
    --repo=rpmfusion-free \
    --repo=rpmfusion-free-updates \
    --repo=rpmfusion-free-updates-testing \
    rpmfusion-free-release-tainted

# Add the Cloudflare WARP repo and import the current signing key.
rpm --import https://pkg.cloudflareclient.com/pubkey.gpg
curl -fsSL https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo \
    -o /etc/yum.repos.d/cloudflare-warp.repo
