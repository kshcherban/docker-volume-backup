#!/bin/sh

BACKUP_SRC=/backup
BACKUP_DST=/opt/backup.tar.zst

if [ "$1" == "backup" ]; then
    tar -Izstd --numeric-owner -cf $BACKUP_DST -C $BACKUP_SRC .
    chown $USER_ID $BACKUP_DST
else
    tar -Izstd --numeric-owner -xf $BACKUP_DST -C $BACKUP_SRC
fi
