#!/bin/bash

set -ouex pipefail

dnf5 install -y \
    ibus-mozc \
    ibus-rime \
    librime-lua

dnf5 remove -y ibus-anthy
