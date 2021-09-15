#!/bin/sh

# export email account
# eg gmail
# account        gmail
# host           smtp.gmail.com
# port           587
# from           ...@gmail.com
# user           ...@gmail.com
# password       ...

cat /etc/msmtprc_backup > /etc/msmtprc
echo "account        backup" >> /etc/msmtprc
echo "host           $BACKUP_EMAIL_HOST" >> /etc/msmtprc
echo "port           $BACKUP_EMAIL_PORT" >> /etc/msmtprc
echo "from           $BACKUP_EMAIL_FROM" >> /etc/msmtprc
echo "user           $BACKUP_EMAIL_FROM" >> /etc/msmtprc
echo "password       $BACKUP_EMAIL_PASSWORD" >> /etc/msmtprc
echo "account default : backup" >> /etc/msmtprc

echo "$DATABASE_HOST:*:*:$DATABASE_USERNAME:$DATABASE_PASSWORD" > /home/docker/.pgpass

# set timezone eg Europe/Stockholm
if [ -n $BACKUP_TIMEZONE ]; then
	echo "Setting timezone $BACKUP_TIMEZONE"
	cat /usr/share/zoneinfo/"$BACKUP_TIMEZONE" > /etc/localtime
	echo "$BACKUP_TIMEZONE" > /etc/timezone
fi

# start cron
/usr/sbin/crond -f -d 0
