## Installs Realtek Drivers for Phoenix CRB
## Author: Reza Aablue, ACE
## Date: January 4 2023

# Creating TEMP folder and copying Realtek driver to TEMP
New-item -Name TEMP -Type Directory -Path C:\
New-Item -ItemType Directory -Path C:\Testres\Ace_R_Realtek_Install\Ethernet_Driver
robocopy "\\ace-raid\ACE-RAID\Reza\S0i3 Setup Tools - PHX\ALL_INST_DASHNICs_NCX11005_WHQL_DASH_5.1.2.2201_20220209_RC5" "C:\TestRes\Ace_R_Realtek_Install\Ethernet_Driver" /E /DCOPY:DAT /R:10 /W:3

# Installing SETUP.exe from Realtek driver package
cd "C:\Testres\Ace_R_Realtek_Install\Ethernet_Driver"
#$wshell = New-Object -ComObject wscript.shell;
Start-Process -FilePath "setup.exe" -ArgumentList "-s" -Wait;



#Start-Sleep -s 20
#$wshell.SendKeys("{ENTER}")
#Start-Sleep -s 10
#$wshell.SendKeys("{ENTER}")
#Start-Sleep -s 10
#$wshell.SendKeys("{ENTER}")
#Start-Sleep -s 600
#$wshell.SendKeys("{ENTER}")