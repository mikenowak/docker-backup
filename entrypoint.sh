#!/bin/bash
set -eo pipefail

CRON_FILE="/etc/cron.d/backup-cron"

log_error() {
    echo "ERROR: $1" >&2
}

log_info() {
    echo "INFO: $1" >&2
}

validate_backup_time() {
    if ! [[ "$BACKUP_TIME" =~ ^[0-9*,/-]+ [0-9*,/-]+ [0-9*,/-]+ [0-9*,/-]+ [0-9*,/-]+$ ]]; then
        log_error "Invalid BACKUP_TIME format: $BACKUP_TIME"
        log_error "Expected format: '0 3 * * *' (minute hour day month weekday)"
        return 1
    fi
}

create_cron_environment() {
    # Ensure directory exists
    mkdir -p "$(dirname "$CRON_FILE")"
    
    # Start with a clean file
    cat > "$CRON_FILE" <<-'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EOF

    # Add environment variables if they exist
    {
        [ -n "$MYSQL_HOST" ] && echo "MYSQL_HOST=${MYSQL_HOST}"
        [ -n "$MYSQL_USER" ] && echo "MYSQL_USER=${MYSQL_USER}"
        [ -n "$MYSQL_DATABASE" ] && echo "MYSQL_DATABASE=${MYSQL_DATABASE}"
        [ -n "$MYSQL_PASSWORD_FILE" ] && echo "MYSQL_PASSWORD_FILE=${MYSQL_PASSWORD_FILE}"
        [ -n "$APP_DIRECTORY" ] && echo "APP_DIRECTORY=${APP_DIRECTORY}"
        [ -n "$CLEANUP_OLDER_THAN" ] && echo "CLEANUP_OLDER_THAN=${CLEANUP_OLDER_THAN}"
    } >> "$CRON_FILE"

    # Add the cron job with proper logging to stderr
    echo "${BACKUP_TIME} /usr/local/bin/backup 2>&1" >> "$CRON_FILE"

    # Set proper permissions
    chmod 0644 "$CRON_FILE"
}

setup_cron() {
    log_info "Creating cron entry to start backup at: $BACKUP_TIME"
    
    # Validate backup time format
    if ! validate_backup_time; then
        return 1
    fi

    # Create the cron environment
    if ! create_cron_environment; then
        log_error "Failed to create cron environment"
        return 1
    fi

    # Load the cron file
    if ! crontab "$CRON_FILE"; then
        log_error "Failed to load crontab"
        return 1
    fi

    log_info "Current crontab configuration:"
    crontab -l
}

main() {
    # Setup cron if not already configured
    if [ ! -f "$CRON_FILE" ]; then
        if ! setup_cron; then
            log_error "Failed to setup cron jobs"
            exit 1
        fi
    fi

    log_info "Starting cron daemon..."
    exec "$@"
}

main "$@"
