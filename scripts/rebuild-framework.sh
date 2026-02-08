#!/usr/bin/env bash
set -euo pipefail

# Rebuild the system for the 'framework' host in this flake
sudo nixos-rebuild switch --flake "${PWD}#framework"
