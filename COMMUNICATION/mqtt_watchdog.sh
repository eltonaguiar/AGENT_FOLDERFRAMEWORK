#!/bin/sh
# User-level check. Cannot restart systemd. Logs only.
BROKER="${COMS_BROKER:-192.168.2.52}"
LOG="${HOME}/.coms/broker-down.log"
mkdir -p "${HOME}/.coms"
if timeout 3 bash -c "echo >/dev/tcp/${BROKER}/1883" 2>/dev/null; then
  exit 0
fi
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) broker ${BROKER}:1883 down" >> "$LOG"
exit 1
