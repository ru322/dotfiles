# Common programs configuration
{ pkgs, ... }:

{
  environment.etc."codex/config.toml".text = ''
    approval_policy = "on-request"
    approvals_reviewer = "auto_review"
    sandbox_mode = "workspace-write"
  '';

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "0";
  };

  users.defaultUserShell = pkgs.fish;

  programs = {
    firefox = {
      enable = true;
      # Electron アプリ (Discord, Unity Hub 等) は子プロセスに GDK_BACKEND=wayland を渡すため、
      # MOZ_ENABLE_WAYLAND=0 と矛盾して "cannot open display" でリンクが開けなくなるのを防ぐ
      package = pkgs.firefox.overrideAttrs (old: {
        makeWrapperArgs = old.makeWrapperArgs ++ [
          "--unset"
          "GDK_BACKEND"
        ];
      });
    };
    git.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    starship.enable = true;
    zsh.enable = true;
    fish.enable = true;
    nix-ld.enable = true;
  };
}
