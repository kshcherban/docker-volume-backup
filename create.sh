#!/bin/bash -e

if [ "$1" == "" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: docker-vol-backup <volume-name> [backup-directory]"
    exit
fi

VOLUME="$1"
if [ "$2" == "" ]; then
    BACKUP_DST="$(pwd)"
else
    BACKUP_DST="$2"
fi

echo "Creating backup of $VOLUME"
docker run --rm -ti -e USER_ID=$(id -u) -v ${BACKUP_DST}:/opt -v ${VOLUME}:/backup:ro volume-backup backup
mv ${BACKUP_DST}/backup.tar.zst ${BACKUP_DST}/${VOLUME}_backup.tar.zst
echo "Backup saved in ${BACKUP_DST}/${VOLUME}_backup.tar.zst"
