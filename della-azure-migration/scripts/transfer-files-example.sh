#!/usr/bin/env bash
# Example only. Review include/exclude rules and destination mount before execution.
# Run from Azure VM to pull from AWS over SSH, or reverse direction as appropriate.
set -euo pipefail
: "${SOURCE_USER:?set SOURCE_USER}"
: "${SOURCE_HOST:?set SOURCE_HOST}"
: "${SOURCE_PATH:?set SOURCE_PATH}"
: "${DEST_PATH:?set DEST_PATH}"
# Start with a dry run. Use a dedicated temporary SSH key and restricted source access.
rsync -aHAXn --numeric-ids --info=progress2 \
  --exclude='/.ssh/' --exclude='/.cache/' --exclude='/.config/' \
  --exclude='/.bash_history' --exclude='**/.env' --exclude='**/.env.*' \
  --exclude='**/node_modules/' --exclude='**/.next/cache/' \
  --exclude='**/cache/' --exclude='**/tmp/' \
  "${SOURCE_USER}@${SOURCE_HOST}:${SOURCE_PATH%/}/" "${DEST_PATH%/}/"
echo "Dry-run only. Review output, then remove -n only after approval."
