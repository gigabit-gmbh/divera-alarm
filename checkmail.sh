#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/.ENV"

workdir="$DIR/processing"
maildir=$workdir/mails
exportdir=$workdir/mailexport
ocrdir=$workdir/ocr
apiUrl="https://www.divera247.com/api/alarm?accesskey=$DIVERA_API_KEY"

# Check for new mails
UNSEEN_MAILS=$(curl -s "imaps://$MAIL_SERVER/$MAIL_FOLDER/" --user "$MAIL_USER:$MAIL_PASS" -X 'SEARCH UNSEEN' | grep -o "[0-9.]\+")
for mail in $UNSEEN_MAILS; do
	curl -s "imaps://$MAIL_SERVER/$MAIL_FOLDER;MAILINDEX=$mail" --user "$MAIL_USER:$MAIL_PASS"  > $maildir/$mail.mail
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
                keywordFull=$(echo ${keywordLine//"Schlagwort: "/})
                keyword=$(echo $keywordFull| cut -c -30)
                if [ "$ALARM_DIVERA" = true ]; then
                # create the alarm
                    curl -i -v \
                        -H "Accept: application/json" \
                        -H "Content-Type:application/json" \
                        -X POST --data "{\"type\": \"$keyword\"}" $apiUrl
                fi

                # print page
                if [ "$PRINT_PDF" = true ]; then
                    lp  -o fit-to-page $exportdir/$file
                fi
                # show alert
                if [ "$SHOW_ALERT" = true ]; then
                    location=$(sed '/EINSATZORT/!d;s//&\n/;s/.*\n//;:a;/EINSATZGRUND/bb;$!{n;ba};:b;s//\n&/;P;D' $ocrdir/$mail.txt | tr -s ' ' | tr -d '\n' | sed -e 's/—/-/g')
                    street=$(echo $location |  grep -oP '(?<=Straße).*(?=Haus-Nr)' | tr -s ' ' | tr -d '=' )
                    nr=$(echo $location |  grep -oP '(?<=Haus-Nr.).*(?=Abschnitt)' | tr -s ' ' | tr -d '=' | tr -d ':')
                    abschnitt=$(echo $location | grep -oP '(?<=Abschnitt).*(?=Ort)' | tr -s ' ' | tr -d '=')
                    ort=$(echo $location | grep -oP '(?<=Ort).*(?=Objekt )' | tr -s ' ' | tr -d '=' | tr -d ':')

                    notify-send -u critical -i dialog-warning  -t 1800000 "Alarm" "$keywordFull\n\n$street $nr\n$ort\nAbschnitt: $abschnitt"
                fi
            fi
	done
    # cleanup exportdir
    rm -r $exportdir/*
done

# Cleanup
rm -rf $exportdir/*
rm -rf $ocrdir/*

