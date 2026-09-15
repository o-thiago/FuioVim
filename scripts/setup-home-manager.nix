{ pkgs, system }:
let
  stateVersion = pkgs.lib.trivial.release;
in
pkgs.writeShellApplication {
  name = "setup-home-manager";

  runtimeInputs = with pkgs; [
    coreutils
    git
    gnused
    nix
    nixfmt
  ];

  text = ''
        AUTO_APPLY=false
        FORCE=false

        for arg in "$@"; do
          case "$arg" in
            -y|--yes)
              AUTO_APPLY=true
              ;;
            -f|--force)
              FORCE=true
              ;;
            -h|--help)
              echo "Uso: setup-home-manager [opções]"
              echo "Opções:"
              echo "  -y, --yes    Aplica a configuração do Home Manager automaticamente sem confirmação"
              echo "  -f, --force  Substitui arquivos existentes criando backup automático"
              echo "  -h, --help   Exibe esta mensagem de ajuda"
              exit 0
              ;;
            *)
              echo "Opção desconhecida: $arg"
              echo "Execute com --help para ver as opções disponíveis."
              exit 1
              ;;
          esac
        done

        TARGET_USER="''${USER:-$(id -un)}"
        TARGET_HOME="''${HOME:-$(getent passwd "$TARGET_USER" | cut -d: -f6)}"
        TARGET_DIR="$TARGET_HOME/.config/home-manager"

        echo "==> Configurando FuioVim com Home Manager Standalone"
        echo "    Usuário: $TARGET_USER"
        echo "    Diretório: $TARGET_HOME"
        echo "    Sistema: ${system}"
        echo "    Versão do NixOS: ${stateVersion}"
        echo ""

        if [ -d "$TARGET_DIR" ]; then
          if [ -f "$TARGET_DIR/flake.nix" ] || [ -f "$TARGET_DIR/home.nix" ]; then
            echo "Aviso: O diretório '$TARGET_DIR' já existe e contém arquivos de configuração."
            if [ "$FORCE" = true ]; then
              BACKUP_DIR="$TARGET_DIR.backup.$(date +%Y%m%d%H%M%S)"
              mv "$TARGET_DIR" "$BACKUP_DIR"
              echo "Backup criado em: $BACKUP_DIR"
            else
              printf "Deseja criar um backup antes de prosseguir? (s/N): "
              read -r response
              if [ "$response" = "s" ] || [ "$response" = "S" ]; then
                BACKUP_DIR="$TARGET_DIR.backup.$(date +%Y%m%d%H%M%S)"
                mv "$TARGET_DIR" "$BACKUP_DIR"
                echo "Backup criado em: $BACKUP_DIR"
              else
                echo "Operação cancelada para evitar sobrescrever sua configuração existente."
                exit 1
              fi
            fi
          fi
        fi

        mkdir -p "$TARGET_DIR"

        echo "==> Gerando $TARGET_DIR/flake.nix..."
        cat <<'EOF' > "$TARGET_DIR/flake.nix"
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
          system = "@system@";
          pkgs = nixpkgs.legacyPackages.''${system};
        in
        {
          homeConfigurations."@user@" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
              fuiovim.homeManagerModules.default
            ];
          };
        };
    }
    EOF

        sed -i "s|@system@|${system}|g" "$TARGET_DIR/flake.nix"
        sed -i "s|@user@|''${TARGET_USER}|g" "$TARGET_DIR/flake.nix"

        echo "==> Gerando $TARGET_DIR/home.nix..."
        cat <<'EOF' > "$TARGET_DIR/home.nix"
    { pkgs, ... }:
    {
      programs.home-manager.enable = true;

      home = {
        username = "@user@";
        homeDirectory = "@home@";
        stateVersion = "@stateVersion@";
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
    EOF

        sed -i "s|@user@|''${TARGET_USER}|g" "$TARGET_DIR/home.nix"
        sed -i "s|@home@|''${TARGET_HOME}|g" "$TARGET_DIR/home.nix"
        sed -i "s|@stateVersion@|${stateVersion}|g" "$TARGET_DIR/home.nix"

        echo "==> Formatando arquivos Nix gerados..."
        nixfmt "$TARGET_DIR/flake.nix" "$TARGET_DIR/home.nix"

        if command -v git >/dev/null 2>&1; then
          echo "==> Inicializando repositório Git em $TARGET_DIR..."
          if [ ! -d "$TARGET_DIR/.git" ]; then
            git -C "$TARGET_DIR" init -q
          fi
          git -C "$TARGET_DIR" add flake.nix home.nix
        fi

        echo ""
        echo "Configuração gerada com sucesso em: $TARGET_DIR"
        echo ""

        if [ "$AUTO_APPLY" = true ]; then
          APPLY=true
        else
          printf "Deseja aplicar a configuração agora com o Home Manager? (S/n): "
          read -r apply_response
          if [ "$apply_response" != "n" ] && [ "$apply_response" != "N" ]; then
            APPLY=true
          else
            APPLY=false
          fi
        fi

        if [ "$APPLY" = true ]; then
          echo "==> Executando 'nix run home-manager -- switch --flake $TARGET_DIR#$TARGET_USER'..."
          nix run home-manager -- switch --flake "$TARGET_DIR#$TARGET_USER"
          echo ""
          echo "==> Sucesso! O FuioVim foi instalado no seu perfil de usuário."
          echo "    Comandos disponíveis: fuiovim, fvim, nvim"
          echo "    Para modificar especificações, edite '$TARGET_DIR/home.nix' e execute:"
          echo "      home-manager switch --flake \"$TARGET_DIR#$TARGET_USER\""
        else
          echo "Para aplicar a configuração manualmente, execute:"
          echo "  nix run home-manager -- switch --flake \"$TARGET_DIR#$TARGET_USER\""
        fi
  '';
}
