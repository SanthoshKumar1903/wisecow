#!/bin/bash

# Simple backup script with rsync

# configuration - CHANGE THESE
SOURCE_DIR="$HOME/documents"  # directory to backup
BACKUP_DIR="$HOME/backups"   # where to store backups
BACKUP_NAME="wisecow-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="backup.log"

echo "=== Backup Started - $(date) ===" | tee -a $LOG_FILE

# create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Created backup directory: $BACKUP_DIR" | tee -a $LOG_FILE
fi

# check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: Source directory does not exist: $SOURCE_DIR" | tee -a $LOG_FILE
    exit 1
fi

# create backup
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

echo "Backing up $SOURCE_DIR to $BACKUP_PATH..." | tee -a $LOG_FILE

# use rsync for backup
rsync -av --progress "$SOURCE_DIR" "$BACKUP_PATH" >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "Backup completed successfully!" | tee -a $LOG_FILE
    
    # show backup size
    BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    echo "Backup size: $BACKUP_SIZE" | tee -a $LOG_FILE
    
    # cleanup old backups (keep last 5)
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR" | wc -l)
    if [ $BACKUP_COUNT -gt 5 ]; then
        echo "Cleaning up old backups (keeping last 5)..." | tee -a $LOG_FILE
        ls -t "$BACKUP_DIR" | tail -n +6 | xargs -I {} rm -rf "$BACKUP_DIR/{}"
    fi
else
    echo "Backup FAILED!" | tee -a $LOG_FILE
    exit 1
fi

echo "=== Backup Finished - $(date) ===" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
