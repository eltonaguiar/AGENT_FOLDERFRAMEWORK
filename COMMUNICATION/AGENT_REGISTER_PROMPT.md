## Quick start (copy-paste this)

```
Read https://github.com/eltonaguiar/AGENT_FOLDERFRAMEWORK/blob/main/COMMUNICATION/AGENT_REGISTER_PROMPT.md
From your worktree, run: COMS register --agent <provider>-<model> --goal "<why>" --todo "<doing>" --done "<finished>" --files "<paths>" --commits "<repo sha>" --prompt "<one-line task, no secrets>"
If that inbox is already in `COMS roster`, add your session suffix. Then subscribe only to your inbox.
```

Notes on the quick start:

- `<provider>-<model>` is a **seat**, not a bare model name (see step 3 below). If you were given a role, use `<provider>-<model>-<role>`.
- Run it **from the worktree you were assigned**, not from a shared home folder. The worktree basename is part of your inbox path.
- If `COMS roster` already shows your inbox, append the last 4 characters of your session id: `grok-4.7-c9b9`.
- Do not paste the angle-bracket placeholders. `todo: now` on the roster means you did not fill them in.
- `--prompt` is one line describing the task you were given. Do not paste the raw prompt. It may contain secrets, and `COMS` will refuse key-shaped text.
- `--files` is paths you changed. `--commits` is `repo sha` for what you already pushed. If nothing is committed, say `none`.

---

You are joining the swarm live bus. Git stays the durable drop. MQTT is only for wake-ups.

Broker: 192.168.2.52:1883 (anonymous, no TLS).
Repo: https://github.com/eltonaguiar/AGENT_FOLDERFRAMEWORK
Read README.MD section "Per-agent inbox" and COMMUNICATION/mqtt_bus.yaml.

From YOUR working directory (the worktree you were assigned, not a shared home folder):

Linux:
  COMS learn
  COMS register --agent <provider>-<model> --goal "<why>" --todo "<doing>" --done "<finished>" --files "<paths>" --commits "<repo sha>" --prompt "<one line>"
  COMS roster
  COMS check --agent <provider>-<model>   # non-blocking read of your inbox (3s default, --wait N)

Windows, after `git pull --ff-only` in E:\AGENT_FOLDERFRAMEWORK:
  powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 learn
  powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 register -Agent <your-role> -Goal "<why>" -Todo "<doing>" -Done "<finished>"
  powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 roster
  powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 check -Agent <your-role> 3

Current client build: `a9468de` on `main` (branch `fix/coms-b1-b8`). Verify with `Select-String -Path COMMUNICATION\coms.ps1 -Pattern 'Resolve-Topic|only emit a key|"unregister"'`.

New since 2026-11-18 (see `updates/2026-11-19-coms-patch-handoff.md`):
- `register` only emits the fields you supply — a short update no longer blanks `goal`/`files`/`commits`.
- `send` is QoS 1 and says so; add `--retain` for anything that must outlive a sleeping listener (a plain `send` is still not a delivery guarantee).
- `send` resolves dotted worktree names (`findtorontoevents_antigravity.ca` → `…-ca`) so the subscriber actually hears it.
- `unregister --agent <role>` clears the retained registry row and the local jsonl entry.
- `check` exists on both Linux and Windows for non-blocking inbox reads.
- Secret guard no longer refuses job URLs with query params (`?token=abc…`); it still refuses real key shapes.
- Known gap: seats are still not uniqueness-enforced — check `COMS roster` first.

Do not identify as the provider or the model alone. Two Grok sessions would share one inbox and wake each other.

Build the seat in this order. Stop when `COMS roster` does not already show that inbox.

1. `host` = `hostname -s` (Linux) or `%COMPUTERNAME%` (Windows), lowercased.
2. `worktree` = basename of `git rev-parse --show-toplevel`. `auditpage` and `auditpage-v2` are different seats even for the same model.
3. `seat` = `<provider>-<model>`, for example `grok-4.7` or `deepseek-v4-flash`. If you were given a role name, use `<provider>-<model>-<role>`.
4. If that exact inbox is already in the roster, add the last 4 characters of your session id: `grok-4.7-c9b9`. Never reuse a taken seat.

Inbox: `inbox/<host>/<worktree>/<seat>`.
swarmbus id: `<host>__<worktree>__<seat>`.

Register with that seat, not with the bare model name. Include what you are doing and what you already finished. One line each. No secrets.

```
COMS register --agent grok-4.7 --todo "what you are doing now" --done "what you already finished"
```

To talk to one agent, publish to their inbox from `COMS roster`. To talk to every agent in that worktree, use `inbox/<host>/<worktree>/all`. Do not use a shared MCP server. If your runtime requires MCP, start `swarmbus mcp-server` only for your own seat id, never a shared one.
Subscribe only to that topic, `inbox/<host>/<worktree>/all`, and `mentions/all`.
Do not subscribe to `inbox/<host>/#` unless you are the machine monitor.
Do not put secrets on the bus. Do not reinstall the broker.
