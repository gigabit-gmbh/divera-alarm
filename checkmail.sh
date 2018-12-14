#!/bin/bash
source .ENV

workdir=./processing
maildir=$workdir/mails
exportdir=$workdir/mailexport
ocrdir=$workdir/ocr
apiUrl="https://www.divera247.com/api/alarm?accesskey=$DIVERA_API_KEY"

# Check for new mails
UNSEEN_MAILS=$(curl "imaps://$MAIL_SERVER/$MAIL_FOLDER/" --user "$MAIL_USER:$MAIL_PASS" -X 'SEARCH UNSEEN' | grep -o "[0-9.]\+")
for mail in $UNSEEN_MAILS; do
	curl "imaps://$MAIL_SERVER/$MAIL_FOLDER;UID=$mail" --user "$MAIL_USER:$MAIL_PASS"  > $maildir/$mail.mail
	ripmime -i $maildir/$mail.mail -d $exportdir
	files=$(ls $exportdir | grep .pdf)
	for file in $files; do
	        pdfTitle=$(pdfinfo $exportdir/$file | grep Title)
	        title=${pdfTitle/#"Title: "}
	        if [[ "$title" == *"$PDF_TITLE"* ]]; then
	                ocrmypdf --oversample 300 -l deu $exportdir/$file $ocrdir/$mail.pdf
	                pdftotext -layout $ocrdir/$mail.pdf $ocrdir/$mail.txt
	                keywordLine=$(cat $ocrdir/$mail.txt | grep Schlagwort)
	                keywordLine=${keywordLine##*( )}
	                keyword=$(echo ${keywordLine//"Schlagwort: "/} | cut -c -30)
	                curl -i -v \
	                        -H "Accept: application/json" \
	                        -H "Content-Type:application/json" \
	                        -X POST --data "{\"type\": \"$keyword\"}" $apiUrl
	        fi
	done
done

# Cleanup
rm -r $exportdir/*
rm -r $ocrdir/*

