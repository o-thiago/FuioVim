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
      neovide.enable = lib.mkEnableOption "Neovide GUI wrapper";

      cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = builtins.mapAttrs (_: v: v.enable) config.specs;
        description = "Exposes enabled spec categories to Lua (accessible via require('nix-info').settings.cats)";
      };
    };
  };

  config = {
    binName = "fuiovim";
    runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

    settings = {
      config_directory = ./config;
      aliases = [
        "fvim"
        "nvim"
      ];
    };

    hosts.neovide.nvim-host.enable = config.settings.neovide.enable;

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
        options.runtimePkgs = lib.mkOption {
          default = [ ];
          type = lib.types.listOf lib.types.package;
          description = ''
            Runtime packages (LSPs, linters, formatters, tools) to put on PATH.
            If this spec is disabled (enable = false), these packages will not be included.
          '';
        };
      };

    specs = {
      core = {
        lazy = false;
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
        data = with pkgs.vimPlugins; [
          blink-cmp
          friendly-snippets
        ];
      };

      treesitter = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
        ];
      };

      lsp = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          nvim-lspconfig
        ];
      };

      formatting = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          conform-nvim
        ];
      };

      linting = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          nvim-lint
        ];
      };

      markdown = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          render-markdown-nvim
        ];
      };

      nix = {
        data = null;
        runtimePkgs = with pkgs; [
          nixd
          statix
          nixfmt
        ];
      };

      lua = {
        data = null;
        runtimePkgs = with pkgs; [
          lua-language-server
          stylua
        ];
      };

      rust = {
        lazy = true;
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
        runtimePkgs = with pkgs; [
          pyright
          ruff
        ];
      };

      c_cpp = {
        data = null;
        runtimePkgs = with pkgs; [
          llvmPackages.clang-tools
          cppcheck
        ];
      };

      csharp = {
        data = null;
        runtimePkgs = with pkgs; [
          omnisharp-roslyn
          csharpier
        ];
      };

      php = {
        data = null;
        runtimePkgs = with pkgs; [
          intelephense
          phpactor
          phpstan
          phpPackages.php-cs-fixer
        ];
      };

      web = {
        data = null;
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
        runtimePkgs = with pkgs; [
          bash-language-server
          shfmt
          shellcheck
        ];
      };

      yaml = {
        data = null;
        runtimePkgs = with pkgs; [
          yaml-language-server
          yamllint
        ];
      };
    };
  };
}
