@ECHO OFF
rem Empezando correr el script
PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""yt-dlp GUI.ps1""' -Verb RunAs}"
PAUSE