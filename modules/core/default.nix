{ config, pkgs, ... }:
{
  # Core system modules: users, system packages, services
  users.users.danny = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ];
  };

  environment.systemPackages = with pkgs; [ vim git curl ];
}
