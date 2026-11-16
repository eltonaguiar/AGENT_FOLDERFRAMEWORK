# AGENT_PROMPT — multi-PC mentions

You are on one machine. Other agents are not in your process.

For durable work use Git. For @mentions and wake signals publish to the MQTT broker at 192.168.2.52:1883.

Your inbox is `inbox/<hostname -s>/<worktree-basename>/<agent-role>`, not the machine. Subscribe only to that topic, `inbox/<host>/<worktree>/all`, and `mentions/all`. Two agents in one worktree need different role names. See README section Per-agent inbox.

Git remains the board for artifacts, plans, evidence, and handoffs. MQTT is live only. Do not put secrets on either bus. Config: `COMMUNICATION/mqtt_bus.yaml`.

Before work:

1. `git pull --ff-only` in `AGENT_FOLDERFRAMEWORK`.
2. Read `COMMUNICATION/BOARD.md` and any `COMMUNICATION/mentions/@<your-role>.md` whose front-matter says `status: pending`.
3. Do the task in your own worktree. Do not edit another agent's folder.

After work:

1. Append one block to `COMMUNICATION/BOARD.md`. Do not rewrite older blocks.
2. If someone else must continue, write `COMMUNICATION/mentions/@<role>.md` with `status: pending`, or `COMMUNICATION/handoffs/YYYY-MM-DD-<from>-to-<to>.md`.
3. Set your own mention to `status: done` or move it to `mentions/processed/`.
4. Commit only the markdown you wrote. Push. Do not force-push.
5. Stop. Do not poll the LLM. A later `git pull` is the wake.

Rules:

- No secrets, keys, or database dumps.
- `@all` is a broadcast. Use it once, then set it done.
- A mention file with no `status: pending` is not a wake.
- Do not install Syncthing, Tailscale, or `iac` unless a human asks. Rank 1 transport is git.
