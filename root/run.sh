#!/bin/sh

# export gmail account
echo "from           $GMAIL_ACCOUNT" >> /etc/msmtprc
echo "user           $GMAIL_ACCOUNT" >> /etc/msmtprc
echo "password       $GMAIL_PASSWORD" >> /etc/msmtprc
echo "account default : gmail" >> /etc/msmtprc

# set timezone
apk add tzdata
cp /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
echo "$TIMEZONE" > /etc/timezone
apk del tzdata


# start cron
for crontab in /root/crontabs/*; do /usr/bin/crontab "$crontab"; done
/usr/sbin/crond -f -l 8
