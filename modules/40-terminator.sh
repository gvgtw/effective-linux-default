#!/usr/bin/env bash
# Installs Terminator and stops there — deliberately no config.
#
# An earlier version of this script wrote a full $HOME/.config/terminator/
# config (theme plugin, custom profile, keybindings, layout). It was built
# against a different distro's Terminator packaging and broke on Pop!_OS.
# Stock Terminator works fine, and its preferences are easy enough to set by
# hand once, so the package install is the whole job here.
set -euo pipefail

apt_install terminator
