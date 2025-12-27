#!/bin/bash
# rsnapshot-wrapper.sh v2.0 - AI Infrastructure Edition
# 功能: LUKS自动挂载 + 备份执行 + 监控检查

set -euo pipefail

# ============================================================================
# 配置区（根据你的环境修改）
# ============================================================================
HDD_UUID="$(blkid -s UUID -o value /dev/sdb)"  # 自动获取UUID
MAPPER_NAME="backup_crypt"
MOUNT_POINT="/mnt/backup_hdd"
KEYFILE="/root/backup_hdd.key"  # 如果不用密钥文件，留空: KEYFILE=""
SNAPSHOT_LEVEL="${1:-hourly}"   # 默认hourly，可传参: daily/weekly/monthly

# 监控阈值
DISK_WARN_PERCENT=80
DISK_CRIT_PERCENT=90
INODE_WARN_PERCENT=85

# ============================================================================
# 日志函数
# ============================================================================
log() {
    local level="$1"
    shift
    logger -t "rsnapshot-wrapper" -p "user.${level}" "$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
}

# ============================================================================
# 1. HDD挂载检查
# ============================================================================
if ! mountpoint -q "$MOUNT_POINT"; then
    log info "HDD未挂载，尝试挂载..."
    
    # 检查LUKS是否已打开
    if [ ! -e "/dev/mapper/$MAPPER_NAME" ]; then
        log info "解密LUKS分区..."
        if [ -n "$KEYFILE" ] && [ -f "$KEYFILE" ]; then
            cryptsetup luksOpen /dev/disk/by-uuid/"$HDD_UUID" "$MAPPER_NAME" --key-file "$KEYFILE"
        else
            cryptsetup luksOpen /dev/disk/by-uuid/"$HDD_UUID" "$MAPPER_NAME"
        fi
    fi
    
    # 挂载
    mkdir -p "$MOUNT_POINT"
    mount /dev/mapper/"$MAPPER_NAME" "$MOUNT_POINT"
    log info "HDD已挂载到 $MOUNT_POINT"
fi

# ============================================================================
# 2. 预检查（空间与inode）
# ============================================================================
log info "执行预检查..."

# 磁盘空间检查
DISK_USAGE=$(df -h "$MOUNT_POINT" | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_CRIT_PERCENT" ]; then
    log err "CRITICAL: HDD磁盘使用率 ${DISK_USAGE}% 超过临界值！"
    exit 1
elif [ "$DISK_USAGE" -gt "$DISK_WARN_PERCENT" ]; then
    log warning "WARNING: HDD磁盘使用率 ${DISK_USAGE}%，建议清理归档数据"
fi

# Inode检查
INODE_USAGE=$(df -i "$MOUNT_POINT" | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$INODE_USAGE" -gt "$INODE_WARN_PERCENT" ]; then
    log warning "WARNING: Inode使用率 ${INODE_USAGE}%，可能有大量小文件"
fi

# SSD空间检查
SSD_USAGE=$(df -h /mnt/nvme1_data1_ext4 | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$SSD_USAGE" -gt 85 ]; then
    log warning "SSD使用率 ${SSD_USAGE}%，建议归档数据到HDD"
fi

# ============================================================================
# 3. 执行备份
# ============================================================================
log info "开始执行 rsnapshot ($SNAPSHOT_LEVEL)..."

START_TIME=$(date +%s)
if rsnapshot "$SNAPSHOT_LEVEL"; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    log info "备份成功完成，耗时 ${DURATION}秒"
    EXIT_CODE=0
else
    log err "备份失败！检查 /var/log/rsnapshot.log"
    EXIT_CODE=1
fi

# ============================================================================
# 4. 备份后报告
# ============================================================================
if [ $EXIT_CODE -eq 0 ]; then
    # 统计快照大小
    SNAPSHOT_SIZE=$(du -sh "$MOUNT_POINT/snapshots" 2>/dev/null | awk '{print $1}')
    log info "快照总大小: $SNAPSHOT_SIZE"
    
    # 统计快照数量
    SNAPSHOT_COUNT=$(find "$MOUNT_POINT/snapshots" -maxdepth 1 -type d | wc -l)
    log info "快照数量: $((SNAPSHOT_COUNT - 1))"  # 减去snapshots目录本身
fi

exit $EXIT_CODE
