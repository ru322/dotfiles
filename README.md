# dotfiles

NixOS / Home Manager の個人設定。flake で管理しています。

## 構成

```
flake.nix           # マシンごとの nixosConfigurations と homeConfigurations
machines/<name>/    # configuration.nix, hardware-configuration.nix, home.nix
common/nixos/       # 共通の NixOS モジュール (niri, fonts, fcitx5, docker, ...)
common/home-mgr/    # 共通の Home Manager モジュール (fish, kitty, neovim, noctalia, ...)
common/.config/     # 上記モジュールから配置する設定ファイル
resources/          # 壁紙、SSH 公開鍵
```

マシン: `Satori`, `Alice`, `Nix`, `NixWSL`, `Orin` (NixOS + Home Manager)、
`Sakura` (Home Manager のみ)

## 適用

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake path:.#<machine>
home-manager switch --flake path:.#<machine>
```

`path:` を付けると、Git に add する前の新規ファイルも含めて評価されます。

## Satori のデスクトップ

niri + noctalia (バー、ランチャー、通知、ロック画面、壁紙) で、tuigreet から起動します。
niri の設定は `common/nixos/niri.nix` が `/etc/niri/config.kdl` に配置するので、
`nixos-rebuild` で反映されます。

## MATLAB (Satori)

MATLAB は distrobox (podman) のコンテナ内で動かします。Nix が管理するのは
コンテナ定義 (`common/home-mgr/matlab.nix`) とランチャーの `matlab` コマンドだけで、
本体はライセンス認証が必要なため初回に手動でインストールします。
インストール先は `$HOME` 配下なので、コンテナを作り直しても消えません。

```bash
distrobox assemble create --file ~/.config/distrobox/containers.ini  # 通常は HM の systemd ユニットが実行済み
distrobox enter matlab
wget https://www.mathworks.com/mpm/glnxa64/mpm && chmod +x mpm
./mpm install --release=R2026b \
  --destination=$HOME/.local/opt/MATLAB/R2026b \
  --products MATLAB   # 必要な Toolbox を追加
exit
matlab   # 初回起動時に MathWorks アカウントでサインインしてライセンス認証
```

リリースを変えるときは `matlab.nix` の `release` とイメージのタグを合わせて変更します。

## Neovim

2 つの設定を共存させています。

- `nvim` — 軽い編集用の最小構成 (`common/.config/nvim`)。LSP なし、補完・検索・git 差分だけ
- `lv` (`NVIM_APPNAME=lazyvim nvim` の fish abbr) — LazyVim (`common/.config/lazyvim`)

プラグインは Nix ではなく lazy.nvim で管理します。どちらの `lazy-lock.json` も
このリポジトリに直接書き込まれるので、プラグインのバージョンも Git で追跡されます。

## 旧インストーラー

`install.sh` / `install.ps1` は Nix を使わない環境向けの旧シンボリックリンク方式の
インストーラーで、現在はメンテしていません。
