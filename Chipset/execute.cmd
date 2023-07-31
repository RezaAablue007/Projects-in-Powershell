powershell Set-ExecutionPolicy -Scope CurrentUser Unrestricted
REM start powershell -WindowStyle Hidden %~dp0amdchipset_phx.ps1
REM start powershell %~dp0amdchipset_phx.ps1
powershell ".\amdchipset_phx.ps1"
rem cmd shutdown /r
