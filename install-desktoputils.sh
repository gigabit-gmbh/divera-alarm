#!/bin/sh

apt install unclutter

mkdir -p ~/.config/lxsession/LXDE-pi/

## TODO: disable screesaver in /etc/xdg/lxsession/LXDE-pi/autostart

cat <<EOT >> ~/.config/lxsession/LXDE-pi/autostart
@unclutter
@xset s off
@xset -dpms
@xset s noblank
@chromium-browser --disable-notifications --noerrordialogs --disable-session-crashed-bubble --disable-infobars --force-device-scale-factor=1.00 --kiosk https://www.divera247.com/monitor/1.html?autologin=
EOT
