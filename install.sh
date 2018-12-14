#!/bin/sh

git clone https://github.com/inflex/ripMIME.git
cd ripMIME
make
mv ripmime /usr/local/bin/
cd ..
rm -fr ripMIME
mkdir processing processing/mails processing/mailexport processing/ocr
apt install poppler-utils tesseract-ocr ocrmypdf tesseract-ocr-deu
