#!/usr/bin/env bash
set -euo pipefail

# Run the home-manager activation package for user 'danny' from this flake.
# If the flake exposes `homeManagerConfigurations.danny.activationPackage`, this will run it.
nix run "${PWD}#homeManagerConfigurations.danny.activationPackage"
