{ inputs, pkgs, ... }:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # herdr 自身が常駐サーバーと PTY を管理し、中でエージェントを動かすため、
  # bwrap ラッパーは付けず素の状態で入れる。
  home.packages = [ llmAgents.herdr ];
}
