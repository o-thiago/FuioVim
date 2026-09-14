inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  options,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  options = {
    settings = {
      neovide.enable = lib.mkEnableOption "Invólucro gráfico para o Neovide";

      specs = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = builtins.mapAttrs (_: v: v.enable) config.specs;
        description = "Mapa de especificações ativas exposto para o runtime Lua através do nix-info";
      };
    };
  };

  config = {
    binName = "fuiovim";
    runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

    hosts = {
      neovide.nvim-host.enable = config.settings.neovide.enable;
    };

    settings = {
      config_directory = ./config;
      aliases = [
        "fvim"
        "nvim"
      ];
    };

    specMods =
      {
        parentSpec ? null,
        parentOpts ? null,
        parentName ? null,
        config,
        options,
        ...
      }:
      {
        options = {
          runtimePkgs = lib.mkOption {
            default = [ ];
            type = lib.types.listOf lib.types.package;
            description = "Pacotes de tempo de execução (LSPs, formatadores, linters) injetados no PATH quando a especificação está ativa.";
          };
        };
      };

    specs = {
      core = {
        lazy = false;
        enable = lib.mkDefault true;
        data = with pkgs.vimPlugins; [
          lze
          rose-pine
          mini-pairs
          mini-icons
          mini-visits
          oil-nvim
          snacks-nvim
          cord-nvim
        ];
        runtimePkgs = with pkgs; [
          ripgrep
          lazygit
          tree-sitter
          figlet
        ];
      };

      completion = {
        lazy = true;
        enable = lib.mkDefault true;
        data = with pkgs.vimPlugins; [
          blink-cmp
          friendly-snippets
        ];
      };

      treesitter = {
        lazy = true;
        enable = lib.mkDefault true;
        data = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
        ];
      };

      lsp = {
        lazy = true;
        enable = lib.mkDefault true;
        data = with pkgs.vimPlugins; [
          nvim-lspconfig
        ];
      };

      formatting = {
        lazy = true;
        enable = lib.mkDefault true;
        data = with pkgs.vimPlugins; [
          conform-nvim
        ];
      };

      linting = {
        lazy = true;
        enable = lib.mkDefault true;
        data = with pkgs.vimPlugins; [
          nvim-lint
        ];
      };

      markdown = {
        lazy = true;
        enable = lib.mkDefault true;
        data = with pkgs.vimPlugins; [
          render-markdown-nvim
        ];
      };

      nix = {
        data = null;
        enable = lib.mkDefault true;
        runtimePkgs = with pkgs; [
          nixd
          statix
          nixfmt
        ];
      };

      lua = {
        data = null;
        enable = lib.mkDefault true;
        runtimePkgs = with pkgs; [
          lua-language-server
          stylua
        ];
      };

      rust = {
        lazy = true;
        enable = lib.mkDefault false;
        data = with pkgs.vimPlugins; [
          rustaceanvim
        ];
        runtimePkgs = with pkgs; [
          rust-analyzer
          clippy
          rustfmt
        ];
      };

      tex = {
        lazy = true;
        enable = lib.mkDefault false;
        data = with pkgs.vimPlugins; [
          vimtex
        ];
        runtimePkgs = with pkgs; [
          texliveFull
          texlab
          zathura
        ];
      };

      python = {
        data = null;
        enable = lib.mkDefault false;
        runtimePkgs = with pkgs; [
          pyright
          ruff
        ];
      };

      c_cpp = {
        data = null;
        enable = lib.mkDefault false;
        runtimePkgs = with pkgs; [
          llvmPackages.clang-tools
          cppcheck
        ];
      };

      csharp = {
        data = null;
        enable = lib.mkDefault false;
        runtimePkgs = with pkgs; [
          omnisharp-roslyn
          csharpier
        ];
      };

      php = {
        data = null;
        enable = lib.mkDefault false;
        runtimePkgs = with pkgs; [
          intelephense
          phpactor
          phpstan
          phpPackages.php-cs-fixer
        ];
      };

      web = {
        data = null;
        enable = lib.mkDefault false;
        runtimePkgs = with pkgs; [
          nodejs
          typescript
          typescript-language-server
          svelte-language-server
          tailwindcss-language-server
          vscode-langservers-extracted
          biome
        ];
      };

      bash = {
        data = null;
        enable = lib.mkDefault false;
        runtimePkgs = with pkgs; [
          bash-language-server
          shfmt
          shellcheck
        ];
      };

      yaml = {
        data = null;
        enable = lib.mkDefault false;
        runtimePkgs = with pkgs; [
          yaml-language-server
          yamllint
        ];
      };
    };
  };
}
