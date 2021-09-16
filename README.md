# Usage

Runs `/etc/crontabs/root`. Mount to overwrite.
If want non root uid 1000 actions just run `su - docker -c "cmd"`

Daily Backups are run 03:00 and rotated weekly.
Weekly Backups are run on Sunday with 5 week rotation.

See run.sh for overwriting timezone that defaults to Europe/Stockholm.

Please define all environmental variables mentioned below

```
  postgresqlbackup:
    container_name: postgresqlbackup
    image: sharetransition/postgresqlbackup
    volumes:
      - "$BACKUP_DB_PATH:/home/docker/backups
    environment:
      - DATABASE_USER=user
      - DATABASE_PASSWORD=password
      - DATABASE_HOST=db
      - BACKUP_TIMEZONE=Europe/Stockholm # Default Europe/Stockholm
      - BACKUP_EMAIL_HOST=smtp@gmail.com
      - BACKUP_EMAIL_PORT=587
      - BACKUP_EMAIL_FROM=myaccount@gmail.com
      - BACKUP_EMAIL_PASSWORD=mygmailpassword
      - BACKUP_EMAIL_TO=myaccount@gmail.com
```
