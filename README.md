# Usage

Runs `/etc/crontabs/root`. Mount to overwrite.
If want non root uid 1000 actions just run `su - docker -c "cmd"`

Daily Backups are run 03:00 and rotated weekly.
Weekly Backups are run on Sunday with 5 week rotation.

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
```
