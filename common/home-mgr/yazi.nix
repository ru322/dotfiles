{ ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = [ "firefox.desktop" ];
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    settings = {
      mgr = {
        ratio = [
          1
          4
          3
        ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
      };

      preview = {
        wrap = "yes";
        tab_size = 2;
        image_filter = "lanczos3";
        image_quality = 80;
      };

      opener = {
        firefox = [
          {
            run = "firefox %s1";
            orphan = true;
            desc = "Firefox";
            for = "linux";
          }
        ];
        onlyoffice = [
          {
            run = "onlyoffice-desktopeditors %s1";
            orphan = true;
            desc = "ONLYOFFICE";
            for = "linux";
          }
        ];
      };

      open.prepend_rules = [
        {
          mime = "application/pdf";
          use = [
            "firefox"
            "onlyoffice"
          ];
        }
      ];
    };

    keymap.mgr.prepend_keymap = [
      {
        on = [ "g" "t" ];
        run = "cd /mnt/nas/TUAT/";
        desc = "Go TUAT";
      }
      {
        on = [ "g" "g" ];
        run = "cd ~/src/github.com/";
        desc = "Go GHQ";
      }
    ];
  };
}
