#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    adw-gtk3-theme \
    distrobox \
    gnome-tweaks \
    NetworkManager-strongswan \
    NetworkManager-strongswan-gnome \
    cloudflare-warp

dnf5 remove -y \
    firefox \
    gnome-tour
