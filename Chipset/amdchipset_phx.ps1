## This script installs AMD Chipset driver for APU/CPU products.
## Author: Reza Aablue

#Get the script path
$SCRIPT_PATH = $MyInvocation.MyCommand.Definition.Replace($MyInvocation.MyCommand.Name, "");
$LOCAL_CACHE = "D:\chipset";

#Clean existing chipset installation package from the image
Remove-Item "D:\chipset\*" -ErrorAction SilentlyContinue;

# Initiate result file
$RESULT_FILE = "result.log";
if(Test-Path "$SCRIPT_PATH$RESULT_FILE")
{
    Remove-Item "$SCRIPT_PATH$RESULT_FILE" -ErrorAction SilentlyContinue;
}

function SetResult($status, $actual)
{
    $report = "[STEPS]`r`nNumber=1`r`n";
    $report += "`r`n";
    $report += "[STEP_001]`r`n";
    $report += "Description=Install AMD chipset drivers`r`n";
    $report += "Status=$status`r`n";
    $report += "Actual=$actual`r`n";

    Set-Content "$SCRIPT_PATH$RESULT_FILE" $report;
}

SetResult "N/C" "Installation was not completed.";

# Grabbing the chipset driver from local server

$chipset_src = "Chipset Driver Folder Path"
$CHIPSET_INSTALLER = "AMD_Chipset_Software.exe";

# Check the server
if(Test-Path $chipset_src)
{
    # Only get the most recent files
    $srv_zip = Get-Item -Path "$chipset_src\*.zip" | sort LastWriteTime | select -Last 1;
    $srv_exe = Get-Item -Path "$chipset_src\*.exe" | sort LastWriteTime | select -Last 1;
}
else
{
    $srv_zip = $null;
    $srv_zip = $null;
    Write-Host "Warning: cannot access the share location or found chipset drivers on the server $chipset_src.";
}

# Check local cache the chipset driver to local
if(Test-Path "$LOCAL_CACHE\*.ZIP") # Then there is cached chipset driver
{
    $loc_zip = Get-Item -Path "$LOCAL_CACHE\*.zip" | sort LastWriteTime | select -Last 1;
}
else
{
    $loc_zip = $null;
}

if($srv_zip -and $loc_zip) # Both server and local found chipset drivers
{
    # Compare the LastWriteTime
    if($srv_zip.LastWriteTime -gt $loc_zip.LastWriteTime) # There is a newer chipset driver on server, cache it
    {
        Copy-Item $srv_zip -Destination (New-Item -ItemType Directory "$LOCAL_CACHE" -Force:$true) -Force:$true;
        $loc_zip = Get-Item -Path "$LOCAL_CACHE\*.zip" | sort LastWriteTime | select -Last 1;
    }
}
elseif($srv_exe -and $loc_zip)
{
    # Compare the LastWriteTime
    if($srv_exe.LastWriteTime -gt $loc_zip.LastWriteTime)
    {
        Copy-Item $srv_exe -Destination (New-Item -ItemType Directory "$LOCAL_CACHE" -Force:$true) -Force:$true;
        $loc_zip = Get-Item -Path "$LOCAL_CACHE\*.exe" | sort LastWriteTime | select -Last 1;
    }
}
elseif($srv_zip) # No local cache yet
{
    Copy-Item $srv_zip -Destination (New-Item -ItemType Directory "$LOCAL_CACHE" -Force:$true) -Force:$true;
    $loc_zip = Get-Item -Path "$LOCAL_CACHE\*.zip" | sort LastWriteTime | select -Last 1;
}
elseif($srv_exe) # No local cache yet
{
    Copy-Item $srv_exe -Destination (New-Item -ItemType Directory "$LOCAL_CACHE" -Force:$true) -Force:$true;
    $loc_zip = Get-Item -Path "$LOCAL_CACHE\*.exe" | sort LastWriteTime | select -Last 1;
}
elseif($loc_zip) # Cannot access the server but there is a local copy of chipset, although it might be out of date.
{
    # Do nothing but just use the local cache $loc_zip
}
else # no access to server, nor local copy, report fail and abort
{
    Write-Host "Error: cannot find chipset drivers to install either on server $chipset_src, or in local cache. Report FAIL to exit."; 
    SetResult "FAIL" "Cannot find chipset driver on server or local cache.";
    Exit;
}

# Unzip the chipset drivers
if($srv_zip)
{
    Expand-Archive $loc_zip -DestinationPath $SCRIPT_PATH -Force:$true;
}
# If exe, simply copy
if($srv_exe)
{
    Copy-Item $loc_zip -Destination $SCRIPT_PATH -Force:$true;
}

if($CHIPSET_INSTALLER -eq "AMD_Chipset_Software.exe")
{
    if(Test-Path "$SCRIPT_PATH$CHIPSET_INSTALLER")
    {
        # Install the new chipset drivers in silent mode, and wait until it's finished
        Write-Host "Installing chipset drivers, please wait...";
        Start-Process -FilePath "$SCRIPT_PATH$CHIPSET_INSTALLER" -ArgumentList @('/S') -Wait;
        Write-Host "Installation is completed.";
        SetResult "PASS" "AMD chipset drivers have been installed.";
    }
}
elseif($CHIPSET_INSTALLER -eq "AMD_Chipset_Drivers.exe")
{
    if(Test-Path "$SCRIPT_PATH$CHIPSET_INSTALLER")
    {
        # Install the new chipset drivers in silent mode, and wait until it's finished
        Write-Host "Installing chipset drivers, please wait...";
        Start-Process -FilePath "$SCRIPT_PATH$CHIPSET_INSTALLER" -ArgumentList @('/S', '/V" SILENT=1 /qr"', '/clone_wait') -Wait;
        Write-Host "Installation is completed.";
        SetResult "PASS" "AMD chipset drivers have been installed.";
    }
}
else
{
    Write-Host "Error: cannot find the installer $CHIPSET_INSTALLER under $SCRIPT_PATH. Report FAIL and exit.";
    SetResult "FAIL" "Cannot find the installer $CHIPSET_INSTALLER under $SCRIPT_PATH.";
}

Exit;