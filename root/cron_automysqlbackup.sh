#!/bin/sh

# Run automysqlbackup and save error
error=$( { automysqlbackup; } 2>&1 >/dev/null )

# Email error if non-empty
if [ -n "$error" ]; then
	echo -e "Subject: Automysqldump error in $DBHOST\n\n$error" | msmtp $RECIPIENT_EMAIL
fi

