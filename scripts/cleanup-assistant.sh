#!/bin/bash
# cleanup-assistant.sh - 空间清理建议工具

echo "======== 磁盘空间分析 ========"

# SSD分析
echo -e "\n[SSD 空间使用]"
df -h /mnt/ssd
echo "=== SSD空间分布 ==="
df -h /mnt/nvme1_data1_ext4
du -h --max-depth=2 /mnt/nvme1_data1_ext4 2>/dev/null | sort -rh | head -10

# HDD快照分析
echo -e "\n[HDD 快照空间]"
du -sh /mnt/backup_hdd/snapshots/*/ 2>/dev/null | sort -rh

# HDD归档分析
echo -e "\n[HDD 归档空间]"
du -sh /mnt/backup_hdd/cold-archive/*/ 2>/dev/null | sort -rh

# Docker清理建议
echo -e "\n[Docker 清理建议]"
docker system df

echo -e "\n======== 清理建议 ========"
echo "1. 删除Docker未使用资源: sudo docker system prune -a --volumes"
echo "2. 清理old归档（超过2年）: find /mnt/backup_hdd/cold-archive -mtime +730 -delete"
echo "3. 压缩大型日志文件: find /mnt/nvme1_data1_ext4 -name '*.log' -size +100M -exec gzip {} \;"
