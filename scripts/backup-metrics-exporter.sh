#!/bin/bash
# backup-metrics-exporter.sh - 导出备份状态到Prometheus

METRICS_FILE="/var/lib/node_exporter/textfile_collector/backup.prom"
mkdir -p "$(dirname $METRICS_FILE)"

# 检查最新备份时间
LAST_BACKUP=$(stat -c %Y /mnt/backup_hdd/snapshots/hourly.0 2>/dev/null || echo 0)
CURRENT_TIME=$(date +%s)
BACKUP_AGE=$((CURRENT_TIME - LAST_BACKUP))

# 快照数量
HOURLY_COUNT=$(ls -d /mnt/backup_hdd/snapshots/hourly.* 2>/dev/null | wc -l)
DAILY_COUNT=$(ls -d /mnt/backup_hdd/snapshots/daily.* 2>/dev/null | wc -l)

# HDD使用率
HDD_USAGE=$(df /mnt/backup_hdd | tail -1 | awk '{print $5}' | sed 's/%//')

# 生成Prometheus格式指标
cat > "$METRICS_FILE" << EOF
# HELP backup_last_success_timestamp_seconds Last successful backup timestamp
# TYPE backup_last_success_timestamp_seconds gauge
backup_last_success_timestamp_seconds $LAST_BACKUP

# HELP backup_age_seconds Age of last backup in seconds
# TYPE backup_age_seconds gauge
backup_age_seconds $BACKUP_AGE

# HELP backup_snapshot_count Number of snapshots by type
# TYPE backup_snapshot_count gauge
backup_snapshot_count{type="hourly"} $HOURLY_COUNT
backup_snapshot_count{type="daily"} $DAILY_COUNT

# HELP backup_hdd_usage_percent HDD disk usage percentage
# TYPE backup_hdd_usage_percent gauge
backup_hdd_usage_percent $HDD_USAGE
EOF
