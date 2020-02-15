# Build
FROM alpine:3.11

RUN apk add --update --upgrade --no-cache postgresql gzip bash tzdata msmtp ca-certificates


# Set timezone
RUN cp /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN echo "Europe/Stockholm" >  /etc/timezone

COPY msmtprc /etc/msmtprc
COPY msmtprc /etc/msmtprc_backup

RUN mkdir /home/docker /home/docker/backups
RUN echo "docker:x:1000:1000::/home/docker:/bin/bash" > /etc/passwd
RUN echo "root:x:0:0::/root:/bin/bash" >> /etc/passwd
COPY autopostgresqlbackup.sh /usr/local/bin/autopostgresqlbackup
RUN chmod +x /usr/local/bin/autopostgresqlbackup

COPY home /home/docker
COPY crontabs /etc/crontabs
RUN echo "" >> /etc/crontabs/root

RUN chown -R 1000:1000 /home/docker /etc/msmtprc /etc/msmtprc_backup /etc/timezone /usr/share/zoneinfo /etc/localtime /etc/crontabs
RUN chmod -R 755 /home/docker
RUN chmod 600 /home/docker/.pgpass
ENV PGPASSFILE="/home/docker/.pgpass"

WORKDIR /home/docker

CMD ["/home/docker/run.sh"]
