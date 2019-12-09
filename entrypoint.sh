#!/bin/sh

if ! [ -f backup-cron ]
then
  echo "Creating cron entry to start backup at: $BACKUP_TIME"
  # Note: Must use tabs with indented 'here' scripts.
  cat <<-EOF >> backup-cron
MYSQL_HOST=${MYSQL_HOST}
MYSQL_USER=${MYSQL_USER}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_PASSWORD_FILE=${MYSQL_PASSWORD_FILE}
APP_DIRECTORY=${APP_DIRECTORY}
EOF

  if [[ ${CLEANUP_OLDER_THAN} ]]
  then
    echo "CLEANUP_OLDER_THAN=${CLEANUP_OLDER_THAN}" >> backup-cron
  fi
  echo "${BACKUP_TIME} /usr/local/bin/backup >/dev/stdout 2>&1" >> backup-cron

  crontab backup-cron
fi

echo "Current crontab:"
crontab -l

echo 'start'
exec "$@"
