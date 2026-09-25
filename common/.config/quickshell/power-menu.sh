#!/bin/sh

choice=$(
  printf '%s\n' \
    '画面ロック' \
    'スリープ' \
    '休止' \
    '再起動' |
    fuzzel --dmenu --prompt='電源: '
)

case "$choice" in
  '画面ロック')
    if [ -r /etc/swaylock/config ]; then
      swaylock -f -C /etc/swaylock/config
    else
      swaylock -f
    fi
    ;;
  'スリープ')
    systemctl suspend
    ;;
  '休止')
    systemctl hibernate
    ;;
  '再起動')
    systemctl reboot
    ;;
esac
