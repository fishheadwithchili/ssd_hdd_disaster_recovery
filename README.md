![Project Logo](assets/images/logo.png)

# SSD-HDD Disaster Recovery

> AI Infrastructure Storage Architecture + Integrated Disaster Recovery Solution (v3.0 Production-Hardened Edition)

This project provides a production-proven disaster recovery solution designed for AI workloads on Ubuntu 24.04 LTS. It combines high-speed NVMe SSDs with high-capacity HDDs, leveraging `rsnapshot` and LUKS full-disk encryption to achieve efficient and secure incremental backups.

## 📁 Project Structure

```
.
├── assets/                 # Static assets
│   └── images/             # Image resources
├── config/                 # Configuration templates
│   ├── backup_alerts.yml   # Prometheus alerting rules
│   ├── daemon.json         # Docker storage configuration
│   ├── node_exporter.service # Systemd service unit
│   ├── rsnapshot-exclude-ai.conf # rsnapshot exclude patterns
│   └── rsnapshot.conf      # rsnapshot main configuration
├── docs/                   # Detailed documentation
│   ├── ssd-hdd-disaster-recovery.md      # Full deployment guide (English)
│   └── ssd-hdd-disaster-recovery_CN.md   # Full deployment guide (Chinese)
├── scripts/                # Automated implementation scripts
│   ├── auto-archive.sh     # Cold data auto-archiving script
│   ├── backup-metrics-exporter.sh # Prometheus metrics exporter
│   ├── cleanup-assistant.sh # Disk cleanup assistant tool
│   ├── deploy-ai-backup-integrated.sh # One-click deployment script
│   ├── inode-analyzer.sh   # Inode usage analysis tool
│   ├── rsnapshot-wrapper.sh # Core backup wrapper (w/ LUKS auto-mount)
│   └── verify-backup.sh    # Backup integrity verification tool
├── README_CN.md            # Chinese Documentation
└── README.md               # English Documentation
```

## 🚀 Key Features

- **Zero-Partition Design**: Single LUKS partition on HDD, folder-based isolation for backups and archives to maximize space efficiency.
- **SSD First**: Focuses on backing up critical business data on SSD (AI models, databases, code), intelligently excluding reproducible artifacts.
- **Security**: LUKS full-disk encryption with dual key slot support guarantees physical security.
- **Production-Grade Monitoring**: Integrated with Prometheus + Grafana for real-time monitoring of backup status and disk health.
- **Extreme Performance**: Benchmark tested at 10,000 files/sec backup rate; incremental backups take only 5-15 minutes.

## 📖 Quick Start

For detailed deployment steps, configuration instructions, and the operations manual, please refer to the full documentation:

👉 **[Full Deployment Guide (Docs)](docs/ssd-hdd-disaster-recovery.md)**

### One-Click Deployment (Test Environment)

If you are on a fresh Ubuntu 24.04 machine with an empty HDD, you can use the one-click deployment script (**WARNING: WILL WIPE HDD DATA**):

```bash
sudo bash scripts/deploy-ai-backup-integrated.sh
```

### Manual Deployment Summary

1.  **Prepare HDD**: Encrypt with LUKS and format as ext4.
2.  **Configure Directories**: Create the planned directory structure on both SSD and HDD.
3.  **Install & Configure**: Install `rsnapshot` and copy configuration files from `config/` to system directories.
4.  **Set Schedule**: Configure crontab to execute `scripts/rsnapshot-wrapper.sh`.
5.  **Verify**: Run `scripts/verify-backup.sh` to ensure the system is functioning correctly.

## 🛠️ Common Commands

- **Trigger Hourly Backup Manually**: `sudo scripts/rsnapshot-wrapper.sh hourly`
- **View Backup Metrics**: `bash scripts/backup-metrics-exporter.sh`
- **Run Backup Verification**: `sudo scripts/verify-backup.sh`

## 📄 License

This project is licensed under the MIT License.
