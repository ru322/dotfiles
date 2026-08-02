#!/bin/sh

choice=$(
  printf '%s\n' \
    'スリープ' \
    '休止' \
    '再起動' |
    fuzzel --dmenu --prompt='電源: '
)

case "$choice" in
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
