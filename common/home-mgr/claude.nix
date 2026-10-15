{ inputs, pkgs, lib, ... }:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [ pkgs.jq pkgs.coreutils ];
    text = builtins.readFile ./claude-statusline.sh;
  };
in
{
    home.packages = [
        llmAgents.claude-code
        llmAgents.claude-desktop
    ];

    # settings.json は Claude Code 自身も書き換えるので symlink にせず、
    # statusLine キーだけ jq でマージする
    home.activation.claudeStatusLine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      f="$HOME/.claude/settings.json"
      run mkdir -p "$HOME/.claude"
      [ -s "$f" ] || run sh -c "echo '{}' > \"$f\""
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq --arg cmd "${statusline}/bin/claude-statusline" \
        '.statusLine = { type: "command", command: $cmd, padding: 0 }' "$f" > "$tmp"
      run mv "$tmp" "$f"
    '';
}
