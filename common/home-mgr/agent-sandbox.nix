# AI コーディングエージェントから /mnt/nas を隠すラッパーを作る。
#
# 使い方: sandbox <package> <binary-name>
#
# エージェントは koyama と同じ uid で動くので、ファイル権限ではアプリ単位の
# 制限ができない。代わりに mount namespace を作り、/mnt/nas の上に空の
# tmpfs を被せることで、エージェント本体からも、そこから起動される bash
# ツールからも NAS が見えないようにする。
#
# --unshare-pid と --proc /proc は、/proc/<host-pid>/root/mnt/nas 経由で
# ホスト側のマウントに抜けられるのを防ぐために必要。
{ pkgs }:
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

  exec ${pkgs.bubblewrap}/bin/bwrap \
    --dev-bind / / \
    --tmpfs /mnt/nas \
    --unshare-pid \
    --proc /proc \
    --die-with-parent \
    -- ${pkg}/bin/${bin} "$@"
''
