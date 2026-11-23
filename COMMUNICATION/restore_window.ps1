# restore_window.ps1 — bring an existing window to the foreground by title substring.
#
# Why this exists: when a window is minimized or on another virtual desktop, screenshot
# capture returns 0x0 and coordinate clicks land nowhere. Clicking the taskbar is not always
# possible (monitors off, session unattended), so we need a no-click restore path.
#
# This is activation only. It does not click, type, or move the mouse — it just asks Windows
# to bring a matching window to the front. Safe to run unattended.
#
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File restore_window.ps1 "Agent Manager"
#   powershell -NoProfile -ExecutionPolicy Bypass -File restore_window.ps1 "Visual Studio Code"
#
# Exit codes: 0 = activated, 1 = no matching window, 2 = bad usage.

param(
    [Parameter(Mandatory = $true, Position = 0)][string]$TitleLike
)

$ErrorActionPreference = 'Stop'

try {
    $shell = New-Object -ComObject WScript.Shell

    # WScript.Shell.AppActivate does prefix matching against the window title and will
    # restore a minimized window as a side effect of activating it.
    $ok = $shell.AppActivate($TitleLike)

    if ($ok) {
        Write-Output "ACTIVATED: $TitleLike"
        exit 0
    }

    # Fallback: enumerate top-level windows and activate the first title match.
    Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class Win {
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

    $hit = [IntPtr]::Zero
    $cb = [Win+EnumWindowsProc]{
        param($hWnd, $lParam)
        if ([Win]::IsWindowVisible($hWnd)) {
            $sb = New-Object System.Text.StringBuilder 512
            [void][Win]::GetWindowText($hWnd, $sb, 512)
            $t = $sb.ToString()
            if ($t -and $t -like "*$TitleLike*") {
                $script:hit = $hWnd
                return $false
            }
        }
        return $true
    }
    [void][Win]::EnumWindows($cb, [IntPtr]::Zero)

    if ($hit -ne [IntPtr]::Zero) {
        [void][Win]::ShowWindow($hit, 9)   # SW_RESTORE
        [void][Win]::SetForegroundWindow($hit)
        Write-Output "ACTIVATED-VIA-ENUM: $TitleLike"
        exit 0
    }

    Write-Output "NOT-FOUND: $TitleLike"
    exit 1
}
catch {
    Write-Output ("ERROR: " + $_.Exception.Message)
    exit 2
}
