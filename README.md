# SQL Server Management Studio 22 Repository

![SQL Server](https://img.shields.io/badge/SQL%20Server-2022-blue?logo=microsoftsqlserver)
![SSMS](https://img.shields.io/badge/SSMS-v22-red)
![License](https://img.shields.io/badge/License-MIT-green)
![Auto--Push](https://img.shields.io/badge/Daily--Backup-7%3A45%20PM-orange)

An organized repository containing SQL Server 2022 queries, data import scripts, reference datasets, and custom code snippets created in SQL Server Management Studio (SSMS 22).

---

## 📁 Repository Structure

```text
SQL-Server-Management-Studio-22/
├── README.md                      # Repository overview & documentation
├── LICENSE                        # MIT Open-Source License
├── .gitignore                     # Git ignore rules for SQL Server & SSMS
├── queries/                       # SQL Query Scripts
│   └── daily/                     # Daily working SQL scripts
├── data/                          # Reference data & CSV imports
├── snippets/                      # Custom SSMS SQL Code Snippets
└── .automation/                   # Backup Automation
    ├── auto_git_push.ps1          # Hardened daily auto-push PowerShell script
    └── auto_push.log              # Automated push log file (git-ignored)
```

---

## 🚀 Daily Backup Automation (7:45 PM)

This repository is configured with an automated daily background backup service using **Windows Task Scheduler**:

- **Execution Schedule**: Every day at **7:45 PM (19:45)**.
- **Missed Task Recovery**: If the computer is powered off or asleep at 7:45 PM, Windows automatically executes the missed backup immediately upon system wake-up.
- **Robust Edge Case Handling**:
  - Automatically clears stale `.git/index.lock` files.
  - Performs `git pull --rebase` prior to pushing to prevent remote non-fast-forward conflicts.
  - Includes a 3-attempt retry loop with a 30-second delay for transient network/Wi-Fi drops.
  - Performs automatic log rotation to keep `auto_push.log` clean.

### Manual Backup Trigger

You can also trigger a manual backup push at any time by running:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\sailenmondal\Documents\SQL Server Management Studio 22\.automation\auto_git_push.ps1"
```

---

## 💻 Environment Details

- **Database Engine**: Microsoft SQL Server 2022
- **IDE**: SQL Server Management Studio 22 (SSMS 22)
- **Author**: Sailen Mondal (`mr.sailenmondal@gmail.com`)

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).
