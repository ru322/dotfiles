{pkgs, ...}:
{
  home.packages = with pkgs; [
    sunshine
  ];

  # Sunshine設定ファイル
  xdg.configFile."sunshine/sunshine.conf" = {
    text = ''
      # Sunshine Configuration
      # Web UI: https://localhost:47990

      # ログレベル (none, fatal, error, warning, info, debug, verbose)
      min_log_level = info

      # エンコーダー (software, nvenc, vaapi, amdenc)
      encoder = software

      # ストリーミングポート
      port = 47989

      # UPnP有効化
      upnp = enabled

      # FPSターゲット
      fps = [30, 60]

      # 解像度オプション
      resolutions = [
        1280x720,
        1920x1080,
        2560x1440,
        3840x2160
      ]
    '';
  };

  # アプリケーション設定
  xdg.configFile."sunshine/apps.json" = {
    text = builtins.toJSON {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
      };
      apps = [
        {
          name = "Desktop";
          image-path = "";
        }
      ];
    };
  };
}
