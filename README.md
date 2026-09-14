# 🇧🇷 FuioVim

**FuioVim** é um editor de código soberano brasileiro baseado em **Neovim** e encapsulado puramente com o [**nix-wrapper-modules**](https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html).

Diferente de distribuições convencionais que dependem de scripts imperativos externos (`curl | sh`), gerenciadores de pacotes ad-hoc em tempo de execução (`Mason`, `pip`, `npm -g`), ou ambientes frágeis e mutáveis, o **FuioVim** adota a **soberania tecnológica**: cada plugin, analisador estático (LSP), formatador, linter e gramática Tree-sitter é declarado e construído hermeticamente através do ecossistema Nix.

Além disso, graças à arquitetura do `nix-wrapper-modules`, o FuioVim oferece uma **base opinada e modular** no estilo de categorias do *nixCats*: usuários downstream podem facilmente habilitar ou desabilitar categorias de plugins e toolchains (por exemplo, desativar TeX, Rust, PHP ou C# para economizar espaço e tempo de compilação) ou injetar seus próprios plugins declarativamente.

---

## ⚡ Características

- **Soberania e Reprodutibilidade Total**: Construído sobre o [`nix-wrapper-modules`](https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html) e Flakes do Nix. O mesmo editor se comporta com fidelidade absoluta em qualquer máquina.
- **Modularidade Estilo nixCats (Opt-in / Opt-out)**:
  - Cada componente ou linguagem é um `spec` com ativação condicional (`enable = true / false`).
  - Desativar um `spec` remove automaticamente os plugins correspondentes e também as ferramentas de runtime (LSPs, formatadores e linters) do `PATH`.
  - As categorias ativas são propagadas ao Lua via `require('nix-info').settings.cats` para carregamento dinâmico e inteligente.
- **Isolamento de Ambiente**: Executa sob o namespace `fuiovim` (`$NVIM_APPNAME=fuiovim`), mantendo estados e caches (`~/.local/state/fuiovim`, `~/.cache/fuiovim`) isolados de outras instalações do Neovim.
- **Desempenho Nativo**: Lazy-loading declarativo ultra-rápido via [`lze`](https://github.com/BirdeeHub/lze).
- **Toolchain de Linguagens Completa Pronta para Uso**:
  - **LSPs**: `nixd`, `statix`, `rust-analyzer`, `pyright`, `ruff`, `clangd`, `lua-language-server`, `typescript-language-server`, `svelte-language-server`, `tailwindcss`, `intelephense`, `phpactor`, `omnisharp`, `bashls`, `yamlls`, `texlab`.
  - **Formatadores**: `nixfmt` (via `nixfmt-tree`), `stylua`, `ruff`, `biome`, `clang-format`, `csharpier`, `shfmt`, `rustfmt`, `php-cs-fixer`.
  - **Linters**: `clippy`, `cppcheck`, `statix`, `shellcheck`, `yamllint`, `phpstan`.
- **Interface e Navegação**:
  - Dashboard soberano em ASCII art e comandos rápidos via `snacks.nvim`.
  - Localizador de arquivos e busca textual via `snacks.picker`.
  - Explorador de arquivos no próprio buffer com `oil.nvim`.
  - Integração Git direta com `lazygit`.
  - Markdown renderizado no terminal via `render-markdown.nvim`.
  - Suporte a LaTeX integrado com visualizador Zathura (`vimtex`).
  - Tema `rose-pine` com suporte a transparência de terminal e suporte a GUI (`neovide`).

---

## 🚀 Como Executar

### 1. Execução Direta via Nix Flake
Você pode executar o FuioVim diretamente sem instalar nada permanentemente:

```bash
# Executar a versão estável empacotada
nix run .

# Ou diretamente pelo app fuiovim / nvim
nix run .#fuiovim
nix run .#nvim
```

### 2. Shell de Desenvolvimento e Formatação
```bash
# Entrar no shell com LSPs e ferramentas
nix develop

# Formatar a árvore de código Nix com nixfmt-tree (sem depender de stdin)
nix fmt
```

---

## 🛠️ Customização e Uso Downstream (Opt-in / Opt-out)

O FuioVim exporta seu módulo como um `wrapperModule` padrão. Isso permite que qualquer usuário importe a base do FuioVim e ligue/desligue especificações conforme desejado:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fuiovim.url = "github:o-thiago/FuioVim";
    wrappers.url = "github:nix-community/nix-wrapper-modules";
  };

  outputs = { self, nixpkgs, fuiovim, wrappers, ... }:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
    
    # Criar uma versão customizada do FuioVim:
    customFuioVim = fuiovim.wrappers.fuiovim.extend {
      # Desabilitar stacks que você não usa (economiza espaço e compilação)
      specs.tex.enable = false;      # Desativa vimtex, texlive e texlab
      specs.php.enable = false;      # Desativa PHP LSPs e ferramentas
      specs.csharp.enable = false;   # Desativa Omnisharp e CSharpier

      # Adicionar seus próprios plugins
      specs.my-custom-plugin = with pkgs.vimPlugins; [
        vim-fugitive
      ];
    };
  in
  {
    packages.x86_64-linux.default = customFuioVim.wrap { inherit pkgs; };
  };
}
```

### Módulos NixOS / Home Manager
O FuioVim também disponibiliza módulos prontos para NixOS e Home Manager:

```nix
# No seu Home Manager ou NixOS configuration.nix:
{
  imports = [ fuiovim.homeManagerModules.default ];

  # Habilitar o wrapper do FuioVim com customizações se desejar:
  wrappers.fuiovim = {
    enable = true;
    specs.tex.enable = false; # exemplo de opt-out
  };
}
```

---

## 📂 Estrutura do Repositório

```
FuioVim/
├── .gitignore              # Ignora builds (result) e diretórios voláteis
├── flake.nix               # Flake exportando packages, apps, wrappers, modules e formatter
├── flake.lock              # Bloqueio reproduzível das revisões do Nix
├── module.nix              # Módulo mestre baseado em nix-wrapper-modules
├── README.md               # Documentação soberana do projeto
└── config/                 # Configuração Lua e Vimscript
    ├── init.lua            # Ponto de entrada carregado pelo nix-wrapper-modules
    ├── lua/
    │   └── fuiovim/
    │       ├── init.lua            # Inicializador principal (carrega opções, plugins e tema)
    │       ├── set.vim             # Opções base do editor e remaps clássicos
    │       └── plugins/
    │           ├── init.lua        # Módulo central com introspecção de categorias (cats)
    │           ├── blink_cmp.lua   # Autocompletion ultra-rápido
    │           ├── conform.lua     # Formatação com ativação dinâmica por categoria
    │           ├── cord.lua        # Rich presence do Discord
    │           ├── lsp.lua         # LSP nativo do Neovim com ativação dinâmica por linguagem
    │           ├── markdown.lua    # Renderização de Markdown no buffer
    │           ├── mini.lua        # Ícones, pares e histórico de visitas
    │           ├── nvim_lint.lua   # Linters assíncronos com ativação por categoria
    │           ├── oil.lua         # Gerenciamento de arquivos como buffer
    │           ├── snacks.lua      # Dashboard, picker, notifier e lazygit
    │           ├── treesitter.lua  # Realce de sintaxe via gramáticas compiladas
    │           └── vimtex.lua      # Integração LaTeX
    └── after/
        ├── ftplugin/
        │   ├── rust.lua    # Ações específicas para Rust (rustaceanvim)
        │   └── tex.lua     # Configurações de tabulação para TeX
        └── lsp/
            ├── lua_ls.lua      # Configurações do servidor Lua
            ├── omnisharp.lua   # Configurações do C# Roslyn
            └── phpactor.lua    # Configurações do PHP
```

---

## ⌨️ Principais Atalhos

| Atalho | Ação |
| :--- | :--- |
| `<Space>` | Tecla Líder (`<leader>`) |
| `<leader>pv` | Abrir explorador de arquivos (`Oil.nvim`) |
| `<leader>pf` | Buscar arquivos (`Snacks.picker.files`) |
| `<leader>ps` | Buscar texto no projeto / Grep (`Snacks.picker.grep`) |
| `<leader>pw` | Buscar palavra sob o cursor (`Snacks.picker.grep_word`) |
| `<leader>lg` | Abrir `LazyGit` flutuante |
| `<leader>f`  | Formatar buffer atual (`conform.nvim`) |
| `<leader>y` / `<leader>p` | Copiar / Colar na área de transferência do sistema |
| `J` / `K` (Visual) | Mover linhas selecionadas para cima / baixo |
| `<leader>gd` | Ir para definição de código (LSP) |
| `<leader>ca` | Ações de código / Code Actions (LSP) |
| `<leader>rn` | Renomear símbolo (LSP) |
| `<leader>vd` | Ver diagnósticos flutuantes (LSP) |
| `<leader>a`  | Adicionar caminho às visitas rápidas (`mini.visits`) |
| `<leader>h`  | Selecionar caminho visitado (`mini.visits`) |
| `<leader>1-5`| Abrir caminho visitado por índice |

---

## ⚖️ Licença

Distribuído sob a licença MIT. Desenvolvido com foco na soberania tecnológica, reprodutibilidade e modularidade.
