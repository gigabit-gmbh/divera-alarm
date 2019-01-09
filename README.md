# Divera Alarm

Checks an IMAP Account for new mails that contains a Fax which was sent from ILS Bamberg. 
After that the script parses it and creates an alarm within divera with the given keyword from ILS.

## Step 1
Download & Setup the Project

    git clone https://github.com/gigabit-gmbh/divera-alarm.git && cd divera-alarm
    cp .ENV-example .ENV
    
Adjust the ```.ENV``` file with your data

Install all requirements:

    sudo ./install.sh
    
## Step 2
To run the script, just call ```./checkmail.sh``` - if a unread mail is in the mailbox, 
it will fetch it and get the attachments. It will just continue when the PDF title matches the title
provided in the ```.ENV``` file.

You could let the Script check by cron for new mails every minute
