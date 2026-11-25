# AI コーディングエージェント用の bwrap ラッパー。
#
# エージェントは koyama と同じ uid で動くので、ファイル権限ではアプリ単位の
# 制限ができない。代わりに mount namespace を作り、ホームや他のマウントを
# tmpfs で隠してから、必要なパスだけを bind mount で戻す。
#
# hideNas:
#   /mnt/nas だけを隠す従来のモード。claude / codex 用。
#
# workspace:
#   起動時のカレントディレクトリを唯一の読み書き可能なワークスペースとして扱う。
#   ホームと /mnt などは tmpfs で隠し、opencode の状態ディレクトリ、Nix
#   プロファイル、git 設定だけを戻す。SSH 鍵や他プロジェクトは見えない。
{ pkgs }:
let
  lib = pkgs.lib;
  bwrap = "${pkgs.bubblewrap}/bin/bwrap";
  coreutils = pkgs.coreutils;

  # extraWritable / extraReadOnly はホスト側の絶対パスを渡す。
  workspace =
    {
      pkg,
      bin,
      extraWritable ? [ ],
      extraReadOnly ? [ ],
    }:
    pkgs.writeShellScriptBin bin ''
      set -eu

      workspace=$(pwd -P)

      die() {
        echo "${bin}: $*" >&2
        exit 1
      }

      # ワークスペースとして広すぎる場所は拒否する。ここを許可すると
      # ホーム全体やシステムディレクトリが読み書き可能になってしまう。
      case "$workspace" in
        /|/home|/root|/nix|/etc|/usr|/var|/run|/tmp|/mnt|/media|/boot|/dev|/proc|/sys|/srv|/opt|"$HOME")
          die "refusing to use $workspace as a workspace" ;;
        /nix/*|/etc/*|/usr/*|/var/*|/run/*|/dev/*|/proc/*|/sys/*|/boot/*)
          die "refusing to use $workspace as a workspace" ;;
        /mnt/nas|/mnt/nas/*)
          die "refusing to start from inside /mnt/nas (current directory: $workspace)" ;;
      esac

      # 状態ディレクトリの親をワークスペースにすると、その配下が丸ごと
      # 読み書き可能になるので拒否する。
      for p in "$HOME/.ssh" "$HOME/.gnupg" "$HOME/.config" "$HOME/.local" "$HOME/.cache"; do
        case "$p/" in
          "$workspace"/*) die "refusing to use $workspace as a workspace (it contains $p)" ;;
        esac
        case "$workspace/" in
          "$p"/*) die "refusing to use $workspace as a workspace (it is inside $p)" ;;
        esac
      done

      # 初回起動でも状態が失われないように、ホスト側の状態ディレクトリを作る。
      ${coreutils}/bin/mkdir -p \
        "$HOME/.local/share/opencode" \
        "$HOME/.local/state/opencode" \
        "$HOME/.cache/opencode"

      args=( --ro-bind / / )

      # ホームや外部マウントは空の tmpfs で覆う。存在しないディレクトリに
      # 対して --tmpfs すると bwrap が ro な / の下に作ろうとして失敗する。
      add_tmpfs() {
        if [ -d "$1" ]; then
          args+=( --tmpfs "$1" )
        fi
      }
      for d in /home /mnt /media /srv /opt /boot /root /var /run /tmp; do
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
        --dir "$HOME"
        --chmod 0700 "$HOME"
        --setenv TMPDIR /tmp
        --setenv XDG_RUNTIME_DIR /tmp/runtime
        # Nix がバージョンを管理しているので、自己更新は試させない。
        --setenv OPENCODE_DISABLE_AUTOUPDATE 1
        # タブは使わない。グローバルの cli.json は触らず、このラッパー経由の
        # 起動にだけ適用する。
        --setenv OPENCODE_CLI_CONFIG_CONTENT '{"tabs":{"mode":"off"}}'
        --cap-drop ALL
        --unshare-user
        --unshare-pid
        --unshare-ipc
        --disable-userns
        # --new-session は制御端末から切り離すため SIGWINCH が届かず、
        # kitty などのリサイズに OpenCode の TUI が追従しなくなる。
        # TIOCSTI は最近のカーネルでは既定で無効 (dev.tty.legacy_tiocsti=0)。
        --die-with-parent
      )

      # /run は tmpfs で隠すが、NixOS のシステムプロファイルだけは戻す。
      if [ -d /run/current-system ]; then
        args+=( --ro-bind /run/current-system /run/current-system )
      fi
      if [ -d /run/wrappers ]; then
        args+=( --ro-bind /run/wrappers /run/wrappers )
      fi

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

      # PATH に載っている Nix / home-manager のプロファイル。
      add_ro "$HOME/.nix-profile"
      add_ro "$HOME/.local/state/nix/profile"
      add_ro "$HOME/.local/bin"
      add_ro "$HOME/bin"

      # git の設定だけ戻す。~/.ssh や ~/.git-credentials は戻さない。
      add_ro "$HOME/.gitconfig"
      add_ro "$HOME/.config/git"
      add_ro "$HOME/.config/nix"

      # opencode 本体の設定は読み取り専用。プラグインを追加するときは
      # サンドボックス外の opencode で行う。
      add_ro "$HOME/.config/opencode"
      add_rw "$HOME/.local/share/opencode"
      add_rw "$HOME/.local/state/opencode"
      add_rw "$HOME/.cache/opencode"

      ${lib.concatMapStringsSep "\n" (p: "add_ro ${lib.escapeShellArg p}") extraReadOnly}
      ${lib.concatMapStringsSep "\n" (p: "add_rw ${lib.escapeShellArg p}") extraWritable}

      # service.json にはホスト側バックグラウンドサービスの URL とパスワードが
      # 入っている。サンドボックス内から localhost 経由でその API を叩かれると
      # bwrap の外でツールが実行されてしまうので、空のファイルで上書きする。
      # --standalone ならサービス情報は不要。
      exec {state_service_fd}<<< '{}'
      args+=( --perms 0600 --bind-data "$state_service_fd" "$HOME/.local/state/opencode/service.json" )
      exec {config_service_fd}<<< '{}'
      args+=( --perms 0600 --ro-bind-data "$config_service_fd" "$HOME/.config/opencode/service.json" )

      # ワークスペースは tmpfs を被せた後に戻す。これでカレントディレクトリ
      # だけが読み書き可能になる。
      args+=( --bind "$workspace" "$workspace" --chdir "$workspace" )

      # OpenCode V2 は既定で共有バックグラウンドサービスに接続する。ホスト側で
      # 既にサービスが動いているとツールがサンドボックスの外で実行されてしまう
      # ので、プライベートサーバーをサンドボックス内で起動させる。
      # service/serve/acp/debug/plugin/pair/upgrade は --standalone を受け付けない。
      standalone=1
      case "''${1-}" in
        service|serve|acp|debug|plugin|pair|upgrade)
          standalone=0 ;;
      esac

      cmd_args=()
      if [ "$standalone" -eq 1 ]; then
        cmd_args+=( --standalone )
      fi

      exec ${bwrap} "''${args[@]}" -- ${pkg}/bin/${bin} "''${cmd_args[@]}" "$@"
    '';

in
{
  inherit workspace;

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
