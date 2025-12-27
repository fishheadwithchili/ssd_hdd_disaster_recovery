![Project Logo](assets/images/logo.png)

# SSD-HDD 灾难恢复方案 (SSD-HDD Disaster Recovery)

> AI 基础设施存储架构 + 灾备一体化方案 (v3.0 Production-Hardened Edition)

本项目提供了一套经过生产环境验证的灾难恢复解决方案，专为 Ubuntu 24.04 LTS 环境下的 AI 工作负载设计。它结合了高速 NVMe SSD 和大容量 HDD，利用 `rsnapshot` 和 LUKS 全盘加密，实现高效、安全的增量备份。

## 📁 项目结构

```
.
├── assets/                 # 静态资源
│   └── images/             # 图片资源
├── config/                 # 配置文件模板
│   ├── backup_alerts.yml   # Prometheus 告警规则
│   ├── daemon.json         # Docker 存储配置
│   ├── node_exporter.service # Systemd 服务配置
│   ├── rsnapshot-exclude-ai.conf # rsnapshot 排除规则
│   └── rsnapshot.conf      # rsnapshot 主配置文件
├── docs/                   # 详细文档
│   ├── ssd-hdd-disaster-recovery.md      # 完整部署指南 (英文版)
│   └── ssd-hdd-disaster-recovery_CN.md   # 完整部署指南 (中文版)
├── scripts/                # 自动化运维脚本
│   ├── auto-archive.sh     # 冷数据自动归档脚本
│   ├── backup-metrics-exporter.sh # Prometheus 监控指标导出
│   ├── cleanup-assistant.sh # 磁盘清理辅助工具
│   ├── deploy-ai-backup-integrated.sh # 一键部署脚本
│   ├── inode-analyzer.sh   # Inode 分析工具
│   ├── rsnapshot-wrapper.sh # 核心备份包装脚本 (含 LUKS 自动挂载)
│   └── verify-backup.sh    # 备份完整性验证工具
└── README_CN.md            # 中文说明
└── README.md               # English Readme
```

## 🚀 核心特性

- **零分区设计**: HDD 单 LUKS 分区，文件夹隔离备份与归档，最大化空间利用率。
- **SSD 优先**: 专注于备份 SSD 上的关键业务数据 (AI 模型、数据库、代码)，智能排除可重建产物。
- **安全保障**: LUKS 全盘加密，支持双密钥槽位，确保物理安全。
- **生产级监控**: 集成 Prometheus + Grafana，实时监控备份状态和磁盘健康。
- **极致性能**: 实测 10,000 文件/秒备份速率，增量备份仅需 5-15 分钟。

## 📖 快速开始

详细的部署步骤、配置说明和运维手册请参考完整的文档：

👉 **[完整部署指南 (Docs)](docs/ssd-hdd-disaster-recovery_CN.md)**

### 一键部署 (测试环境)

如果你在一个全新的 Ubuntu 24.04 机器上，且有一块空的 HDD，可以使用一键部署脚本（**警告：会擦除 HDD 数据**）：

```bash
sudo bash scripts/deploy-ai-backup-integrated.sh
```

### 手动部署概要

1.  **准备 HDD**: 使用 LUKS 加密并格式化为 ext4。
2.  **配置目录**: 在 SSD 和 HDD 上创建规划好的目录结构。
3.  **安装配置**: 安装 `rsnapshot`，复制 `config/` 下的配置文件到系统目录。
4.  **设置定时任务**: 配置 crontab 执行 `scripts/rsnapshot-wrapper.sh`。
5.  **验证**: 运行 `scripts/verify-backup.sh` 确保系统正常工作。

## 🛠️ 常用命令

- **手动触发每小时备份**: `sudo scripts/rsnapshot-wrapper.sh hourly`
- **查看备份状态指标**: `bash scripts/backup-metrics-exporter.sh`
- **运行备份验证**: `sudo scripts/verify-backup.sh`

## 📄 许可证

本项目采用 MIT 许可证。详见 LICENSE 文件。
