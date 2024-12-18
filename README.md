# Docker Backup

A Docker container for automated backups of application files and MySQL/MariaDB databases. This solution provides both backup and restore functionality with configurable scheduling.

## Installation

You can pull the image directly from Docker Hub:

```bash
docker pull mikenowak/backup
```

## Features

- Scheduled backups of application directories
- MySQL/MariaDB database dumps
- Configurable backup schedule
- Automatic cleanup of old backups
- Secure credential handling
- Backup restoration capability

## Usage

### Docker Compose Example

```yaml
version: '3.8'

services:
  backup:
    image: mikenowak/backup
    # alternatively, build from source:
    # build: .
    environment:
      - BACKUP_TIME=0 3 * * *  # Run at 3 AM daily
      - MYSQL_HOST=db
      - MYSQL_USER=dbuser
      - MYSQL_DATABASE=myapp
      - MYSQL_PASSWORD_FILE=/run/secrets/db_password
      - APP_DIRECTORY=/app
      - CLEANUP_OLDER_THAN=30  # Optional: remove backups older than 30 days
    volumes:
      - ./app:/app:ro  # Application files (read-only)
      - ./backups:/backup  # Backup storage
      - ./db_password:/run/secrets/db_password:ro  # Database password file
```

### Environment Variables

- `BACKUP_TIME`: Cron schedule for backups (default: "0 3 * * *")
- `MYSQL_HOST`: Database host
- `MYSQL_USER`: Database user
- `MYSQL_DATABASE`: Database name
- `MYSQL_PASSWORD_FILE`: Path to file containing database password
- `APP_DIRECTORY`: Directory to backup
- `CLEANUP_OLDER_THAN`: Days to keep backups (optional)

### Backup Format

Backups are stored in the `/backup` volume with the following naming convention:
- Application files: `app_YYYYMMDD_HHMMSS.tar.gz`
- Database dumps: `db_YYYYMMDD_HHMMSS.sql.bz2`

### Performing a Restore

The container includes a restore script to recover from backups. To restore:

1. First, list available backups:
```bash
docker exec backup ls -l /backup
```

2. Restore from a specific backup using the timestamp:
```bash
docker exec backup restore YYYYMMDD_HHMMSS
```

For example:
```bash
docker exec backup restore 20240318_030000
```

### Manual Backup

To trigger a manual backup:
```bash
docker exec backup backup
```

## Security Considerations

- Database passwords should be provided via a file mount, not environment variables
- Use read-only mounts for source directories where possible
- The backup volume should be properly secured
- Backups are compressed to save space
- Consider encrypting sensitive backups

## Logging

- All operations log to stderr/stdout for container logging
- Errors are clearly marked with "ERROR:" prefix
- Informational messages are marked with "INFO:" prefix
- Use `docker logs` to view the backup history

## Building

```bash
docker build -t backup .
```

## Development

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Credits

Inspired by [aveltens/wordpress-backup](https://hub.docker.com/r/aveltens/wordpress-backup/)

## License

[MIT](LICENSE)
