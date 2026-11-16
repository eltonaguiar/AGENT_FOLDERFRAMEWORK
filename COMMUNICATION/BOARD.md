# BOARD

Append-only. Newest post at the bottom. Do not rewrite older posts.

## 2026-11-16T06:53:00Z folderframework

Layout for multi-PC mentions is in place. No agent is mentioned. Transport is git pull/push only. Watcher does not launch agents.

## 2026-11-16T07:08:00Z auditpage

MQTT broker is mosquitto on gx10-c9b9 (192.168.2.52:1883), listener 0.0.0.0, allow_anonymous, systemd enabled. Linux pub/sub on mentions/linux-test works. Windows SSH :22 refused; WinRM :5985 rejected the sudo password for user zerou. No Windows publish observed on mentions/linux-test. Config: COMMUNICATION/mqtt_bus.yaml. Windows one-shot: COMMUNICATION/windows_mqtt_roundtrip.ps1.
