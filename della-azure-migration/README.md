# Della AWS-to-Azure migration — Terraform foundation

This project provisions a secure Azure landing zone and a Linux VM target. It does **not** copy application data or perform a DNS cutover. It is intentionally a safe first stage.

## Important known workload facts

- AWS source reported: `t2.xlarge` (4 vCPU / 16 GiB), AWS Mumbai (`ap-south-1`).
- Existing EBS data reported: 500 GB gp3; verify whether this is root or a separate volume.
- Ubuntu host; Apache, PHP/PHP-FPM, multiple Next.js apps, Node.js, Strapi, Python services, MySQL 8.0, Redis, OCR, cron/systemd/PM2.
- `/home/della` reported around 176 GB; classify before copying.
- MySQL databases total approximately 2.8 GB including system schemas.
- OpenVPN Access Server, vsftpd, Postfix, Webmin, FixMyCloud connector, S3 sync and backup services were found.
- OpenVPN migration is undecided. Its ports are not opened by default.

## Design decisions

- Proposed Azure region: `westindia`; confirm regional VM SKU availability and latency before apply.
- VM starting size: `Standard_D4s_v5` (4 vCPU / 16 GiB candidate), not a guaranteed available SKU.
- Ubuntu 24.04 image is a provisional target. Confirm exact source OS release and PHP-FPM version first.
- 128-GiB OS disk plus separate 512-GiB Premium managed data disk. The data disk is attached but **not formatted or mounted automatically**.
- SSH is restricted to `ssh_source_cidr`. Only TCP 80/443 are public by default.
- MySQL and Redis are not exposed through NSG.
- MySQL remains on the VM for first-pass compatibility; evaluate Azure Database for MySQL Flexible Server later.
- No passwords, private SSH keys, application secrets or database credentials belong in Terraform files.

## Prerequisites

1. Azure CLI authenticated: `az login`
2. Correct subscription selected: `az account set --subscription <SUBSCRIPTION_ID>`
3. Terraform >= 1.6 and Azure CLI installed.
4. Generate a **new** SSH key on your workstation:

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/della-azure -C "della-azure"
   chmod 600 ~/.ssh/della-azure
   ```

   Put the contents of `~/.ssh/della-azure.pub` into `admin_ssh_public_key`. Keep `~/.ssh/della-azure` private and never upload it to Git.

5. Copy `terraform.tfvars.example` to `terraform.tfvars`; replace subscription ID, public key and your trusted public IP `/32`.

## Safe Terraform workflow

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=della.tfplan
terraform show della.tfplan
```

Review the plan carefully. Only then:

```bash
terraform apply della.tfplan
```

Never run `terraform destroy` against this workload. State contains infrastructure metadata and can expose sensitive values if later added; use a protected remote backend with locking and restricted access before team/production use. Do not commit state or tfvars.

## After provisioning

- Connect using the new Azure private key.
- Confirm Ubuntu release, disk devices and network before formatting the data disk.
- Format/mount the data disk only after verifying its device identity and that it is a new empty disk.
- Harden SSH, install monitoring/backup, and then migrate application services.
- Keep AWS live and unchanged until Azure validation and rollback criteria are met.

## Not provisioned yet

- Azure Database for MySQL Flexible Server, Redis managed service, VPN Gateway, OpenVPN ports, FTP/FTPS, SMTP relay, Webmin, Azure Backup vault, Log Analytics/alerts, Key Vault, DNS zones and TLS certificates.
- These require final service ownership, connectivity, retention, cost and security decisions. Avoid creating unused services before requirements are confirmed.
