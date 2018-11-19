#!/bin/sh

BACKUP_SRC=/backup
BACKUP_DST=/opt/backup.tar.zst

if [ "$1" == "backup" ]; then
    tar -Izstd -cf $BACKUP_DST -C $BACKUP_SRC .
    chown $USER_ID $BACKUP_DST
else
    tar -Izstd -xf $BACKUP_DST -C $BACKUP_SRC
fi
