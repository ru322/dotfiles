{ ... }:
let
  # A Hazkey_Config_Profile (protocol/config.proto in fcitx5-hazkey), starting
  # from the server's genDefaultConfig(). Unset fields decode as false/0, so
  # every setting is spelled out.
  profile = {
    profileName = "Default";
    # Convert only on Space, not while typing.
    autoConvertMode = "AUTO_CONVERT_DISABLED";
    auxTextMode = "AUX_TEXT_SHOW_WHEN_CURSOR_NOT_AT_END";
    suggestionListMode = "SUGGESTION_LIST_SHOW_PREDICTIVE_RESULTS";
    numSuggestions = 3;
    useRichSuggestion = false;
    numCandidatesPerPage = 9;
    useRichCandidates = false;
    useInputHistory = true;
    stopStoreNewHistory = false;
    specialConversionMode = {
      commaSeparatedNumber = true;
      mailDomain = true;
      calendar = true;
      time = true;
      romanTypography = true;
      unicodeCodepoint = true;
      hazkeyVersion = true;
      halfwidthKatakana = true;
      extendedEmoji = true;
    };
    enabledKeymaps =
      map
        (name: {
          inherit name;
          isBuiltIn = true;
          filename = name;
        })
        [
          "Fullwidth Number"
          "Fullwidth Symbol"
          "Japanese Symbol"
          "Fullwidth Space"
        ];
    enabledTables = [
      {
        name = "Romaji";
        isBuiltIn = true;
        filename = "Romaji";
      }
    ];
    submodeEntryPointChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    zenzaiEnable = true;
    # ggml device name of the Radeon 780M (see services.hazkey in nixos/hazkey.nix).
    zenzaiBackendDeviceName = "Vulkan0";
    zenzaiInferLimit = 10;
    zenzaiContextualMode = true;
    zenzaiProfile = "";
  };
in
{
  # fcitx5 profile: Japanese keyboard plus hazkey as the default input method.
  # fcitx5 forwards keys with the group layout, so a "us" default makes
  # Xwayland apps (e.g. Unity) see a US keymap. Read-only: configtool can't save.
  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      Name=Default
      Default Layout=jp
      DefaultIM=hazkey

      [Groups/0/Items/0]
      Name=keyboard-jp
      Layout=

      [Groups/0/Items/1]
      Name=hazkey
      Layout=jp

      [GroupOrder]
      0=Default
    '';
  };

  # Read-only: hazkey-settings can't save; change settings here instead.
  xdg.configFile."hazkey/config.json" = {
    force = true;
    text = builtins.toJSON [ profile ];
    # The server reads config.json only at startup.
    onChange = "systemctl --user try-restart hazkey-server.service || true";
  };
}
