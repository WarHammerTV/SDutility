## Script for running clean up tools 

param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

'running with full privileges'


 ## Defining scans

$sfc = sfc /scannow 
$dism1 = dism /online /cleanup-image /checkhealth
$dism2 = dism /online /cleanup-image /restorehealth

## Selecting the right scan function

Function Select-Scan
{
 Write-Host "3 options:"
 Write-Host "sfc"
 Write-Host "dism check"
 Write-Host "dism restore"
$input = Read-Host "Please enter the correct scan"

if ( $input -eq "sfc")
{ $sfc 
}
elseif ( $input -eq "dism check" )
{$dism1
}
elseif ($input -eq "dism restore")
{$dism2
}
else 
{
Write-host "scan not recognised please try again" 
}

}

## Gather IP function
function gather-ip
{

New-Item -ItemType "directory" -Path "C:\Scaninfo"

Get-NetIPConfiguration | out-file -filepath "C:\Scaninfo\ipconfig.txt."
Test-NetConnection -TraceRoute | out-file -filepath "C:\Scaninfo\tracert.txt"
Test-NetConnection | out-file -filepath "C:\Scaninfo\ping.txt"
Resolve-DnsName www.google.com| out-file -filepath "C:\Scaninfo\test.txt" 

Invoke-Item -path "C:\Scaninfo\*.txt"
}

#Get system info function

function Get-cmptinfo
{

$computerSystem = Get-CimInstance CIM_ComputerSystem
$computerBIOS = Get-CimInstance CIM_BIOSElement
$computerOS = Get-CimInstance CIM_OperatingSystem
$computerCPU = Get-CimInstance CIM_Processor
$computerHDD = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = 'C:'"
Clear-Host

Write-Host "System Information for: " $computerSystem.Name -BackgroundColor DarkCyan
"Manufacturer: " + $computerSystem.Manufacturer
"Model: " + $computerSystem.Model
"Serial Number: " + $computerBIOS.SerialNumber
"CPU: " + $computerCPU.Name
"HDD Capacity: "  + "{0:N2}" -f ($computerHDD.Size/1GB) + "GB"
"HDD Space: " + "{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size) + " Free (" + "{0:N2}" -f ($computerHDD.FreeSpace/1GB) + "GB)"
"RAM: " + "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB) + "GB"
"Operating System: " + $computerOS.caption + ", Service Pack: " + $computerOS.ServicePackMajorVersion
"User logged In: " + $computerSystem.UserName
"Last Reboot: " + $computerOS.LastBootUpTime
}

## Network reset function

function net-reset {
ipconfig /release
ipconfig /renew 



}

# menu creation

function Show-Menu
{
    param (
        [string]$Title = 'What would you like to run'
    )
    Clear-Host
    Write-Host "================ $Title ================" -BackgroundColor White -ForegroundColor Black
    
    Write-Host "1: Press '1' for repair scans." -BackgroundColor White -ForegroundColor Black
    Write-Host "2: Press '2' for ip info." -BackgroundColor White -ForegroundColor Black
    Write-Host "3: Press '3' for system info." -BackgroundColor White -ForegroundColor Black
    Write-Host "3: Press '4' for network reset" -BackgroundColor White -ForegroundColor Black
    Write-Host "Q: Press 'Q' to quit." -BackgroundColor White -ForegroundColor Red
}

## menu config

do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection" 
     switch ($selection)
     {
         '1' {
             Select-Scan
         } '2' {
             gather-ip
         } '3' {
             Get-cmptinfo
         }
         '4' {
             net-reset
         }
     }
     pause
 }
 until ($selection -eq 'q')
