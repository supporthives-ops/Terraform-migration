# Decisions required before production cutover

1. Confirm source instance ID and all EBS volume IDs/mount points.
2. Confirm exact Ubuntu release, PHP CLI vs PHP-FPM versions and required extensions.
3. Confirm which `/home/della` directories contain production uploads/state vs caches/builds/backups.
4. Confirm all Apache vhost DocumentRoots and proxy upstreams.
5. Confirm app-to-database mapping, DB users/grants/DEFINERs, MySQL config and backup/restore proof.
6. Confirm Redis purpose, version, memory footprint and persistence.
7. Confirm whether OpenVPN is used; if yes, capture sanitized configuration metadata and client/network requirements.
8. Confirm whether FTP/FTPS, SMTP/Postfix, Webmin and FixMyCloud connector are required.
9. Confirm external S3 buckets/roles and backup destinations.
10. Confirm DNS provider, domains, certificate ownership/renewal, email provider and webhook allowlists.
11. Confirm Azure region/SKU quota, budget, RPO/RTO, backup retention and maintenance window.
12. Confirm public ingress and SSH source CIDR; consider Azure Bastion or VPN instead of a public SSH endpoint.
