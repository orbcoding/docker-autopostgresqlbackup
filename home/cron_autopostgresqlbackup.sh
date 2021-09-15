#!/bin/sh

# Run autopostgresqlbackup and save error
error=$( { autopostgresqlbackup; } 2>&1 >/dev/null )

# Email error if non-empty requires,
# if using gmail might require app access https://support.google.com/accounts/answer/6010255?hl=en
if [ -n "$error" ]; then
	echo  $error
	echo -e "Subject: Autopostgresqldump error in $DATABASE_HOST\n\n$error" | msmtp $BACKUP_EMAIL_TO
fi

