#Importing S0i3 Regkeys & Windows Maintenance Disable Regkey
reg import .\SleepStudyReg.reg

#Disables IPV6
Disable-NetAdapterBinding -Name "Ethernet (Kernel Debugger)" -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name "Ethernet 1" -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name "Ethernet 2" -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name "Ethernet 3" -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name "Ethernet 4" -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name "Ethernet (Kernel Debugger)" -ComponentID ms_tcpip6

#Installing Realtek SD Card Reader
New-Item -ItemType Directory -Path C:\TestRes\Ace_R_S0i3_Setup\SD_Card_Reader
robocopy "\\ace-raid\ace-raid\Reza\S0i3 Setup Tools - PHX\RtsPer_10.0.22000.21354_20220222_WHQL_RTD3" "C:\TestRes\Ace_R_S0i3_Setup\SD_Card_Reader"  /E /DCOPY:DAT /R:10 /W:3

cd "C:\TestRes\Ace_R_S0i3_Setup\SD_Card_Reader"
#$wshell = New-Object -ComObject wscript.shell;
Start-Process -FilePath "setup.exe" -ArgumentList "-s" -Wait;

#Start-Sleep -s 90
#$wshell.SendKeys("{ENTER}")

#Installing Realtek Audio Driver for S0i3
New-Item -ItemType Directory -Path C:\TestRes\Ace_R_S0i3_Setup\Audio_Driver
robocopy "\\ace-raid\ace-raid\Reza\S0i3 Setup Tools - PHX\9388.1_UAD_WHQL_2022_0730_001510" "C:\TestRes\Ace_R_S0i3_Setup\Audio_Driver"  /E /DCOPY:DAT /R:10 /W:3

cd "C:\TestRes\Ace_R_S0i3_Setup\Audio_Driver"
#$wshell = New-Object -ComObject wscript.shell;
Start-Process -FilePath "setup.exe" -ArgumentList "-s" -Wait;

#Start-Sleep -s 15
#$wshell.SendKeys("{ENTER}")
#Start-Sleep -s 60
#$wshell.SendKeys("{ENTER}")