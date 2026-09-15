# Configuração Local e Rebuild Independente (~/.config/FuioVim)

Este documento detalha o planejamento e a arquitetura para suportar uma experiência de instalação e personalização autônoma ("DX first") em distribuições Linux não-NixOS (Ubuntu, Debian, Fedora, Arch, etc.) sem exigir a adoção obrigatória do Home Manager.

---

## 1. Contexto e Motivação

Atualmente, o FuioVim oferece duas abordagens principais em distribuições não-NixOS:
1. **`nix profile install github:o-thiago/FuioVim`**: Rápido e direto, porém instala a distribuição com o conjunto padrão de especificações (`specs`), sem permitir ao usuário final habilitar pilhas de linguagens *opt-in* (como Rust, Python, Web) ou adicionar plugins próprios de forma declarativa.
2. **Home Manager Standalone**: Fornece controle declarativo completo e reproduzível, mas impõe o overhead de configurar e manter um ambiente de gerenciamento de usuário inteiro (`~/.config/home-manager/`).

### Objetivo
Permitir que o consumidor do FuioVim tenha um ambiente personalizável e reproduzível através de um template de configuração em `~/.config/FuioVim/flake.nix` (ou `~/.config/FuioVim/config.nix`), permitindo estender o editor e recompilá-lo facilmente, mantendo a solução **100% opt-in** e sem interferir com quem já utiliza Home Manager ou NixOS.

---

## 2. Arquitetura Proposta

### 2.1 Estrutura em `~/.config/FuioVim/`

O usuário terá um diretório dedicado de configuração local com a seguinte estrutura:

```
~/.config/FuioVim/
├── flake.nix       # Flake local que consome o FuioVim como input e expõe o pacote estendido
├── flake.lock      # Gerado automaticamente, garantindo reproducibilidade
├── config.nix      # Módulo com personalizações do usuário (specs, plugins, opções)
└── lua/            # (Opcional) Configurações e plugins Lua puros do usuário
```

#### Modelo do `~/.config/FuioVim/flake.nix`
```nix
{
  description = "Configuração personalizada do FuioVim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fuiovim = {
      url = "github:o-thiago/FuioVim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      fuiovim,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extended = fuiovim.wrappers.fuiovim.extend (import ./config.nix { inherit pkgs; });
        in
        {
          default = extended.wrap { inherit pkgs; };
          fuiovim = extended.wrap { inherit pkgs; };
        }
      );
    };
}
```

#### Modelo do `~/.config/FuioVim/config.nix`
```nix
{ pkgs }:
{
  # Configurações do Neovim / Wrapper:
  settings.neovide.enable = false;

  # Ativação das pilhas de linguagem desejadas:
  specs = {
    rust = { ... }: { enable = true; };
    python = { ... }: { enable = true; };
    web = { ... }: { enable = true; };

    # Adição de plugins extras:
    meus-plugins.data = with pkgs.vimPlugins; [
      vim-fugitive
    ];
  };
}
```

---

## 3. Experiência do Desenvolvedor (DX) & Fluxo de Rebuild

Para manter a simplicidade sem exigir conhecimentos avançados de Nix:

### 3.1 Inicialização (Bootstrap)
O usuário poderá inicializar o template com um comando simples do Nix:
```bash
mkdir -p ~/.config/FuioVim
cd ~/.config/FuioVim
nix flake init -t github:o-thiago/FuioVim
```

Ou através de uma `app` fornecida diretamente pelo flake do FuioVim:
```bash
nix run github:o-thiago/FuioVim#init
```
Esse script cuidará de:
1. Criar o diretório `~/.config/FuioVim/` (sem sobrescrever se já existir).
2. Copiar os arquivos de template `flake.nix` e `config.nix`.
3. Executar o primeiro build e instalar no perfil do usuário (`nix profile install ~/.config/FuioVim`).

### 3.2 Rebuild e Atualizações
Após editar `~/.config/FuioVim/config.nix`, o usuário poderá aplicar as mudanças com um comando único:
```bash
# Script de conveniência empacotado no FuioVim ou alias de shell:
fvim-rebuild
# Equivalente a:
nix profile install --upgrade ~/.config/FuioVim
```

Para atualizar o FuioVim upstream:
```bash
cd ~/.config/FuioVim
nix flake lock --update-input fuiovim
fvim-rebuild
```

---

## 4. Garantia de Isolamento e Opt-in

- **Sem efeitos colaterais para Home Manager / NixOS**:
  O código principal do FuioVim e seus módulos (`homeManagerModules.default`, `nixosModules.default`) **não** realizam buscas impuras em `~/.config/FuioVim`. O comportamento existente permanece idêntico e estritamente declarativo.
- **Pureza e Reproducibilidade**:
  O diretório `~/.config/FuioVim/` funciona como um flake independente com seu próprio `flake.lock`, evitando flags impuras (`--impure`) ou inconsistências de build.

---

## 5. Roteiro de Tarefas (Roadmap)

### Fase 1: Template de Flake
- [ ] Criar diretório `templates/default/` no repositório com:
  - `flake.nix`: estrutura mínima que consome o wrapper do FuioVim e exporta o pacote.
  - `config.nix`: arquivo comentado em português com exemplos de ativação de `specs` e plugins.
- [ ] Declarar `templates.default` no `flake.nix` raiz do FuioVim.
- [ ] Documentar o comando `nix flake init -t github:o-thiago/FuioVim ~/.config/FuioVim` no README.

### Fase 2: Automação de Bootstrap e Rebuild
- [ ] Adicionar app `init` no `flake.nix` (`apps.init`): script shell que cria `~/.config/FuioVim` e inicializa o flake caso o diretório não exista.
- [ ] Adicionar app/binário `rebuild` (`apps.rebuild` ou embutido no wrapper como `fvim-rebuild`) que executa a recompilação e atualização do perfil Nix.

### Fase 3: Suporte a Diretório Lua Customizado
- [ ] Permitir que o wrapper importe arquivos Lua em `~/.config/FuioVim/lua/` ou `~/.config/FuioVim/after/` de forma opcional (via `opt-in` no `config.nix`).

### Fase 4: CI e Testes
- [ ] Adicionar step de CI no GitHub Actions validando que o template `templates/default` avalia com sucesso (`nix flake check` no template).
- [ ] Testar idempotência dos comandos `init` e `rebuild`.
