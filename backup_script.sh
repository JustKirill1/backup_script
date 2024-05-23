#!/bin/bash

BACKUP_DIR="/root/backups"
DAILY_BACKUP_DIR="/root/backups/once_in_two_backups"
WEEKLY_BACKUP_DIR="/root/backups/weekly_backup"
DB_USER="postgres"
DB_NAME="financial_exchange"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_$(date +'%Y-%m-%d_%H%M%S').sql.gz"
LOG_FILE="/root/backups/backup.log"
SECONDS_COUNT=$(date +%s)
DAY_OF_WEEK=$(date +%u)
PG_DUMP="/usr/lib/postgresql/14/bin/pg_dump"
$PG_DUMP -U $DB_USER -d $DB_NAME | gzip > $BACKUP_FILE

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Бэкап выполнен: $BACKUP_FILE" >> $LOG_FILE

cd $BACKUP_DIR
ls -t ${DB_NAME}_*.sql.gz | sed -e '1,5d' | xargs -d '\n' rm -f

if (( $SECONDS_COUNT % (2 * 24 * 3600) < 3600 )); then
    cp $BACKUP_FILE $DAILY_BACKUP_DIR/
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Бэкап раз-в-два-дня выполнен: $DAILY_BACKUP_DIR/$(basename $BACKUP_FILE)" >> $LOG_FILE
    cd $DAILY_BACKUP_DIR
    ls -t ${DB_NAME}_*.sql.gz | sed -e '1,5d' | xargs -d '\n' rm -f
fi

if [ $DAY_OF_WEEK -eq 7 ]; then
    cp $BACKUP_FILE $WEEKLY_BACKUP_DIR/
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Еженедельный бэкап выполнен: $WEEKLY_BACKUP_DIR/$(basename $BACKUP_FILE)" >> $LOG_FILE
fi
