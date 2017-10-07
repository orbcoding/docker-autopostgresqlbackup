#!/bin/sh

# export gmail account
echo "from           $GMAIL_ACCOUNT" >> /etc/msmtprc
echo "user           $GMAIL_ACCOUNT" >> /etc/msmtprc
echo "password       $GMAIL_PASSWORD" >> /etc/msmtprc
echo "account default : gmail" >> /etc/msmtprc

# start cron
for crontab in /root/crontabs/*; do /usr/bin/crontab "$crontab"; done
/usr/sbin/crond -f -l 8
