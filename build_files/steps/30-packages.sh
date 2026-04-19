#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    adw-gtk3-theme \
    cloudflare-warp \
    distrobox

dnf5 remove -y gnome-tour
