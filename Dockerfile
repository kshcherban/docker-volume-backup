FROM alpine:3.8

RUN apk add --update --no-cache zstd tar

COPY *.sh /bin/
RUN chmod +x /bin/*.sh

ENTRYPOINT ["backup.sh"]
