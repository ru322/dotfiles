{ config, lib, ... }:
{
  programs.firefox = {
    enable = true;
    # Installed by common/nixos/programs.nix; only the profile is managed here.
    package = null;
    configPath = "${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/mozilla/firefox";

    profiles.default = {
      id = 0;
      isDefault = true;
      # Existing profile directory, so history and logins are kept.
      path = "ykx3zsb2.default";
      settings = {
        # Always go through xdg-desktop-portal so the file chooser is yazi
        # (termfilechooser, see common/nixos/niri.nix).
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # Load userChrome.css below.
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Let sidebar extension pages (Tree Style Tab) be see-through.
        "browser.tabs.allow_transparent_browser" = true;
      };

      # Translucent (0.5) tabs/toolbars/sidebar; page content at 0.9.
      # The window only gets an alpha channel when body's background isn't
      # opaque, so body carries the 0.5 color and everything above it is cleared.
      userChrome = ''
        body {
          background-color: color-mix(in srgb, var(--toolbox-background-color) 50%, transparent) !important;
        }
        body:-moz-window-inactive {
          background-color: color-mix(in srgb, var(--toolbox-background-color-inactive) 50%, transparent) !important;
        }
        .browser-toolbar,
        #navigator-toolbox,
        #browser,
        #sidebar-box,
        #sidebar-main,
        #webextpanels-window {
          background-color: transparent !important;
        }
        /* allow_transparent_browser also clears pages without a background,
           so restore the default white behind tab contents. */
        .browserStack > browser {
          background-color: white !important;
        }
        /* Page area: 0.8 over body's 0.5 layer composes to 0.9.
           (opacity on the <browser> itself is ignored for remote content.) */
        #tabbrowser-tabpanels {
          opacity: 0.8 !important;
        }
        /* URL/search bar; a bit denser while the dropdown is open so results
           stay readable over page text (backdrop-filter doesn't blur pages). */
        .urlbar-background,
        #searchbar {
          background-color: color-mix(in srgb, var(--urlbar-background-color) 50%, transparent) !important;
        }
        .urlbar:is([focused], [open]) > .urlbar-background,
        #searchbar:focus-within {
          background-color: color-mix(in srgb, var(--urlbar-background-color-focus) 70%, transparent) !important;
        }
        /* Selected tab: half its color, without the opaque toolbox layer under it. */
        #tabbrowser-tabs {
          --selected-tab-bg-orig: var(--tab-background-color-selected);
        }
        .tab-background {
          --toolbox-background-color: transparent !important;
          --toolbox-background-color-inactive: transparent !important;
          --tab-background-color-selected: color-mix(in srgb, var(--selected-tab-bg-orig) 50%, transparent) !important;
        }
      '';

      # Clear Tree Style Tab's own sidebar background.
      userContent = ''
        @-moz-document regexp("moz-extension://[^/]+/sidebar/sidebar\\.html.*") {
          :root,
          body,
          #background {
            background: transparent !important;
          }
          tab-item-substance .background {
            background-color: color-mix(in srgb, var(--tab-surface) 50%, transparent) !important;
          }
        }
      '';
    };
  };
}
