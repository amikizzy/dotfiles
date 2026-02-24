#!/usr/bin/env bash
set -euo pipefail

# Build and run the Home Manager activation package for user 'danny'.
# This works reliably with flakes without requiring the home-manager CLI.

FLAKE_PATH="${PWD}"
ATTR="homeManagerConfigurations.danny.activationPackage"

echo "Building activation package: ${FLAKE_PATH}#${ATTR}"
nix build "${FLAKE_PATH}#${ATTR}" -o ./result-home

echo "Running activation script"
./result-home/activate

echo "Home Manager activation completed."
