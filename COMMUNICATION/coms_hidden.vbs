' coms_hidden.vbs — launch a COMS subcommand with NO visible console window.
'
' Why this exists: a Scheduled Task whose Action is `powershell ...` with
' LogonType=InteractiveToken allocates a console for every run, so a black
' command-prompt box flashes on the user's desktop each time it fires. That is
' what COMS-heartbeat (every 5 min) was doing.
'
' WScript.Shell.Run with window style 0 starts the process hidden and returns
' immediately (bWaitOnReturn=False), so nothing is drawn at all — unlike
' `powershell -WindowStyle Hidden`, which still flashes the conhost window
' before PowerShell gets a chance to hide itself.
'
' Usage: wscript.exe //nologo coms_hidden.vbs heartbeat
'        wscript.exe //nologo coms_hidden.vbs "send mentions/all hello"

Option Explicit
Dim sh, cmd, args, i

If WScript.Arguments.Count = 0 Then
    WScript.Quit 2
End If

args = ""
For i = 0 To WScript.Arguments.Count - 1
    If i > 0 Then args = args & " "
    args = args & WScript.Arguments(i)
Next

cmd = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden " & _
      "-File ""E:\AGENT_FOLDERFRAMEWORK\COMMUNICATION\coms.ps1"" " & args

Set sh = CreateObject("WScript.Shell")
sh.Run cmd, 0, False
