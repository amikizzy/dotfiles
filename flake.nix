{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    hyprland.url = "github:hyprwm/Hyprland";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    tpanel = {
      url = "github:tuxdotrs/tpanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, ...} @ inputs: {
   # overlays = import ./overlays {inherit inputs;};

    nixosConfigurations = {
      # Desktop
      nixos = (import ./flake/nixos) {inherit inputs self;};
    };
  };
}

