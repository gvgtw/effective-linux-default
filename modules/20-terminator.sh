#!/usr/bin/env bash
# Installs Terminator and stops there — deliberately no config.
#
# The effective_kali branch bakes a full config (Dark-Pastel profile from the
# TerminatorThemes plugin, custom keybindings/layout) into
# $HOME/.config/terminator/config. That config was written against Kali's
# Terminator build and its bundled theme assets; ported to Pop!_OS it left
# Terminator broken. Stock Terminator with its own defaults works fine, so
# this branch installs the package and leaves the config alone.
set -euo pipefail

apt_install terminator
