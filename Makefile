build:
	docker build -t volume-backup .

clean:
	docker rmi -f volume-backup || true
ifdef BACKUP
	rm -fv ${BACKUP}/*.zst
else
	rm -fv *.zst
endif

backup:
ifdef VOLUME
	./create.sh ${VOLUME} ${BACKUP}
else
	$(error "Usage: make backup VOLUME=<volume-name> BACKUP=[backup-directory]")
endif

restore:
ifdef VOLUME
	./restore.sh ${VOLUME} ${BACKUP}
else
	$(error "Usage: make restore VOLUME=<volume-name> BACKUP=[backup-directory]")
endif

.PHONY: build clean backup restore
