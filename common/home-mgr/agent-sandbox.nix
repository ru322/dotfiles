# AI コーディングエージェント用の bwrap ラッパー。
#
# エージェントは koyama と同じ uid で動くので、ファイル権限ではアプリ単位の
# 制限ができない。代わりに mount namespace を作り、ルートを基本 RO にした上で
# /mnt/nas や認証系・プライベートパスを遮蔽し、ワークスペースとエージェント自身の
# 状態ディレクトリだけを選択的に RW で公開する。
#
# workspace (およびプリセット agy / opencode / claude / codex):
#   RO ベース + 機密マスク + 選択的 RW モード。
#   - `/` を `--ro-bind` で読み取り専用にする（非認証の config 類は閲覧可）。
#   - `/mnt`（`/mnt/nas` を含む）, `/media`, `/run`（gvfs, ssh-agent, keyring,
#     dbus, podman 等）, `/var`, `/tmp`, `/root`, `/boot`, `/srv` は tmpfs で遮蔽。
#   - SSH 鍵、GPG、keyring、各種 CLI/クラウド認証、ブラウザプロファイル、シェル履歴、
#     個人用ディレクトリ（Documents, Downloads, myObsidian 等）、他エージェントの
#     認証・状態ディレクトリを遮蔽する。
#   - 起動時のカレントディレクトリと、エージェント自身の状態ディレクトリだけを RW にする。
#
# hideNas:
#   /mnt/nas だけを隠す従来の軽量モード（必要時のフォールバック用）。
{ pkgs }:
let
  lib = pkgs.lib;
  bwrap = "${pkgs.bubblewrap}/bin/bwrap";
  coreutils = pkgs.coreutils;
  emptyFile = pkgs.writeText "agent-sandbox-empty" "";

  # デフォルトで遮蔽する $HOME 配下の認証・機密・プライベートパス。
  # ディレクトリは 0000 の空 tmpfs、ファイルは空の RO ファイルで覆う。
  # エージェント自身の stateDirs / stateFiles に含まれるパスは自動的に除外される。
  defaultHomeMasked = [
    # 鍵・証明書・キーリング・Git/netrc 認証
    ".ssh"
    ".gnupg"
    ".pki"
    ".password-store"
    ".local/share/keyrings"
    ".local/share/kwalletd"
    ".local/share/pki"
    ".netrc"
    ".git-credentials"
    ".config/git/credentials"
    ".pulse-cookie"

    # クラウド・開発 CLI・パッケージレジストリ認証
    ".aws"
    ".azure"
    ".kube"
    ".docker"
    ".config/gcloud"
    ".config/gh"
    ".config/github-copilot"
    ".copilot"
    ".config/.wrangler"
    ".config/configstore"
    ".config/atcoder-cli-nodejs"
    ".local/share/online-judge-tools"
    ".npmrc"
    ".pypirc"
    ".cargo/credentials"
    ".cargo/credentials.toml"
    ".gem/credentials"
    ".cache/huggingface"
    ".config/containers/auth.json"
    ".local/share/containers/auth.json"

    # ブラウザ・デスクトップアプリ認証
    ".mozilla"
    ".config/mozilla"
    ".config/chromium"
    ".config/google-chrome"
    ".config/BraveSoftware"
    ".config/discord"
    ".config/remmina"
    ".local/share/remmina"
    ".config/freerdp"
    ".config/evolution"
    ".local/share/evolution"
    ".config/goa-1.0"
    ".config/konsolesshconfig"
    ".config/spotify-player"
    ".local/share/GitKrakenCLI"
    ".local/share/gk"
    ".MathWorks"
    ".steam"
    ".local/share/Steam"

    # プライベートな個人用ディレクトリ
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Public"
    "Templates"
    "Videos"
    "myObsidian"

    # シェル履歴（トークンやパスワードが残りやすい）
    ".bash_history"
    ".zsh_history"
    ".local/share/fish/fish_history"

    # 他 AI エージェントの認証・状態 & ホスト側オーケストレータのソケット
    ".claude"
    ".claude.json"
    ".cache/claude-cli-nodejs"
    ".codex"
    ".config/Codex"
    ".local/state/codex"
    ".cache/Codex"
    ".cache/codex-runtimes"
    ".codebuddy.json"
    ".t3"
    ".config/t3code-v2"
    ".gemini"
    ".config/antigravity"
    ".cache/antigravity"
    ".local/share/opencode"
    ".local/state/opencode"
    ".cache/opencode"
    ".config/herdr"
    ".local/state/herdr"
  ];

  # stateDirs / stateFiles / unmasked: $HOME からの相対パス、または絶対パス。
  # extraWritable / extraReadOnly / extraMasked: ホスト側の絶対パス（または $HOME 相対）。
  workspace =
    {
      pkg,
      bin,
      stateDirs ? [ ],
      stateFiles ? [ ],
      extraWritable ? [ ],
      extraReadOnly ? [ ],
      extraMasked ? [ ],
      unmasked ? [ ],
      extraEnv ? { },
      extraBwrapSetup ? "",
      extraCmdSetup ? "",
    }:
    let
      envArgs = lib.concatMapStringsSep "\n" (
        name:
        "args+=( --setenv ${lib.escapeShellArg name} ${lib.escapeShellArg extraEnv.${name}} )"
      ) (builtins.attrNames extraEnv);
    in
    pkgs.writeShellScriptBin bin ''
      set -eu

      workspace=$(pwd -P)

      die() {
        echo "${bin}: $*" >&2
        exit 1
      }

      resolve_path() {
        case "$1" in
          /*) printf '%s\n' "$1" ;;
          *)  printf '%s\n' "$HOME/$1" ;;
        esac
      }

      # ワークスペースとして広すぎる場所や /mnt/nas 配下は拒否する。
      case "$workspace" in
        /mnt/nas|/mnt/nas/*)
          die "refusing to start from inside /mnt/nas (current directory: $workspace)" ;;
        /|/home|/root|/nix|/etc|/usr|/var|/run|/tmp|/mnt|/media|/boot|/dev|/proc|/sys|/srv|/opt|"$HOME")
          die "refusing to use $workspace as a workspace" ;;
        /nix/*|/etc/*|/usr/*|/var/*|/run/*|/dev/*|/proc/*|/sys/*|/boot/*|/mnt/*|/media/*)
          die "refusing to use $workspace as a workspace" ;;
      esac

      # 機密・状態ディレクトリの親や内部をワークスペースにすると保護が破れるので拒否する。
      for p in \
        "$HOME/.ssh" \
        "$HOME/.gnupg" \
        "$HOME/.config" \
        "$HOME/.local" \
        "$HOME/.cache" \
        "$HOME/.gemini" \
        "$HOME/.claude" \
        "$HOME/.codex"; do
        case "$p/" in
          "$workspace"/*) die "refusing to use $workspace as a workspace (it contains $p)" ;;
        esac
        case "$workspace/" in
          "$p"/*) die "refusing to use $workspace as a workspace (it is inside $p)" ;;
        esac
      done

      state_dirs=()
      ${lib.concatMapStringsSep "\n" (
        p: ''state_dirs+=( "$(resolve_path ${lib.escapeShellArg p})" )''
      ) stateDirs}

      state_files=()
      ${lib.concatMapStringsSep "\n" (
        p: ''state_files+=( "$(resolve_path ${lib.escapeShellArg p})" )''
      ) stateFiles}

      # 初回起動でも状態が失われないように、ホスト側の状態ディレクトリ・ファイルを作る。
      for d in "''${state_dirs[@]}"; do
        ${coreutils}/bin/mkdir -p "$d"
      done
      for f in "''${state_files[@]}"; do
        ${coreutils}/bin/mkdir -p "$(${coreutils}/bin/dirname "$f")"
        if [ ! -e "$f" ]; then
          ${coreutils}/bin/touch "$f"
        fi
      done

      # 遮蔽対象から除外するパス集合（自身の状態パス + 明示的な unmasked / extraWritable）。
      declare -A unmasked_set=()
      for p in "''${state_dirs[@]}" "''${state_files[@]}"; do
        unmasked_set["$p"]=1
      done
      ${lib.concatMapStringsSep "\n" (
        p: ''unmasked_set["$(resolve_path ${lib.escapeShellArg p})"]=1''
      ) (unmasked ++ extraWritable)}

      # ルート全体を読み取り専用でバインドする（非認証の config 類はそのまま読める）。
      args=( --ro-bind / / )

      # 外部マウント（/mnt/nas を含む /mnt, /media）やホストのランタイムソケット群
      # （/run/user/$UID/{gvfs,ssh-agent,gnupg,keyring,bus,podman} 等）を空の tmpfs で遮蔽する。
      add_tmpfs() {
        if [ -d "$1" ]; then
          args+=( --tmpfs "$1" )
        fi
      }
      for d in /mnt /media /srv /boot /root /var /run /tmp; do
        add_tmpfs "$d"
      done

      args+=(
        --dir /var/tmp
        --chmod 1777 /var/tmp
        --symlink /run /var/run
        --chmod 1777 /tmp
        --dir /tmp/runtime
        --chmod 0700 /tmp/runtime
        --dev /dev
        --tmpfs /dev/shm
        --chmod 1777 /dev/shm
        --proc /proc
        --setenv TMPDIR /tmp
        --setenv XDG_RUNTIME_DIR /tmp/runtime
        --unsetenv SSH_AUTH_SOCK
        --unsetenv DBUS_SESSION_BUS_ADDRESS
        --unsetenv GPG_AGENT_INFO
        --unsetenv XAUTHORITY
        --cap-drop ALL
        --unshare-user
        --unshare-pid
        --unshare-ipc
        --disable-userns
        # --new-session は制御端末から切り離すため SIGWINCH が届かず、
        # kitty などのリサイズに TUI が追従しなくなる。
        # TIOCSTI は最近のカーネルでは既定で無効 (dev.tty.legacy_tiocsti=0)。
        --die-with-parent
      )

      ${envArgs}

      # /run は tmpfs で隠すが、NixOS のシステムプロファイルだけは RO で戻す。
      if [ -d /run/current-system ]; then
        args+=( --ro-bind /run/current-system /run/current-system )
      fi
      if [ -d /run/wrappers ]; then
        args+=( --ro-bind /run/wrappers /run/wrappers )
      fi

      # 認証・機密・プライベートパスを遮蔽する。
      mask_path() {
        local p="$1"
        if [ -n "''${unmasked_set[$p]:-}" ] || [ "$p" = "$workspace" ]; then
          return 0
        fi
        if [ -d "$p" ]; then
          # ワークスペースが遮蔽対象ディレクトリ配下にある場合（例: ~/Documents/work）は
          # 0500 の空 tmpfs にし、兄弟ファイルを隠しつつワークスペースの bind を通す。
          case "$workspace" in
            "$p"/*)
              args+=( --perms 0500 --tmpfs "$p" ) ;;
            *)
              args+=( --perms 0000 --tmpfs "$p" ) ;;
          esac
        elif [ -e "$p" ]; then
          args+=( --ro-bind ${emptyFile} "$p" )
        fi
      }

      ${lib.concatMapStringsSep "\n" (
        p: ''mask_path "$(resolve_path ${lib.escapeShellArg p})"''
      ) (defaultHomeMasked ++ extraMasked)}

      add_ro() {
        if [ -e "$1" ]; then
          args+=( --ro-bind "$1" "$1" )
        fi
      }
      add_rw() {
        if [ -e "$1" ]; then
          args+=( --bind "$1" "$1" )
        fi
      }

      # 選択的 RW: エージェント自身の状態ディレクトリ・ファイルと追加許可パス。
      for p in "''${state_dirs[@]}" "''${state_files[@]}"; do
        add_rw "$p"
      done
      ${lib.concatMapStringsSep "\n" (
        p: ''add_ro "$(resolve_path ${lib.escapeShellArg p})"''
      ) extraReadOnly}
      ${lib.concatMapStringsSep "\n" (
        p: ''add_rw "$(resolve_path ${lib.escapeShellArg p})"''
      ) extraWritable}

      ${extraBwrapSetup}

      # 起動時のワークスペースだけを RW でバインドする。
      args+=( --bind "$workspace" "$workspace" --chdir "$workspace" )

      cmd_args=()
      ${extraCmdSetup}

      exec ${bwrap} "''${args[@]}" -- ${pkg}/bin/${bin} "''${cmd_args[@]}" "$@"
    '';

  opencode =
    {
      pkg,
      bin ? "opencode",
      extraWritable ? [ ],
      extraReadOnly ? [ ],
      extraMasked ? [ ],
      unmasked ? [ ],
    }:
    workspace {
      inherit
        pkg
        bin
        extraWritable
        extraReadOnly
        extraMasked
        unmasked
        ;
      stateDirs = [
        ".local/share/opencode"
        ".local/state/opencode"
        ".cache/opencode"
      ];
      extraEnv = {
        # Nix がバージョンを管理しているので、自己更新は試させない。
        OPENCODE_DISABLE_AUTOUPDATE = "1";
        # タブは使わない。グローバルの cli.json は触らず、このラッパー経由の
        # 起動にだけ適用する。
        OPENCODE_CLI_CONFIG_CONTENT = ''{"tabs":{"mode":"off"}}'';
      };
      # service.json にはホスト側バックグラウンドサービスの URL とパスワードが
      # 入っている。サンドボックス内から localhost 経由でその API を叩かれると
      # bwrap の外でツールが実行されてしまうので、空のファイルで上書きする。
      extraBwrapSetup = ''
        exec {state_service_fd}<<< '{}'
        args+=( --perms 0600 --bind-data "$state_service_fd" "$HOME/.local/state/opencode/service.json" )
        exec {config_service_fd}<<< '{}'
        args+=( --perms 0600 --ro-bind-data "$config_service_fd" "$HOME/.config/opencode/service.json" )
      '';
      # OpenCode V2 は既定で共有バックグラウンドサービスに接続する。ホスト側で
      # 既にサービスが動いているとツールがサンドボックスの外で実行されてしまう
      # ので、プライベートサーバーをサンドボックス内で起動させる。
      # service/serve/acp/debug/plugin/pair/upgrade は --standalone を受け付けない。
      extraCmdSetup = ''
        standalone=1
        case "''${1-}" in
          service|serve|acp|debug|plugin|pair|upgrade)
            standalone=0 ;;
        esac
        if [ "$standalone" -eq 1 ]; then
          cmd_args+=( --standalone )
        fi
      '';
    };

  agy =
    {
      pkg,
      bin ? "agy",
      extraWritable ? [ ],
      extraReadOnly ? [ ],
      extraMasked ? [ ],
      unmasked ? [ ],
    }:
    workspace {
      inherit
        pkg
        bin
        extraWritable
        extraReadOnly
        extraMasked
        unmasked
        ;
      stateDirs = [
        ".gemini"
        ".config/antigravity"
        ".cache/antigravity"
      ];
    };

  claude =
    {
      pkg,
      bin ? "claude",
      extraWritable ? [ ],
      extraReadOnly ? [ ],
      extraMasked ? [ ],
      unmasked ? [ ],
    }:
    workspace {
      inherit
        pkg
        bin
        extraWritable
        extraReadOnly
        extraMasked
        unmasked
        ;
      stateDirs = [
        ".claude"
        ".cache/claude-cli-nodejs"
      ];
      stateFiles = [
        ".claude.json"
      ];
    };

  codex =
    {
      pkg,
      bin ? "codex",
      extraWritable ? [ ],
      extraReadOnly ? [ ],
      extraMasked ? [ ],
      unmasked ? [ ],
    }:
    workspace {
      inherit
        pkg
        bin
        extraWritable
        extraReadOnly
        extraMasked
        unmasked
        ;
      stateDirs = [
        ".codex"
        ".local/state/codex"
        ".cache/codex-runtimes"
      ];
    };
in
{
  inherit
    workspace
    opencode
    agy
    claude
    codex
    ;

  hideNas =
    pkg: bin:
    pkgs.writeShellScriptBin bin ''
      set -eu

      # cwd が /mnt/nas 配下だと、上にマウントを被せても cwd 経由で元の
      # ファイルに届いてしまうので、その場合は起動を拒否する。
      case "$PWD/" in
        /mnt/nas/*)
          echo "${bin}: refusing to start from inside /mnt/nas (current directory: $PWD)" >&2
          exit 1
          ;;
      esac

      exec ${bwrap} \
        --dev-bind / / \
        --tmpfs /mnt/nas \
        --unshare-pid \
        --proc /proc \
        --die-with-parent \
        -- ${pkg}/bin/${bin} "$@"
    '';
}
