# Windows COMS. Same protocol as Linux `COMS`.
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 learn
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 register -Agent claude
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 roster
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 heartbeat
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 send <topic> <message>
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 guard [files...]
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 listen -Agent <role>
param(
  [Parameter(Position=0)][string]$Command = "learn",
  [string]$Agent = "",
  [string]$Todo = "",
  [string]$Done = "",
  [string]$Goal = "",
  [string]$Files = "",
  [string]$Commits = "",
  [string]$Prompt = "",
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
function Resolve-Topic([string]$t) {
  # B7: slug() rewrites dots, so a folder named ..._antigravity.ca becomes
  # ..._antigravity-ca. Resolve the host/worktree segments so "sent" matches
  # what a subscriber (which slugs) is actually listening on.
  if ($t -match '^inbox/([^/]+)/([^/]+)/(.+)$') {
    return "inbox/$(Slug $Matches[1])/$(Slug $Matches[2])/$($Matches[3])"
  }
  return $t
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
    @{ p = "(?i)(?<![?&])(api[_-]?key|secret|password|passwd|token)\s*[:=]\s*\S{8,}"; n = "assigned-secret" }
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
    if ($Rest[$i] -match '^--?(agent|todo|done|goal|files|commits|prompt)$' -and ($i + 1) -lt $Rest.Count) {
      $v = $Rest[$i + 1]
      switch ($Matches[1]) {
        "agent" { $Agent = $v }
        "todo" { $Todo = $v }
        "done" { $Done = $v }
        "goal" { $Goal = $v }
        "files" { $Files = $v }
        "commits" { $Commits = $v }
        "prompt" { $Prompt = $v }
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
      registered_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    # B2: only emit a key when its flag was supplied, so a short status update
    # does not blank goal/files/commits/prompt/todo/done.
    if ($Goal)    { $obj.goal    = $Goal }
    if ($Todo)    { $obj.todo    = $Todo }
    if ($Done)    { $obj.done    = $Done }
    if ($Files)   { $obj.files   = $Files }
    if ($Commits) { $obj.commits = $Commits }
    if ($Prompt)  { $obj.prompt  = $Prompt }
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
    $resolved = Resolve-Topic $Topic
    if ($resolved -ne $Topic) { Write-Output "note: resolved topic $Topic -> $resolved (slug rewrites dots)" }
    Publish $resolved $Message
    Write-Output "sent $resolved (qos1, not retained — no delivery guarantee; verify with: coms.ps1 check -Agent <role>)"
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
  "listen" {
    $t = if ($Topic) { Resolve-Topic $Topic } elseif ($Agent) { Resolve-Topic "inbox/$(HostName)/$(Worktree)/$(Slug $Agent)" } else { Write-Error "usage: coms.ps1 listen -Agent <role>   (or: coms.ps1 listen <topic>)"; exit 2 }
    Write-Output "listening $t  (Ctrl-C to stop; reconnects on broker blips)"
    python -c @"
import time, paho.mqtt.client as mqtt
while True:
    try:
        c = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
        c.on_message = lambda cl, u, msg: print(msg.topic, msg.payload.decode(), flush=True)
        c.connect('$Broker', $Port, 60)
        c.subscribe('$t')
        c.loop_forever()
    except Exception as e:
        print('listener dropped:', e, flush=True)
        time.sleep(5)
"@
  }
  "check" {
    if (-not $Agent -and -not $Topic) { Write-Error "usage: coms.ps1 check -Agent <role>"; exit 2 }
    $t = if ($Topic) { Resolve-Topic $Topic } else { Resolve-Topic "inbox/$(HostName)/$(Worktree)/$(Slug $Agent)" }
    $wait = 3
    foreach ($r in $Rest) { if ($r -match '^\d+$') { $wait = [int]$r } }
    python -c @"
import time, paho.mqtt.client as mqtt
c = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
c.on_message = lambda cl, u, msg: print(msg.topic, msg.payload.decode())
c.connect('$Broker', $Port, 60)
c.subscribe('$t')
c.loop_start(); time.sleep($wait); c.loop_stop(); c.disconnect()
"@
    Write-Output "checked $t over ${wait}s (retained + in-flight; not a delivery guarantee)"
  }
  "unregister" {
    if (-not $Agent) { Write-Error "unregister -Agent <role> is required"; exit 2 }
    $hostName = HostName; $wt = Worktree; $role = Slug $Agent
    Publish "registry/$hostName/$wt/$role" "" -Retain
    if (Test-Path $Reg) {
      $keep = Get-Content $Reg | Where-Object { $_ -and ($_ -notmatch [regex]::Escape("inbox/$hostName/$wt/$role")) }
      Set-Content -Path $Reg -Value $keep
    }
    Write-Output "unregistered inbox/$hostName/$wt/$role"
  }
  "prompt" {
    Get-Content -Raw (Join-Path (Split-Path $PSCommandPath) "AGENT_REGISTER_PROMPT.md")
  }
  default { Write-Output "commands: learn, register -Agent <role> [-Todo .. -Done ..], roster, heartbeat, send <topic> <message>, guard [files], listen -Agent <role>, check -Agent <role>, unregister -Agent <role>" }
}
