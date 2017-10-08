# Usage

- All crontab files in `/root/crontabs` will be run at startup. Use mounts to override or add more. The automysqlbackup crontab is by default set to 03:00 every day. 
- Check out the automysqlbackup config or mount a new one to `/etc/automysqlbackup/automysqlbackup.conf`.

# Sample from docker-compose

Please define all environmental variables mentioned below

```
  mysqlbackup:
    container_name: mysqlbackup
    image: sharetransition/alpine3.6-cron-automysqlbackup3-gmail
    environment:
      - MYSQL_USER=user
      - MYSQL_PASSWORD=password
      - MYSQL_HOST=mysql
      - GMAIL_ACCOUNT=myaccount@gmail.com
      - GMAIL_PASSWORD=mygmailpassword
      - RECIPIENT_EMAIL=recipent@email.com
    depends_on:
      - mysql
```
