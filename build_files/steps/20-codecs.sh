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
    dnf5 install -y mesa-va-drivers-freeworld
fi

if rpm -q mesa-vdpau-drivers >/dev/null 2>&1; then
    dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing
fi

dnf5 remove -y \
    mozilla-openh264 \
    gstreamer1-plugin-openh264 \
    openh264 || true

dnf5 install -y \
    gstreamer1-plugin-libav \
    gstreamer1-plugins-bad-freeworld \
    gstreamer1-plugins-ugly \
    libdvdcss
