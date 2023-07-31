# Author: Reza Aablue

echo "Setup TDRLevel =1; Working"
#Importing S0i3 Regkeys & Windows Maintenance Disable Regkey
$PathofRegFile="C:\TestRes\Ace_H_Set_TDR1_EnableWindbg\TDR1.reg"
regedit /s $PathofRegFile

#Disable WinDBG
echo "Setup winDBG Enable; Working"
bcdedit /debug on

Get-WmiObject -Class Win32_OSRecoveryConfiguration -EnableAllPrivileges |
Set-WmiInstance -Arguments @{ DebugInfoType=1 }
wmic recoveros set AutoReboot = False


Function Get-BusFunctionID { 

    gwmi -namespace root\cimv2 -class Win32_PnPEntity |% {

        if ($_.PNPDeviceID -like "PCI\*") {

            $locationInfo = $_.GetDeviceProperties('DEVPKEY_Device_LocationInfo').deviceProperties.Data

            if ($locationInfo -match 'PCI bus (\d+), device (\d+), function (\d+)') {

                new-object psobject -property @{ 
                    "Name"       = $_.Name
                    "PnPID"      = $_.PNPDeviceID
                    "BusID"      = $matches[1]
                    "DeviceID"   = $matches[2]
                    "FunctionID" = $matches[3]
                }
            }
        }
    }
} 
echo "Setup winDBG Params; Working"
[String[]]$list = "Intel(R) Ethernet Server Adapter I210-T1", "Intel(R) Ethernet Server Adapter I210-T1 #2", "Realtek PCIe GbE Family Controller", "Intel(R) Ethernet I210-T1 GbE NIC"
$deviceList = Get-BusFunctionID
foreach ($Device in $deviceList){
    foreach ($EthernetAdapter in $list){
        if ($Device.Name -eq $EthernetAdapter){
            $b = $Device.BusID
            $d = $Device.DeviceID
            $f = $Device.FunctionID
            Write-Output "$b.$d.$f"
            bcdedit /set "{dbgsettings}" busparams "$b.$d.$f"
        }
    }
}


echo "Setup winDBG, working"
$string = $env:computername | Select-Object
#$string = "CZ-FP6-1265"
$string = $string.substring($string.Length-4,4)
$string = $string -replace "\D+"
$string = $string.Insert(0, "5")
    
if($string.Length -eq 5){
    if($string -In 50001..50999) {#bench one
            $host_name = "10.6.206.230"
    
    }elseif($string -In 51000..51399) {#bench one
            $host_name = "10.6.255.1"

    }elseif($string -In 51400..51999){
            $host_name = "10.6.255.12"

    }elseif($string -In 52000..52399){#bench two
            $host_name = "10.6.205.61" #DBG-B2-123
    }elseif($string -In 52400..52999){
            $host_name = "10.6.206.36" #DBG-B2-456

    }elseif($string -In 53000..53399){#bench three
            $host_name = "10.6.205.80"#DBG-B3-456
    }elseif($string -In 53400..53999){
            $host_name = "10.6.205.80"#DBG-B3-456

    }elseif($string -In 54000..54399){#bench four
            $host_name = "10.6.207.124" #DBG-B4-1
    }elseif($string -In 54400..54999){
            $host_name = "10.6.207.124" #DBG-B4-1

    }elseif($string -In 55000..55399){#bench five
            $host_name = "10.6.205.78"
    }elseif($string -In 55400..55999){
            $host_name = "10.6.205.78"

    }elseif($string -In 56000..56399){#bench six
            $host_name = "10.6.206.230" #ACE-DBG-NV2X
    }elseif($string -In 56400..56999){
            $host_name = "10.6.206.230" #ACE-DBG-NV2X

    }elseif($string -In 57000..57399){#bench 7
            $host_name = "10.6.206.230" #ACE-DBG-NV2X
    }elseif($string -In 57400..57999){
            $host_name = "10.6.206.230" #ACE-DBG-NV2X
    }

    elseif($string -In 58000..58999){
            $host_name = "10.6.206.230" #ACE-DBG-NV2X
    }
    elseif($string -In 59000..59999){
            $host_name = "10.6.206.230" #ACE-DBG-NV2X
    }
}
#adding section for first partner lab
#all systems in there have 3 numbers not 4.
elseif($string.Length -eq 4){
    $string = $string.Insert(0, "5")

    if     ($string -In 55101..55199) {#bench one
            $host_name = "10.6.255.255" # DBG-FPL-B1
    
    }elseif($string -In 55200..55299) {#bench two
            $host_name = "10.6.255.224" # DBG-FPL-B2

    }elseif($string -In 55300..55399){#bench three
            $host_name = "10.6.255.227" # DBG-FPL-B3

    }elseif($string -In 55400..55499){#bench fore
            $host_name = "10.6.205.61" # DBG-FPL-B4
    }
}

bcdedit /dbgsettings NET HOSTIP:$host_name PORT:$string KEY:1.2.3.4
bcdedit /debug on