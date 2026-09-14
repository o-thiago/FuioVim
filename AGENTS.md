# AGENTS.md - Diretrizes do Projeto FuioVim

## Visão Geral do Projeto

**FuioVim** é um editor de código baseado em Neovim, empacotado e configurado hermeticamente utilizando [nix-wrapper-modules](https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html).

Princípios arquiteturais fundamentais:
- **Declarativo e Reprodutível**: Flake Nix totalmente reproduzível encapsulando o Neovim, seus plugins de tempo de execução, servidores de linguagem (LSPs), formatadores e linters sem depender de gerenciadores de pacotes imperativos (ex.: Mason, pip, npm).
- **Especificações Modulares Opt-In (`specs`)**: A base do editor inclui apenas o essencial por padrão. Ferramentas e linguagens específicas (Rust, Python, Web, C/C++, TeX, C#, PHP, Bash, YAML) são desabilitadas por padrão (`enable = lib.mkDefault false;`) para manter o ambiente enxuto. Usuários e configurações downstream ativam explicitamente o que precisam (`specs.<nome>.enable = true;`), o que adiciona simultaneamente os plugins Neovim e os binários ao `$PATH`.
- **Inspeção Dinâmica em Lua**: O estado das especificações ativas é exposto pelo módulo `nix-info` e consumido em Lua de forma centralizada através de `require("fuiovim.util").has_spec(nome)`.

---

## Padrões de Código e Formatação

### 1. Aninhamento de Atributos sobre Sintaxe Ponto
Prefira conjuntos de atributos aninhados sempre que houver mais de um atributo sob o mesmo prefixo. Evite repetir prefixos pontuados consecutivamente.

```nix
# Recomendado:
config = {
  binName = "fuiovim";

  settings = {
    config_directory = ./config;
    aliases = [ "fvim" "nvim" ];
  };
};

# Evitar:
config.binName = "fuiovim";
config.settings.config_directory = ./config;
config.settings.aliases = [ "fvim" "nvim" ];
```

### 2. Ordenação de Declarações
- Posicione definições mais curtas, escalares e simples no início do bloco.
- Posicione blocos aninhados, conjuntos multilinha e funções complexas no final do bloco envolvente.

### 3. Resolução de Binários via `lib.getExe`
Nunca use caminhos fixos de binários (como `"${pkg}/bin/fuiovim"`). Sempre utilize `lib.getExe` ou `lib.getExe'`:

```nix
program = lib.getExe fuiovimPkg;
program = lib.getExe' fuiovimPkg "nvim";
```

### 4. Formatação de Árvore com `nixfmt-tree`
Sempre configure `pkgs.nixfmt-tree` como o `formatter` do flake. O `nixfmt` padrão espera entrada via stdin, enquanto `nixfmt-tree` aceita caminhos de arquivos e formata a árvore do repositório corretamente via `nix fmt`.

### 5. Carregamento Preguiçoso Agressivo (Lazy-Loading)
Todo plugin passível de adiamento deve ser carregado preguiçosamente para garantir inicialização instantânea:
- Plugins visuais secundários e de presença: `event = "DeferredUIEnter"` (ex.: `cord.nvim`, `mini.icons`, `nvim-treesitter`).
- Plugins específicos do modo de inserção: `event = "InsertEnter"` (ex.: `mini.pairs`, `blink.cmp`).
- Ferramentas e utilitários: disparados por `cmd` ou `keys` (ex.: `oil.nvim`, `mini.visits`, `conform.nvim`).
- Plugins específicos por tipo de arquivo: `ft` (ex.: `vimtex`, `render-markdown`).

### 6. Centralização de Lógica sem Duplicação
Centralize utilitários e funções auxiliares em `lua/fuiovim/util.lua`. Nunca duplique lógica de verificação de especificações (`has_spec`), inspeção de plugins (`has_plugin`) ou detecções de ambiente.

### 7. Descrições em Português Brasileiro
Todas as descrições em opções Nix (`description`), mensagens de commit e descrições de atalhos em Lua (`desc`) devem estar redigidas em português brasileiro.

---

## Diretrizes de Git e Fluxo de Trabalho

### 1. Rastreamento Obrigatório no Git
Flakes Nix apenas avaliam arquivos rastreados pelo Git. Sempre execute `git add -A` antes de testar ou avaliar com o Nix.

### 2. Verificação Pré-Commit
Sempre valide as alterações com:
```bash
git add -A
nix fmt
nix flake check --no-build
nix run . -- --headless "+lua print('OK')" +qa
```

### 3. Commits Limpos e Convencionais
Mantenha o histórico sem arquivos esquecidos ou mensagens vagas:
- `feat(...)`: Nova funcionalidade ou configuração
- `fix(...)`: Correção de bug ou ajuste de configuração
- `refactor(...)`: Reorganização de código sem alteração funcional
- `docs(...)`: Atualizações de documentação (`README.md`, `AGENTS.md`)
- `style(...)`: Ajustes estéticos ou formatação
