{ ... }:
{
  programs.fish = {
    enable = true;
    shellAbbrs = {
      gc = {
        setCursor = true;
        expansion = "git commit -m \"%\"";
      };
      lg = "lazygit";
      sp = "spotify_player";
      lv = "NVIM_APPNAME=lazyvim nvim";
    };
    functions = {
      gcd = ''
        set -l dir (ghq list -p | fzf); and cd $dir
      '';
    };
    interactiveShellInit = ''
      set -g fish_greeting

      # Ctrl+Backspaceで単語単位に削除
      # 端末によって Ctrl+Backspace の送信値が異なるため両方に対応
      bind \b backward-kill-word
      bind \e\x7f backward-kill-word
    '';
  };
}
