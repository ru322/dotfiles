{ inputs, pkgs, ... }:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  opencode = pkgs.symlinkJoin {
    name = "opencode";
    paths = [ llmAgents.opencode2 ];
    postBuild = ''
      mv $out/bin/opencode2 $out/bin/opencode
    '';
  };
in
{
  programs.codex = {
    enable = true;
    package = llmAgents.codex;
  };
  home.packages = [
    opencode
    pkgs.bubblewrap
  ];
}
