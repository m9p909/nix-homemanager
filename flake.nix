{
  description = "Home Manager configuration of jack";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Lock nixpkgs to current revision
  nixConfig = {
    extra-substituters = [ "https://cache.nixos.org" ];
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    {
      homeConfigurations."jackclarke" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./home.nix ];
      };

      homeConfigurations."jack" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./home.nix ];
      };

      homeConfigurations."jack.clarke" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./home.nix ];
      };
    };
}
