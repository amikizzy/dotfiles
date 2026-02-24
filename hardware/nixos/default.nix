{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # NVIDIA
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      modesetting.enable = true;
      nvidiaSettings = true;
      forceFullCompositionPipeline = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
    };
    hardware.opengl.enable = true;
    hardware.opengl.extraPackages = with pkgs; [ vulkan-tools vulkan-loader ];
  hardware.graphics.enable = true;
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/59651dbd-455f-40cf-b40a-d63aab878e0d";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/73A3-81B2";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
  '';
}
