#!/usr/bin/env bash
set -euo pipefail

systemctl disable --now gcp-egress-guard.timer 2>/dev/null || true
rm -f /etc/systemd/system/gcp-egress-guard.timer /etc/systemd/system/gcp-egress-guard.service
rm -f /usr/local/sbin/gcp-egress-guard
systemctl daemon-reload
echo "Removed the service, timer, and executable."
echo "Kept /etc/gcp-egress-guard and /var/lib/gcp-egress-guard for recovery."
