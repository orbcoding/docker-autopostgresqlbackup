# Build
FROM alpine:3.11

RUN apk add --update --upgrade --no-cache postgresql gzip bash tzdata msmtp ca-certificates


# Set timezone
RUN cp /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN echo "Europe/Stockholm" >  /etc/timezone

COPY msmtprc /etc/msmtprc
COPY msmtprc /etc/msmtprc_backup

# Create docker 1000 user
RUN mkdir /home/docker /home/docker/backups
COPY home /home/docker
RUN echo "docker:x:1000:1000::/home/docker:/bin/bash" > /etc/passwd
RUN echo "root:x:0:0::/root:/bin/bash" >> /etc/passwd

# Add backup script
COPY autopostgresqlbackup.sh /usr/local/bin/autopostgresqlbackup
RUN chmod +x /usr/local/bin/autopostgresqlbackup

COPY crontabs /etc/crontabs
RUN echo >> /etc/crontabs/root

RUN chown -R 1000:1000 /home/docker
RUN chmod -R 755 /home/docker
RUN chmod 600 /home/docker/.pgpass
ENV PGPASSFILE="/home/docker/.pgpass"

WORKDIR /home/docker

CMD ["/home/docker/run.sh"]
