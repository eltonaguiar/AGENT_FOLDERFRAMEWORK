COMS watch + agent wakeups
==========================

Task: COMS-watch-50
- Every 20 minutes, 50 runs total (counter in runs.txt; task disables itself at 50).
- Runs only while the user is logged on.
- Action: powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\zerou\.coms\watch\coms-agent-wake.ps1

Each run:
1. coms-watch.ps1 refreshes the digest (COMS, GitHub main tips/new commits, local edits, live /audit, /audit2, /audit3, audit3 ledger, money_ready, audit2_forward).
2. The read-only agent `coms-watch` (model deepseek/deepseek-flash) reads LATEST.md and writes STATUS / CHANGES / RESPONSE. It cannot edit, run shell, or send.
3. Output is written to LATEST_RESPONSE.md and appended to agent-log.md.

Files:
- LATEST.md            current digest
- LATEST_RESPONSE.md   current prepared response
- log.md               digest history
- agent-log.md         agent response history
- runs.txt             run counter
- state.txt            last tips/ledger/hash (change detection)
- AUTOSEND             optional flag file; if present, a RESPONSE with SEND: yes is sent retained to inbox/gx10-c9b9/vanilla-handsaw/kilo (secret-like drafts are blocked)

Enable auto-send (off by default):
  New-Item -ItemType File "$env:USERPROFILE\.coms\watch\AUTOSEND"

Disable auto-send:
  Remove-Item "$env:USERPROFILE\.coms\watch\AUTOSEND"

Inspect / control:
  Get-Content "$env:USERPROFILE\.coms\watch\LATEST_RESPONSE.md"
  Get-Content "$env:USERPROFILE\.coms\watch\agent-log.md" -Tail 80
  schtasks /Query /TN COMS-watch-50 /V /FO LIST
  schtasks /Run /TN COMS-watch-50
  schtasks /End /TN COMS-watch-50
  schtasks /Change /TN COMS-watch-50 /DISABLE
  schtasks /Change /TN COMS-watch-50 /ENABLE

Notes:
- The agent is read-only. It cannot commit, push, or change files.
- The task does not run when the user is logged off (no stored password).
- The agent's text is advisory. Auto-send is opt-in because model output can be wrong.
