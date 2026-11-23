# Windows: the flashing console window, what COMS actually does, and how to install it again

**Status:** verified on `desktop-081g9oh` (Windows 11, 10.0.26300.9974), 2026-11-23.
**Audience:** whoever re-installs Windows, or debugs "a black command prompt keeps flashing on my desktop".

---

## The short answer to the question we kept asking

> **Was that popup COMS watching something, or was it COMS itself?**

**Neither. It was a Scheduled Task whose Action was `powershell.exe`, and that task existed only to publish a
heartbeat — outbound visibility, not surveillance.** COMS has no UI and no background watcher: `coms.ps1` is a
script you call, and it produces a window only if something already gave it a console.

Windows allocates a console when `powershell.exe` starts, **before** any parameter is read. So `-WindowStyle Hidden`
does not prevent the flash — the box exists for a moment regardless. The only reliable fix is to never let a console
be created: launch through `wscript.exe` with a VBS that calls `WScript.Shell.Run(cmd, 0, False)` (window style `0`
= hidden from creation). That is what `coms_hidden.vbs` in this folder does.

---

## What watches COMS, and what does not

| thing | what it is | watches COMS? |
|---|---|---|
| `coms.ps1` | the protocol: `send`, `register`, `roster`, `heartbeat`, `listen`, `check`, `guard`, `topics` | **No.** It acts only when called. Nothing runs in the background. |
| `COMS.cmd` | thin PATH wrapper: `powershell ... coms.ps1 %*` | No. It is for humans typing `COMS send ...`. A console is expected there. |
| `coms_hidden.vbs` | no-console launcher for scheduled/automated callers | No. |
| Task **`COMS-heartbeat`** | every 5 min publishes `alive <UTC>` to `status/<host>` | **No — it writes.** Its purpose is to make this seat visible to peers, so they can tell a live agent from a dead one. |
| Task **`COMS-watch-50`** | freebuff's agent-wake task (20 min) | Reads/wakes an agent; already hidden via `C:\Users\zerou\.coms\watch\launch-hidden.vbs` |

**To actually read COMS** you run one of: `coms.ps1 listen -Agent <role>`, `coms.ps1 check -Agent <role>`, or an MQTT
subscribe. There is no resident reader on this box, by design — a listener that is not running misses everything
between runs, so read-on-demand beats a permanently broken tail.

**Broker:** `192.168.2.52:1883` on the Linux host. **There is no broker on Windows** and there should not be.

---

## What was wrong, specifically

| | Command | Logon type | Flashed? |
|---|---|---|---|
| Before | `powershell` → `coms.ps1 heartbeat` | `InteractiveToken` | **YES — every 5 minutes, on the user's desktop** |
| After | `wscript.exe //B //Nologo coms_hidden.vbs heartbeat` | `InteractiveToken` | **No** |

`COMS-watch-50` was already correct (it uses `wscript.exe //B //Nologo launch-hidden.vbs ...`) — that was the fix made
the previous day and it held. The regression was a **second, newer task** that re-introduced the bare-`powershell`
form.

---

## Fresh Windows install — exact steps

1. Clone and pin:
   ```
   git clone https://github.com/eltonaguiar/AGENT_FOLDERFRAMEWORK.git E:\AGENT_FOLDERFRAMEWORK
   ```
2. Confirm `COMMUNICATION\coms_hidden.vbs` and `COMS.cmd` exist (both are in the repo).
3. Smoke-test the protocol **before** scheduling anything — this proves the script works and prints the expected line:
   ```
   powershell -NoProfile -ExecutionPolicy Bypass -File "E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1" heartbeat
   → alive 2026-11-23T07:20:38Z
   ```
4. Register the heartbeat **through the VBS launcher, never bare powershell**:
   ```
   schtasks /Create /TN "COMS-heartbeat" /SC MINUTE /MO 5 /F /TR "wscript.exe //B //Nologo \"E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms_hidden.vbs\" heartbeat"
   ```
5. Put `COMS.cmd` on PATH if convenient. **Optional, and not required** — every scheduled action uses absolute paths,
   and adding a directory to the machine PATH affects name resolution for every process on the box, so it is an
   owner decision rather than a maintenance step.

---

## How to prove it is fixed (do not take it on trust)

```powershell
schtasks /Run /TN "COMS-heartbeat"
schtasks /Query /TN "COMS-heartbeat" /FO LIST /V | findstr "Last Result"     # expect 0
```
```bash
# the objective test: console-host count must stay FLAT across the fire
for i in 1 2 3 4 5 6; do sleep 0.6; tasklist | grep -ci conhost.exe; done
```

**Measured 2026-11-23:** flat at **135** across six polls after repointing to the VBS launcher, `Last Result: 0`.
The previous bare-`powershell` action produced a visible box every five minutes.

---

## Traps that cost time here

1. **`powershell -WindowStyle Hidden` is not a fix.** `conhost.exe` is allocated at process start. Use a VBS
   `Run(..., 0, ...)` or a task that runs outside the interactive session.
2. **`schtasks /Change /TR` prompts for a run-as password.** Empty is accepted, but always re-check `Last Result`
   afterwards — a task that never runs also never flashes, and looks "fixed".
3. **Never schedule `coms.ps1 listen`.** Each fire is a fresh process; it sees nothing that happened between fires.
4. **MQTT retains only the last payload per topic.** A topic is a status board, not an archive. If a message matters,
   commit it to git or write it to a file — a later `send` legally overwrites an earlier one.
5. **The Windows wrapper has no secret scanner.** The Linux `send`/`register` refuses private keys, `AKIA`, `sk-`,
   `gh*_` and `password=` assignments. Until that is mirrored here, a Windows seat can publish something a Linux seat
   would have refused.

---

## What this box runs, as of 2026-11-23

| scheduled task | interval | mechanism | purpose |
|---|---|---|---|
| `COMS-heartbeat` | 5 min | `wscript` + `coms_hidden.vbs` | publish `alive` so peers see this seat |
| `COMS-watch-50` | 20 min | `wscript //B` + `C:\Users\zerou\.coms\watch\launch-hidden.vbs` | wake an agent |

No broker. No resident listener. Nothing else on a timer that touches COMS.
