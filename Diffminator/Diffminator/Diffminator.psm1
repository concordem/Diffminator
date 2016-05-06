<#
 Author				:			Nicolas Belanger

 FileName			:			Diffminator.ps1

 Description		:			Entry point for Diffminator Module

 Creation Date		:			2016-05-05

 Modification Date	:			2016-05-06
#>

Set-StrictMode -Version Latest

[string]$dp0 = Split-Path -Path $MyInvocation.MyCommand.Path
[string]$dp0Script = $MyInvocation.MyCommand.Definition
[string]$dp0Module = $MyInvocation.MyCommand.Name.Split('.')[0]

#$VerbosePreference = 'SilentlyContinue' 
#$DebugPreference = 'SilentlyContinue' 



#### Import Needed Modules ####
#Importing module Orckestra.Menu for generating user's menu
#Import-Module -Force "$dp0\0_Modules\Orckestra.Menu\Orckestra.Menu.psm1" <# -Verbose -Debug#>
### End Import Module ####
