{ ... }:
{
  programs.kitty = {
    enable = true;
    font.name = "HackGen Console NF";
    font.size = 12;
    themeFile = "tokyo_night_night";
    settings = {
      background_opacity = "0.8";
      tab_bar_edge = "left";
      tab_bar_style = "separator";
      tab_separator = "\"\"";
      tab_title_max_lines = 2;
      tab_title_template = "\" {index} {tab.active_exe}\\n   {fmt.fg._565f89}{tab.active_wd}\"";
      active_tab_font_style = "bold";
      tab_activity_symbol = "\"● \"";
      tab_bar_margin_width = 4;
      window_padding_width = 4;
      cursor_shape = "beam";
      hide_window_decorations = "yes";
    };
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+page_up" = "previous_tab";
      "ctrl+page_down" = "next_tab";
    };
  };
}
