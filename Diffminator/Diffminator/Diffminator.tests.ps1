[string]$dp0 = Split-Path -Path $MyInvocation.MyCommand.Path
[string]$dp0Script = $MyInvocation.MyCommand.Definition
[string]$dp0Module = $MyInvocation.MyCommand.Name.Split('.')[0]

#$VerbosePreference = 'SilentlyContinue' 
#$DebugPreference = 'SilentlyContinue' 

### Starting Logging module ###
#Import module for logging
Import-Module -Force LogManagement <# -Verbose -Debug#>
#Configure logging
#[string]$LogPath = "$dp0\logs"
#[string]$BaseLogFileName = "freshserviceadsync-$(Get-Date -Format yyyyMMdd_hhmmss).log"
#[boolean]$OutputToConsole = $True
#Set-LogManagement -LogPath $LogPath -BaseLogFileName $BaseLogFileName -OutputToConsole $OutputToConsole
### End Logging module ###

Import-Module -Force "$dp0\Diffminator.psm1"
#Save-InitialState -jobID $(get-date) -payload $(Get-Process) -filepath "c:\temp\" -filename "DiffminatorTest" | Out-Null
$r = CompareWith-InitialState -jobID $(get-date) -payload $(Get-Process) -filepath "c:\temp\" -filename "DiffminatorTest"
Write-Host -ForegroundColor Magenta "FIN"