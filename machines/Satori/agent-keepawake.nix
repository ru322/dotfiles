# コーディングエージェントが動いている間は、フタを閉じてもすぐにはスリープしない。
#
# 通常は logind がフタを閉じた時点で suspend する。opencode / codex / claude が
# 動いている間は handle-lid-switch の inhibitor を保持して suspend を止めるが、
# フタを閉じたまま 30 分経ったら inhibitor を手放して通常どおり suspend する。
{ pkgs, ... }:
let
  keepAwake = pkgs.writeShellApplication {
    name = "agent-keepawake";
    runtimeInputs = with pkgs; [
      systemd
      procps
      gnugrep
      coreutils
    ];
    text = builtins.readFile ./agent-keepawake.sh;
  };
in
{
  systemd.services.agent-keepawake = {
    description = "Keep the laptop awake while an AI coding agent is running";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-logind.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${keepAwake}/bin/agent-keepawake";
      Restart = "on-failure";
      RestartSec = 10;
    };
    environment = {
      KEEP_AWAKE_USER = "koyama";
      # この名前のプロセスが動いている間だけ inhibitor を保持する。
      KEEP_AWAKE_AGENTS = "opencode codex claude";
      # フタを閉じたまま起こしておく時間 (分)。
      MAX_MINUTES = "30";
    };
  };
}
