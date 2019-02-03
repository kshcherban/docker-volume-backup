#!/bin/bash -e

# Following variables should be set
# S3_BUCKET - s3://mybucket/path/to/backups - s3 path where to store backups, if empty s3 upload will not happen
# BACKUP_PATH - path to store backup files, defaults to ${HOME}/backups
# VOLUME_REGEXP - regexp for volumes to backup, default *, which means all
# CLEANUP_OLD - cleanup old backups, defaults to true

BACKUP_PATH="${BACKUP_PATH:-$HOME/backups}"
VOLUME_REGEXP="${VOLUME_REGEXP:-*}"
CLEANUP_OLD="${CLEANUP_OLD:-true}"

TODAY="$(date +%Y-%m-%d)"

# go to script source directory to execute make commands
cd $(dirname $0)

# check if backup image exists or create it
if ! (docker image inspect volume-backup &> /dev/null); then
    echo "** Building docker image helper"
    make build
fi

mkdir -p ${BACKUP_PATH}/${TODAY}

echo "** Creating backup for $TODAY"
for VOLUME in $(docker volume ls --format {{.Name}} | grep $VOLUME_REGEXP); do
    make backup VOLUME=${VOLUME} BACKUP=${BACKUP_PATH}/${TODAY}
done

if [ x"$S3_BUCKET" != x ]; then
    echo "** Uploading to S3 $S3_BUCKET"
    for f in ${BACKUP_PATH}/${TODAY}/*; do
        aws s3 cp $f ${S3_BUCKET}/$f
    done
fi

if [ $CLEANUP_OLD == "true" ]; then
    echo "** Cleaning up"
    find $BACKUP_PATH ! -name "*$TODAY*" -exec rm -v {} +
fi
