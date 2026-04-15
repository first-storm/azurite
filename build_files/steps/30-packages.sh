#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    adw-gtk3-theme \
    cloudflare-warp \
    distrobox \
    mullvad-vpn

dnf5 remove -y gnome-tour
