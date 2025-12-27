#!/bin/bash
# auto-archive.sh - 自动将SSD冷数据归档到HDD
# 执行频率: 每日凌晨2:00

set -euo pipefail

ARCHIVE_ROOT="/mnt/backup_hdd/cold-archive"
SSD_ROOT="/mnt/nvme1_data1_ext4"

log() {
    logger -t "auto-archive" "$1"
    echo "[$(date)] $1"
}

# ============================================================================
# 1. 归档数据库备份（假设PostgreSQL）
# ============================================================================
archive_database() {
    log "开始归档数据库..."
    
    local DB_BACKUP_DIR="$SSD_ROOT/hot-data/db-backups"
    local ARCHIVE_DB_DIR="$ARCHIVE_ROOT/db-history/$(date +%Y)/$(date +%m)"
    
    mkdir -p "$ARCHIVE_DB_DIR"
    
    # 移动30天前的备份
    find "$DB_BACKUP_DIR" -type f -name "*.sql.gz" -mtime +30 -exec mv {} "$ARCHIVE_DB_DIR/" \;
    
    log "数据库归档完成"
}

# ============================================================================
# 2. 归档应用日志
# ============================================================================
archive_logs() {
    log "开始归档日志..."
    
    local LOG_DIR="$SSD_ROOT/hot-data/logs"
    local ARCHIVE_LOG_DIR="$ARCHIVE_ROOT/logs-compressed/$(date +%Y-%m)"
    
    mkdir -p "$ARCHIVE_LOG_DIR"
    
    # 压缩并移动90天前的日志
    find "$LOG_DIR" -type f -name "*.log" -mtime +90 -exec gzip {} \; -exec mv {}.gz "$ARCHIVE_LOG_DIR/" \;
    
    log "日志归档完成"
}

# ============================================================================
# 3. 归档AI推理结果
# ============================================================================
archive_ai_results() {
    log "开始归档AI推理结果..."
    
    local AI_RESULTS="$SSD_ROOT/services/inference-results"
    local ARCHIVE_AI_DIR="$ARCHIVE_ROOT/ai-results/$(date +%Y-%m)"
    
    mkdir -p "$ARCHIVE_AI_DIR"
    
    # 移动30天未访问的结果
    find "$AI_RESULTS" -type f -atime +30 -exec mv {} "$ARCHIVE_AI_DIR/" \;
    
    log "AI结果归档完成"
}

# ============================================================================
# 4. 清理归档暂存区
# ============================================================================
clean_staging() {
    log "清理归档暂存区..."
    
    local STAGING="$SSD_ROOT/archive-staging"
    
    # 将暂存区内容移动到归档区
    if [ -d "$STAGING" ] && [ "$(ls -A $STAGING)" ]; then
        rsync -a --remove-source-files "$STAGING/" "$ARCHIVE_ROOT/manual/"
        find "$STAGING" -type d -empty -delete
    fi
    
    log "暂存区清理完成"
}

# ============================================================================
# 执行归档
# ============================================================================
log "======== 开始自动归档 ========"

archive_database
archive_logs
archive_ai_results
clean_staging

# 报告归档空间使用
ARCHIVE_SIZE=$(du -sh "$ARCHIVE_ROOT" | awk '{print $1}')
log "归档区总大小: $ARCHIVE_SIZE"

log "======== 归档完成 ========"
