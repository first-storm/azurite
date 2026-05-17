#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    adw-gtk3-theme \
    distrobox

dnf5 install -y \
	--nobest \
	cloudflare-warp

dnf5 remove -y gnome-tour
