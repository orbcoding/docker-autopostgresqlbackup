# Build
FROM alpine:3.11

RUN apk add --update --upgrade --no-cache postgresql gzip busybox-suid bash tzdata msmtp ca-certificates

# Set timezone
RUN cp /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN echo "Europe/Stockholm" >  /etc/timezone

COPY msmtprc /etc/msmtprc

RUN mkdir /home/docker /home/docker/backups
COPY autopostgresqlbackup.sh /usr/local/bin/autopostgresqlbackup
RUN chmod +x /usr/local/bin/autopostgresqlbackup

COPY home /home/docker
RUN chown -R 1000:1000 /home/docker /etc/msmtprc /etc/timezone /usr/share/zoneinfo /etc/localtime
RUN chmod -R 755 /home/docker

WORKDIR /home/docker

CMD ["/home/docker/run.sh"]
