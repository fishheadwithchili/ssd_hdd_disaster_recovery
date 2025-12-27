#!/bin/bash
# verify-backup.sh - 验证备份完整性

set -euo pipefail

SNAPSHOT_DIR="/mnt/backup_hdd/snapshots/hourly.0"
VERIFY_LOG="/var/log/backup-verify.log"

log() {
    echo "[$(date)] $1" | tee -a "$VERIFY_LOG"
}

log "======== 开始备份验证 ========"

# 1. 检查关键目录是否存在
CRITICAL_PATHS=(
    "$SNAPSHOT_DIR/ssd/hot-data"
    "$SNAPSHOT_DIR/ssd/docker/volumes"
    "$SNAPSHOT_DIR/ssd/projects"
)

for path in "${CRITICAL_PATHS[@]}"; do
    if [ -d "$path" ]; then
        log "✓ $path 存在"
    else
        log "✗ 错误: $path 不存在！"
        exit 1
    fi
done

# 2. 随机抽样文件完整性检查
log "执行随机抽样校验..."
SAMPLE_FILES=$(find "$SNAPSHOT_DIR/ssd" -type f | shuf -n 10)

while IFS= read -r file; do
    if [ -f "$file" ]; then
        # 尝试读取文件（检测硬盘坏道）
        if dd if="$file" of=/dev/null bs=1M 2>/dev/null; then
            log "✓ $(basename $file) 可读"
        else
            log "✗ $(basename $file) 损坏"
        fi
    fi
done <<< "$SAMPLE_FILES"

# 3. 统计备份大小
BACKUP_SIZE=$(du -sh "$SNAPSHOT_DIR" | awk '{print $1}')
log "备份大小: $BACKUP_SIZE"

log "======== 验证完成 ========"
