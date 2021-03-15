## Script for running clean up tools 

#set-policy

$executepolicy = Get-ExecutionPolicy

Set-ExecutionPolicy -ExecutionPolicy Unrestricted


##Elevate the script


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


##Windows 10 scan function/menu
 function scan-win10 {

function win-scan
{
    param (
        [string]$Title = 'Windows Scans'
    )
    Clear-Host
    Write-Host "================ $Title ================" -BackgroundColor White -ForegroundColor Black
    
    Write-Host "1: Press '1' for SFC." -BackgroundColor White -ForegroundColor Black
    Write-Host "2: Press '2' DISM Check." -BackgroundColor White -ForegroundColor Black
    Write-Host "3: Press '3' for DISM Restore." -BackgroundColor White -ForegroundColor Black
    Write-Host "Q: Press 'Q' to quit." -BackgroundColor White -ForegroundColor Red
}

do
 {
     win-scan
     $selection = Read-Host "Please make a selection" 
     switch ($selection)
     {
         '1' {
             sfc /scannow 
         } '2' {
             dism /online /cleanup-image /checkhealth
         } '3' {
             dism /online /cleanup-image /restorehealth
         }
         
     }
     pause
 }
 until ($selection -eq 'q')
 }

 ##IP scans menu/config 

Function ip-infoo {function IP-Menu
{
    param (
        [string]$Title = 'Select IP Information'
    )
    Clear-Host
    Write-Host "================ $Title ================" -BackgroundColor White -ForegroundColor Black
    
    Write-Host "1: Press '1' for IP Config." -BackgroundColor White -ForegroundColor Black
    Write-Host "2: Press '2' Trace Route." -BackgroundColor White -ForegroundColor Black
    Write-Host "3: Press '3' for Test Connection." -BackgroundColor White -ForegroundColor Black
    Write-Host "4: Press '4' for Test DNS" -BackgroundColor White -ForegroundColor Black
    Write-Host "Q: Press 'Q' to quit." -BackgroundColor White -ForegroundColor Red
}

do
 {
     IP-Menu
     $selection = Read-Host "Please make a selection" 
     switch ($selection)
     {
         '1' {
             Get-NetIPConfiguration
         } '2' {
             Test-NetConnection -TraceRoute
         } '3' {
             Test-NetConnection
         }
         '4' {
             Resolve-DnsName www.google.com
         }
     }
     pause
 }
 until ($selection -eq 'q')
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
    Write-Host "4: Press '4' for network reset" -BackgroundColor White -ForegroundColor Black
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
             scan-win10 
         } '2' {
             ip-infoo
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
 
 Function exit-clean{
 Write-Host "Would you like to reset the execution policy?" 
 $input = Read-Host "Y/N"
if ($input -eq "y")
{Set-ExecutionPolicy -ExecutionPolicy $executepolicy}
else { exit 
}
}