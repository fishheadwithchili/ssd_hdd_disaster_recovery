#!/bin/bash
# inode-analyzer.sh - 分析inode消耗

echo "======== Inode 使用分析 ========"

# 总体情况
df -i /mnt/backup_hdd

echo -e "\nTop 20 Inode消耗大户:"
find /mnt/backup_hdd -xdev -type d -exec bash -c \
    'echo $(find "$1" -maxdepth 1 | wc -l) "$1"' _ {} \; 2>/dev/null | \
    sort -rn | head -20

echo -e "\n检查是否有异常小文件堆积:"
find /mnt/backup_hdd/snapshots -type f -size -1k 2>/dev/null | head -20
