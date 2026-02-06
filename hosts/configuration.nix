{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos";

  users.users.danny = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio"];
  };

  boot.loader.systemd-boot.enable = true;
  # Pressing ESC on boot will bring up the bootloader menu.
  boot.loader.timeout = 5;
  system.stateVersion = "25.11";
}
