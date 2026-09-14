# AGENTS.md - FuioVim Project Guidelines

## Project Overview

**FuioVim** is a sovereign Brazilian code editor based on Neovim, hermetically packaged and configured using [nix-wrapper-modules](https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html).

Key architectural principles:
- **Declarative & Reproducible**: Fully reproducible Nix flake wrapping Neovim, its runtime plugins, language servers, formatters, and linters without imperative package managers (e.g. Mason, pip, npm).
- **Modular Opt-In / Opt-Out (`specs`)**: Downstream consumers can selectively enable or disable individual language stacks and toolchains via `specs.<category>.enable = false;` (similar to nixCats categories). Disabling a category automatically strips out both plugins and corresponding runtime tools from PATH.
- **Dynamic Lua Gating**: Categories enabled in Nix are exposed to Lua via `require('nix-info').settings.cats` and accessed cleanly through `require("fuiovim.util").cat`.

---

## Code Style & Formatting Standards

### 1. Attribute Nesting Over Dotted Syntax
Prefer nested attribute sets whenever defining more than a single nested attribute under the same prefix. Do not repeat dotted prefixes consecutively.

```nix
# Preferred:
config = {
  binName = "fuiovim";

  settings = {
    config_directory = ./config;
    aliases = [ "fvim" "nvim" ];
  };
};

# Avoid:
config.binName = "fuiovim";
config.settings.config_directory = ./config;
config.settings.aliases = [ "fvim" "nvim" ];
```

### 2. Statement Ordering
- Place shorter, scalar, and simpler definitions first.
- Place multi-line attribute sets, nested blocks, and complex functions at the end of the enclosing block.

### 3. Binary Resolution via `lib.getExe`
Never hardcode derivation output binary paths (e.g. `"${pkg}/bin/fuiovim"`). Always resolve executables via `lib.getExe` or `lib.getExe'`:

```nix
program = lib.getExe fuiovimPkg;
program = lib.getExe' fuiovimPkg "nvim";
```

### 4. Tree Formatting via `nixfmt-tree`
Always configure `pkgs.nixfmt-tree` as the flake `formatter`. Standard `nixfmt` expects input on stdin, whereas `nixfmt-tree` accepts file paths and formats trees properly when invoked via `nix fmt`.

### 5. Aggressive Lazy-Loading
Every plugin that can be lazily loaded must be lazily loaded to preserve instant time-to-active:
- Defer non-critical UI and presence plugins to `event = "DeferredUIEnter"` (e.g. `cord.nvim`).
- Defer insert-specific plugins to `event = "InsertEnter"` (e.g. `mini.pairs`, `blink.cmp`).
- Defer tool-specific plugins to `cmd` or `keys` (e.g. `oil.nvim`, `mini.visits`).
- Defer filetype-specific plugins to `ft` (e.g. `vimtex`, `render-markdown`).

### 6. No Code Duplication Across Lua Modules
Centralize common helpers and utilities into `lua/fuiovim/util.lua`. Never duplicate runtime inspection, category checking (`cat`), or repetitive logic across plugin specification files.

---

## Git & Workflow Guidelines

### 1. Git Tracking Mandatory for Nix Flakes
Nix flakes only evaluate files tracked by Git. Always run `git add -A` before running `nix flake check`, evaluating expressions, or testing builds.

### 2. Verification Before Committing
Verify changes using:
```bash
git add -A
nix fmt
nix flake check --no-build
nix run . -- --headless "+lua print('OK')" +qa
```

### 3. Always Commit Cleanly
Do not leave unstaged or dirty working trees. Use conventional commits:
- `feat(...)`: New feature or configuration option
- `fix(...)`: Bug fix or configuration correction
- `refactor(...)`: Reorganization or cleanup without behavior changes
- `docs(...)`: Documentation updates (`README.md`, `AGENTS.md`)
- `style(...)`: Formatting or aesthetic improvements
