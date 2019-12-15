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

RUN mkdir /etc/automysqlbackup /home/user /home/user/backup
COPY automysqlbackup-v3.0_rc6/automysqlbackup /usr/local/bin
RUN chmod +x /usr/local/bin/automysqlbackup

COPY home /home/user
RUN chown -R 1000:1000 /home/user
RUN chmod -R 755 /home/user

WORKDIR /home/user

CMD ["/root/run.sh"]
