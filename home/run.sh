#!/bin/sh

# export gmail account
echo "from           $GMAIL_ACCOUNT" >> /etc/msmtprc
echo "user           $GMAIL_ACCOUNT" >> /etc/msmtprc
echo "password       $GMAIL_PASSWORD" >> /etc/msmtprc
echo "account default : gmail" >> /etc/msmtprc

echo "$DATABASE_HOST:*:*:$DATABASE_USERNAME:$DATABASE_PASSWORD" > /home/docker/.pgpass

# set timezone eg Europe/Stockholm
if [ ! -z $TIMEZONE ]; then
	echo "Setting timezone $TIMEZONE (Default was Europe/Stockholm)"
	cat /usr/share/zoneinfo/"$TIMEZONE" > /etc/localtime
	echo "$TIMEZONE" > /etc/timezone
fi


# start cron
for crontab in /home/docker/crontabs/*; do /usr/bin/crontab "$crontab"; done
/usr/sbin/crond -f -l 8
