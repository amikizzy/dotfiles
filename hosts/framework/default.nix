{ config, pkgs, ... }:
let
  base = import ../default/default.nix { inherit config pkgs; };
in base // {
  # Framework-specific overrides
}
