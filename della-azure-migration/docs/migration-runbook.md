# Della workload migration runbook

## Phase 0 — change control and source baseline

- Record approval, maintenance window, owners, rollback owner and DNS TTL.
- Capture EC2 ID, AMI, instance type, attached EBS volumes, snapshots, SG/NACL, EIP, routes, IAM role, DNS and current backup status.
- Confirm actual OS release, filesystem mount points, disk usage, CPU/RAM/disk/network metrics and peak traffic.
- Inventory Apache vhosts and each vhost's DocumentRoot, proxy rules, TLS certificate path and upstream.
- Inventory PM2 apps (root PM2 daemon was observed), systemd units, Supervisor programs, cron jobs, environment variable *names* (do not export values into tickets), users/groups and file ownership.
- Determine whether each service is required: OpenVPN, FTP/FTPS, Postfix, Webmin, FixMyCloud, S3 auto-sync, incremental WordPress backup, OCR and helper Python services.

Read-only source commands (run on AWS; do not stop/restart services):
```bash
cat /etc/os-release
lsblk -f
df -hT
free -h
uptime
sudo apache2ctl -S
sudo apache2ctl -M
sudo systemctl --type=service --state=running --no-pager
sudo systemctl list-unit-files --type=service
sudo ss -lntup
sudo crontab -l
sudo -u www-data crontab -l
sudo mysql -NBe "SELECT VERSION(); SHOW DATABASES;"
sudo mysql -NBe "SELECT table_schema, ROUND(SUM(data_length+index_length)/1024/1024,1) MB FROM information_schema.tables GROUP BY table_schema;"
redis-cli INFO server
redis-cli INFO persistence
```
Do not paste `.env`, `wp-config.php`, SSH private keys, MySQL passwords, TLS private keys or full process environments into chat.

## Phase 1 — build Azure landing zone

- Deploy Terraform foundation.
- Confirm VM SKU availability, region, quotas, public IP, NSG, SSH access and data disk.
- Configure Azure Backup and monitoring before application cutover.
- Keep admin ports private/restricted. Do not open 3306, 33060, 6379, 10000, 25, 990, OpenVPN helper ports or app debug ports to the Internet.
- Create Key Vault and identity-based access before moving secrets.

## Phase 2 — prepare target OS

- Confirm source Ubuntu version and package repositories.
- Install matching Apache/PHP-FPM/Node/Python/MySQL/Redis versions only after exact versions and modules are recorded.
- Recreate users/groups and directory ownership.
- Attach and mount the new data disk using UUID in `/etc/fstab` only after device verification.
- Restore Apache vhosts with new certificate handling; test config using `apache2ctl configtest`.
- Recreate systemd/PM2/Supervisor/cron definitions with secrets injected securely.

## Phase 3 — application and data migration

- Freeze a file manifest and classify the 176-GB `/home/della` tree. Exclude `.ssh`, shell history, caches, temporary files, secrets, build artefacts not needed at runtime and old backups unless explicitly required.
- Copy application files using `rsync -aHAX --numeric-ids` where ownership/ACL preservation is needed. Use a secured channel and test a small non-production sample first.
- For MySQL, create and test a logical dump. Keep credentials in a protected option file; do not put passwords on command lines:
  ```bash
  sudo mysqldump --single-transaction --routines --triggers --events --all-databases > /secure/path/all-databases.sql
  ```
  This example must be reviewed before use: exclude/recreate system schemas appropriately for target version, and verify GTID/DEFINER/users/grants and database consistency. Encrypt and transfer dumps securely.
- Validate each application database separately. Never copy live MySQL data files while mysqld is running.
- Redis: determine whether it is cache-only or stores sessions/queues/state. Plan a quiesced snapshot/restore or rebuild cache; test persistence.
- Validate S3 sync paths, IAM permissions, external APIs, SMTP delivery and webhook callbacks.

## Phase 4 — OpenVPN decision gate

Do not enable OpenVPN ingress until the following are known:
- Access Server version/licence and whether the service is still used.
- Client count, authentication backend, certificates, MFA, routes, DNS, split/full tunnel policy, UDP/TCP ports, public hostname and client config distribution.
- Whether clients require the old public IP or subnet routes.
- Plan for certificate/key protection and client reconnect test.

If not needed, do not migrate it. If needed, build a dedicated VPN design (prefer Azure VPN Gateway or a hardened dedicated VPN VM depending on feature/licensing requirements), not a casually exposed port on the public application VM.

## Phase 5 — test and cutover

- Test every domain and vhost using a hosts-file override or temporary test hostname.
- Test login, uploads, CMS, license validation, signatures API, webhooks, OCR, email, scheduled jobs, S3 sync, backups, VPN (if approved), FTP (if approved), monitoring and SSL renewal.
- Run a data delta sync and final consistent DB dump during an approved maintenance window.
- Stop writes on AWS only at the agreed cutover point; do not shut down AWS until Azure validation succeeds.
- Lower DNS TTL ahead of the window; change records only after tests pass.
- Monitor errors, latency, CPU/RAM/disk, DB connections and application logs.

## Rollback

- Keep AWS instance, volumes/snapshots, DNS values and credentials available and unchanged during the rollback window.
- If Azure fails, stop writes on Azure, restore DNS to AWS, validate AWS service health and reconcile any writes made after cutover before reopening traffic.
- Never allow simultaneous writes to both databases.
- Define explicit go/no-go checks and rollback owner before cutover.
