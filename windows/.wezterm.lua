local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- フォント
config.font = wezterm.font('HackGen Console NF')
config.font_size = 14.0

-- カラースキーム
config.color_scheme = 'Solarized Dark (Gogh)'

-- 背景: Solarized Dark ベース色の上に画像を20%で重ねる
config.background = {
  { source = { Color = '#002b36' }, width = '100%', height = '100%' },
  { source = { File = wezterm.home_dir .. '/.config/wallpapers/Top14.png' }, opacity = 0.2, width = '100%', height = '100%' },
}

-- デフォルトシェル
config.default_prog = { 'pwsh.exe' }

-- ① タイトルバーを非表示 (ウィンドウ枠のみ残す)
config.window_decorations = 'RESIZE'

-- ② マウス設定
config.mouse_bindings = {
  -- 右クリックでペースト
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

-- キーバインド
config.keys = {
  -- Shift+Enter で改行を送信
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString '\n',
  },
  -- Ctrl+C: 選択中ならコピー、なければ SIGINT を送信
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        window:perform_action(wezterm.action.CopyTo 'Clipboard', pane)
      else
        window:perform_action(wezterm.action.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  },
  -- Ctrl+V: クリップボードからペースト
  {
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

-- ③ タブバー背景をターミナル背景色と統一
-- ④ タブを平行四辺形に (retro モードで format-tab-title を使用)
config.use_fancy_tab_bar = false

config.colors = {
  tab_bar = {
    background    = '#002b36',
    new_tab       = { bg_color = '#002b36', fg_color = '#839496' },
    new_tab_hover = { bg_color = '#073642', fg_color = '#93a1a1' },
  },
}

-- Nerd Fonts Powerline Extra の斜線区切り文字で平行四辺形を構成
local L = '\u{e0ba}'  -- 左斜め
local R = '\u{e0bc}'  -- 右斜め

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local BAR_BG    = '#002b36'
  local ACTIVE_BG = '#073642'

  local bg = (tab.is_active or hover) and ACTIVE_BG or BAR_BG
  local fg = tab.is_active and '#93a1a1' or (hover and '#839496' or '#586e75')

  local title = tostring(tab.tab_index + 1) .. ': ' .. tab.active_pane.title
  title = wezterm.truncate_right(title, max_width - 4)

  return {
    { Background = { Color = BAR_BG } }, { Foreground = { Color = bg } }, { Text = L },
    { Background = { Color = bg } },     { Foreground = { Color = fg } }, { Text = ' ' .. title .. ' ' },
    { Background = { Color = BAR_BG } }, { Foreground = { Color = bg } }, { Text = R },
  }
end)

return config
