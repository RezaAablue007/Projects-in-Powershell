## Script created for better insight into S0i3 HW and SW DRIPS percentage scores for each sleep cycle, along with other key statistics.
## Author: Reza Aablue, ACE
## Date: July 21 2023

## Previous WA was to copy and paste all content from sleepstudyreport into a text file in the SAME FOLDER PATH, then run the script. 

## July 2023 Update: Script now optimized to work with XML sleepstudy report. WA explained above is no longer needed.

# List of Features to add:

# 1. Average HW and SW DRIPS Scores - DONE
# 2. 1% Low and 1% High HW and SW DRIPS Scores - DONE
# 3. Median HW and SW DRIPS Scores - DONE
# 4. # of HW/SW DRIPS Scores above/below 75% - DONE
# 5. Average Sleep Time Per Cycle (Use LocalTimeStamp Delta between a sleep cycle and the next Active cycle) - DONE
# 6. Top Offenders - print out the High Level ones. - DONE
# 7. Add number of times each top offender shows up in SleepStudyReport - DONE
# 8. Save results to a text file in the debug_logs path of the system - DONE

# Define the path to the text file
[xml]$sleepstudy = Get-Content -Path "\\ace-raid\ace-raid\Debug_logs\2023\07\24\PHX-FP7-3103\sleepstudy-report.xml" -ErrorAction SilentlyContinue;

# Create an array for the HIGH ACTIVITY Top Offenders
    $topBlockers = @();

# Checking if the report does exist, and then XML queries for the sleep cycles and the top offenders
if ($sleepstudy) {
    $cs_instances = $sleepstudy.GetElementsByTagName("ScenarioInstance");
    $cs_blockers = $sleepstudy.GetElementsByTagName("TopBlockers");
    $sw_drips_total = 0;
    $hw_drips_total = 0;

    # Initialize arrays to store HW and SW scores
    $HWArray = @()
    $SWArray = @()

    # Create variables to track sleep time
    $SleepTimeTotal = 0
    $SleepTimeAvg = 0
}

# Making sure there are instances of sleep cycles, and then calculating for HW and SW DRIPS
if ($cs_instances.Count -gt 0) {
    for ($i = 0; $i -lt $cs_instances.Count; $i++) {
        $sw_drips_total += [math]::Round(($cs_instances[$i].LowPowerStateTime / $cs_instances[$i].Duration) * 100, 2);
        $hw_drips_total += [math]::Round(($cs_instances[$i].HwLowPowerStateTime / $cs_instances[$i].Duration) * 100, 2);

        $SWArray += [math]::Round(($cs_instances[$i].LowPowerStateTime / $cs_instances[$i].Duration) * 100, 2);
        $HWArray += [math]::Round(($cs_instances[$i].HwLowPowerStateTime / $cs_instances[$i].Duration) * 100, 2);

        # Get the LocalTimestamp for the current instance
        $temp = Get-Date $cs_instances[$i].LocalTimestamp

        # Get the LocalTimestamp for the previous instance (if available)
        $temp1 = if ($i -gt 0) {
            Get-Date $cs_instances[$i - 1].LocalTimestamp
        } else {
            $temp
        }

        # Calculate the time difference and add it to the total sleep time
        $SleepTimeTotal += ($temp - $temp1).TotalSeconds


        $blockers = $cs_blockers[$i].ChildNodes;
            for($j =0; $j -lt $blockers.Count; $j++)
            {
                if(($blockers[$j].ActivityLevel -eq 'high') -and (-not ($topBlockers -contains $blockers[$j].Name)))
                {
                    $topBlockers += $blockers[$j].Name;
                }
            }


    }

    # Calculation space for all HW/SW DRIPS Scores
    $sw_drips_avg = [math]::Round(($sw_drips_total / $cs_instances.Count), 2);
    $hw_drips_avg = [math]::Round(($hw_drips_total / $cs_instances.Count), 2);

    # Sort the HW and SW arrays
    $SWArray = $SWArray | Sort-Object
    $HWArray = $HWArray | Sort-Object

    # Calculate the indices for the 1% low and 1% high scores
    $lowIndex = [math]::Ceiling($cs_instances.Count * 0.01) - 1
    $highIndex = [math]::Floor($cs_instances.Count * 0.99) - 1

    # Calculate the 1% low and 1% high HW and SW scores
    $swLow = [math]::Round(($SWArray[0..$lowIndex] | Measure-Object -Average).Average, 2)
    $swHigh = [math]::Round(($SWArray[$highIndex..($cs_instances.Count - 1)] | Measure-Object -Average).Average, 2)
    $hwLow = [math]::Round(($HWArray[0..$lowIndex] | Measure-Object -Average).Average, 2)
    $hwHigh = [math]::Round(($HWArray[$highIndex..($cs_instances.Count - 1)] | Measure-Object -Average).Average, 2)

    # Calculate the median of HW and SW scores
    $hwMedian = [math]::Round(($HWArray[$cs_instances.Count / 2] + $HWArray[($cs_instances.Count / 2) - 1]) / 2, 2)
    $swMedian = [math]::Round(($SWArray[$cs_instances.Count / 2] + $SWArray[($cs_instances.Count / 2) - 1]) / 2, 2)

    # Count HW and SW scores above and below 75%
    $hwAbove75 = $HWArray | Where-Object { $_ -gt 75 } | Measure-Object | Select-Object -ExpandProperty Count
    $hwBelow75 = $HWArray | Where-Object { $_ -lt 75 } | Measure-Object | Select-Object -ExpandProperty Count
    $swAbove75 = $SWArray | Where-Object { $_ -gt 75 } | Measure-Object | Select-Object -ExpandProperty Count
    $swBelow75 = $SWArray | Where-Object { $_ -lt 75 } | Measure-Object | Select-Object -ExpandProperty Count

    # Calculate the average sleep time per cycle
    # Subtracting 65 seconds to make sure the active time isn't taken into account
    $SleepTimeAvg = [math]::Round((($SleepTimeTotal / $cs_instances.Count) - 65), 0)

    # Output of S0i3 Analytics
    Write-Host "HW Average: $hw_drips_avg%"
    Write-Host "SW Average: $sw_drips_avg%"

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

    Write-Host "Average Sleep Time Per Cycle: $SleepTimeAvg Seconds"

    Write-Host "List of Top Offenders with High Activity Level from Sleep Study Report:"
    Write-Host $topBlockers[0]
    Write-Host $topBlockers[1]
    Write-Host $topBlockers[2]
    Write-Host $topBlockers[3]
    Write-Host $topBlockers[4]
    Write-Host $topBlockers[5]
    Write-Host $topBlockers[6]
    Write-Host $topBlockers[7]
    Write-Host $topBlockers[8]
    Write-Host $topBlockers[9]
}

# Create a dictionary to store the count of each top offender
$topBlockersCount = @{}

# Making sure there are instances of sleep cycles, and then calculating for HW and SW DRIPS
if ($cs_instances.Count -gt 0) {
    # ... (previous code)

    for ($i = 0; $i -lt $cs_instances.Count; $i++) {
        # ... (previous code)

        $blockers = $cs_blockers[$i].ChildNodes;
        for ($j = 0; $j -lt $blockers.Count; $j++) {
            if (($blockers[$j].ActivityLevel -eq 'high') -and (-not ($topBlockers -contains $blockers[$j].Name))) {
                $topBlockers += $blockers[$j].Name;
            }
        }
    }
}

# Initialize a StringBuilder to store the output content
$outputContent = New-Object System.Text.StringBuilder

# Output of S0i3 Analytics
$outputContent.AppendLine("HW Average: $hw_drips_avg%")
$outputContent.AppendLine("SW Average: $sw_drips_avg%")
$outputContent.AppendLine("HW DRIPS scores' 1% Low: $hwLow%")
$outputContent.AppendLine("HW DRIPS scores' 1% High: $hwHigh%")
$outputContent.AppendLine("SW DRIPS scores' 1% Low: $swLow%")
$outputContent.AppendLine("SW DRIPS scores' 1% High: $swHigh%")
$outputContent.AppendLine("HW DRIPS scores' Median: $hwMedian%")
$outputContent.AppendLine("SW DRIPS scores' Median: $swMedian%")
$outputContent.AppendLine("Number of HW DRIPS scores above 75%: $hwAbove75")
$outputContent.AppendLine("Number of HW DRIPS scores below 75%: $hwBelow75")
$outputContent.AppendLine("Number of SW DRIPS scores above 75%: $swAbove75")
$outputContent.AppendLine("Number of SW DRIPS scores below 75%: $swBelow75")
$outputContent.AppendLine("Average Sleep Time Per Cycle: $SleepTimeAvg Seconds")
$outputContent.AppendLine("List of Top Offenders with High Activity Level from Sleep Study Report:")
$outputContent.AppendLine($topBlockers[0])
$outputContent.AppendLine($topBlockers[1])
$outputContent.AppendLine($topBlockers[2])
$outputContent.AppendLine($topBlockers[3])
$outputContent.AppendLine($topBlockers[4])
$outputContent.AppendLine($topBlockers[5])
$outputContent.AppendLine($topBlockers[6])
$outputContent.AppendLine($topBlockers[7])
$outputContent.AppendLine($topBlockers[8])
$outputContent.AppendLine($topBlockers[9])

    for ($i = 0; $i -lt $topBlockers.Count; $i++) {
        $topOffenderName = $topBlockers[$i]
        $topBlockersCount[$topOffenderName] = 0
        for ($j = 0; $j -lt $cs_instances.Count; $j++) {
            $blockers = $cs_blockers[$j].ChildNodes;
            for ($k = 0; $k -lt $blockers.Count; $k++) {
                if ($blockers[$k].Name -eq $topOffenderName) {
                    $topBlockersCount[$topOffenderName]++
                }
            }
        }
        Write-Host "Number of times $topOffenderName is active in report: $($topBlockersCount[$topOffenderName]) times"
        $outputContent.AppendLine("Number of times $topOffenderName is active in report: $($topBlockersCount[$topOffenderName]) times")
    }

# Generate the full path for the output text file
$outputFileName = "SleepStudyResults.txt"
$outputFilePath = Join-Path -Path "\\ace-raid\ace-raid\Debug_logs\2023\07\24\PHX-FP7-3103" -ChildPath $outputFileName

# Save the output content to the new text file
$outputContent.ToString() | Out-File -FilePath $outputFilePath

Write-Host "Results have been saved to: $outputFilePath"