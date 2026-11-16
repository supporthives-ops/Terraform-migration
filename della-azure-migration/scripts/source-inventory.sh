#!/usr/bin/env bash
# Read-only inventory helper. Run on the AWS source as a sudo-capable user.
set -u
echo "=== OS ==="; cat /etc/os-release
echo "=== CPU/MEMORY ==="; lscpu | egrep 'Model name|CPU\(s\)|Socket|Core|Thread' || true; free -h
echo "=== STORAGE ==="; lsblk -f; df -hT
echo "=== APACHE ==="; sudo apache2ctl -S; sudo apache2ctl -M
echo "=== SERVICES ==="; sudo systemctl --type=service --state=running --no-pager
echo "=== PORTS ==="; sudo ss -lntup
echo "=== CRON (root) ==="; sudo crontab -l 2>/dev/null || true
echo "=== MYSQL VERSION / DATABASE SIZES ==="
sudo mysql -NBe "SELECT VERSION(); SELECT table_schema, ROUND(SUM(data_length+index_length)/1024/1024,1) MB FROM information_schema.tables GROUP BY table_schema ORDER BY MB DESC;"
echo "=== REDIS PERSISTENCE ==="; redis-cli INFO persistence 2>/dev/null | egrep 'loading:|rdb_last_save_time|aof_enabled|aof_rewrite_in_progress' || true
echo "=== APP TREE SIZE (top level only) ==="
sudo du -sh /home/della/* /var/www/html/* 2>/dev/null | sort -h
echo "NOTE: Do not collect .env contents, wp-config.php, private keys, passwords or process environments."
