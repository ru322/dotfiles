{ ... }:
{
  programs.kitty = {
    enable = true;
    font.name = "UDEV Gothic 35NF";
    font.size = 12;
    themeFile = "tokyo_night_night";
    settings = {
      background_opacity = "1";

      # Rounded window with a subtle focus border. The padding keeps text clear
      # of the rounded corners.
      window_padding_width = "8";
      window_border_width = "1";
      window_border_radius = "10";
      active_border_color = "#7aa2f7";
      inactive_border_color = "#2a2e42";
      # Let the client-side titlebar blend into the terminal background.
      wayland_titlebar_color = "background";
      # niri/Hyprland draw no server-side decorations, GNOME expects CSD;
      # letting kitty draw its titlebar also provides the close button.
      hide_window_decorations = "no";

      # Vertical powerline tabs on the left.
      tab_bar_edge = "left";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_bar_align = "left";
      tab_bar_min_tabs = "1";
      tab_bar_show_new_tab_button = "yes";
      tab_bar_margin_width = "4";
      tab_bar_margin_height = "0 8";
      tab_bar_margin_color = "#16161e";
      tab_bar_background = "#16161e";
      active_tab_background = "#7aa2f7";
      active_tab_foreground = "#16161e";
      inactive_tab_background = "#1a1b26";
      inactive_tab_foreground = "#565f89";
      active_tab_font_style = "bold";
      tab_activity_symbol = "\"● \"";
      tab_title_max_lines = "1";
      tab_title_max_length = "26";
      tab_title_template = "\" {index} {title}\"";
      cursor_shape = "beam";
      remember_window_size = "no";
    };
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+page_up" = "previous_tab";
      "ctrl+page_down" = "next_tab";
    };
  };
}
