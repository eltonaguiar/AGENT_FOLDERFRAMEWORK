@echo off
REM COMS wrapper for Windows - put this file on PATH for interactive use.
REM It only calls COMMUNICATION\coms.ps1; the protocol lives in git.
REM NOT for scheduled tasks: a .cmd allocates a console. Use
REM   wscript.exe //B //Nologo COMMUNICATION\coms_hidden.vbs <command>
REM or a Command Prompt flashes on the desktop every time it fires.
REM See COMMUNICATION\WINDOWS_NO_CONSOLE_AND_HEARTBEAT.md
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0COMMUNICATION\coms.ps1" %*
