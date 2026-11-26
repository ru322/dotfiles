{ inputs, pkgs, ... }:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  sandbox = import ./agent-sandbox.nix { inherit pkgs; };
in
{
  home.packages = [
    # /mnt/nas を隠すだけの従来モード。claude / codex と同じ扱い。
    (sandbox.hideNas llmAgents.antigravity-cli "agy")
    pkgs.jq
  ];

  home.file.".gemini/config/skills/herdr-opencode" = {
    source = ../.gemini/skills/herdr-opencode;
    recursive = true;
  };
}
