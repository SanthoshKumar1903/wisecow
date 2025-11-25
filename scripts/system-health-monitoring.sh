#!/bin/bash

# Quick health check script - checks CPU, memory, disk, processes

LOG_FILE="system_health.log"

# thresholds - adjust these based on your system
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

echo "=== System Health Check - $(date) ===" | tee -a $LOG_FILE

# check CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
CPU_INT=${CPU_USAGE%.*}

echo "CPU Usage: ${CPU_INT}%" | tee -a $LOG_FILE

if [ $CPU_INT -gt $CPU_THRESHOLD ]; then
    echo "WARNING: CPU usage is above ${CPU_THRESHOLD}%!" | tee -a $LOG_FILE
fi

# check memory
MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
MEM_INT=${MEM_USAGE%.*}

echo "Memory Usage: ${MEM_INT}%" | tee -a $LOG_FILE

if [ $MEM_INT -gt $MEM_THRESHOLD ]; then
    echo "WARNING: Memory usage is above ${MEM_THRESHOLD}%!" | tee -a $LOG_FILE
fi

# check disk space (root partition)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "Disk Usage (/): ${DISK_USAGE}%" | tee -a $LOG_FILE

if [ $DISK_USAGE -gt $DISK_THRESHOLD ]; then
    echo "WARNING: Disk usage is above ${DISK_THRESHOLD}%!" | tee -a $LOG_FILE
fi

# show top 5 processes by CPU
echo "" | tee -a $LOG_FILE
echo "Top 5 CPU-consuming processes:" | tee -a $LOG_FILE
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{print $11, "-", $3"%"}' | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "---" | tee -a $LOG_FILE
