FROM alpine:3.7
RUN apk add --no-cache mysql-client bzip2

COPY entrypoint.sh /entrypoint.sh
COPY backup restore /usr/local/bin/

VOLUME /backup

ENTRYPOINT ["/entrypoint.sh"]
CMD ["crond", "-f"]
