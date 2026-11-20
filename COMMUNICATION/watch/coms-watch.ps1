$ErrorActionPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$root = Join-Path $env:USERPROFILE '.coms\watch'
New-Item -ItemType Directory -Force -Path $root | Out-Null
$statePath = Join-Path $root 'state.txt'
$logPath = Join-Path $root 'log.md'
$latestPath = Join-Path $root 'LATEST.md'
$counterPath = Join-Path $root 'runs.txt'
$maxRuns = 0
$run = 0
if (Test-Path $counterPath) { try { $run = [int]((Get-Content $counterPath -Raw).Trim()) } catch {} }
$run++
Set-Content -Path $counterPath -Value $run
$now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
if ($maxRuns -gt 0 -and $run -gt $maxRuns) { schtasks /Change /TN COMS-watch-50 /DISABLE | Out-Null; exit 0 }

$state = @{}
if (Test-Path $statePath) {
  foreach ($l in Get-Content $statePath) { if ($l -match '^([^=]+)=(.*)$') { $state[$Matches[1]] = $Matches[2] } }
}
function Save-State {
  $out = @()
  foreach ($k in @('feTip','fwTip','a3gen','mrgen','comsHash','a3id')) { $out += "$k=$($state[$k])" }
  Set-Content -Path $statePath -Value $out
}
function Sanitize($t) {
  ($t -split "`n" | ForEach-Object { if ($_ -match 'AUDIT_DB_PASS') { '[redacted line]' } else { $_ } }) -join "`n"
}

$lines = @()
$lines += "## $now run $run/$maxRuns"
$changes = @()

# COMS (run from the project worktree so the seat resolves to the right inbox)
Push-Location 'E:\findtorontoevents_antigravity.ca'
$coms = & powershell -NoProfile -File 'E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1' check -Agent opencode --wait 2 2>&1 | Out-String
Pop-Location
$coms = Sanitize $coms
$comsTmp = Join-Path $root 'coms.txt'
Set-Content -Path $comsTmp -Value $coms
$comsHash = (Get-FileHash -Path $comsTmp -Algorithm SHA256).Hash
if ($state['comsHash'] -and $state['comsHash'] -ne $comsHash) { $changes += 'COMS output changed' }
$state['comsHash'] = $comsHash
$lines += '### COMS'
$lines += '```'
$lines += $coms.Trim()
$lines += '```'

# GitHub main tips
$fe = 'E:\findtorontoevents_antigravity.ca'
$fw = 'E:\AGENT_FOLDERFRAMEWORK'
function Tip($repo) {
  $o = git -C $repo ls-remote origin refs/heads/main 2>$null
  if ($o) { return (($o | Select-Object -First 1) -split '\s+')[0] }
  return ''
}
$feTip = Tip $fe
$fwTip = Tip $fw
$lines += '### GitHub main tips'
$lines += "- findtorontoevents: $feTip"
$lines += "- AGENT_FOLDERFRAMEWORK: $fwTip"
if ($state['feTip'] -and $state['feTip'] -ne $feTip) {
  $changes += "findtorontoevents main moved $($state['feTip']) -> $feTip"
  git -C $fe fetch --quiet origin main 2>$null
  $lines += '#### new findtorontoevents commits'
  $lines += '```'
  $lines += (git -C $fe log --oneline "$($state['feTip'])..origin/main" 2>$null | Select-Object -First 20)
  $lines += '```'
}
if ($state['fwTip'] -and $state['fwTip'] -ne $fwTip) {
  $changes += "AGENT_FOLDERFRAMEWORK main moved $($state['fwTip']) -> $fwTip"
  git -C $fw fetch --quiet origin main 2>$null
  $lines += '#### new framework commits'
  $lines += '```'
  $lines += (git -C $fw log --oneline "$($state['fwTip'])..origin/main" 2>$null | Select-Object -First 20)
  $lines += '```'
}
$state['feTip'] = $feTip
$state['fwTip'] = $fwTip

# Local edits
$lines += '### Local edits'
$lines += '```'
$lines += (git -C $fe status --short --untracked-files=no 2>$null | Select-Object -First 25)
$lines += '--- framework ---'
$lines += (git -C $fw status --short --untracked-files=no 2>$null | Select-Object -First 25)
$lines += '```'

# Live audit surfaces
$ua = @{ 'User-Agent' = 'Mozilla/5.0 coms-watch' }
function GetJson($u) { try { return Invoke-RestMethod -Uri $u -Headers $ua -TimeoutSec 45 } catch { return $null } }
$a3 = GetJson 'https://findtorontoevents.ca/audit3/audit3_ledger.json'
$mr = GetJson 'https://findtorontoevents.ca/audit/data/money_ready_verdict.json'
$a2 = GetJson 'https://findtorontoevents.ca/audit2/audit2_forward.json'
$lines += '### Live audit surfaces'
foreach ($u in @('https://findtorontoevents.ca/audit/','https://findtorontoevents.ca/audit2/','https://findtorontoevents.ca/audit3/')) {
  try { $h = Invoke-WebRequest -Uri $u -Headers $ua -Method Head -TimeoutSec 30 -UseBasicParsing; $lines += "- $u HTTP $($h.StatusCode)" } catch { $lines += "- $u HTTP ERR" }
}
if ($a3) {
  $lines += "- audit3 generated_at=$($a3.generated_at) source=$($a3.source_generated_at) id=$($a3.provenance.id)"
  $lines += "- rows=$($a3.summary.n_rows) proven=$($a3.summary.n_proven) candidate=$($a3.summary.n_candidate) weak=$($a3.summary.n_weak) kill=$($a3.summary.n_kill)"
  $lines += "- coverage=$($a3.coverage.scored_rows)/$($a3.coverage.total_closed_picks) ($($a3.coverage.scored_share_of_total_pct)%) alpha=$($a3.selection_alpha.overall.alpha_pct) CI=$($a3.selection_alpha.overall.alpha_ci -join ',') n=$($a3.selection_alpha.overall.n)"
  $lines += "- forward rows=$($a3.forward_gate.n_rows) equity_pod=$($a3.forward_gate.pods.'POD-EQUITY-BREAKOUT'.n_forward)"
  $eq = $a3.classes | Where-Object { $_.asset_class -eq 'EQUITY' } | Select-Object -First 1
  if ($eq) { $lines += "- EQUITY n=$($eq.n) net=$($eq.net_expectancy_pct) CI=$($eq.net_ci_pct -join ',') PF=$($eq.pf) required_n=$($eq.required_n) verdict=$($eq.verdict)" }
  if ($state['a3gen'] -and $state['a3gen'] -ne $a3.generated_at) { $changes += "audit3 ledger regenerated $($state['a3gen']) -> $($a3.generated_at)" }
  $state['a3gen'] = $a3.generated_at
  $state['a3id'] = $a3.provenance.id
} else { $lines += '- audit3 fetch failed' }
if ($mr) {
  $lines += "- money_ready generated=$($mr.generated_at) money=[$($mr.summary.money_ready -join ',')] watch=[$($mr.summary.watch -join ',')]"
  if ($state['mrgen'] -and $state['mrgen'] -ne $mr.generated_at) { $changes += 'money_ready regenerated' }
  $state['mrgen'] = $mr.generated_at
} else { $lines += '- money_ready fetch failed' }
if ($a2) {
  $hyps = (@($a2.by_hypothesis.PSObject.Properties.Name)) -join ','
  $lines += "- audit2_forward generated=$($a2.generated_at) rows=$($a2.n_rows) hyps=$hyps"
}

# Prepared response
$lines += '### Prepared response'
if ($changes.Count -eq 0) {
  $lines += '- No material change. Hold: cheap beta only; EQUITY paper-only until the pod forward gate passes.'
} else {
  foreach ($c in $changes) { $lines += "- Change: $c" }
  $lines += '- Re-check COMS for a direct ask; reject claims lacking committed artifact + reproduce command + 2x-cost net CI; post one concise reply.'
}
$lines += ''

Add-Content -Path $logPath -Value ($lines -join "`n")
Set-Content -Path $latestPath -Value ($lines -join "`n")
Save-State
if ($run -ge $maxRuns) {
  schtasks /Change /TN COMS-watch-50 /DISABLE | Out-Null
  Add-Content -Path $logPath -Value "`n[SCHEDULE COMPLETE: $maxRuns runs]"
}
