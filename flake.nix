{
  description = "FuioVim - Editor de código baseado em Neovim e empacotado via Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";

    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          fuiovim-pkg = self.wrappers.fuiovim.wrap { pkgs = pkgsUnfree; };
        in
        {
          formatter = pkgs.nixfmt-tree;

          packages = {
            default = fuiovim-pkg;
            fuiovim = fuiovim-pkg;
          };

          apps = {
            default = {
              type = "app";
              program = lib.getExe fuiovim-pkg;
            };
            fuiovim = {
              type = "app";
              program = lib.getExe fuiovim-pkg;
            };
            nvim = {
              type = "app";
              program = lib.getExe' fuiovim-pkg "nvim";
            };
            fvim = {
              type = "app";
              program = lib.getExe' fuiovim-pkg "fvim";
            };
          };

          devShells = {
            default = pkgs.mkShell {
              packages = [
                pkgs.nil
                pkgs.nixd
                pkgs.nixfmt-tree
                pkgs.lua-language-server
                pkgs.stylua
              ];
            };
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
