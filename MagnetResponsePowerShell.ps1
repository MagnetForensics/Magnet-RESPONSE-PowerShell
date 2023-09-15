<#

Magnet RESPONSE PowerShell Enterprise
doug.metz@magnetforensics.com
ver 1.7

The script first checks if it is running with administrative permissions and exits if not. 
The script will then download Magnet RESPONSE from a web server, extract it, and run with the specified options.

The $outputpath parameter can be used to write to a local directory `C:Temp`, `D:\Output` or network `\\Server\Share`.

Finally, the script removes the downloaded Magnet RESPONSE files and prints the time taken for the collection 
and transfer to complete.

#>
param ([switch]$Elevated)
function Test-Admin {
        $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
        $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false) {
        if ($elevated) {
        } else {
                Write-host ""
                Write-host  "Magnet RESPONSE requires Admin permissions. 
Exiting.
"
}
exit
}
### VARIABLE SETUP
$caseID = "INC-8675309" # no spaces
$outputpath = "\\server\share" # Update to reflect output destination. C:\Temp R:\Output \\Server\Share
$server = "192.168.1.10" # "192.168.1.10" resolves to http://192.168.1.10/MagnetRESPONSE.zip
<#
### COLLECION PROFILE - Uncomment the collection type to be used:
#>
#### Quick Sweep
<#
$profileName = "QUICK SWEEP"
$arguments = "/capturevolatile /captureextendedprocessinfo"
#>
#### Capture Volatile

$profileName = "CAPTURE VOLATILE"
$arguments = "/capturevolatile"
#>
#### Capture Volatile & RAM
<#
$profileName = "CAPTURE VOLATILE & RAM"
$arguments = "/captureram /capturevolatile"
#>
#### Extended Process Capture
<#
$profileName = "EXTENDED PROCESS CAPTURE"
$arguments = "/capturevolatile /captureextendedprocessinfo /saveprocfiles"
#>
#### Systen Files
<#
$profileName = "SYSTEM FILES"
$arguments = "/capturesystemfiles" 
#>
#### Just RAM
<#
$profileName = "CAPTURE RAM"
$arguments = "/captureram" 
#>
#### Magnet TRIAGE
<#
$profileName = "Magnet TRIAGE"
$arguments = "/captureram /capturevolatile /capturesystemfiles /captureextendedprocessinfo" 
#>
#### Full Capture
<#
$profileName = "FULL CAPTURE"
$arguments = "/captureram /capturepagefile /capturevolatile /capturesystemfiles /captureextendedprocessinfo /saveprocfiles"
#>
#### Kitchen Sink
<#
$profileName = "KITCHEN SINK"
$arguments = "/captureram /capturepagefile /capturevolatile /capturesystemfiles /captureextendedprocessinfo /saveprocfiles /capturefiles:.ps1,.vbs,confidential /skipsystemfolders /maxsize:500  /captureransomnotes"
#>
#### End of Collection Profiles
Clear-Host
Write-Host ""
$tstamp = (Get-Date -Format "yyyyMMddHHmm")
$global:progressPreference = 'silentlyContinue'
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
[console]::ForegroundColor="DarkCyan"
Write-Host  "Downloading Magnet RESPONSE"
Invoke-WebRequest -Uri http://$server/MagnetRESPONSE.zip -OutFile .\MagnetRESPONSE.zip
Expand-Archive -Path .\MagnetRESPONSE.zip
Remove-Item .\MagnetRESPONSE.zip
Clear-Host
Write-Host ""
Write-Host  "Magnet RESPONSE v1.7
$([char]0x00A9)2021-2023 Magnet Forensics Inc
"
$OS = $(((gcim Win32_OperatingSystem -ComputerName $server.Name).Name).split('|')[0])
$arch = (get-wmiobject win32_operatingsystem).osarchitecture
$name = (get-wmiobject win32_operatingsystem).csname
Write-Host  "
Selected Profile: $profileName"
if (Test-Path -Path $outputpath) {
    Write-host  "Output directory: $outputpath"
} else {
    Write-host  "Specified output path does not exist.
    "
exit
}
Write-host  "
Hostname: $name
Operating System: $OS
Architecture: $arch
"
MagnetRESPONSE\MagnetRESPONSE.exe /accepteula /unattended /output:$outputpath/$caseID-$env:ComputerName-$tstamp /caseref:$caseID $arguments
Write-Host  "[Collecting Arifacts]"
Wait-Process -name "MagnetRESPONSE"
$null = $stopwatch.Elapsed
$Minutes = $StopWatch.Elapsed.Minutes
$Seconds = $StopWatch.Elapsed.Seconds
Write-Host  "** Acquisition Completed in $Minutes minutes and $Seconds seconds.**
"
Remove-Item "MagnetRESPONSE\" -Recurse -Confirm:$false -Force
Write-Host  "Operations Complete.
"