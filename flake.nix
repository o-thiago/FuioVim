{
  description = "FuioVim - Sovereign Brazilian Code Editor based on Neovim and Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wrappers.url = "github:nix-community/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      wrappers,
      flake-parts,
      systems,
      ...
    }:
    let
      module = nixpkgs.lib.modules.importApply ./module.nix inputs;
      wrapper = wrappers.lib.evalModule module;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      perSystem =
        {
          system,
          pkgs,
          lib,
          ...
        }:
        let
          pkgsUnfree = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          fuiovimPkg = self.wrappers.fuiovim.wrap { pkgs = pkgsUnfree; };
        in
        {
          formatter = pkgs.nixfmt-tree;

          packages = {
            default = fuiovimPkg;
            fuiovim = fuiovimPkg;
          };

          apps = {
            default = {
              type = "app";
              program = lib.getExe fuiovimPkg;
            };
            fuiovim = {
              type = "app";
              program = lib.getExe fuiovimPkg;
            };
            nvim = {
              type = "app";
              program = lib.getExe' fuiovimPkg "nvim";
            };
            fvim = {
              type = "app";
              program = lib.getExe' fuiovimPkg "fvim";
            };
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.nil
              pkgs.nixd
              pkgs.nixfmt-tree
              pkgs.lua-language-server
              pkgs.stylua
            ];
          };
        };

      flake = {
        wrapperModules = {
          default = self.wrapperModules.fuiovim;
          fuiovim = module;
          neovim = module;
        };

        wrappers = {
          default = self.wrappers.fuiovim;
          fuiovim = wrapper.config;
          neovim = wrapper.config;
        };

        overlays = {
          default = self.overlays.fuiovim;
          fuiovim = final: prev: { fuiovim = self.wrappers.fuiovim.wrap { pkgs = final; }; };
        };

        nixosModules = {
          default = self.nixosModules.fuiovim;
          fuiovim = wrappers.lib.getInstallModule {
            name = "fuiovim";
            value = module;
          };
        };

        homeModules = {
          default = self.homeModules.fuiovim;
          fuiovim = self.nixosModules.fuiovim;
        };

        homeManagerModules = {
          default = self.homeModules.default;
          fuiovim = self.homeModules.fuiovim;
        };
      };
    };
}
