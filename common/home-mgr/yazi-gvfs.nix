{ inputs, pkgs, ... }:
{
  home.packages = [ 
     pkgs.glib
     pkgs.file
 ];

  programs.yazi = {
    plugins.gvfs = inputs.gvfs-yazi;

    initLua = ''
      require("gvfs"):setup({})
    '';

    keymap.mgr.prepend_keymap = [
      {
        on = [
          "M"
          "m"
        ];
        run = "plugin gvfs -- select-then-mount --jump";
        desc = "Mount device and jump";
      }
      {
        on = [
          "M"
          "u"
        ];
        run = "plugin gvfs -- select-then-unmount --eject";
        desc = "Unmount and eject device";
      }
      {
        on = [
          "g"
          "m"
        ];
        run = "plugin gvfs -- jump-to-device";
        desc = "Jump to mounted device";
      }
      {
        on = [
          "`"
          "`"
        ];
        run = "plugin gvfs -- jump-back-prev-cwd";
        desc = "Jump back from device";
      }
    ];

    settings.plugin = {
      prepend_preloaders = [
        {
          url = "/run/user/1000/gvfs/**/*";
          run = "noop";
        }
        {
          url = "/run/media/koyama/**/*";
          run = "noop";
        }
      ];
      prepend_previewers = [
        {
          url = "*/";
          run = "folder";
        }
        {
          url = "/run/user/1000/gvfs/**/*";
          run = "noop";
        }
        {
          url = "/run/media/koyama/**/*";
          run = "noop";
        }
      ];
    };
  };
}
