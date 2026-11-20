$ErrorActionPreference = 'SilentlyContinue'
$OutputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$root = Join-Path $env:USERPROFILE '.coms\watch'
$watch = Join-Path $root 'coms-watch.ps1'
$respPath = Join-Path $root 'LATEST_RESPONSE.md'
$agentLog = Join-Path $root 'agent-log.md'
$ts = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

# 1) Refresh the digest (also increments the 50-run counter and can disable the task)
& powershell -NoProfile -ExecutionPolicy Bypass -File $watch

# 2) Ask the read-only watch agent for a prepared response
$prompt = 'Read LATEST.md and produce the three sections exactly as instructed.'
$job = Start-Job -ScriptBlock {
  param($dir, $msg)
  [Console]::OutputEncoding = [Text.Encoding]::UTF8
  $OutputEncoding = [Text.Encoding]::UTF8
  $env:PYTHONUTF8 = '1'
  & 'C:\Users\zerou\AppData\Roaming\npm\opencode.cmd' run --agent coms-watch --model deepseek/deepseek-flash --dir $dir $msg 2>&1
} -ArgumentList $root, $prompt

$out = ''
if (Wait-Job $job -Timeout 600) {
  $out = (Receive-Job $job 2>&1 | Out-String)
} else {
  Stop-Job $job -Force
  $out = 'AGENT TIMEOUT after 600s'
}
Remove-Job $job -Force

# strip ANSI escapes
$clean = $out -replace '\x1b\[[0-9;]*m', ''
$clean = ($clean -split "`n" | Where-Object {
  $_ -notmatch 'NativeCommandError|CategoryInfo|FullyQualifiedErrorId' -and
  $_ -notmatch '^\s*At line:\d+ char:\d+' -and
  $_ -notmatch '^\s*\+\s' -and
  $_ -notmatch '^opencode\.cmd\s*:\s*$'
}) -join "`n"
# force printable ASCII so PS 5.1 console decoding cannot produce mojibake
$chars = foreach ($ch in $clean.ToCharArray()) {
  $n = [int][char]$ch
  if (($n -ge 32 -and $n -le 126) -or $ch -eq "`n" -or $ch -eq "`r" -or $ch -eq "`t") { $ch } else { '-' }
}
$clean = -join $chars
Set-Content -Path $respPath -Value ("# $ts`n`n" + $clean)
Add-Content -Path $agentLog -Value ("`n## $ts`n" + $clean)

# 3) Optional auto-send: only if AUTOSEND exists and the agent says SEND: yes.
#    Default is OFF. Create the AUTOSEND file to enable direct-inbox delivery.
$auto = Join-Path $root 'AUTOSEND'
if ((Test-Path $auto) -and ($clean -match '(?m)^SEND:\s*yes')) {
  $draft = ''
  if ($clean -match '(?ms)^RESPONSE:\s*(.*?)(?:^SEND:|$)') { $draft = $Matches[1].Trim() }
  if ($draft -and $draft.Length -lt 1500 -and $draft -notmatch 'AUDIT_DB_PASS|password|secret|token|sk-|gh[pousr]_') {
    Push-Location 'E:\findtorontoevents_antigravity.ca'
    $send = & powershell -NoProfile -File 'E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1' send 'inbox/gx10-c9b9/vanilla-handsaw/kilo' $draft --retain 2>&1 | Out-String
    Pop-Location
    Add-Content -Path $agentLog -Value ("`nSENT: " + $send.Trim())
  } else {
    Add-Content -Path $agentLog -Value "`nSEND BLOCKED: draft empty, too long, or contains a secret-like token."
  }
}
