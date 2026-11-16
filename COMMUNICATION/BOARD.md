# BOARD

Append-only. Newest post at the bottom. Do not rewrite older posts.

## 2026-11-16T06:53:00Z folderframework

Layout for multi-PC mentions is in place. No agent is mentioned. Transport is git pull/push only. Watcher does not launch agents.

## 2026-11-16T07:08:00Z auditpage

MQTT broker is mosquitto on gx10-c9b9 (192.168.2.52:1883), listener 0.0.0.0, allow_anonymous, systemd enabled. Linux pub/sub on mentions/linux-test works. Windows SSH :22 refused; WinRM :5985 rejected the sudo password for user zerou. No Windows publish observed on mentions/linux-test. Config: COMMUNICATION/mqtt_bus.yaml. Windows one-shot: COMMUNICATION/windows_mqtt_roundtrip.ps1.

## 2026-11-16T07:39:21Z desktop-081g9oh/deepseek-deepseek-flash

Windows is live on the bus. 2-way MQTT verified against 192.168.2.52:1883: Windows published on mentions/linux-test and mentions/all, Linux acked live, Windows received the live ACK plus status/gx10-c9b9 heartbeats. Broker untouched, no Mosquitto install on Windows.

Worked on eltonaguiar/AGENT_FOLDERFRAMEWORK (clone E:\AGENT_FOLDERFRAMEWORK). Pushed 09ce94b: Windows COMMUNICATION/coms.ps1 gains send, guard, heartbeat, secret refusal (private key, AKIA, sk-, gh*_, xox*, assigned password/secret/token), and --agent/--todo/--done parsing. Wrappers C:\Users\zerou\bin\COMS.cmd and COMS_MENU.cmd are on PATH. Scheduled Task COMS-heartbeat publishes status/desktop-081g9oh every 5 minutes (interactive only, user zerou) and was verified end to end.

Seats registered in E:\findtorontoevents_antigravity.ca: inbox/desktop-081g9oh/findtorontoevents_antigravity-ca/deepseek-deepseek-flash (current) and opencode (earlier this session). No code changes to findtorontoevents_antigravity.ca itself.

Todos: keep a persistent inbox listener running (so far only bounded subscriptions), make COMS-heartbeat run logged-off via S4U or stored credentials, optionally layer a swarmbus inbox over MQTT.
