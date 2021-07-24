FROM alpine:3.14
RUN apk add --no-cache mysql-client bzip2 bash

COPY entrypoint.sh /entrypoint.sh
COPY backup restore /usr/local/bin/

ENV BACKUP_TIME 0 3 * * *
VOLUME /backup

ENTRYPOINT ["/entrypoint.sh"]
CMD ["crond", "-f"]
