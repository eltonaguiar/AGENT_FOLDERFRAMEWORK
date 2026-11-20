# verify_coms_windows.ps1 -- run on the Windows host to confirm the COMS findings
# NOTE: keep this file PURE ASCII. Windows PowerShell 5.1 reads a .ps1 with no
# BOM using the ANSI code page, so any non-ASCII byte breaks the parser (F1).
# The UTF-8 probe below is built from code points at runtime for that reason.
#
# Written 2026-11-20 by subq (Linux). UNVERIFIED BY ME: there is no pwsh on the
# Linux host, so I could not execute a single line of this. It is written for
# PS 5.1 compatibility (no ternary, no ??, no -Parallel) because coms.ps1 was
# fixed to run under 5.1.
#
# REV 2 -- corrected after a peer audit (copilot-cli-deepseek-flash). Three real
# defects in rev 1, all fixed here:
#   1. Test 7 was DESTRUCTIVE BY DESIGN: it published retained to a REAL peer
#      inbox (inbox/desktop-081g9oh/auditpage/opencode) to assert that such
#      writes are guarded -- asserting a guard by exercising its absence, after
#      the side effect. Now: a fabricated seat nobody subscribes to, cleaned up,
#      and recorded INFO (guard absence is a known open item, not a regression).
#   2. Test 4 tested the WRONG LAYER: it called mosquitto_pub -f directly, so it
#      could never detect the client's own trailing-newline loss, which lives in
#      coms send's $(cat) -> -m path. Now: both legs -- transport AND client.
#   3. Retained topics were left behind (status/verify-*, status/verify-big-*)
#      and the UTF-8 probe was broadcast to mentions/all. Now: dedicated topics,
#      all cleared at the end.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File verify_coms_windows.ps1 -Agent <your-role>
#   pwsh -File verify_coms_windows.ps1 -Agent <your-role>

param(
    [string]$Agent = "verify",
    [string]$Coms  = "E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1",
    [string]$Broker = "192.168.2.52",
    [int]$Port = 1883
)

$ErrorActionPreference = "Continue"
$results = @()
$written = @()   # retained topics this script writes; all cleared at the end

function Record($name, $status, $detail) {
    $script:results += [pscustomobject]@{ Test = $name; Status = $status; Detail = $detail }
    Write-Host ("[{0}] {1} -- {2}" -f $status, $name, $detail)
}

function Clear-Topic($topic) {
    # Uses the bundled transport when the mosquitto binaries are absent, so a
    # cleanup never silently does nothing.
    if (Get-Command mosquitto_pub -ErrorAction SilentlyContinue) {
        & mosquitto_pub -h $Broker -p $Port -r -t $topic -m ''
        Write-Host "        cleared $topic"
    } elseif ($script:hasIo) {
        Io-Pub $topic "" -Retain | Out-Null
        Write-Host "        cleared $topic (bundled transport)"
    }
}

# ---------------------------------------------------------------- 0. context
Write-Host "=== 0. context ==="
Record "PS version" "INFO" ($PSVersionTable.PSVersion.ToString())
Record "CLI exists" $(if (Test-Path $Coms) { "PASS" } else { "FAIL" }) $Coms
$hasSub = $null -ne (Get-Command mosquitto_sub -ErrorAction SilentlyContinue)
$hasPub = $null -ne (Get-Command mosquitto_pub -ErrorAction SilentlyContinue)
Record "mosquitto_sub/pub on PATH" $(if ($hasSub -and $hasPub) { "PASS" } else { "INFO" }) "absent on this host; transport tests use the bundled paho path below"

# ---------------------------------------------- transport (bundled, no SKIPs)
# Three tests used to be recorded SKIP because the mosquitto binaries are not
# installed here, which left the 500 KB path never exercised. coms.ps1 already
# publishes through python + paho, so that is the bundled transport: use it and
# the transport tests become real. mqtt_io.py lives beside this script.
$IoScript = Join-Path (Split-Path -Parent $Coms) "mqtt_io.py"
$hasIo = Test-Path $IoScript
Record "bundled transport (mqtt_io.py)" $(if ($hasIo) { "PASS" } else { "FAIL" }) $IoScript
function Io-Pub([string]$T, [string]$M, [string]$Path, [switch]$Retain) {
    $a = @($IoScript, 'pub', '--broker', $Broker, '--port', "$Port", '--topic', $T)
    if ($Path) { $a += @('--file', $Path) } else { $a += @('--message', $M) }
    if ($Retain) { $a += @('--retain') }
    return (& python @a 2>&1 | Out-String)
}
function Io-Sub([string]$T, [int]$WaitSec = 3) {
    return (& python $IoScript 'sub' '--broker' $Broker '--port' "$Port" '--topic' $T '--wait' "$WaitSec" 2>$null | Out-String)
}
function Io-Sub-Len([string]$T, [int]$WaitSec = 3) {
    $out = & python $IoScript 'sub' '--broker' $Broker '--port' "$Port" '--topic' $T '--wait' "$WaitSec" '--len' 2>$null | Out-String
    return $out.Trim()
}
if (-not (Test-Path $Coms)) { Write-Host "coms.ps1 not found -- stopping"; exit 1 }

# ------------------------------------------------- 1. check does not crash
Write-Host "`n=== 1. check (UTF-8 + notes index) ==="
$out = & $Coms check -Agent $Agent 2>&1 | Out-String
$code = $LASTEXITCODE
Record "check exit code" $(if ($code -eq 0) { "PASS" } else { "FAIL" }) "exit=$code"
$nonAscii = ($out.ToCharArray() | Where-Object { [int]$_ -gt 127 }).Count
Record "check emitted non-ASCII text" "INFO" ("{0} non-ASCII chars survived" -f $nonAscii)
if ($out -match "note\(s\) on notes/#") {
    Record "check lists notes" "PASS" "notes index present"
} else {
    Record "check lists notes" "SKIP" "no notes matched, or index not in this build"
}

# ------------------------------------------------------- 2. topics enumerates
Write-Host "`n=== 2. topics ==="
$t = & $Coms topics '#' --wait 3 2>&1 | Out-String
Record "topics exit code" $(if ($LASTEXITCODE -eq 0) { "PASS" } else { "FAIL" }) "exit=$LASTEXITCODE"
$prefixes = @{}
foreach ($line in ($t -split "`n")) {
    if ($line -match "^\s*(\d+)\s+(\S+)\s+(\d+)\s+topic") { $prefixes[$matches[2]] = $matches[1] }
}
Record "topics prefix rollup" "INFO" (($prefixes.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join " ")

# ------------------------------------------- 3. UTF-8 round trip (own topic)
Write-Host "`n=== 3. UTF-8 send ==="
# Dedicated topic, not mentions/all -- a shared broadcast channel is not a test bed.
$utf8T = "status/verify-utf8-$Agent"
$written += $utf8T
$probe = "utf8 probe " + [char]0x2014 + " B " + [char]0x00B1 + " " + [char]0x2013 + " " + [char]0x00E9 + " " + [char]::ConvertFromUtf32(0x1F680)
$sendOut = & $Coms send $utf8T $probe -Retain 2>&1 | Out-String
Record "send non-ASCII payload" $(if ($sendOut -match "sent") { "PASS" } else { "FAIL" }) $sendOut.Trim()
$back = Io-Sub $utf8T 2
Record "UTF-8 survives round trip" $(if ($back.Trim() -eq $probe) { "PASS" } else { "FAIL" }) ("read back: " + $back.Trim())

# ------------------------- 4. trailing newline -- TWO legs (transport, client)
Write-Host "`n=== 4. trailing newline ==="
if (-not $hasIo) {
    Record "trailing newline round trip" "SKIP" "no bundled transport on this host"
} else {
    $tmpIn = [System.IO.Path]::GetTempFileName()
    $payload = "line-one`n`n"          # ends with TWO newlines
    [System.IO.File]::WriteAllText($tmpIn, $payload, (New-Object System.Text.UTF8Encoding($false)))
    $want = (Get-Item $tmpIn).Length

    # --- leg A: transport (direct pub/sub) -- what rev 1 tested, and all it tested
    $tA = "status/verify-nl-transport-$Agent"
    $written += $tA
    Io-Pub $tA "" -Path $tmpIn -Retain | Out-Null
    Start-Sleep -Milliseconds 500
    $gotA = [int](Io-Sub-Len $tA 2)
    Record "transport preserves trailing newline" $(if ($gotA -eq $want) { "PASS" } else { "FAIL" }) "sent $want bytes, read back $gotA"

    # --- leg B: the CLIENT path (rev 2). Scope, stated honestly: this leg
    # does NOT cover the $(cat file) newline loss. Measured on Linux, the strip
    # happens in the CALLER's shell before coms runs, not inside coms send:
    #   send --retain T "$(cat f)"  -> 8 B payload   (f was 10 B)
    #   send --retain T "line-one<NL><NL>" -> 10 B payload
    # coms send itself is byte-faithful on argv. So this leg tests a DIFFERENT
    # risk that is real on Windows: whether coms.ps1's paho path re-encodes,
    # strips, or mangles argv before publish. It will PASS on any correct
    # client; a FAIL means the Windows client is lossy. Neither leg can catch
    # E3 -- that needs a `coms send --file` flag, which does not exist yet
    # (usage: COMS send [--retain] <topic> <message>).
    $tB = "status/verify-nl-client-$Agent"
    $written += $tB
    $raw = [System.IO.File]::ReadAllText($tmpIn)
    $clientOut = & $Coms send $tB $raw -Retain 2>&1 | Out-String
    Start-Sleep -Milliseconds 500
    $lenB = Io-Sub-Len $tB 2
    if ([int]$lenB -lt 0) {
        Record "client preserves trailing newline" "SKIP" "no readback ($($clientOut.Trim()))"
    } else {
        Record "client preserves trailing newline" $(if ([int]$lenB -eq $want) { "PASS" } else { "FAIL" }) "source $want bytes, client published $lenB"
    }

    # $tmpBack is gone: the bundled transport returns the length as a string, so
    # there is no readback file to delete (this line bound null and threw).
    Remove-Item $tmpIn -ErrorAction SilentlyContinue
}

# ------------------------------- 5. large payload: 500 KB through the client
# This used to SKIP because mosquitto_pub was not on PATH, so the 500 KB path had
# never run here. argv cannot carry 500 KB on Windows (32767-char command line),
# so `send -File` publishes the bytes through paho and the length is read back.
Write-Host "`n=== 5. large payload, 500 KB via -File ==="
if (-not $hasIo) {
    Record "500 KB via -File" "SKIP" "no bundled transport on this host"
} else {
    $bigPath = [System.IO.Path]::GetTempFileName()
    $big = New-Object byte[] 500000
    for ($i = 0; $i -lt $big.Length; $i++) { $big[$i] = 0x42 }
    [System.IO.File]::WriteAllBytes($bigPath, $big)
    $bigT = "status/verify-big-$Agent"
    $written += $bigT
    $sendOut = & $Coms send $bigT -File $bigPath -Retain 2>&1 | Out-String
    Record "client accepted 500 KB -File" $(if ($sendOut -match 'sent') { "PASS" } else { "FAIL" }) $sendOut.Trim()
    $gotLen = [int](Io-Sub-Len $bigT 5)
    Record "500 KB arrives whole" $(if ($gotLen -eq 500000) { "PASS" } else { "FAIL" }) "published $gotLen of 500000 bytes"
    Remove-Item -LiteralPath $bigPath -ErrorAction SilentlyContinue
}

# --------------------------------------------- 6. roster duplicates (upsert)
Write-Host "`n=== 6. roster duplicates ==="
$reg = Join-Path $env:USERPROFILE ".coms\agents.jsonl"
if (-not (Test-Path $reg)) {
    Record "roster duplicates" "SKIP" "no $reg on this host"
} else {
    $rows = @()
    foreach ($line in (Get-Content $reg)) {
        if ($line.Trim()) { try { $rows += ($line | ConvertFrom-Json) } catch { } }
    }
    $keys = $rows | ForEach-Object { "$($_.host)|$($_.worktree)|$($_.agent)" }
    $distinct = ($keys | Select-Object -Unique).Count
    $dups = $keys.Count - $distinct
    Record "roster rows vs seats" $(if ($dups -eq 0) { "PASS" } else { "FAIL" }) "$($keys.Count) rows, $distinct distinct, $dups duplicated"
    $top = $keys | Group-Object | Sort-Object Count -Descending | Select-Object -First 3
    foreach ($g in $top) { if ($g.Count -gt 1) { Write-Host ("        {0}x  {1}" -f $g.Count, $g.Name) } }
}

# ------------------------------------- 7. retain guard (NON-DESTRUCTIVE)
Write-Host "`n=== 7. retain guard on a foreign inbox ==="
# Rev 1 targeted a REAL peer inbox and left the probe there. A seat that nobody
# subscribes to measures the same thing and costs nothing. The guard's absence
# is a known open item (see COMS_CODE_REVIEW_2026-11-20.md #6), so it is INFO,
# not FAIL -- a suite that fails on known-open work trains people to ignore it.
$probeT = "inbox/gx10-c9b9/coms-probe-wt/probe-agent"
$written += $probeT
$g = & $Coms send $probeT "guard probe -- safe fabricated seat" -Retain 2>&1 | Out-String
$guardExists = ($g -match "refus")
Record "retain guard on foreign inbox" $(if ($guardExists) { "PASS" } else { "INFO" }) "guard $(if ($guardExists) { 'present' } else { 'ABSENT on this build' }); probe topic will be cleared"

# ---------------------------------------------------------------- cleanup
Write-Host "`n=== cleanup ==="
foreach ($topic in $written) { Clear-Topic $topic }

# ---------------------------------------------------------------- summary
Write-Host "`n=== summary ==="
$results | Group-Object Status | ForEach-Object { Write-Host ("{0}: {1}" -f $_.Name, $_.Count) }
$fail = @($results | Where-Object { $_.Status -eq "FAIL" }).Count
Write-Host ""
if ($fail -gt 0) {
    Write-Host "$fail FAILING test(s):"
    $results | Where-Object { $_.Status -eq "FAIL" } | ForEach-Object { Write-Host ("  - {0}: {1}" -f $_.Test, $_.Detail) }
    exit 1
}
Write-Host "No failures. Paste this transcript into the COMS PR."
exit 0
