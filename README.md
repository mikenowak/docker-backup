# Docker Backup

A Docker container for automated backups of application files and MySQL/MariaDB databases. This solution provides both backup and restore functionality with configurable scheduling.

## Installation

You can pull the image directly from Docker Hub:

```bash
docker pull mikenowak/backup
```

## Features

- Flexible backup modes:
  - Application files only
  - MySQL/MariaDB database only
  - Both files and database
- Configurable backup schedule
- Automatic cleanup of old backups
- Secure credential handling
- Backup restoration capability

## Usage

The container can operate in three modes depending on which environment variables you provide:

### 1. Application Files Only

For backing up just application files:

```yaml
version: '3.8'
services:
  backup:
    image: mikenowak/backup
    environment:
      - BACKUP_TIME=0 3 * * *  # Run at 3 AM daily
      - APP_DIRECTORY=/app
      - CLEANUP_OLDER_THAN=30  # Optional
    volumes:
      - ./app:/app:ro
      - ./backups:/backup
```

### 2. MySQL/MariaDB Database Only

For backing up just a database:

```yaml
version: '3.8'
services:
  backup:
    image: mikenowak/backup
    environment:
      - BACKUP_TIME=0 3 * * *
      - MYSQL_HOST=db
      - MYSQL_USER=dbuser
      - MYSQL_DATABASE=myapp
      - MYSQL_PASSWORD_FILE=/run/secrets/db_password
      - CLEANUP_OLDER_THAN=30  # Optional
    volumes:
      - ./backups:/backup
      - ./db_password:/run/secrets/db_password:ro
```

### 3. Both Files and Database

For backing up both:

```yaml
version: '3.8'
services:
  backup:
    image: mikenowak/backup
    environment:
      - BACKUP_TIME=0 3 * * *
      - APP_DIRECTORY=/app
      - MYSQL_HOST=db
      - MYSQL_USER=dbuser
      - MYSQL_DATABASE=myapp
      - MYSQL_PASSWORD_FILE=/run/secrets/db_password
      - CLEANUP_OLDER_THAN=30  # Optional
    volumes:
      - ./app:/app:ro
      - ./backups:/backup
      - ./db_password:/run/secrets/db_password:ro
```

## Environment Variables

Required (at least one set):
- Application backup:
  - `APP_DIRECTORY`: Directory to backup
- Database backup:
  - `MYSQL_HOST`: Database host
  - `MYSQL_USER`: Database user
  - `MYSQL_DATABASE`: Database name
  - `MYSQL_PASSWORD_FILE`: Path to file containing database password

Optional:
- `BACKUP_TIME`: Cron schedule for backups (default: "0 3 * * *")
- `CLEANUP_OLDER_THAN`: Days to keep backups

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
