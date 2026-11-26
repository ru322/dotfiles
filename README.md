# dotfiles

NixOS / Home Manager の個人設定。flake で管理しています。

## 構成

```
flake.nix           # マシンごとの nixosConfigurations と homeConfigurations
machines/<name>/    # configuration.nix, hardware-configuration.nix, home.nix
common/nixos/       # 共通の NixOS モジュール (gnome/hyprland, fonts, fcitx5, docker, ...)
common/home-mgr/    # 共通の Home Manager モジュール (fish, kitty, neovim, gnome, ...)
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

## AI エージェントのサンドボックス

`common/home-mgr/agent-sandbox.nix` が bwrap でエージェントを包みます。
`opencode` は起動したディレクトリをワークスペースとして、そこだけを読み書き可能にします。
ホーム、`/mnt`、`/media` などは tmpfs で隠し、opencode の状態ディレクトリ
(`~/.local/share/opencode` など)、Nix プロファイル、git 設定だけを戻します。
`/mnt/nas`、SSH 鍵、他のプロジェクトは見えません。

`claude` / `codex` / `agy` はホームを見せたまま `/mnt/nas` だけを隠します。

- `opencode` は `--standalone` で起動し、ホストのバックグラウンドサービスには接続しません。
  さらに `service.json` を空に上書きするので、ホスト側サービスの API も叩けません。
- 追加で許可したいパスは `common/home-mgr/codex.nix` の
  `sandbox.workspace { extraWritable = [ ... ]; extraReadOnly = [ ... ]; }` に書きます。
  パスはホスト側の絶対パスです。
- TUI のタブは `OPENCODE_CLI_CONFIG_CONTENT` で無効化しています (`tabs.mode: "off"`)。
  グローバルの `~/.config/opencode/cli.json` は変更しません。
- SSH 鍵が見えないため、`git push` はサンドボックス外で行います。
- ネットワークは隔離していません (モデル API に接続するため)。

## Satori のデスクトップ

GNOME 50 (Wayland) を GDM から起動します。標準の GNOME の操作に合わせつつ、
Colloid-Dark の GTK テーマ + アイコン、Afterglow (Catppuccin Pink) カーソル、
blur-my-shell によるパネル/ドック/Overview のブラー（OJII3 さんの dotfiles を
参考）でまとめています。壁紙は `~/Pictures/Wallpapers` (無ければ `~/Pictures`)
の画像から 30 分ごとにランダムに切り替わります (ログイン直後と
`home-manager switch` 時にも適用)。アプリウィンドウ自体は透過しません。
画面左には常時表示のドック (Dash to Dock) があり、アプリの起動と切り替えが
できます。GNOME と kitty の設定は共通モジュールに置いて、Orin / Alice とも
共有しています。

- `common/nixos/gnome.nix`: GDM、GNOME セッション、ポータル、gnome-keyring
- `common/home-mgr/gnome.nix`: Colloid テーマ/アイコン/カーソル、壁紙
  ローテーション、左ドック、クリップボード履歴、blur-my-shell、
  ショートカット、AppIndicator
- `common/home-mgr/kitty.nix`: UDEV Gothic 35NF、角丸ウィンドウ、左の
  powerline タブバー
- `machines/Satori/gnome.nix`: ノート PC の電源設定のみ (AC 接続中は
  自動サスペンドしない、バッテリー時は 30 分)

ショートカットは GNOME 標準 (Super でアクティビティ、`Super+←/→` で
ウィンドウをタイル、`Super+Tab` で切り替え) に加えて、`Super+Return` で
kitty、`Super+E` で Nautilus、`Super+Q` でウィンドウを閉じます。
`Super+V` でクリップボード履歴を開いて選択できます
(通知一覧は `Super+M`)。ワークスペースは `Super+Ctrl+←/→` で移動します。
スクリーンショットは GNOME 標準の Print / Alt+Print / Shift+Print です。

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

### Toolbox・Simulink などの追加

MathWorks 製品は Add-On Explorer から入れられません。製品を選ぶと MATLAB が終了して
後段の `AddOnInstaller` に引き継ぐ仕組みですが、`distrobox enter` のセッションが
MATLAB と一緒に終わるため、インストーラも途中で消えます。代わりに MATLAB を終了してから
`mpm` で追加します (`mpm` は上の手順で取得したものをそのまま使えます)。

```bash
distrobox enter matlab
./mpm install --release=R2026b \
  --destination=$HOME/.local/opt/MATLAB/R2026b \
  --products Simulink Control_System_Toolbox   # 製品名のスペースは _
exit
```

File Exchange などのコミュニティ製アドオンは MATLAB を終了せずに入るので、
Add-On Explorer からそのまま入れられます。

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
