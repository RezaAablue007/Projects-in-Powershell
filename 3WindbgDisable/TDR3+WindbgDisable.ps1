# Author: Reza Aablue

#Importing S0i3 Regkeys & Windows Maintenance Disable Regkey
$PathofRegFile="C:\TestRes\Ace_H_Set_TDR3_DisableWindbg\TDR3.reg"
regedit /s $PathofRegFile

#Disable WinDBG
bcdedit /debug off

Get-WmiObject -Class Win32_OSRecoveryConfiguration -EnableAllPrivileges |
Set-WmiInstance -Arguments @{ DebugInfoType=1 }
wmic recoveros set AutoReboot = True