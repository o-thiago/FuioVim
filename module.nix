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

  # Binary name & command aliases
  config.binName = "fuiovim";
  config.settings.aliases = [
    "fvim"
    "nvim"
  ];

  # Neovim configuration directory
  config.settings.config_directory = ./config;

  # Submodule enhancements: attach runtimePkgs to specs so they are only included when the spec is enabled
  config.specMods =
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
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = ''
          Runtime packages (LSPs, linters, formatters, tools) to put on PATH.
          If this spec is disabled (enable = false), these packages will not be included.
        '';
      };
    };

  # Collect runtimePkgs from all enabled specs
  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

  # Inform Lua of which top-level specs are enabled (similar to nixCats categories)
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
    description = "Exposes enabled spec categories to Lua (accessible via require('nix-info').settings.cats)";
  };

  # Optional Neovide GUI wrapper
  options.settings.neovide.enable = lib.mkEnableOption "Neovide GUI wrapper";
  config.hosts.neovide.nvim-host.enable = config.settings.neovide.enable;

  # =========================================================================
  # Modular, opinionated specs (Opt-in / Opt-out)
  # Downstream users can toggle any category with `specs.<name>.enable = false;`
  # or add their own specs with `specs.<name> = ...;`
  # =========================================================================

  # Core editor experience & visual identity
  config.specs.core = {
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
    ];
  };

  # Autocompletion engine
  config.specs.completion = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      blink-cmp
      friendly-snippets
    ];
  };

  # Syntax highlighting via precompiled Tree-sitter grammars
  config.specs.treesitter = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];
  };

  # Native LSP client
  config.specs.lsp = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      nvim-lspconfig
    ];
  };

  # Formatting engine
  config.specs.formatting = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      conform-nvim
    ];
  };

  # Linting engine
  config.specs.linting = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      nvim-lint
    ];
  };

  # Markdown rendering in terminal
  config.specs.markdown = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      render-markdown-nvim
    ];
  };

  # --- Language Toolchains (LSPs, Formatters, Linters) ---

  # Nix language
  config.specs.nix = {
    data = null;
    runtimePkgs = with pkgs; [
      nixd
      statix
      nixfmt
    ];
  };

  # Lua language
  config.specs.lua = {
    data = null;
    runtimePkgs = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  # Rust language
  config.specs.rust = {
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

  # LaTeX support with Zathura viewer
  config.specs.tex = {
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

  # Python language
  config.specs.python = {
    data = null;
    runtimePkgs = with pkgs; [
      pyright
      ruff
    ];
  };

  # C / C++
  config.specs.c_cpp = {
    data = null;
    runtimePkgs = with pkgs; [
      llvmPackages.clang-tools
      cppcheck
    ];
  };

  # C# (.NET)
  config.specs.csharp = {
    data = null;
    runtimePkgs = with pkgs; [
      omnisharp-roslyn
      csharpier
    ];
  };

  # PHP language
  config.specs.php = {
    data = null;
    runtimePkgs = with pkgs; [
      intelephense
      phpactor
      phpstan
      phpPackages.php-cs-fixer
    ];
  };

  # Web development (JS, TS, HTML, CSS, Svelte, Tailwind)
  config.specs.web = {
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

  # Bash / Shell scripting
  config.specs.bash = {
    data = null;
    runtimePkgs = with pkgs; [
      bash-language-server
      shfmt
      shellcheck
    ];
  };

  # YAML language
  config.specs.yaml = {
    data = null;
    runtimePkgs = with pkgs; [
      yaml-language-server
      yamllint
    ];
  };
}
