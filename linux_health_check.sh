#!/bin/bash

# ====================================================
# Project : Linux Health Check Script
# Author  : Lakshmana Gowda
# Version : 1.0
# Created : June 2026
# Purpose :
#   Collects Linux system information and performs
#   basic health analysis for memory and disk usage.
#
# Features:
#   - System Information
#   - Uptime
#   - Memory Report & Analysis
#   - Disk Report & Analysis
#   - Colored Output
#   - Timestamped Logging
# ====================================================

###############
# Configuration
###############

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

LOG_DIR="logs"

MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

SCRIPT_VERSION="1.0"

LOG_FILE="${LOG_DIR}/health_check_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

log() {
    echo -e "$@" | tee -a "$LOG_FILE"
}

header() {
    echo
log "${CYAN}===================================================${RESET}"
log "${CYAN}Linux Health Check Script v${SCRIPT_VERSION}${RESET}"
log "${CYAN}===================================================${RESET}"
}

system_info() {
log ""
log "Hostname      : $(hostname)"
log "Current User  : $(whoami)"
log "Date and Time : $(date)"
log "Kernel Version: $(uname -r)"
}

show_uptime() {
log ""
log "${BLUE}System Uptime${RESET}"
log "----------------------------------------"
uptime -p | tee -a "$LOG_FILE"
}

show_memory() {
log ""
log "${BLUE}Memory Usage${RESET}"
log "----------------------------------------"
free -h | tee -a "$LOG_FILE"
}

check_memory_health() {
log ""
total_memory=$(free | awk 'NR==2 {print $2}')
used_memory=$(free | awk 'NR==2 {print $3}')
memory_usage=$(( used_memory * 100 / total_memory ))
log "${BLUE}Memory Health Analysis${RESET}"
log "----------------------------------------"
log "Memory Usage : ${memory_usage}%"
if [ "$memory_usage" -ge "$MEMORY_THRESHOLD" ]
then
    log "${YELLOW}WARNING: High Memory Usage.${RESET}"
else
    log "${GREEN}Memory Usage is Healthy.${RESET}"
fi
}

show_disk() {
log ""
log "${BLUE}Disk Usage${RESET}"
log "----------------------------------------"
df -h / | tee -a "$LOG_FILE"
}

check_disk_health() {
log ""
log "${BLUE}Disk Health Analysis${RESET}"
log "----------------------------------------"
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
log "Disk Usage : ${disk_usage}%"
if [ "$disk_usage" -ge "$DISK_THRESHOLD" ]
then
    log "${YELLOW}WARNING: Disk Usage is above ${DISK_THRESHOLD}%.${RESET}"
else
    log "${GREEN}Disk Usage is Healthy.${RESET}"
fi
}

footer() {
log ""
log "${CYAN}===================================================${RESET}"
log "${CYAN}      Health Check Completed Successfully.         ${RESET}"
log "${CYAN}===================================================${RESET}"
}


main() {
    header
    system_info
    show_uptime
    show_memory
    check_memory_health
    show_disk
    check_disk_health
    footer
}

main
exit 0
