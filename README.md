# FuioVim

FuioVim é uma configuração de Neovim empacotada de forma declarativa e reproduzível com Nix através do [nix-wrapper-modules](https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html).

Em vez de usar instaladores imperativos (como Mason, scripts shell ou pacotes globais de pip e npm), o FuioVim gerencia plugins, LSPs, formatadores e ferramentas diretamente no ambiente Nix.

O projeto adota uma arquitetura predominantemente **opt-in**: a base do editor é leve e inclui apenas utilitários essenciais. Pilhas pesadas de linguagens específicas são desabilitadas por padrão, permitindo que você habilite somente o que usa.

---

## Execução Rápida (Sem Instalação)

Com o Nix instalado e suporte a Flakes ativo:

```bash
nix run github:o-thiago/FuioVim
```

---

## Instalação e Personalização com Home Manager (Recomendado)

Em distribuições não-NixOS (Ubuntu, Debian, Fedora, Arch, etc.), o **Home Manager** em modo *standalone* é a forma recomendada de instalar e personalizar o FuioVim de forma declarativa e reproduzível. Ele permite ativar toolchains adicionais (`specs`), configurar formatadores e gerenciar os binários sem interferir com os pacotes do sistema operacional.

### 1. Instalar o Nix e Habilitar Flakes

Se ainda não possui o Nix instalado:

```bash
# Instalador oficial multi-usuário (daemon):
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Habilite o suporte experimental a Flakes e novos comandos:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

> [!TIP]
> Reinicie o terminal ou encerre a sessão atual para que o Nix seja carregado no seu `$PATH`.

---

### 2. Configurar o Home Manager Standalone

Você pode configurar o Home Manager automaticamente através do instalador do FuioVim ou seguir o passo a passo manual.

#### Opção A: Configuração Automática via Script (Recomendado)

Execute o instalador oficial:

```bash
nix run github:o-thiago/FuioVim#setup-home-manager
```

Esse script realiza automaticamente:
- A detecção do seu usuário (`whoami`), diretório `$HOME`, arquitetura (`system`) e versão de estado do NixOS (`stateVersion`).
- A criação de `~/.config/home-manager/flake.nix` e `home.nix` já formatados com as opções e especificações do FuioVim.
- A inicialização do repositório Git local em `~/.config/home-manager/`.
- A compilação e ativação inicial do ambiente via `home-manager switch`.

> [!TIP]
> Para automações ou execução sem confirmação interativa, utilize a flag `-y`:
> ```bash
> nix run github:o-thiago/FuioVim#setup-home-manager -- --yes
> ```

---

#### Opção B: Configuração Manual Passo a Passo

Caso prefira criar os arquivos manualmente, crie o diretório:

```bash
mkdir -p ~/.config/home-manager
```

#### Arquivo `~/.config/home-manager/flake.nix`

Crie o arquivo `~/.config/home-manager/flake.nix` substituindo `"seu-usuario"` pelo nome do seu usuário Linux (descubra com `whoami`):

```nix
{
  description = "Configuração do Home Manager com FuioVim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fuiovim = {
      url = "github:o-thiago/FuioVim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      fuiovim,
      ...
    }:
    let
      system = "x86_64-linux"; # Altere para "aarch64-linux" se estiver em ARM
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."seu-usuario" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          fuiovim.homeManagerModules.default
        ];
      };
    };
}
```

#### Arquivo `~/.config/home-manager/home.nix`

Crie o arquivo `~/.config/home-manager/home.nix` ajustando `home.username` e `home.homeDirectory`:

```nix
{ pkgs, ... }:
{
  programs.home-manager.enable = true;

  home = {
    username = "seu-usuario";
    homeDirectory = "/home/seu-usuario";
    stateVersion = "26.11";
  };

  wrappers.fuiovim = {
    enable = true;

    # Ativação das pilhas de linguagem desejadas (opt-in):
    specs = {
      rust = { ... }: { enable = true; };
      python = { ... }: { enable = true; };
      web = { ... }: { enable = true; };
      c_cpp = { ... }: { enable = true; };
    };
  };
}
```

---

### 3. Aplicar a Configuração

Na primeira vez, aplique a configuração diretamente via `nix run`:

```bash
nix run home-manager -- switch --flake ~/.config/home-manager#seu-usuario
```

Após a primeira aplicação, o executável `home-manager` estará disponível no seu `$PATH`. Para aplicar futuras modificações:

```bash
home-manager switch --flake ~/.config/home-manager#seu-usuario
```

Os executáveis `fuiovim`, `fvim` e `nvim` estarão prontos para uso com todas as linguagens e LSPs selecionados instalados de maneira hermética.

---

### 4. Atualizar o FuioVim no Home Manager

Para atualizar o FuioVim para a versão mais recente da branch `main`:

```bash
cd ~/.config/home-manager
nix flake lock --update-input fuiovim
home-manager switch --flake .#seu-usuario
```

---

## Instalação Rápida via `nix profile` (Sem Customização)

Se você deseja apenas instalar o FuioVim com a configuração padrão (sem ativar toolchains opt-in como Rust, Python, etc.) e sem configurar o Home Manager:

### Instalar
```bash
nix profile install github:o-thiago/FuioVim
```

### Atualizar
```bash
nix profile install --refresh github:o-thiago/FuioVim
```

### Desinstalar
```bash
nix profile remove fuiovim
```

---

## Integração em Dotfiles Existentes (NixOS & Home Manager)

Caso você já possua um flake gerenciando seu sistema ou dotfiles:

### Módulo do Home Manager
Adicione o FuioVim aos inputs e importe o módulo:

```nix
{
  inputs.fuiovim.url = "github:o-thiago/FuioVim";

  # Na lista de modules do homeManagerConfiguration:
  modules = [
    fuiovim.homeManagerModules.default
    {
      wrappers.fuiovim = {
        enable = true;

        specs = {
          rust = { ... }: { enable = true; };
          # ...
        };
      };
    }
  ];
}
```

### Módulo do NixOS
Para instalar para todos os usuários do sistema em NixOS:

```nix
{
  inputs.fuiovim.url = "github:o-thiago/FuioVim";

  # Na lista de modules do nixosSystem:
  modules = [
    fuiovim.nixosModules.default
    {
      wrappers.fuiovim = {
        enable = true;

        specs = {
          rust = { ... }: { enable = true; };
          # ...
        };
      };
    }
  ];
}
```

---

## Personalização Avançada com `extend`

Você pode estender o módulo base do FuioVim em expressões Nix para ajustar opções ou adicionar plugins e pacotes adicionais:

```nix
let
  meuFuioVim = fuiovim.wrappers.fuiovim.extend {
    specs = {
      rust = { ... }: { enable = true; };

      # Adiciona plugins extras via spec customizada:
      meus-plugins.data = with pkgs.vimPlugins; [
        vim-fugitive
      ];
    };
  };
in
meuFuioVim.wrap { inherit pkgs; }
```

---

## Especificações e Pilhas (`specs`)

Cada especificação controla simultaneamente a ativação dos plugins no Neovim e a injeção dos respectivos binários (LSPs, formatadores, linters) no `$PATH`.

| Especificação | Padrão | Descrição | Componentes Principais |
| :--- | :--- | :--- | :--- |
| `core` | Ativo | Base do editor e UI essencial | `lze`, `rose-pine`, `mini`, `oil`, `snacks`, `cord`, `ripgrep`, `lazygit`, `figlet` |
| `completion` | Ativo | Autocompletar e snippets | `blink-cmp`, `friendly-snippets` |
| `treesitter` | Ativo | Realce de sintaxe Tree-sitter | `nvim-treesitter.withAllGrammars` |
| `lsp` | Ativo | Suporte a Language Server Protocol | `nvim-lspconfig` |
| `formatting` | Ativo | Formatação de arquivos ao salvar | `conform-nvim` |
| `linting` | Ativo | Linting assíncrono | `nvim-lint` |
| `markdown` | Ativo | Renderização visual de Markdown | `render-markdown-nvim` |
| `lua` | Ativo | Toolchain Lua | `lua-language-server`, `stylua` |
| `nix` | Ativo | Toolchain Nix | `nixd`, `statix`, `nixfmt` |
| `rust` | *Opt-in* | Toolchain Rust | `rustaceanvim`, `rust-analyzer`, `clippy`, `rustfmt` |
| `python` | *Opt-in* | Toolchain Python | `pyright`, `ruff` |
| `web` | *Opt-in* | JS, TS, HTML, CSS, Svelte, Tailwind | `typescript-language-server`, `tailwindcss`, `biome`, `svelte-language-server` |
| `c_cpp` | *Opt-in* | C e C++ | `clang-tools`, `cppcheck` |
| `tex` | *Opt-in* | LaTeX e TeX | `vimtex`, `texliveFull`, `texlab`, `zathura` |
| `csharp` | *Opt-in* | C# e .NET | `omnisharp-roslyn`, `csharpier` |
| `php` | *Opt-in* | PHP | `intelephense`, `phpactor`, `phpstan`, `php-cs-fixer` |
| `bash` | *Opt-in* | Scripts Shell / Bash | `bash-language-server`, `shfmt`, `shellcheck` |
| `yaml` | *Opt-in* | Arquivos YAML | `yaml-language-server`, `yamllint` |

---

## Atalhos Principais

| Atalho | Modo | Ação |
| :--- | :--- | :--- |
| `<Space>` | Normal | Tecla líder (`<leader>`) |
| `<leader>pv` | Normal | Abrir o gerenciador de arquivos (`Oil.nvim`) |
| `<leader>pf` | Normal | Localizar arquivos no projeto (`Snacks.picker.files`) |
| `<leader>ps` | Normal | Buscar texto no projeto (`Snacks.picker.grep`) |
| `<leader>pw` | Normal | Buscar palavra sob o cursor (`Snacks.picker.grep_word`) |
| `<leader>lg` | Normal | Abrir terminal com LazyGit flutuante |
| `<leader>f` | Normal | Formatar buffer atual (`conform.nvim`) |
| `<leader>y` / `<leader>p` | Normal/Visual | Copiar / Colar na área de transferência do sistema |
| `J` / `K` | Visual | Mover linhas selecionadas para baixo / cima |
| `<leader>gd` | Normal | Ir para a definição do símbolo (LSP) |
| `<leader>ca` | Normal | Ações de código (LSP / RustLsp) |
| `<leader>rn` | Normal | Renomear símbolo (LSP) |
| `<leader>vd` | Normal | Exibir diagnósticos flutuantes (LSP) |
| `<leader>a` | Normal | Adicionar caminho atual às visitas (`mini.visits`) |
| `<leader>h` | Normal | Selecionar caminho visitado (`mini.visits`) |
| `<leader>1` – `<leader>5` | Normal | Abrir caminho visitado pelo índice correspondente |

---

## Desenvolvimento Local

Para clonar e testar modificações no projeto:

```bash
# Entrar no shell com ferramentas de desenvolvimento (formatadores, LSPs)
nix develop

# Formatar os arquivos Nix do repositório
nix fmt

# Verificar integridade das definições do flake
nix flake check --no-build

# Testar execução local
nix run .
```

---

## Licença

Distribuído sob a licença MIT.
