{ inputs, pkgs, lib, ... }:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  sandbox = import ./agent-sandbox.nix { inherit pkgs; };
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
    (sandbox opencode "opencode")
    # programs.codex が入れる本物の codex より優先して、ラッパーを PATH に置く。
    # cfg.package は本物のままなので、ホームマネージャーのバージョン判定は壊れない。
    (lib.hiPrio (sandbox llmAgents.codex "codex"))
    pkgs.bubblewrap
  ];
}
