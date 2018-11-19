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

BACKUP_FILE="${BACKUP_DST}/${VOLUME}_backup.tar.zst"

if ! [ -f $BACKUP_FILE ]; then
    echo "$BACKUP_FILE does not exist to be restored"
    exit 1
fi

echo "Creating docker volume $VOLUME"
docker volume create $VOLUME || true

echo "Restoring ${BACKUP_FILE} inside $VOLUME"
docker run --rm -ti -v ${BACKUP_FILE}:/opt/backup.tar.zst -v ${VOLUME}:/backup volume-backup restore
echo "Backup restored"
