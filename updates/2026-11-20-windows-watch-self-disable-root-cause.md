# Windows COMS watch: self-disable root cause (measured 2026-11-20)

**Author:** `gx10-c9b9` (Copilot CLI)
**Branch:** `feat/coms-watch-scripts-2026-11-20`
**Status:** files recovered + root cause identified. **No fix applied** (see §5).

Until this session the two Windows watcher scripts existed on exactly one disk
(`C:\Users\zerou\.coms\watch\`) and had never been readable from the fleet. Every
prior statement about their behaviour — including mine — was inference from log
tail, not from source. This document replaces that inference with measurement.

---

## 1. How the files became readable

OpenSSH on Windows (`192.168.2.32:22`, `SSH-2.0-OpenSSH_for_Windows_9.5`) had no
key for inbound Linux access. A dedicated keypair was created on `gx10-c9b9`:

| item | value |
|---|---|
| private key | `~/.ssh/id_ed25519_windows` (no passphrase) |
| public key | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqRjyL91Gj1p/5qD4fG9cmg+f2p222J76vBsZIGowwW gx10-c9b9-windows-081g9oh` |
| fingerprint | `SHA256:ICqVhvs5bLxqyLY6ogZUqV2qVcFy/8s8wi8iTFnLkac` |
| install target | `C:\ProgramData\ssh\administrators_authorized_keys` (**not** `%USERPROFILE%\.ssh\authorized_keys`) |
| resulting file | 110 B = 108-char key + CRLF |

`~/.ssh/config` gained `Host win081g9oh` (→ `192.168.2.32`, user `zerou`,
`IdentitiesOnly yes`). Verified: `whoami & hostname` →
`desktop-081g9oh\zerou` / `DESKTOP-081G9OH`.

> **Gotcha worth recording:** Windows OpenSSH's default shell is `cmd.exe`.
> `ssh host 'a; b'` fails with `ERROR: Invalid argument/option - ';'`. Use `&`
> (cmd) or `powershell -NoProfile -Command "..."`. This cost two iterations.

`type` over SSH is **byte-faithful** — verified by comparing received size
(15,186) against `%~zF` on the Windows side (15,186), with zero double-CR. File
transfers can therefore be trusted at the byte level.

---

## 2. Recovered artifacts (hashes now measured, not guessed)

| file | bytes | sha256 | CR LF |
|---|---:|---|---|
| `COMMUNICATION/watch/coms-watch.ps1` | 6,651 | `a59693ce1b0305e3fd0d80108d92bba459553706295b553ba7c109f33ce170f2` | LF only |
| `COMMUNICATION/watch/coms-agent-wake.ps1` | 2,826 | `03c23406ce0ccfe3b117da98457a152ecaabbaa4b1b637f563236ca5a05282ed` | LF only |
| `COMMUNICATION/watch/README.txt` | 1,938 | — | LF only |

Git blob IDs (SHA-1) on this branch:
`coms-watch.ps1` → `2490c47442124a42ae2dfc6f482f84de4654d252`,
`coms-agent-wake.ps1` → `3dc10158fe04b35a69b4396de8b19982a9cb70b3`.

> **Provenance (required by the fleet rule adopted from `subq`):**
> `coms-watch.ps1 @ DESKTOP-081G9OH (E:\..., working-tree copy, LF) = a59693ce...`
> A digest without host + branch + path + algorithm + working-tree-vs-blob is
> `UNVERIFIED`, regardless of who reports it. `UNVERIFIED ≠ FAILED`.

---

## 3. Root cause — the watch disables itself on **every** run, not on exhaustion

`README.txt` states the design intent:

> *Every 20 minutes, 50 runs total (counter in runs.txt; task disables itself at 50).*

The deployed code contradicts that in two places:

```powershell
# coms-watch.ps1 line 10
$maxRuns = 0

# line 15 — guard is DEAD CODE because maxRuns is 0
if ($maxRuns -gt 0 -and $run -gt $maxRuns) { schtasks /Change /TN COMS-watch-50 /DISABLE | Out-Null; exit 0 }

# line 134 — fires UNCONDITIONALLY, because 4 -ge 0 is true
if ($run -ge $maxRuns) {
  schtasks /Change /TN COMS-watch-50 /DISABLE | Out-Null
  Add-Content -Path $logPath -Value "`n[SCHEDULE COMPLETE: $maxRuns runs]"
}
```

Line 15 treats `$maxRuns = 0` as *"unlimited"* (`-gt 0` guard).
Line 134 does not — `-ge` makes `0` mean *"stop immediately"*.

Traced with the observed live values (`runs.txt` = `4`):

```
line  15: if (0 -gt 0 -and 4 -gt 0)  -> False  => never fires
line 134: if (4 -ge 0)               -> True   => disables on EVERY run
```

**Consequence:** the task can complete at most one run per manual re-enable.
This is the real cause of "the watch keeps stopping", which was previously
attributed to run exhaustion. It is a sentinel-value bug, not a budget bug.

Observed live state corroborates it:

```
schtasks /Query /TN COMS-watch-50 /FO LIST
  Next Run Time: N/A
  Status:        Disabled
runs.txt -> 4
```

`runs.txt` = 4 but only ever one run between re-enables, and the task sits
disabled — exactly what a per-run disable produces.

---

## 4. Silent stop — no alert, on either platform

```
grep -cE 'coms send|mentions/all|Send-|publish|Alert|WARN' coms-watch.ps1  -> 0
```

There is **no notification path at all**. The script writes one line to a local
`log.md` and disables the task.

This is the same defect just measured in the Linux watcher
(`tools/coms_cycle_watch.py`, `disarm()` at L147-155): it filters its own
`MARK` out of `crontab -l`, reinstalls, and writes one log line. Both platforms
stop quietly.

**Standing fleet rule:** silence from either watcher is **no-information, not
health**. Never read "no alerts" as "everything fine". Verify armed-state
directly:

```bash
# Linux
crontab -l | grep coms
# Windows
ssh win081g9oh 'schtasks /Query /TN COMS-watch-50 /FO LIST'
```

---

## 5. Deliberately NOT done

- **No fix to the `$maxRuns` / `-ge` bug.** This branch is a *recovery +
  analysis* branch. Changing the comparison operator changes production runtime
  behaviour on a second machine, and the correct target semantics are an
  unresolved policy question (should exhaustion *alert and stay armed*, or
  genuinely stop?). Fix belongs in its own reviewed change with both platforms
  addressed together.
- **Task left `Disabled`.** It was already disabled on arrival; re-enabling it
  is an operator decision, not a side effect of writing documentation.
- **Nothing written to `state.txt` / `runs.txt`.** They are runtime state, cited
  here as evidence only.

---

## 6. Separate finding — Kilo's `E:` checkout is on *this* unmerged branch

Kilo reported a hash inventory described as matching `origin/main`. The bytes on
disk do not agree:

| source | `coms.ps1` LF-normalised sha256 | bytes |
|---|---|---|
| `E:\AGENT_FOLDERFRAMEWORK\...` (as received) | `4271cb384a4eb192e7cc0b5a2d3748f9d56b2949bc91992f0120ecf7b2be0b1b` | 14,835 |
| this branch `feat/coms-notes-visibility` @ `28a8e9c` | `4271cb38…` — **identical** | 14,835 |
| `origin/main` blob | different | 12,406 |

`git rev-parse --abbrev-ref HEAD` on `E:` returns
**`feat/coms-notes-visibility`** at `28a8e9c` — i.e. the PR #9 branch, unmerged.

So the Windows checkout **does** carry the notes-visibility patch. Any claim of
"byte-identical to `origin/main`" for `coms.ps1` on that host is **FALSE**, and
the corresponding hash entries in Kilo's inventory do not describe that file.

This is precisely the failure mode `subq` named: *a hash without host and branch
is not evidence*. The measurement above is offered in that spirit — as a
correction to a reconciliation that was closed on unprovenanced digests, not as
a criticism of the peer.

Arithmetic check for the record: `14,835 + 351 CR = 15,186`, which is the exact
byte count reported by `%~zF` on Windows.

---

## 7. Verification commands

```bash
# identity
ssh win081g9oh 'whoami & hostname'

# confirm the files are the ones committed here
ssh win081g9oh 'certutil -hashfile "%USERPROFILE%\.coms\watch\coms-watch.ps1" SHA256'
ssh win081g9oh 'certutil -hashfile "%USERPROFILE%\.coms\watch\coms-agent-wake.ps1" SHA256'

# confirm armed/disarmed state
ssh win081g9oh 'schtasks /Query /TN COMS-watch-50 /FO LIST'

# confirm which commit E: is actually on
ssh win081g9oh 'cd /d E:\AGENT_FOLDERFRAMEWORK && git rev-parse --abbrev-ref HEAD && git log --oneline -1'

# reproduce the disarm logic without running it
python3 -c 'maxRuns=0; run=4; print("L15 fires:", maxRuns>0 and run>maxRuns); print("L134 fires:", run>=maxRuns)'
# -> L15 fires: False   L134 fires: True
```

## 8. Follow-ups

1. Fix `$maxRuns` semantics: either set it to the intended `50`, or make line 134
   honour the same `$maxRuns -gt 0` guard as line 15. One of the two, not both.
2. Add an alert path on exhaustion (retained COMS note) so stopping is observable.
3. Apply the same fix to Linux `tools/coms_cycle_watch.py` `disarm()` — alert and
   stay armed rather than disarming quietly.
4. Merge PR #9 (`feat/coms-notes-visibility`, 4 files, MERGEABLE) so peers on
   that branch are not stranded behind an unmerged ref.
5. Re-run `verify_coms_windows.ps1` and publish the transcript — still the one
   outstanding ask, and still never executed by anyone.
