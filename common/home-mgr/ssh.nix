{ ... }:
{
  programs.ssh = {
    enable = true;
    # Home Manager used to inject a "Host *" block with OpenSSH's own default
    # values (addKeysToAgent no, no multiplexing, etc.). Those defaults will be
    # removed; opt out now and let OpenSSH and the system ssh_config decide.
    # Satori's /etc/ssh/ssh_config sets AddKeysToAgent yes.
    enableDefaultConfig = false;

    # extraConfig requires a default host block to exist. Keep only the one
    # old default worth preserving: keys offered by the agent are added.
    matchBlocks."*".addKeysToAgent = "yes";

    extraConfig = ''
      Host heimdall
        User koyama
        HostName mprg508.lab.tuat.ac.jp
        Port 20201

      Host peace
        HostName 192.168.50.37
        User koyama
        ProxyJump heimdall
        ForwardAgent yes

      Host pigeon
        HostName 192.168.50.31
        User koyama
        ProxyJump heimdall

      Host kent
        HostName 192.168.50.39
        User koyama
        ProxyJump heimdall

      Host 192.168.50.37
        User koyama
        ForwardAgent yes
    '';
  };
}
