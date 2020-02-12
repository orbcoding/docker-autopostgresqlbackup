#!/bin/bash
#
# PostgreSQL Backup Script Ver 1.0
# http://autopgsqlbackup.frozenpc.net
# Copyright (c) 2005 Aaron Axelsen <axelseaa@amadmax.com>
#               2005 Friedrich Lobenstock <fl@fl.priv.at>
#               2013-2019 Emmanuel Bouthenot <kolter@openics.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#=====================================================================
# Set the following variables to your system needs
# (Detailed instructions below variables)
#=====================================================================

# Username to access the PostgreSQL server e.g. dbuser
USERNAME=$DATABASE_USERNAME

# Password
# create a file $HOME/.pgpass containing a line like this
#   hostname:*:*:dbuser:dbpass
# replace hostname with the value of DBHOST and postgres with
# the value of USERNAME

# Host name (or IP address) of PostgreSQL server e.g localhost
DBHOST="$DATABASE_HOST"

# List of DBNAMES for Daily/Weekly Backup e.g. "DB1 DB2 DB3"
DBNAMES="$DATABASE_NAME"

# pseudo database name used to dump global objects (users, roles, tablespaces)
GLOBALS_OBJECTS=""

# Backup directory location e.g /backups
BACKUPDIR="/home/docker/backups"

# Mail setup
# What would you like to be mailed to you?
# - log   : send only log file
# - files : send log file and sql files as attachments (see docs)
# - stdout : will simply output the log to the screen if run manually.
# - quiet : Only send logs if an error occurs to the MAILADDR.
# MAILCONTENT="stdout"

# Set the maximum allowed email size in k. (4000 = approx 5MB email [see docs])
# MAXATTSIZE="4000"

# Email Address to send mail to? (user@domain.com)
# MAILADDR="user@domain.com"

# ============================================================
# === ADVANCED OPTIONS ( Read the doc's below for details )===
#=============================================================

# List of DBBNAMES for Monthly Backups.
MDBNAMES=""

# List of DBNAMES to EXLUCDE if DBNAMES are set to all (must be in " quotes)
DBEXCLUDE=""

# Include CREATE DATABASE in backup?
CREATE_DATABASE=yes

# Separate backup directory and file for each DB? (yes or no)
SEPDIR=yes

# Which day do you want weekly backups? (1 to 7 where 1 is Monday)
DOWEEKLY=7

# Choose Compression type. (gzip, bzip2 or xz)
COMP=gzip

# Compress communications between backup server and PostgreSQL server?
# set compression level from 0 to 9 (0 means no compression)
COMMCOMP=0

# Additionally keep a copy of the most recent backup in a seperate directory.
LATEST=no

# OPT string for use with pg_dump ( see man pg_dump )
OPT=""

# Backup files extension
EXT="sql"

# Backup files permissions
PERM=660

# Encyrption settings
# (inspired by http://blog.altudov.com/2010/09/27/using-openssl-for-asymmetric-encryption-of-backups/)
#
# Once the backup done, each SQL dump will be encrypted and the original file
# will be deleted (if encryption was successful).
# It is recommended to backup into a staging directory, and then use the
# POSTBACKUP script to sync the encrypted files to the desired location.
#
# Encryption uses private/public keys. You can generate the key pairs like the following:
# openssl req -x509 -nodes -days 100000 -newkey rsa:2048 -keyout backup.key -out backup.crt -subj '/'
#
# Decryption:
# openssl smime -decrypt -in backup.sql.gz.enc -binary -inform DEM -inkey backup.key -out backup.sql.gz

# Enable encryption
ENCRYPTION=no

# Encryption public key
ENCRYPTION_PUBLIC_KEY=""

# Encryption Cipher (see enc manpage)
ENCRYPTION_CIPHER="aes256"

# Suffix for encyrpted files
ENCRYPTION_SUFFIX=".enc"

# Command to run before backups (uncomment to use)
#PREBACKUP="/etc/postgresql-backup-pre"

# Command run after backups (uncomment to use)
#POSTBACKUP="/etc/postgresql-backup-post"

#=====================================================================
# Debian specific options ===
#=====================================================================

if [ -f /etc/default/autopostgresqlbackup ]; then
    . /etc/default/autopostgresqlbackup
fi

#=====================================================================
# Options documentation
#=====================================================================
# Set USERNAME and PASSWORD of a user that has at least SELECT permission
# to ALL databases.
#
# Set the DBHOST option to the server you wish to backup, leave the
# default to backup "this server".(to backup multiple servers make
# copies of this file and set the options for that server)
#
# Put in the list of DBNAMES(Databases)to be backed up. If you would like
# to backup ALL DBs on the server set DBNAMES="all".(if set to "all" then
# any new DBs will automatically be backed up without needing to modify
# this backup script when a new DB is created).
#
# If the DB you want to backup has a space in the name replace the space
# with a % e.g. "data base" will become "data%base"
# NOTE: Spaces in DB names may not work correctly when SEPDIR=no.
#
# You can change the backup storage location from /backups to anything
# you like by using the BACKUPDIR setting..
#
# The MAILCONTENT and MAILADDR options and pretty self explanitory, use
# these to have the backup log mailed to you at any email address or multiple
# email addresses in a space seperated list.
# (If you set mail content to "log" you will require access to the "mail" program
# on your server. If you set this to "files" you will have to have mutt installed
# on your server. If you set it to "stdout" it will log to the screen if run from
# the console or to the cron job owner if run through cron. If you set it to "quiet"
# logs will only be mailed if there are errors reported. )
#
# MAXATTSIZE sets the largest allowed email attachments total (all backup files) you
# want the script to send. This is the size before it is encoded to be sent as an email
# so if your mail server will allow a maximum mail size of 5MB I would suggest setting
# MAXATTSIZE to be 25% smaller than that so a setting of 4000 would probably be fine.
#
# Finally copy autopostgresqlbackup.sh to anywhere on your server and make sure
# to set executable permission. You can also copy the script to
# /etc/cron.daily to have it execute automatically every night or simply
# place a symlink in /etc/cron.daily to the file if you wish to keep it
# somwhere else.
# NOTE:On Debian copy the file with no extention for it to be run
# by cron e.g just name the file "autopostgresqlbackup"
#
# Thats it..
#
#
# === Advanced options doc's ===
#
# The list of MDBNAMES is the DB's to be backed up only monthly. You should
# always include "template1" in this list to backup the default database
# template used to create new databases.
# NOTE: If DBNAMES="all" then MDBNAMES has no effect as all DBs will be backed
# up anyway.
#
# If you set DBNAMES="all" you can configure the option DBEXCLUDE. Other
# wise this option will not be used.
# This option can be used if you want to backup all dbs, but you want
# exclude some of them. (eg. a db is to big).
#
# Set CREATE_DATABASE to "yes" (the default) if you want your SQL-Dump to create
# a database with the same name as the original database when restoring.
# Saying "no" here will allow your to specify the database name you want to
# restore your dump into, making a copy of the database by using the dump
# created with autopostgresqlbackup.
# NOTE: Not used if SEPDIR=no
#
# The SEPDIR option allows you to choose to have all DBs backed up to
# a single file (fast restore of entire server in case of crash) or to
# seperate directories for each DB (each DB can be restored seperately
# in case of single DB corruption or loss).
#
# To set the day of the week that you would like the weekly backup to happen
# set the DOWEEKLY setting, this can be a value from 1 to 7 where 1 is Monday,
# The default is 6 which means that weekly backups are done on a Saturday.
#
# COMP is used to choose the copmression used, options are gzip or bzip2.
# bzip2 will produce slightly smaller files but is more processor intensive so
# may take longer to complete.
#
# COMMCOMP is used to set the compression level (from 0 to 9, 0 means no compression)
# between the client and the server, so it is useful to save bandwidth when backing up
# a remote PostgresSQL server over the network.
#
# LATEST is to store an additional copy of the latest backup to a standard
# location so it can be downloaded bt thrid party scripts.
#
# Use PREBACKUP and POSTBACKUP to specify Per and Post backup commands
# or scripts to perform tasks either before or after the backup process.
#
#
#=====================================================================
# Backup Rotation..
#=====================================================================
#
# Daily Backups are rotated weekly..
# Weekly Backups are run by default on Saturday Morning when
# cron.daily scripts are run...Can be changed with DOWEEKLY setting..
# Weekly Backups are rotated on a 5 week cycle..
# Monthly Backups are run on the 1st of the month..
# Monthly Backups are NOT rotated automatically...
# It may be a good idea to copy Monthly backups offline or to another
# server..
#
#=====================================================================
# Please Note!!
#=====================================================================
#
# I take no resposibility for any data loss or corruption when using
# this script..
# This script will not help in the event of a hard drive crash. If a
# copy of the backup has not be stored offline or on another PC..
# You should copy your backups offline regularly for best protection.
#
# Happy backing up...
#
#=====================================================================
# Restoring
#=====================================================================
# Firstly you will need to uncompress the backup file.
# eg.
# gunzip file.gz (or bunzip2 file.bz2)
#
# Next you will need to use the postgresql client to restore the DB from the
# sql file.
# eg.
# psql --host dbserver --dbname database < /path/file.sql
#
# NOTE: Make sure you use "<" and not ">" in the above command because
# you are piping the file.sql to psql and not the other way around.
#
# Lets hope you never have to use this.. :)
#
#=====================================================================
# Change Log
#=====================================================================
#
# VER 1.0 - (2005-03-25)
#   Initial Release - based on AutoMySQLBackup 2.2
#
#=====================================================================
#=====================================================================
#=====================================================================
#
# Should not need to be modified from here down!!
#
#=====================================================================
#=====================================================================
#=====================================================================
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/postgres/bin:/usr/local/pgsql/bin
DATE=`date +%Y-%m-%d_%Hh%Mm`    # Datestamp e.g 2002-09-21
DOW=`date +%A`                  # Day of the week e.g. Monday
DNOW=`date +%u`                 # Day number of the week 1 to 7 where 1 represents Monday
DOM=`date +%d`                  # Date of the Month e.g. 27
M=`date +%B`                    # Month e.g January
W=`date +%V`                    # Week Number e.g 37
VER=1.0                         # Version Number
LOGFILE=$BACKUPDIR/${DBHOST//\//_}-`date +%N`.log           # Logfile Name
LOGERR=$BACKUPDIR/ERRORS_${DBHOST//\//_}-`date +%N`.log     # Logfile Name
BACKUPFILES=""

# Add --compress pg_dump option to $OPT
if [ "$COMMCOMP" -gt 0 ];
    then
    OPT="$OPT --compress=$COMMCOMP"
fi

# Create required directories
if [ ! -e "$BACKUPDIR" ]        # Check Backup Directory exists.
    then
    mkdir -p "$BACKUPDIR"
fi

if [ ! -e "$BACKUPDIR/daily" ]      # Check Daily Directory exists.
    then
    mkdir -p "$BACKUPDIR/daily"
fi

if [ ! -e "$BACKUPDIR/weekly" ]     # Check Weekly Directory exists.
    then
    mkdir -p "$BACKUPDIR/weekly"
fi

if [ ! -e "$BACKUPDIR/monthly" ]    # Check Monthly Directory exists.
    then
    mkdir -p "$BACKUPDIR/monthly"
fi

if [ "$LATEST" = "yes" ]
then
    if [ ! -e "$BACKUPDIR/latest" ] # Check Latest Directory exists.
    then
        mkdir -p "$BACKUPDIR/latest"
    fi
rm -f "$BACKUPDIR"/latest/*
fi

# IO redirection for logging.
touch $LOGFILE
exec 6>&1           # Link file descriptor #6 with stdout.
                    # Saves stdout.
exec > $LOGFILE     # stdout replaced with file $LOGFILE.
touch $LOGERR
exec 7>&2           # Link file descriptor #7 with stderr.
                    # Saves stderr.
exec 2> $LOGERR     # stderr replaced with file $LOGERR.


# Functions

# Database dump function
dbdump () {
    rm -f $2
    touch $2
    chmod $PERM $2
    for db in $1 ; do
        if [ -n "$SU_USERNAME" ]; then
            if [ "$db" = "$GLOBALS_OBJECTS" ]; then
                su $SU_USERNAME -l -c "pg_dumpall $PGHOST --globals-only" >> $2
            else
                su $SU_USERNAME -l -c "pg_dump $PGHOST $OPT $db" >> $2
            fi
        else
            if [ "$db" = "$GLOBALS_OBJECTS" ]; then
                pg_dumpall --username=$USERNAME $PGHOST --globals-only >> $2
            else
                pg_dump --username=$USERNAME $PGHOST $OPT $db >> $2
            fi
        fi
    done
    return 0
}

# Encryption function
encryption() {
    ENCRYPTED_FILE="$1$ENCRYPTION_SUFFIX"
    # Encrypt as needed
    if [ "$ENCRYPTION" = "yes" ]; then
        echo
        echo "Encrypting $1"
        echo "  to $ENCRYPTED_FILE"
        echo "  using cypher $ENCRYPTION_CIPHER and public key $ENCRYPTION_PUBLIC_KEY"
        if openssl smime -encrypt -$ENCRYPTION_CIPHER -binary -outform DEM \
            -out "$ENCRYPTED_FILE" \
            -in "$1" "$ENCRYPTION_PUBLIC_KEY" ; then
            echo "  and remove $1"
            chmod $PERM "$ENCRYPTED_FILE"
            rm -f "$1"
        fi
    fi
    return 0
}

# Compression (and encrypt) function plus latest copy
SUFFIX=""
compression () {
if [ "$COMP" = "gzip" ]; then
    gzip -f "$1"
    echo
    echo Backup Information for "$1"
    gzip -l "$1.gz"
    SUFFIX=".gz"
elif [ "$COMP" = "bzip2" ]; then
    echo Compression information for "$1.bz2"
    bzip2 -f -v $1 2>&1
    SUFFIX=".bz2"
elif [ "$COMP" = "xz" ]; then
    echo Compression information for "$1.xz"
    xz -9 -v $1 2>&1
    SUFFIX=".xz"
else
    echo "No compression option set, check advanced settings"
fi
encryption $1$SUFFIX
if [ "$LATEST" = "yes" ]; then
    cp $1$SUFFIX* "$BACKUPDIR/latest/"
fi
return 0
}

# Run command before we begin
if [ "$PREBACKUP" ]
    then
    echo ======================================================================
    echo "Prebackup command output."
    echo
    $PREBACKUP
    echo
    echo ======================================================================
    echo
fi


if [ "$SEPDIR" = "yes" ]; then # Check if CREATE DATABSE should be included in Dump
    if [ "$CREATE_DATABASE" = "no" ]; then
        OPT="$OPT"
    else
        OPT="$OPT --create"
    fi
else
    OPT="$OPT"
fi

# Hostname for LOG information
if [ "$DBHOST" = "localhost" ]; then
    HOST=`hostname`
    PGHOST=""
else
    HOST=$DBHOST
    PGHOST="-h $DBHOST"
fi

# If backing up all DBs on the server
if [ "$DBNAMES" = "all" ]; then
    if [ -n "$SU_USERNAME" ]; then
        DBNAMES="$(su $SU_USERNAME -l -c "LANG=C psql -U $USERNAME $PGHOST -l -A -F: | sed -ne '/:/ { /Name:Owner/d; /template0/d; s/:.*$//; p }'")"
    else
        DBNAMES="`LANG=C psql -U $USERNAME $PGHOST -l -A -F: | sed -ne "/:/ { /Name:Owner/d; /template0/d; s/:.*$//; p }"`"
    fi

    # If DBs are excluded
    for exclude in $DBEXCLUDE
    do
        DBNAMES=`echo $DBNAMES | sed "s/\b$exclude\b//g"`
    done
    DBNAMES="$(echo $DBNAMES| tr '\n' ' ')"
    MDBNAMES=$DBNAMES
fi

# Include global objects (users, tablespaces)
DBNAMES="$GLOBALS_OBJECTS $DBNAMES"
MDBNAMES="$GLOBALS_OBJECTS $MDBNAMES"

echo ======================================================================
echo AutoPostgreSQLBackup VER $VER
echo http://autopgsqlbackup.frozenpc.net/
echo
echo Backup of Database Server - $HOST
echo ======================================================================

# Test is seperate DB backups are required
if [ "$SEPDIR" = "yes" ]; then
echo Backup Start Time `date`
echo ======================================================================
    # Monthly Full Backup of all Databases
    if [ "$DOM" = "01" ]; then
        for MDB in $MDBNAMES
        do

             # Prepare $DB for using
                MDB="`echo $MDB | sed 's/%/ /g'`"

            if [ ! -e "$BACKUPDIR/monthly/$MDB" ]       # Check Monthly DB Directory exists.
            then
                mkdir -p "$BACKUPDIR/monthly/$MDB"
            fi
            echo Monthly Backup of $MDB...
                dbdump "$MDB" "$BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.$EXT"
                compression "$BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.$EXT"
                BACKUPFILES="$BACKUPFILES $BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.$EXT$SUFFIX*"
            echo ----------------------------------------------------------------------
        done
    fi

    for DB in $DBNAMES
    do
    # Prepare $DB for using
    DB="`echo $DB | sed 's/%/ /g'`"

    # Create Seperate directory for each DB
    if [ ! -e "$BACKUPDIR/daily/$DB" ]      # Check Daily DB Directory exists.
        then
        mkdir -p "$BACKUPDIR/daily/$DB"
    fi

    if [ ! -e "$BACKUPDIR/weekly/$DB" ]     # Check Weekly DB Directory exists.
        then
        mkdir -p "$BACKUPDIR/weekly/$DB"
    fi

    # Weekly Backup
    if [ "$DNOW" = "$DOWEEKLY" ]; then
        echo Weekly Backup of Database \( $DB \)
        echo Rotating 5 weeks Backups...
            if [ "$W" -le 05 ];then
                REMW=`expr 48 + $W`
            elif [ "$W" -lt 15 ];then
                REMW=0`expr $W - 5`
            else
                REMW=`expr $W - 5`
            fi
        rm -fv "$BACKUPDIR/weekly/$DB/${DB}_week.$REMW".*
        echo
            dbdump "$DB" "$BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.$EXT"
            compression "$BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.$EXT"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.$EXT$SUFFIX*"
        echo ----------------------------------------------------------------------

    # Daily Backup
    else
        echo Daily Backup of Database \( $DB \)
        echo Rotating last weeks Backup...
        rm -fv "$BACKUPDIR/daily/$DB"/*."$DOW".$EXT*
        echo
            dbdump "$DB" "$BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.$EXT"
            compression "$BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.$EXT"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.$EXT$SUFFIX*"
        echo ----------------------------------------------------------------------
    fi
    done
echo Backup End `date`
echo ======================================================================


else # One backup file for all DBs
echo Backup Start `date`
echo ======================================================================
    # Monthly Full Backup of all Databases
    if [ "$DOM" = "01" ]; then
        echo Monthly full Backup of \( $MDBNAMES \)...
            dbdump "$MDBNAMES" "$BACKUPDIR/monthly/$DATE.$M.all-databases.$EXT"
            compression "$BACKUPDIR/monthly/$DATE.$M.all-databases.$EXT"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/monthly/$DATE.$M.all-databases.$EXT$SUFFIX*"
        echo ----------------------------------------------------------------------
    fi

    # Weekly Backup
    if [ "$DNOW" = "$DOWEEKLY" ]; then
        echo Weekly Backup of Databases \( $DBNAMES \)
        echo
        echo Rotating 5 weeks Backups...
            if [ "$W" -le 05 ];then
                REMW=`expr 48 + $W`
            elif [ "$W" -lt 15 ];then
                REMW=0`expr $W - 5`
            else
                REMW=`expr $W - 5`
            fi
        rm -fv "$BACKUPDIR/weekly/week.$REMW".*
        echo
            dbdump "$DBNAMES" "$BACKUPDIR/weekly/week.$W.$DATE.$EXT"
            compression "$BACKUPDIR/weekly/week.$W.$DATE.$EXT"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/weekly/week.$W.$DATE.$EXT$SUFFIX*"
        echo ----------------------------------------------------------------------
    # Daily Backup
    else
        echo Daily Backup of Databases \( $DBNAMES \)
        echo
        echo Rotating last weeks Backup...
        rm -fv "$BACKUPDIR"/daily/*."$DOW".$EXT*
        echo
            dbdump "$DBNAMES" "$BACKUPDIR/daily/$DATE.$DOW.$EXT"
            compression "$BACKUPDIR/daily/$DATE.$DOW.$EXT"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/daily/$DATE.$DOW.$EXT$SUFFIX*"
        echo ----------------------------------------------------------------------
    fi
echo Backup End Time `date`
echo ======================================================================
fi
echo Total disk space used for backup storage..
echo Size - Location
echo `du -hs "$BACKUPDIR"`
echo


# Run command when we're done
if [ "$POSTBACKUP" ]
    then
    echo ======================================================================
    echo "Postbackup command output."
    echo
    $POSTBACKUP
    echo
    echo ======================================================================
fi

#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 2>&7 7>&-      # Restore stdout and close file descriptor #7.

if [ "$MAILCONTENT" = "files" ]
then
    if [ -s "$LOGERR" ]
    then
        # Include error log if is larger than zero.
        BACKUPFILES="$BACKUPFILES $LOGERR"
        ERRORNOTE="WARNING: Error Reported - "
    fi
    #Get backup size
    ATTSIZE=`du -c $BACKUPFILES | grep "[[:digit:][:space:]]total$" |sed s/\s*total//`
    if [ $MAXATTSIZE -ge $ATTSIZE ]
    then
        if which biabam >/dev/null 2>&1
        then
            BACKUPFILES=$(echo $BACKUPFILES | sed -r -e 's#\s+#,#g')
            biabam -s "PostgreSQL Backup Log and SQL Files for $HOST - $DATE" $BACKUPFILES $MAILADDR < $LOGFILE
        elif which heirloom-mailx >/dev/null 2>&1
        then
            BACKUPFILES=$(echo $BACKUPFILES | sed -e 's# # -a #g')
            heirloom-mailx -s "PostgreSQL Backup Log and SQL Files for $HOST - $DATE" $BACKUPFILES $MAILADDR < $LOGFILE
        elif which neomutt >/dev/null 2>&1
        then
            BACKUPFILES=$(echo $BACKUPFILES | sed -e 's# # -a #g')
            neomutt -s "PostgreSQL Backup Log and SQL Files for $HOST - $DATE" -a $BACKUPFILES -- $MAILADDR < $LOGFILE
        elif which mutt >/dev/null 2>&1
        then
            BACKUPFILES=$(echo $BACKUPFILES | sed -e 's# # -a #g')
            mutt -s "PostgreSQL Backup Log and SQL Files for $HOST - $DATE" -a $BACKUPFILES -- $MAILADDR < $LOGFILE
        else
            cat "$LOGFILE" | mail -s "WARNING! - Enable to send PostgreSQL Backup dumps, no suitable mail client found on $HOST - $DATE" $MAILADDR
        fi
    else
        cat "$LOGFILE" | mail -s "WARNING! - PostgreSQL Backup exceeds set maximum attachment size on $HOST - $DATE" $MAILADDR
    fi
elif [ "$MAILCONTENT" = "log" ]
then
    cat "$LOGFILE" | mail -s "PostgreSQL Backup Log for $HOST - $DATE" $MAILADDR
    if [ -s "$LOGERR" ]
        then
            cat "$LOGERR" | mail -s "ERRORS REPORTED: PostgreSQL Backup error Log for $HOST - $DATE" $MAILADDR
    fi
elif [ "$MAILCONTENT" = "quiet" ]
then
    if [ -s "$LOGERR" ]
        then
            cat "$LOGERR" | mail -s "ERRORS REPORTED: PostgreSQL Backup error Log for $HOST - $DATE" $MAILADDR
            cat "$LOGFILE" | mail -s "PostgreSQL Backup Log for $HOST - $DATE" $MAILADDR
    fi
else
    if [ -s "$LOGERR" ]
        then
            cat "$LOGFILE"
            echo
            echo "###### WARNING ######"
            echo "Errors reported during AutoPostgreSQLBackup execution.. Backup failed"
            echo "Error log below.."
            cat "$LOGERR"
    else
        cat "$LOGFILE"
    fi
fi

if [ -s "$LOGERR" ]
    then
        STATUS=1
    else
        STATUS=0
fi

# Clean up Logfile
rm -f "$LOGFILE"
rm -f "$LOGERR"

exit $STATUS
