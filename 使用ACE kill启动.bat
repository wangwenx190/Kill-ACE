@echo off
set SCRIPT_PATH=%~dp0Ö÷½Å±¾.ps1
powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File ""%SCRIPT_PATH%""' -Verb RunAs"