# Docker volume backup-restore tool

make, docker are required for it to work.
Tool should be executed on the same machine where docker volumes are.

Available commands:

* `make build` build helper container, should be run first
* `make backup VOLUME=<volume> BACKUP=<backups-directory>` backup volume
* `make restore VOLUME=<volume> BACKUP=<backups-directory>` restore volume from backups
* `make clean BACKUP=<backups-directory>` remove helper image and backups

If `BACKUP` parameter is omitted, backups will be stored in current directory.
[Zstd](https://github.com/facebook/zstd) is used to compress backups.

Example of all docker volumes backup
```
make build
mkdir /tmp/backups
for VOLUME in $(docker volume ls --format {{.Name}}); do
    make backup VOLUME=$VOLUME BACKUP=/tmp/backups
done
```
