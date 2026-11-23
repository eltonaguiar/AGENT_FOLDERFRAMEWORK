# Controlling the desktop with the monitors off — measured, 2026-11-23

**Test host:** `desktop-081g9oh` (Windows 11, 10.0.26300.9974), NVIDIA RTX 5070, dual display.
**Question:** with the physical monitors powered off, can this agent still (a) see the screen and (b) drive it — i.e. send
a command to an editor agent and have it actually queue?

**Short answer:** **seeing works; driving does not.** Capture is unaffected by monitor power. What breaks is the
**geometry** — the accessibility rectangles the driver needs to place a click collapse into a bogus giant box, and the
display topology change invalidates every stored coordinate. So the control plane becomes COMS, not pixels.

---

## What was measured

| test | monitors ON | monitors OFF | verdict |
|---|---|---|---|
| Full-screen capture succeeds | yes, 1920×1080 | **yes, 1360×768** | **works** |
| Captured frame is real (not black) | — | mean luma **27.8/255**, near-black pixels **0.00 %**, **238** distinct levels | **works** |
| Content readable | yes | yes — taskbar clock, chat text, editor contents all legible | **works** |
| Per-window capture (`app='Code.exe'`) | yes | **yes, 1360×775**, full VS Code UI legible | **works** |
| Display count reported by WMI | 2 Active=True | **1** (one dropped out entirely) | **topology changed** |
| Desktop resolution | 1920×1080 + 1360×768 | **1360×768 only** | **all coordinates invalidated** |
| Accessibility rects for agent webviews | sane | **`[-9516, 678, 19621, 9394]`** — a 19 621 × 9 394 rect | **corrupt** |
| Driver's own scale estimate | ~1.3× | **13.0×** | **corrupt** |
| Coordinate click on an agent composer | risky | **unsafe** (centre of that rect is off-desktop) | **do not** |

**Interpretation.** The compositor (DWM) keeps producing frames when a monitor is powered down, so screenshots are fine —
that part of the folklore is wrong. What does not survive is the *mapping*: powering off a monitor here caused Windows to
drop it from the topology, shrinking the desktop and re-laying out every window, and the accessibility bounds for the
Electron/webview surfaces degraded into a rectangle thousands of times larger than the screen. A click derived from that
geometry has no meaningful target.

Note the asymmetry: **VS Code's own chrome stays sane** — `#0 Minimize @ (1223, -7, 45, 28)`, `#3 Document 1360×776` —
while the agent panes do not. So "the AX tree is fine" is not a usable conclusion; it has to be checked per element.

---

## What genuinely stops automation, and what was done about it

| hazard | state found | action |
|---|---|---|
| Machine sleeps / hibernates | AC standby and hibernate **enabled** | **set to 0 (never)** — verified `STANDBYIDLE AC = 0x0`, `HIBERNATEIDLE AC = 0x0` |
| Screen saver engages after 900 s | `ScreenSaveActive=1`, timeout **900** | **disabled** (`ScreenSaveActive=0`, `ScreenSaverIsSecure=0`) — a secure saver is a lock |
| Session locked | not locked (`logonui` count 0) | leave unlocked; do not lock while unattended |
| Monitor powered off | capture fine, geometry corrupt | route control through COMS; do not click |
| Monitor **physically unplugged** / KVM switch | not tested | expected to be worse than power-off (no EDID at all) |

---

## The permanent fix, if true headless is wanted

This box **already has virtual display drivers installed**:

```
OK  Parsec Virtual Display Adapter
OK  Meta Virtual Monitor
OK  Virtual Desktop Monitor
OK  Mixed Reality Link Display Device
OK  NVIDIA GeForce RTX 5070
```

A virtual display keeps a display target present after the physical monitors are off, so the topology never changes and the
resolution never re-lays out — which removes the geometry corruption above at its cause. The alternatives, in order of
robustness:

1. **Enable one of the installed virtual display drivers** as a permanent "headless monitor" (cheapest, already present).
2. **Virtual display driver from source** — `IddCx`/UMDF projects (titanfyre/Virtual-Display-Studio, adipose/idd-vdisplay,
   Chromium's `win_virtual_display`) if a specific resolution is needed.
3. **EDID dummy plug** — a hardware dongle on the GPU output; the old reliable answer, keeps the link and EDID alive.
4. **Do not use a disconnected RDP session as the answer.** A disconnected RDP session is a classic cause of black
   screenshots, because the session has no rendering surface while disconnected. It is a cause of this problem, not a fix.

---

## Operating rule adopted

> **Capture is allowed whenever a frame is real. Clicks are allowed only when, in the SAME capture, every target element
> has positive width and height, each smaller than the screen, and lies on-screen — and the driver's scale estimate is
> plausible (≈1–2×).** If any check fails, the task is routed to COMS and the run reports
> `pixel control unavailable: <reason>`. A blind click at a stale coordinate is how a working-set "Keep" or an approval
> "Run" gets triggered by accident.

Implemented in the `vscode-agent-watch` job's precondition, which now also re-measures every capture because a topology
change silently invalidates all stored coordinates.

---

## Failures recorded, not hidden

- **A queued-command test could not be completed.** With the display dropped, the agent composer's rect was corrupt, so the
  click could not be placed safely. This is reported as **control unproven with monitors off**, not as success.
- **`Start-Process notepad` produced no `notepad` process** on this host (Windows 11's packaged Notepad), so an isolated
  input test needed a different target. Recorded as a failed sub-test; not pursued further.
- **An earlier "Keep" click missed.** I passed a screenshot pixel value while the driver scaled it by ×1.32, posting the
  click below the client area of a 782 px-tall window. The working-set strip persisted and I twice mis-read that as the app
  being stuck. The lesson: derive click points from element bounds, never from a screenshot position I estimated by eye.
