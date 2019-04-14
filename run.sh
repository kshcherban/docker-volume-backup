#!/bin/bash -e

# Following variables should be set
# S3_BUCKET - s3://mybucket/path/to/backups - s3 path where to store backups, if empty s3 upload will not happen
# BACKUP_PATH - path to store backup files, defaults to ${HOME}/backups
# VOLUME_REGEXP - regexp for volumes to backup, default *, which means all
# CLEANUP_OLD - cleanup old backups, defaults to false

BACKUP_PATH="${BACKUP_PATH:-$HOME/backups}"
VOLUME_REGEXP="${VOLUME_REGEXP:-.*}"
CLEANUP_OLD="${CLEANUP_OLD:-false}"

TODAY="$(date +%Y-%m-%d)"

function logger() {
    echo "$(date +"%h %d %H:%M:%S") $@"
}

# go to script source directory to execute make commands
cd $(dirname $0)

# check if backup image exists or create it
if ! (docker image inspect volume-backup &> /dev/null); then
    logger "INFO: building docker image helper"
    make build
fi

mkdir -p ${BACKUP_PATH}/${TODAY}

logger "INFO: creating backup for $TODAY"
for VOLUME in $(docker volume ls --format {{.Name}} | grep "$VOLUME_REGEXP"); do
    make backup VOLUME=${VOLUME} BACKUP=${BACKUP_PATH}/${TODAY}
done

if [ x"$S3_BUCKET" != x ]; then
    logger "INFO: uploading to S3 $S3_BUCKET"
    for f in $(ls ${BACKUP_PATH}/${TODAY}/); do
        aws s3 cp --quiet ${BACKUP_PATH}/${TODAY}/$f ${S3_BUCKET}/${TODAY}/$f
    done
fi

if [ $CLEANUP_OLD == "true" ]; then
    logger "INFO: cleaning up"
    # Stupid check for wrong files deletion
    # TODO implement proper cleanup
    if [ "$BACKUP_PATH" == "/" ]; then
        logger "ERROR: backup path is /, may delete wrong files"
        exit 1
    else
        find $BACKUP_PATH -mindepth 1 -type d ! -name "*$TODAY*" -exec rm -rfv {} +
    fi
fi

logger "INFO: backup finished successfully!"
aws s3 ls ${S3_BUCKET}/${TODAY}/
