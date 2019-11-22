#!/bin/sh

cp kiosk.sh /home/pi/kiosk.sh

cat <<EOT >> /lib/systemd/system/kiosk.service
[Unit]
Description=Chromium Kiosk
Wants=graphical.target
After=graphical.target

[Service]
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
Type=simple
ExecStart=/bin/bash /home/pi/kiosk.sh
Restart=on-abort
User=pi
Group=pi

[Install]
WantedBy=graphical.target
EOT

systemctl enable kiosk.service
systemctl start kiosk.service
