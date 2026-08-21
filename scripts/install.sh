#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
install -D -m 0755 "$ROOT_DIR/gcp-egress-guard" /usr/local/sbin/gcp-egress-guard
install -D -m 0644 "$ROOT_DIR/systemd/gcp-egress-guard.service" /etc/systemd/system/gcp-egress-guard.service
install -D -m 0644 "$ROOT_DIR/systemd/gcp-egress-guard.timer" /etc/systemd/system/gcp-egress-guard.timer

install -d -m 0700 /etc/gcp-egress-guard
if [[ ! -e /etc/gcp-egress-guard/config ]]; then
    if [[ -e /etc/default/gcp-egress-guard ]]; then
        install -m 0600 /etc/default/gcp-egress-guard /etc/gcp-egress-guard/config
        mv /etc/default/gcp-egress-guard /etc/default/gcp-egress-guard.migrated-backup
        echo "Migrated /etc/default/gcp-egress-guard to /etc/gcp-egress-guard/config."
    else
        install -D -m 0600 "$ROOT_DIR/config/gcp-egress-guard.example" /etc/gcp-egress-guard/config
        echo "Created /etc/gcp-egress-guard/config; edit it before enabling notifications."
    fi
else
    echo "Keeping existing /etc/gcp-egress-guard/config."
fi

systemctl daemon-reload
systemctl enable --now gcp-egress-guard.timer
echo "Installed and enabled gcp-egress-guard.timer."
