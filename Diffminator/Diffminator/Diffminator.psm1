<#
 Author				:			Nicolas Belanger

 FileName			:			Diffminator.ps1

 Description		:			Entry point for Diffminator Scripts

 Creation Date		:			2016-05-05

 Modification Date	:			2016-05-05
#>

Set-StrictMode -Version Latest

[string]$dp0 = Split-Path -Path $MyInvocation.MyCommand.Path
[string]$dp0Script = $MyInvocation.MyCommand.Definition
[string]$dp0Module = $MyInvocation.MyCommand.Name.Split('.')[0]

#$VerbosePreference = 'SilentlyContinue' 
#$DebugPreference = 'SilentlyContinue' 

[String] $Results = ""

### Starting Logging module ###
#Import module for logging
Import-Module -Force "$dp0\0_Modules\LogManagement\LogManagement.psm1" <# -Verbose -Debug#>
#Configure logging
[string]$LogPath = "$dp0\logs"
[string]$BaseLogFileName = "azureDiffminator-$(Get-Date -Format yyyyMMdd_hhmmss).log"
[boolean]$OutputToConsole = $False
Set-LogManagement -LogPath $LogPath -BaseLogFileName $BaseLogFileName -OutputToConsole $OutputToConsole
### End Logging module ###

#Start Transcript to have all output, maybe will be removed to only use LogManagement
[string]$TranscriptPath = "$dp0\logs\azureDiffminator-$(Get-Date -Format yyyyMMdd_hhmmss).txt"
Start-Transcript -Path $TranscriptPath

#Loading configuration
[System.Xml.XmlDocument]$Configuration = Get-Content "$dp0\Settings.xml"
#[System.Xml.XmlElement]$DomainControllers = $Configuration.Settings.DomainControllers
#[System.Xml.XmlElement]$SearchBases = $Configuration.Settings.OUs

#### Import Needed Modules ####
#Importing module Orckestra.Menu for generating user's menu
#Import-Module -Force "$dp0\0_Modules\Orckestra.Menu\Orckestra.Menu.psm1" <# -Verbose -Debug#>
### End Import Module ####


Log-Normal $Results

#Send logs by email
Email-Logs

Stop-Transcript