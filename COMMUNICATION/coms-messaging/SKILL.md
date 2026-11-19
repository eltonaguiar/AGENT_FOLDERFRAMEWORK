---
name: coms-messaging
description: Send, receive, register, and clean up agent-to-agent messages on the COMS MQTT bus (192.168.2.52:1883). Use when the user says "message an agent", "check the bus", "COMS", "wake the fleet", "drop a note to COMS", or when a task needs a durable handoff to a sleeping agent. Covers Linux (coms) and Windows (coms.ps1).
---

# COMS Messaging Skill

COMS is the live wake bus. **Git is the durable drop; MQTT is only for wake-ups.** Messages are transient unless you make them retained.

- Broker: `192.168.2.52:1883` (anonymous, no TLS). Config: `AGENT_FOLDERFRAMEWORK/COMMUNICATION/mqtt_bus.yaml`.
- Client build: `1c8b562` on `main` (Windows parity: PR #2 merge `465b7dc`, source fix `44a0b75`; gap fixes `884f9b6`; unregister tombstone fix `1c8b562`). Verify your copy is current before troubleshooting. Windows requires the ASCII-only client for PowerShell 5.1; `COMS_PORT`/`COMS_BROKER` env overrides work on both platforms.
- Canonical docs: `AGENT_FOLDERFRAMEWORK/README.MD` § Per-agent inbox, `COMMUNICATION/AGENT_REGISTER_PROMPT.md`, `COMMUNICATION/handoffs/2026-11-19-kilo-coms-patch-handoff.md`.

## Identity (do not skip)

Inbox topic: `inbox/<host>/<worktree>/<agent>`.
- host = `hostname -s` (Linux) / `%COMPUTERNAME%` (Windows), slugified.
- worktree = basename of `git rev-parse --show-toplevel`, slugified (dots become `-`).
- agent = `<provider>-<model>` or a role; must be unique within the worktree.

Subscribe only to: your inbox, `inbox/<host>/<worktree>/all`, and `mentions/all`. Never `inbox/<host>/#` unless you are the machine monitor.

## Verbs (client build 2026-11-19)

| Goal | Linux | Windows |
|---|---|---|
| Learn / status | `COMS learn`, `COMS status` | `coms.ps1 learn` |
| Register seat | `COMS register --agent <seat> --goal .. --todo .. --done ..` | `coms.ps1 register -Agent <seat> -Goal .. -Todo .. -Done ..` |
| Read inbox (non-blocking) | `COMS check --agent <seat> --wait 3` | `coms.ps1 check -Agent <seat> 3` |
| Listen (supervised) | `COMS listen --agent <seat>` | `coms.ps1 listen -Agent <seat>` |
| Send (live only) | `COMS send <topic> "<msg>"` | `coms.ps1 send <topic> "<msg>"` |
| Send (durable) | `COMS send --retain <topic> "<msg>"` | `coms.ps1 send --retain <topic> "<msg>"` |
| Broadcast | `COMS send --retain mentions/all "<msg>"` | `coms.ps1 send --retain mentions/all "<msg>"` |
| Roster | `COMS roster` | `coms.ps1 roster` |
| Clear a seat | `COMS unregister --agent <seat>` | `coms.ps1 unregister -Agent <seat>` |
| Secret scan | `COMS guard <file>` | `coms.ps1 guard <file>` |

## Delivery semantics (the part that bites)

- `send` is **QoS 1, not retained** → live-only. If nobody is subscribed, it is discarded and `sent` still prints. Not a delivery guarantee.
- `send --retain` stores the last message on the topic; any later subscriber receives it. Use it for handoffs and wake-ups. Retained is last-writer-wins per topic.
- `check` reads retained + in-flight without blocking; default window 3s (`--wait N`).
- `register` writes a **retained** `registry/<host>/<worktree>/<seat>` plus `~/.coms/agents.jsonl`, and **only stores the flags you pass**.

## Common patterns

```bash
# Durable handoff to the whole fleet (Linux)
COMS() { /home/eaguiar2015/AGENT_FOLDERFRAMEWORK/COMMUNICATION/coms "$@"; }
COMS send --retain mentions/all "PATCH READY: main @ <sha>; see COMMUNICATION/handoffs/<file>.md"
COMS check --agent <your-seat> --wait 3          # confirm receipt
COMS roster                                      # who is registered
```

Windows (PowerShell, after `git pull --ff-only origin main` in `E:\AGENT_FOLDERFRAMEWORK`):
```powershell
powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 register -Agent <seat> -Goal "<why>"
powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 check -Agent <seat> 3
powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 send --retain mentions/all "<msg>"
```

Raw probe (no client):
```bash
mosquitto_sub -h 192.168.2.52 -p 1883 -t 'mentions/all' -v --retained-only -W 3
```

## Pitfalls

- **Seat reuse (B6):** the broker does not enforce unique seats; `register` now warns loudly if the inbox is already taken. Check `roster` first and add a session suffix.
- **Dotted worktree names:** the client now resolves `findtorontoevents_antigravity.ca` → `…-ca`; if you publish by hand, slugify yourself.
- **Secrets:** guard refuses private keys, `AKIA`, `sk-`, `gh*_`, Slack tokens, and assigned `password=`/`api_key=`/`token=` values. Job URLs with query params are allowed.
- Do not reinstall the broker. Do not treat MQTT as an archive — put artifacts in Git.
