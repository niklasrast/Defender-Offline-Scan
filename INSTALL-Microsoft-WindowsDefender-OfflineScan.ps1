<#
    .SYNOPSIS 
    Windows 10 Software packaging wrapper

    .DESCRIPTION
    Install:   C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-Microsoft-WindowsDefender-OfflineScan.ps1 -install
    Uninstall: C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\INSTALL-Microsoft-WindowsDefender-OfflineScan.ps1 -uninstall
    
    .ENVIRONMENT
    PowerShell 5.0
    
    .AUTHOR
    Niklas Rast
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ParameterSetName = 'install')]
	[switch]$install,
	[Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
	[switch]$uninstall
)

$ErrorActionPreference = "SilentlyContinue"
#Use "C:\Windows\Logs" for System Installs and "$env:TEMP" for User Installs
$logFile = ('{0}\{1}.log' -f "C:\Windows\Logs", [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))

#Test if registry folder exists
if ($true -ne (test-Path -Path "HKLM:\SOFTWARE\COMPANY")) {
    New-Item -Path "HKLM:\SOFTWARE\" -Name "COMPANY" -Force
}

if ($install)
{
    Start-Transcript -path $logFile -Append
        try
        {   
            #test if key folder exists
            if ($true -eq (test-Path -Path "HKLM:\SOFTWARE\COMPANY\Microsoft-WindowsDefender-OfflineScan")) {
        
             return $true
            }

            else {

            #Register package in registry
            New-Item -Path "HKLM:\SOFTWARE\COMPANY\" -Name "Microsoft-WindowsDefender-OfflineScan"
            New-ItemProperty -Path "HKLM:\SOFTWARE\COMPANY\Microsoft-WindowsDefender-OfflineScan" -Name "Version" -PropertyType "String" -Value "1.0.0" -Force
            

            #Start Offline Scan
            Start-MpWDOScan
            }

            return $true        
        } 
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}

if ($uninstall)
{
    Start-Transcript -path $logFile -Append
        try
        {

            #Remove package registration in registry
            Remove-Item -Path "HKLM:\SOFTWARE\COMPANY\Microsoft-WindowsDefender-OfflineScan" -Recurse -Force 

            return $true     
        }
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}
