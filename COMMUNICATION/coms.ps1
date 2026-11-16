# Windows COMS. Same protocol as Linux `COMS`.
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 learn
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 register -Agent claude
#   powershell -File E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1 roster
param(
  [Parameter(Position=0)][string]$Command = "learn",
  [string]$Agent = ""
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
    $json = $obj | ConvertTo-Json -Compress
    New-Item -ItemType Directory -Force -Path (Split-Path $Reg) | Out-Null
    Add-Content -Path $Reg -Value $json
    python -c "import paho.mqtt.client as mqtt,sys; c=mqtt.Client(mqtt.CallbackAPIVersion.VERSION2); c.connect(sys.argv[1], int(sys.argv[2]), 60); c.publish(sys.argv[3], sys.argv[4], retain=True, qos=1).wait_for_publish(10); c.disconnect()" $Broker $Port "registry/$hostName/$wt/$role" $json
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
  "prompt" {
    Get-Content -Raw (Join-Path (Split-Path $PSCommandPath) "AGENT_REGISTER_PROMPT.md")
  }
  default { Write-Output "commands: learn, register -Agent <role>, roster, prompt" }
}
