# AGENTS.md

## Project Overview

**FuioVim** is a Neovim distribution packaged hermetically using [nix-wrapper-modules](https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html).

- **Hermetic & Reproducible**: Plugins, LSPs, formatters, and tools are managed via Nix flakes without imperative package managers (Mason, pip, npm).
- **Opt-In Architecture (`specs`)**: Language toolchains default to disabled (`enable = lib.mkDefault false;`). Downstream users opt into languages explicitly (`specs.<name>.enable = true;`), pulling in plugins and PATH binaries together.
- **Lua Gating**: State is exposed via `nix-info` and checked centrally with `require("fuiovim.util").has_spec(name)`.

---

## Code & Formatting Standards

### 1. Attribute Nesting vs. Dotted Syntax
Only ever use nested attribute syntax when there is more than a single nested attribute under the same prefix. If there is only one nested attribute, use dotted syntax.

```nix
# Correct:
nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
hosts.neovide.nvim-host.enable = config.settings.neovide.enable;

wrappers = {
  url = "github:nix-community/nix-wrapper-modules";
  inputs.nixpkgs.follows = "nixpkgs";
};

# Incorrect (single nested attribute should not be nested):
hosts = {
  neovide.nvim-host.enable = config.settings.neovide.enable;
};
```

### 2. Statement Ordering
- Simpler, scalar, and shorter declarations come first.
- Multi-line attribute sets, nested blocks, and complex functions go at the end of the enclosing block.

### 3. Binary Resolution
Always resolve executables with `lib.getExe` or `lib.getExe'`, never hardcoded paths:

```nix
program = lib.getExe fuiovimPkg;
program = lib.getExe' fuiovimPkg "nvim";
```

### 4. Formatter
Use `pkgs.nixfmt-tree` as the flake formatter.

### 5. Aggressive Lazy-Loading
Lazy load every deferred plugin:
- Non-critical visual / presence: `event = "DeferredUIEnter"` (`cord.nvim`, `mini.icons`, `nvim-treesitter`).
- Insert-mode features: `event = "InsertEnter"` (`mini.pairs`, `blink.cmp`).
- Commands and keybindings: `cmd` or `keys` (`oil.nvim`, `mini.visits`).
- Filetypes: `ft` (`vimtex`, `render-markdown`).

### 6. Centralized Utilities
Keep common helpers in `lua/fuiovim/util.lua`. Never duplicate `has_spec` or plugin checks across Lua files.

### 7. Brazilian Portuguese for Descriptions
All `desc` attributes in Lua keymaps and `description` attributes in Nix options must be written in Brazilian Portuguese.

---

## Git & Pre-Commit Verification

1. Flakes only evaluate git-tracked files. Always run `git add -A` before evaluating or checking.
2. Validate changes before committing:
```bash
git add -A
nix fmt
nix flake check --no-build
nix run . -- --headless "+lua print('OK')" +qa
```
3. Use conventional commit messages (`feat`, `fix`, `refactor`, `docs`, `style`).
