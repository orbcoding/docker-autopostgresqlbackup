# Build
FROM alpine:3.6

RUN apk update
RUN apk upgrade
RUN apk add --no-cache mysql-client
RUN apk add bash

# Set timezone
RUN apk add tzdata
RUN cp /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN echo "Europe/Stockholm" >  /etc/timezone
RUN apk del tzdata

RUN apk add msmtp ca-certificates
COPY msmtprc /etc/msmtprc

RUN mkdir /etc/automysqlbackup
COPY automysqlbackup-v3.0_rc6/automysqlbackup.conf /etc/automysqlbackup
COPY automysqlbackup-v3.0_rc6/automysqlbackup /usr/local/bin
RUN chmod +x /usr/local/bin/automysqlbackup

COPY root /root
RUN chmod 755 /root/cron_automysqlbackup.sh /root/run.sh

VOLUME /backup
WORKDIR /backup

CMD ["/root/run.sh"]
