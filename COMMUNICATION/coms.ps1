# Windows COMS. Same protocol as Linux `COMS`.
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 learn
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 register -Agent claude
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 roster
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 heartbeat
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 send <topic> <message>
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 guard [files...]
param(
  [Parameter(Position=0)][string]$Command = "learn",
  [string]$Agent = "",
  [string]$Todo = "",
  [string]$Done = "",
  [Parameter(Position=1)][string]$Topic = "",
  [Parameter(Position=2)][string]$Message = "",
  [Parameter(ValueFromRemainingArguments=$true)][string[]]$Rest = @()
)
$Broker = if ($env:COMS_BROKER) { $env:COMS_BROKER } else { "192.168.2.52" }
$Port = 1883
$Reg = Join-Path $env:USERPROFILE ".coms\agents.jsonl"

function Slug([string]$s) {
  $t = $s.ToLower() -replace '[^a-z0-9_-]', '-'
  return $t.Trim('-')
}
function HostName { Slug $env:COMPUTERNAME }
function Worktree {
  $top = ""
  try { $top = (git rev-parse --show-toplevel 2>$null) } catch {}
  if (-not $top) { $top = (Get-Location).Path }
  return Slug (Split-Path $top -Leaf)
}
function Publish([string]$T, [string]$M, [switch]$Retain) {
  $r = if ($Retain) { "retain=True" } else { "retain=False" }
  python -c "import sys, paho.mqtt.client as mqtt; c=mqtt.Client(mqtt.CallbackAPIVersion.VERSION2); c.connect(sys.argv[1], int(sys.argv[2]), 60); c.publish(sys.argv[3], sys.argv[4], qos=1, $r).wait_for_publish(10); c.disconnect()" $Broker $Port $T $M
}
function Test-Secret([string]$Text) {
  $pats = @(
    @{ p = "-----BEGIN [A-Z ]*PRIVATE KEY-----"; n = "private-key" },
    @{ p = "\bAKIA[0-9A-Z]{16}\b"; n = "aws-key" },
    @{ p = "\bsk-[A-Za-z0-9]{20,}"; n = "sk-token" },
    @{ p = "\bgh[pousr]_[A-Za-z0-9]{20,}"; n = "github-token" },
    @{ p = "\bxox[baprs]-[A-Za-z0-9-]{10,}"; n = "slack-token" },
    @{ p = "(?i)(api[_-]?key|secret|password|passwd|token)\s*[:=]\s*\S{8,}"; n = "assigned-secret" }
  )
  return @($pats | Where-Object { $Text -match $_.p } | ForEach-Object { $_.n })
}
function Refuse-Secret([string]$Text) {
  $hits = Test-Secret $Text
  if ($hits.Count -gt 0) {
    [Console]::Error.WriteLine("refusing secret-like content: " + ($hits -join ","))
    [Console]::Error.WriteLine("do not publish or commit this. Git and MQTT are both shared.")
    return $false
  }
  return $true
}

if ($Command -eq "register" -and $Rest.Count -gt 0) {
  $i = 0
  while ($i -lt $Rest.Count) {
    if ($Rest[$i] -match '^--?(agent|todo|done)$' -and ($i + 1) -lt $Rest.Count) {
      $v = $Rest[$i + 1]
      switch ($Matches[1]) {
        "agent" { $Agent = $v }
        "todo" { $Todo = $v }
        "done" { $Done = $v }
      }
      $i += 2
    } else { $i++ }
  }
}

switch ($Command) {
  "learn" {
@"
COMS — live wake bus. Git is the filing cabinet. MQTT is the intercom.
Broker: ${Broker}:${Port} anonymous. Repo: https://github.com/eltonaguiar/AGENT_FOLDERFRAMEWORK
Inbox: inbox/<host>/<worktree>/<agent>
This folder: inbox/$(HostName)/$(Worktree)/<agent>
Register here: powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 register -Agent <role>
Do not reinstall the broker. Do not put secrets on the bus.
"@
  }
  "register" {
    if (-not $Agent) { Write-Error "register -Agent <role> is required"; exit 2 }
    $hostName = HostName
    $wt = Worktree
    $role = Slug $Agent
    $inbox = "inbox/$hostName/$wt/$role"
    $repos = @()
    try { $repos = @(git remote -v 2>$null | ForEach-Object { ($_ -split '\s+')[1] } | Sort-Object -Unique) } catch {}
    $obj = [ordered]@{
      agent = $role
      host = $hostName
      os = "windows"
      worktree = $wt
      path = (Get-Location).Path
      inbox = $inbox
      swarmbus_id = "$hostName`__$wt`__$role"
      repos = $repos
      todo = $Todo
      done = $Done
      registered_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    $json = $obj | ConvertTo-Json -Compress
    if (-not (Refuse-Secret $json)) { exit 2 }
    New-Item -ItemType Directory -Force -Path (Split-Path $Reg) | Out-Null
    Add-Content -Path $Reg -Value $json
    Publish "registry/$hostName/$wt/$role" $json -Retain
    Write-Output "registered $inbox"
    Write-Output $json
  }
  "roster" {
    if (Test-Path $Reg) { Get-Content $Reg }
    python -c @"
import time, paho.mqtt.client as mqtt
seen=[]
def on_msg(c,u,m):
    print(m.topic, m.payload.decode())
c=mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
c.on_message=on_msg
c.connect('$Broker', $Port, 60)
c.subscribe('registry/#')
c.loop_start(); time.sleep(2); c.loop_stop(); c.disconnect()
"@
  }
  "heartbeat" {
    $line = "alive " + (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    Publish "status/$(HostName)" $line
    Write-Output $line
  }
  "send" {
    if (-not $Topic -or -not $Message) { Write-Error "usage: coms.ps1 send <topic> <message>"; exit 2 }
    if (-not (Refuse-Secret $Message)) { exit 2 }
    Publish $Topic $Message
    Write-Output "sent $Topic"
  }
  "guard" {
    $paths = @(@($Topic, $Message) + $Rest) | Where-Object { $_ }
    if ($paths.Count -eq 0) {
      $text = [Console]::In.ReadToEnd()
      if (-not (Refuse-Secret $text)) { exit 2 }
      Write-Output "clean"
      exit 0
    }
    $hit = $false
    foreach ($f in $paths) {
      if ((Test-Path -LiteralPath $f) -and -not (Refuse-Secret (Get-Content -Raw -LiteralPath $f))) {
        [Console]::Error.WriteLine("blocked $f"); $hit = $true
      }
    }
    if (-not $hit) { Write-Output "clean" } else { exit 2 }
  }
  "prompt" {
    Get-Content -Raw (Join-Path (Split-Path $PSCommandPath) "AGENT_REGISTER_PROMPT.md")
  }
  default { Write-Output "commands: learn, register -Agent <role> [-Todo .. -Done ..], roster, heartbeat, send <topic> <message>, guard [files]" }
}
