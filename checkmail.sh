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
	# export the mail / attachments into a separate dir
	ripmime -i $maildir/$mail.mail -d $exportdir
	# just use the pdf file(s)
	files=$(ls $exportdir | grep .pdf)
	for file in $files; do
		# check title if it matches the configured one
	        pdfTitle=$(pdfinfo $exportdir/$file | grep Title)
	        title=${pdfTitle/#"Title: "}
	        if [[ "$title" == *"$PDF_TITLE"* ]]; then
			# use higher oversample to guarantee better ocr
	                ocrmypdf --oversample 300 -l deu $exportdir/$file $ocrdir/$mail.pdf
			# get plain text of the pdf
	                pdftotext -layout $ocrdir/$mail.pdf $ocrdir/$mail.txt
			# just get the keyword and trim the unnecessary whitespace / spaces
	                keywordLine=$(cat $ocrdir/$mail.txt | grep Schlagwort)
	                keywordLine=${keywordLine##*( )}
			# Remove the identifier and set the length to 30chars, more won´t be accepted by the API
	                keyword=$(echo ${keywordLine//"Schlagwort: "/} | cut -c -30)
			if [ "$ALARM_DIVERA" = true ]; then
			# create the alarm
	                curl -i -v \
	                        -H "Accept: application/json" \
	                        -H "Content-Type:application/json" \
	                        -X POST --data "{\"type\": \"$keyword\"}" $apiUrl
			fi

	        fi
	done
done

# Cleanup
rm -rf $exportdir/*
rm -rf $ocrdir/*

