cd C:\TestRes\Ace_H_VBIOSFlash
amdvbflash.exe -p 0 "vBIOS name.sbin" -fa -fp -fs -fv
SLEEP 100
amdvbflash.exe -p 1 "vBIOS name.sbin" -fa -fp -fs -fv
