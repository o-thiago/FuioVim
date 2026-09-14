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

## Instalação e Atualização em Distros Não-Nix

Você pode usar o FuioVim em qualquer distribuição Linux (Ubuntu, Debian, Fedora, Arch, etc.) sem alterar os pacotes gerenciados pelo seu sistema operacional.

### 1. Instalar o Nix

Utilize o instalador oficial multi-usuário do Nix:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Habilite o suporte a Flakes adicionando as flags experimentais em `~/.config/nix/nix.conf`:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Reinicie o terminal (ou encerre e inicie a sessão) para carregar o Nix no `$PATH`.

### 2. Instalar o FuioVim

Instale o pacote no perfil do seu usuário:

```bash
nix profile install github:o-thiago/FuioVim
```

Isso cria os executáveis `fuiovim`, `fvim` e `nvim` no diretório `~/.nix-profile/bin`.

### 3. Atualizar

Para atualizar o FuioVim para a versão mais recente:

```bash
nix profile install --refresh github:o-thiago/FuioVim
```

Ou, se preferir atualizar todos os pacotes do perfil:

```bash
nix profile upgrade '.*'
```

### 4. Desinstalar

Caso deseje remover o FuioVim:

```bash
nix profile remove fuiovim
```

---

## Uso com Flakes e Home Manager

O FuioVim expõe módulos prontos para o Home Manager e NixOS, além de permitir estender o wrapper para ativar linguagens ou adicionar plugins próprios.

### No Home Manager

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fuiovim.url = "github:o-thiago/FuioVim";
  };

  outputs = { self, nixpkgs, fuiovim, home-manager, ... }: {
    homeConfigurations."seu-usuario" = home-manager.lib.homeManagerConfiguration {
      modules = [
        fuiovim.homeManagerModules.default
        {
          wrappers.fuiovim = {
            enable = true;

            # Ativação das pilhas de linguagem desejadas (opt-in):
            specs = {
              rust.enable = true;
              web.enable = true;
              python.enable = true;
            };
          };
        }
      ];
    };
  };
}
```

### Personalização Avançada com `extend`

Você pode estender o módulo base do FuioVim para ajustar configurações ou incluir plugins adicionais:

```nix
let
  meuFuioVim = fuiovim.wrappers.fuiovim.extend {
    # Ativa linguagens necessárias
    specs = {
      rust.enable = true;
      c_cpp.enable = true;

      # Adiciona novos plugins
      meus-plugins = with pkgs.vimPlugins; [
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
