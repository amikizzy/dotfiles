{ config, lib, pkgs, ... }:
let
  enabled = config.hardware.graphics.enable;
in {
  config = lib.mkIf enabled {
    # Ensure OpenGL is enabled system-wide
    hardware.opengl.enable = true;
  };
}
