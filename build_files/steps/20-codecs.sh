#!/bin/bash

set -ouex pipefail

if rpm -q ffmpeg-free >/dev/null 2>&1; then
    dnf5 swap -y ffmpeg-free ffmpeg --allowerasing
fi

if rpm -q libavcodec-free >/dev/null 2>&1; then
    dnf5 swap -y libavcodec-free libavcodec-freeworld --allowerasing
fi

if rpm -q mesa-va-drivers >/dev/null 2>&1; then
    dnf5 swap -y mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
else
    # RPM Fusion can publish a mesa build before it reaches Fedora's stable
    # repo, making this uninstallable. Skip it rather than pulling mesa from
    # updates-testing (which breaks later dependency resolution); a later
    # scheduled build picks it up once mesa is stable.
    dnf5 install -y mesa-va-drivers-freeworld ||
        echo "WARNING: mesa-va-drivers-freeworld skipped (mesa version mismatch)"
fi

if rpm -q mesa-vdpau-drivers >/dev/null 2>&1; then
    dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing
fi

# Keep openh264 itself: it provides libopenh264.so, which libavcodec and
# ffmpeg-libs link against. Removing it makes dnf5 remove every package that
# depends on it, including gnome-shell, nautilus and flatpak.
dnf5 remove -y \
    mozilla-openh264 \
    gstreamer1-plugin-openh264 || true

dnf5 install -y \
    gstreamer1-plugin-libav \
    gstreamer1-plugins-bad-freeworld \
    gstreamer1-plugins-ugly \
    libdvdcss
