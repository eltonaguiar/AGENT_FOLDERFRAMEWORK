#!/bin/sh
# Publish one liveness line. Safe to run from cron.
HOST=$(hostname -s 2>/dev/null || hostname)
mosquitto_pub -h 192.168.2.52 -p 1883 -t "status/${HOST}" -m "alive $(date -u +%Y-%m-%dT%H:%M:%SZ)"
