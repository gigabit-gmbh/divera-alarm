#!/bin/sh

git clone https://github.com/inflex/ripMIME.git
cd ripMIME
make
mv ripmime /usr/local/bin/
cd ..
rm -fr ripMIME
mkdir processing processing/mails processing/mailexport processing/ocr
apt install poppler-utils tesseract-ocr ocrmypdf tesseract-ocr-deu libnotify-bin notification-daemon cups notify-osd at-spi2-core libnotify-bin dbus
usermod -a -G lpadmin pi

cat <<EOT >> /home/pi/.xsessionrc
#!/bin/sh
/usr/lib/notification-daemon/notification-daemon &
EOT
