#!/bin/sh

# Run autopostgresqlbackup and save error
error=$( { autopostgresqlbackup; } 2>&1 >/dev/null )

# Email error if non-empty
if [ -n "$error" ]; then
	echo -e "Subject: Autopostgresqldump error in $DATABASE_HOST\n\n$error" | msmtp $RECIPIENT_EMAIL
fi

