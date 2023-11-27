<#
.NOTES
Defender_RESPONSE.ps1
doug.metz@magnetforensics.com
v1.1

.SYNOPSIS
This script can be used to leverage Magnet RESPONSE and the Microsoft Defender for Endpoint Live Response console to capture triage collections on remote endpoints.

Prerequisites:
- Defender Live Response Console - upload MagnetRESPONSE.exe to the Library
- Defender Live Response Console - upload Defender_RESPONSE.ps1 to the Library

Operation:
1. 'connect' to endpoint in Live Response // establish connection with the endpoint
2. 'put MagnetRESPONSE.exe' // copies the exe to the target system
3. 'run Defender_RESPONSE.ps1' // where the magic happens

Retrieving the Data:

    Once the script has finished running, the zipped output will be saved at the location “C:\Temp\RESPONSE” on the remote machine.

    * 	Navigate to output folder using command — cd c:\Temp\RESPONSE
    * 	List files using “dir” command
    * 	Copy the zip filename <filename.zip>
    *   After the output filename is copied, collect the output by downloading it from the remote machine to your local system using the “Download” command. Download <filename.zip> &

#>
Write-Host ""
Write-Host  "Magnet RESPONSE v1.7
$([char]0x00A9)2021-2023 Magnet Forensics, LLC
"
$OS = $(((gcim Win32_OperatingSystem -ComputerName $server.Name).Name).split('|')[0])
$arch = (get-wmiobject win32_operatingsystem).osarchitecture
$name = (get-wmiobject win32_operatingsystem).csname
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-host  "
Hostname: $name
Operating System: $OS
Architecture: $arch
"
./MagnetRESPONSE.exe /accepteula /unattended /output:C:\temp\RESPONSE /caseref:DefenderRESPONSE /captureram
Write-Host  "[Collecting Arifacts]"
Wait-Process -name "MagnetRESPONSE"
$null = $stopwatch.Elapsed
$Minutes = $StopWatch.Elapsed.Minutes
$Seconds = $StopWatch.Elapsed.Seconds
Write-Host  "** Acquisition Completed in $Minutes minutes and $Seconds seconds.**"
