## Script created for better insight into S0i3 HW and SW DRIPS percentage scores for each sleep cycle.
## Author: Reza Aablue, ACE
## Date: May 24 2023

## Curent WA is to copy and paste all content from sleepstudyreport into a text file in the SAME FOLDER PATH. 
## Then, you can run this script to get the statistics from the report's results.

## July 2023 Update: Script now optimized to work with XML sleepstudy report. WA explained above is no longer needed.

# Define the path to the text file
$filePath = "\\ace-raid\ace-raid\Debug_logs\2023\07\20\PHX-FP8-3503\sleepstudy-report.txt"

# Read the content of the file
$fileContent = Get-Content -Path $filePath -Raw

# Added feature to check Average Sleep Time Per Cycle
$sleepCount = 0
$sleepTimeTotal = 0

# Check if the file exists
if (Test-Path $filePath) {
    # Read the file and search for lines with the word "Sleep"
    $lines = Get-Content $filePath
    for ($i = 1; $i -lt $lines.Count; $i++) {
        $currentLine = $lines[$i]
        $previousLine = $lines[$i - 1]

        if ($currentLine -match "Sleep" -and $previousLine -match "(\d):(\d{2}):(\d{2})") {
            $hours = [int]$Matches[1]
            $minutes = [int]$Matches[2]
            $seconds = [int]$Matches[3]

            $sleepCount++
            $sleepTimeTotal += ($hours * 3600) + ($minutes * 60) + $seconds
        }
    }

    $sleepTimePerCycleAvg = 0
    if ($sleepCount -ne 0) {
        $sleepTimePerCycleAvg = $sleepTimeTotal / $sleepCount
    }

    # Convert average sleep time per cycle to minutes and seconds format
    $avgMinutes = [math]::floor($sleepTimePerCycleAvg / 60.00)
    $avgSeconds = [int]($sleepTimePerCycleAvg % 60)

    Write-Output "Number of cycles Completed: $sleepCount Cycles"
    Write-Output "Average Sleep Time Per Cycle: $avgMinutes minutes and $avgSeconds seconds"
}
else {
    Write-Output "File not found: $filePath"
}

# Search for scores in the file content
$scorePattern = "(?<=SW: )(\d+)%.*?(?<=HW: )(\d+)%"
$scores = [regex]::Matches($fileContent, $scorePattern)

# Check if scores are found
if ($scores.Count -eq 0) {
    Write-Host "No scores found in the file."
}
else {
    # Initialize variables to store the total scores and the count of scores
    $swTotal = 0
    $hwTotal = 0
    $scoreCount = 0

    # Initialize arrays to store HW and SW scores
    $HWArray = @()
    $SWArray = @()

    # Loop through the matched scores, calculate the total and count,
    # and populate the HW and SW arrays
    foreach ($score in $scores) {
        $sw = $score.Groups[1].Value
        $hw = $score.Groups[2].Value

        $swTotal += [int]$sw
        $hwTotal += [int]$hw
        $scoreCount++

        $SWArray += [int]$sw
        $HWArray += [int]$hw
    }

    # Sort the HW and SW arrays
    $SWArray = $SWArray | Sort-Object
    $HWArray = $HWArray | Sort-Object

    # Calculate the indices for the 1% low and 1% high scores
    $lowIndex = [math]::Ceiling($scoreCount * 0.01) - 1
    $highIndex = [math]::Floor($scoreCount * 0.99) - 1

    # Calculate the 1% low and 1% high HW and SW scores
    $swLow = [math]::Round(($SWArray[0..$lowIndex] | Measure-Object -Average).Average, 2)
    $swHigh = [math]::Round(($SWArray[$highIndex..($scoreCount - 1)] | Measure-Object -Average).Average, 2)
    $hwLow = [math]::Round(($HWArray[0..$lowIndex] | Measure-Object -Average).Average, 2)
    $hwHigh = [math]::Round(($HWArray[$highIndex..($scoreCount - 1)] | Measure-Object -Average).Average, 2)

    # Calculate the median of HW and SW scores
    $hwMedian = [math]::Round(($HWArray[$scoreCount / 2] + $HWArray[($scoreCount / 2) - 1]) / 2, 2)
    $swMedian = [math]::Round(($SWArray[$scoreCount / 2] + $SWArray[($scoreCount / 2) - 1]) / 2, 2)

    # Calculate the average scores
    $swAverage = [math]::Round($swTotal / $scoreCount, 2)
    $hwAverage = [math]::Round($hwTotal / $scoreCount, 2)

    # Count HW and SW scores above and below 75%
    $hwAbove75 = $HWArray | Where-Object { $_ -gt 75 } | Measure-Object | Select-Object -ExpandProperty Count
    $hwBelow75 = $HWArray | Where-Object { $_ -lt 75 } | Measure-Object | Select-Object -ExpandProperty Count
    $swAbove75 = $SWArray | Where-Object { $_ -gt 75 } | Measure-Object | Select-Object -ExpandProperty Count
    $swBelow75 = $SWArray | Where-Object { $_ -lt 75 } | Measure-Object | Select-Object -ExpandProperty Count

    # Display the other calculations and statistics
    Write-Host "HW Average: $hwAverage%"
    Write-Host "SW Average: $swAverage%"

    Write-Host "HW DRIPS scores' 1% Low: $hwLow%"
    Write-Host "HW DRIPS scores' 1% High: $hwHigh%"
    Write-Host "SW DRIPS scores' 1% Low: $swLow%"
    Write-Host "SW DRIPS scores' 1% High: $swHigh%"

    Write-Host "HW DRIPS scores' Median: $hwMedian%"
    Write-Host "SW DRIPS scores' Median: $swMedian%"

    Write-Host "Number of HW DRIPS scores above 75%: $hwAbove75"
    Write-Host "Number of HW DRIPS scores below 75%: $hwBelow75"
    Write-Host "Number of SW DRIPS scores above 75%: $swAbove75"
    Write-Host "Number of SW DRIPS scores below 75%: $swBelow75"
}



## Feedback Area/Next features to implement


# Overall Tierlist of top offenders with % Active Time per cycle on average.

# Count the # of cycles that each offender showed up the sleepstudy report.












