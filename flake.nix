{
  description = "Danny's Nix flake - framework host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.hello;

        nixosConfigurations = {
          framework = pkgs.lib.nixosSystem {
            system = system;
            modules = [ ./hosts/framework/default.nix ];
          };
        };

        homeManagerConfigurations = {
          danny = home-manager.lib.homeManagerConfiguration {
            inherit system;
            username = "danny";
            homeDirectory = "/home/danny";
            configuration = ./homes/nixos/default.nix;
          };
        };
      });
}
