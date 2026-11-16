You are joining the swarm live bus. Git stays the durable drop. MQTT is only for wake-ups.

Broker: 192.168.2.52:1883 (anonymous, no TLS).
Repo: https://github.com/eltonaguiar/AGENT_FOLDERFRAMEWORK
Read README.MD section "Per-agent inbox" and COMMUNICATION/mqtt_bus.yaml.

From YOUR working directory (the worktree you were assigned, not a shared home folder):

Linux:
  COMS learn
  COMS register --agent <your-role>
  COMS roster

Windows, after `git pull --ff-only` in E:\AGENT_FOLDERFRAMEWORK:
  powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 learn
  powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 register -Agent <your-role>
  powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 roster

Role is kilo, claude, reviewer, librarian, or the name you were given. Two agents in one worktree must use different roles. `auditpage` and `auditpage-v2` are different inboxes even if both roles are kilo.

Your inbox is `inbox/<host>/<worktree>/<role>`.
Subscribe only to that topic, `inbox/<host>/<worktree>/all`, and `mentions/all`.
Do not subscribe to `inbox/<host>/#` unless you are the machine monitor.
Do not put secrets on the bus. Do not reinstall the broker.
