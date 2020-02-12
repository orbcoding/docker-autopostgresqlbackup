# Usage

- All crontab files in `/root/crontabs` will be run at startup. Use mounts to override or add more. The autopostgresqlbackup crontab is by default set to 03:00 every day.
- Check out the autopostgresqlbackup config or mount a new one to `/etc/autopostgresqlbackup/autopostgresqlbackup`.

# Sample from docker-compose

Please define all environmental variables mentioned below

```
  postgresqlbackup:
    container_name: postgresqlbackup
    image: sharetransition/postgresqlbackup
    environment:
      - DATABASE_USER=user
      - DATABASE_PASSWORD=password
      - DATABASE_HOST=db
      - GMAIL_ACCOUNT=myaccount@gmail.com
      - GMAIL_PASSWORD=mygmailpassword
      - RECIPIENT_EMAIL=recipent@email.com
    depends_on:
      - db
```
