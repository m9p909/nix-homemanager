
{
  description = "Home Manager configuration of jack";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";        # add sops-nix
  };

  outputs = { nixpkgs, home-manager, sops-nix, ... }:   # expose sops-nix
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."jack" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          sops-nix.homeManagerModules.sops   # import the HM module
          ./home.nix
        ];
      };
    };
}

