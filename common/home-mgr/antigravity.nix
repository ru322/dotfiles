{ inputs, pkgs, ... }:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  sandbox = import ./agent-sandbox.nix { inherit pkgs; };
in
{
  home.packages = [
    # RO ベース + 機密マスク + 選択的 RW で隔離する。
    # herdr-opencode スキルで herdr CLI を使うため、agy のみ .config/herdr を許可する。
    (sandbox.agy {
      pkg = llmAgents.antigravity-cli;
      unmasked = [ ".config/herdr" ];
    })
    pkgs.jq
  ];

  home.file.".gemini/config/skills/herdr-opencode" = {
    source = ../.gemini/skills/herdr-opencode;
    recursive = true;
  };
}
