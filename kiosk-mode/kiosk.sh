#!/bin/bash

xset s noblank
xset s off
xset -dpms

unclutter -idle 0.5 -root &

sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences

/usr/bin/chromium-browser --no-sandbox --noerrordialogs --disable-session-crashed-bubble --disable-infobars --disable-notifications --force-device-scale-factor=1.00 --no-first-run --fast --fast-start --disable-popup-blocking --kiosk https://www.divera247.com/monitor/1.html?autologin=
