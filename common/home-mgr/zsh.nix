{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    zsh-abbr = {
        enable = true;
        abbreviations = {
            "gc" = "git commit -m \"\"";
        };
    };
    initContent =  ''
        source ${../.config/zsh/.zshrc}
    '';
  };
}
