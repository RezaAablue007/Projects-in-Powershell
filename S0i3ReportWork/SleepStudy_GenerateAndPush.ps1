#Author: Reza Aablue (Referenced code fragments from Majd Alber and Harkirat Gill)

# This script generates the sleepstudyreport from an SUT for a particular time duration (which can be changed), and then
# pushes the sleepstudy reports (in XML and HTML formats) to ACE RAID in the Debug Logs folder.

# Can be modified by user. Sets the duration for which the sleepstudyreport is generated.
$durationInDays = 3

# Generate sleep study data in XML format for the specified duration
$XMLReportPath = "C:\Users\TACCUSER\Desktop\LogCollector\sleepstudy-report.xml"
& powercfg /sleepstudy /duration $durationInDays /xml /output $XMLReportPath

# Transform the XML report into an HTML report
$HTMLReportPath = "C:\Users\TACCUSER\Desktop\LogCollector\sleepstudy-report.html"
& powercfg /sleepstudy /transformxml $XMLReportPath /output $HTMLReportPath

# Process of "pushing" the sleepstudyreports to ACE RAID.

# Grabbing the system name locally from the SUT, along with the current year, month, and day.
$SystemName = $env:COMPUTERNAME
$Month = (Get-Date -UFormat "%m")
$Day = (Get-Date -UFormat "%d")
$Year = (Get-Date -UFormat "%Y")

# Enable the network adapter
Get-NetAdapter -Name Ethernet | Enable-NetAdapter

# Create a directory on ACE RAID for the logs
$LogDirectory = "\\ace-raid\ACE-RAID\Debug_logs\$Year\$Month\$Day\$SystemName"

# Create the directory if it does not exist
if (!(Test-Path $LogDirectory -PathType Container)) {
    New-Item -Path $LogDirectory -ItemType Directory -Force
}

# Copy both the XML and HTML reports to the network location without creating the extra subfolder
Get-ChildItem C:\Users\TACCUSER\Desktop\LogCollector -Filter *.html | Copy-Item -Destination \\ace-raid\ACE-RAID\Debug_logs\$Year\$Month\$Day\$SystemName -Force -PassThru
Get-ChildItem C:\Users\TACCUSER\Desktop\LogCollector -Filter *.xml | Copy-Item -Destination \\ace-raid\ACE-RAID\Debug_logs\$Year\$Month\$Day\$SystemName -Force -PassThru