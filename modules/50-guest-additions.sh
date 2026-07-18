#!/usr/bin/env bash
# VirtualBox guest utilities — not in the old README, but directly useful
# since this image is specifically built to run in VirtualBox: clipboard
# sharing, shared folders, and proper display resizing.
set -euo pipefail

apt_install virtualbox-guest-utils virtualbox-guest-x11
