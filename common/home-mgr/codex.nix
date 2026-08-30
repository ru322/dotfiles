{ inputs, pkgs, ... }:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.codex = {
    enable = true;
    package = llmAgents.codex;
  };
  home.packages = [
    llmAgents.opencode
    pkgs.bubblewrap
  ];
}
