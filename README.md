# FuioVim

FuioVim é uma configuração de Neovim empacotada de forma declarativa e reproduzível utilizando o [nix-wrapper-modules](https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html).

Ao contrário de distribuições tradicionais que dependem de scripts imperativos (`curl | bash`), gerenciadores mutáveis como Mason, ou pacotes globais de npm e pip, todas as dependências do FuioVim — plugins, LSPs, formatadores, linters e gramáticas Tree-sitter — são construídas hermeticamente via Nix.

Além disso, o projeto adota um modelo modular com opt-in/opt-out (similar ao conceito de categorias do *nixCats*). Usuários downstream podem desativar ou adicionar toolchains com uma linha de configuração no Nix, sem que plugins desnecessários ou ferramentas pesadas permaneçam no sistema ou no `$PATH`.

---

## Como Usar

### Execução Imediata (Sem Instalar)

Caso já possua o Nix instalado com suporte a Flakes:

```bash
nix run github:o-thiago/FuioVim
```

---

## Instalação e Atualização em Distribuições Não-Nix

O FuioVim pode ser instalado e atualizado em qualquer distribuição Linux (Ubuntu, Debian, Fedora, Arch, etc.) sem interferir com o gerenciador de pacotes do sistema (apt, dnf, pacman).

### 1. Instalar o Nix

A maneira recomendada é o instalador oficial da Determinate Systems:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Reinicie o terminal após a instalação para carregar as variáveis de ambiente.

### 2. Instalar o FuioVim

Instale o binário no perfil do usuário:

```bash
nix profile install github:o-thiago/FuioVim
```

Isso disponibiliza os comandos `fuiovim`, `fvim` e `nvim` no seu `$PATH` (`~/.nix-profile/bin`).

### 3. Atualizar o FuioVim

Para atualizar para a versão mais recente do repositório:

```bash
# Atualização via perfil
nix profile upgrade '.*'

# Ou reinstalação forçando atualização do cache
nix profile install --refresh github:o-thiago/FuioVim
```

### 4. Desinstalar

```bash
nix profile remove fuiovim
```

---

## Integração em Sistemas com Nix

### Home Manager

Adicione o input ao seu `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fuiovim.url = "github:o-thiago/FuioVim";
  };

  outputs = { self, nixpkgs, fuiovim, ... }: {
    homeConfigurations."usuario" = home-manager.lib.homeManagerConfiguration {
      modules = [
        fuiovim.homeManagerModules.default
        {
          # Ativar e configurar opt-out se desejado
          wrappers.fuiovim = {
            enable = true;
            specs.tex.enable = false;   # desativa TeX/LaTeX (economiza espaço)
            specs.php.enable = false;   # desativa stack PHP
          };
        }
      ];
    };
  };
}
```

### NixOS

```nix
{
  environment.systemPackages = [
    fuiovim.packages.${pkgs.system}.default
  ];
}
```

---

## Customização Downstream (Estilo nixCats)

O FuioVim expõe sua configuração como um `wrapperModule`. É possível estender a base para ligar/desligar toolchains ou incluir plugins adicionais:

```nix
let
  customFuioVim = fuiovim.wrappers.fuiovim.extend {
    # Desabilitar stacks indesejadas (remove plugins e LSPs do PATH)
    specs.tex.enable = false;
    specs.csharp.enable = false;
    specs.php.enable = false;

    # Adicionar plugins próprios
    specs.meus-plugins = with pkgs.vimPlugins; [
      vim-fugitive
    ];
  };
in
customFuioVim.wrap { inherit pkgs; }
```

### Categorias Disponíveis

| Categoria | Descrição | Componentes |
| :--- | :--- | :--- |
| `core` | Base do editor | `lze`, `rose-pine`, `mini`, `oil`, `snacks`, `cord`, `ripgrep`, `lazygit`, `figlet` |
| `completion` | Autocompletion | `blink-cmp`, `friendly-snippets` |
| `treesitter` | Realce sintático | `nvim-treesitter.withAllGrammars` |
| `lsp` | LSP nativo | `nvim-lspconfig` |
| `formatting` | Formatação | `conform-nvim` |
| `linting` | Linting assíncrono | `nvim-lint` |
| `markdown` | Markdown visual | `render-markdown-nvim` |
| `nix` | Toolchain Nix | `nixd`, `statix`, `nixfmt` |
| `rust` | Toolchain Rust | `rustaceanvim`, `rust-analyzer`, `clippy`, `rustfmt` |
| `python` | Toolchain Python | `pyright`, `ruff` |
| `web` | JS/TS/HTML/CSS | `typescript-language-server`, `svelte-language-server`, `tailwindcss`, `biome` |
| `c_cpp` | C e C++ | `clang-tools`, `cppcheck` |
| `tex` | LaTeX | `vimtex`, `texliveFull`, `texlab`, `zathura` |
| `csharp` | C# (.NET) | `omnisharp-roslyn`, `csharpier` |
| `php` | PHP | `intelephense`, `phpactor`, `phpstan`, `php-cs-fixer` |
| `bash` | Shell script | `bash-language-server`, `shfmt`, `shellcheck` |
| `yaml` | YAML | `yaml-language-server`, `yamllint` |

---

## Desenvolvimento Local

```bash
# Entrar no ambiente de desenvolvimento com formatadores e LSPs
nix develop

# Formatar o repositório via nixfmt-tree
nix fmt

# Testar execução local
nix run .
```

---

## Atalhos Principais

| Atalho | Ação |
| :--- | :--- |
| `<Space>` | Tecla Líder (`<leader>`) |
| `<leader>pv` | Abrir explorador de arquivos (`Oil.nvim`) |
| `<leader>pf` | Localizar arquivos (`Snacks.picker.files`) |
| `<leader>ps` | Buscar texto no projeto (`Snacks.picker.grep`) |
| `<leader>pw` | Buscar palavra sob o cursor (`Snacks.picker.grep_word`) |
| `<leader>lg` | Abrir LazyGit flutuante |
| `<leader>f` | Formatar buffer atual (`conform.nvim`) |
| `<leader>y` / `<leader>p` | Copiar / Colar na área de transferência do sistema |
| `J` / `K` (Visual) | Mover linhas selecionadas para cima / baixo |
| `<leader>gd` | Ir para definição de código (LSP) |
| `<leader>ca` | Ações de código / Code Actions (LSP) |
| `<leader>rn` | Renomear símbolo (LSP) |
| `<leader>vd` | Diagnósticos flutuantes (LSP) |
| `<leader>a` | Adicionar caminho às visitas (`mini.visits`) |
| `<leader>h` | Selecionar caminho visitado (`mini.visits`) |
| `<leader>1-5` | Abrir caminho visitado por índice |

---

## Licença

MIT
