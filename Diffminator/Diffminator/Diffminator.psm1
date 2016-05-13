#Requires -Version 4
#Requires -Modules Logmanagement

<#
 Author				:			Nicolas Belanger

 FileName			:			Diffminator.ps1

 Description		:			Entry point for Diffminator Module
								****For the time being, all classes are in the current file because Powershell
								does not support exploding class hierarchy in multiple file outside a module file :
								http://powershell.org/wp/forums/topic/dsc-custom-resource-using-classes-each-class-in-separate-file/
																and
								http://powershell.org/wp/2014/09/08/powershell-v5-class-support/********

 Creation Date		:			2016-05-05

 Modification Date	:			2016-05-12
#>

Set-StrictMode -Version Latest

[string]$dp0 = Split-Path -Path $MyInvocation.MyCommand.Path
[string]$dp0Script = $MyInvocation.MyCommand.Definition
[string]$dp0Module = $MyInvocation.MyCommand.Name.Split('.')[0]

#$VerbosePreference = 'SilentlyContinue' 
#$DebugPreference = 'SilentlyContinue' 

#region Module Functions

Function Save-InitialState {
	<#
	.SYNOPSIS
	Save the data to compare initial state
	.DESCRIPTION
	Save the data to compare initial state
	.EXAMPLE
	Save-InitialState ........ TO BE COMPLETED
	.EXAMPLE
	Save-InitialState ........ TO BE COMPLETED SECOND EXAMPLE
	.PARAMETER jobID
	The job unique ID.
	.PARAMETER $payload
	The original object to save for future comparison.
	.PARAMETER $filePath
	Where to save the file.
	.PARAMETER $filename
	The file's name
	#>
[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param (
		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The job unique ID.")]
		[object]$jobID,
					
		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The original object to save for future comparison.")]
		#[ValidateLength(0,30)]
		[System.Management.Automation.PSObject]$payload,

		[Parameter(Mandatory=$False,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="Where to save the file.")]
		#[ValidateLength(0,30)]
		[string]$filepath,

		[Parameter(Mandatory=$False,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The file's name")]
		#[ValidateLength(0,30)]
		[string]$filename
	)

	begin {
		Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Beginning - Saving data's to be compared initial state."
	}

	process {
		Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Beginning process loop"
		[System.Management.Automation.PSObject]$results = $null
		[string]$savedFile = ""

		$results = New-Object System.Management.Automation.PSObject
		
		$payload | Add-Member -MemberType NoteProperty "jobID" $jobID

		$results | Add-Member -MemberType NoteProperty "payload" ($payload | ConvertTo-Json | Out-String)

		$savedFile = $results | ConvertTo-Json | Out-String

		$savedFile | Out-File -FilePath "$($filepath+$filename)-initialState.json"
		
		Write-Output ($savedFile)

	}
}

Function CompareWith-InitialState {
	<#
	.SYNOPSIS
	Save the data to compare initial state
	.DESCRIPTION
	Save the data to compare initial state
	.EXAMPLE
	CompareWith-InitialState ........ TO BE COMPLETED
	.EXAMPLE
	CompareWith-InitialState ........ TO BE COMPLETED SECOND EXAMPLE
	.PARAMETER jobID
	The job unique ID.
	.PARAMETER $payload
	The original object to save for future comparison.
	.PARAMETER $filePath
	Where to save the file.
	.PARAMETER $filename
	The file's name
	#>
[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param (
		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The job unique ID.")]
		[object]$jobID,
					
		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The original object to save for future comparison.")]
		#[ValidateLength(0,30)]
		[System.Management.Automation.PSObject]$payload,

		[Parameter(Mandatory=$False,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="Where to save the file.")]
		#[ValidateLength(0,30)]
		[string]$filepath,

		[Parameter(Mandatory=$False,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The file's name")]
		#[ValidateLength(0,30)]
		[string]$filename
	)

	begin {
		Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Beginning - Saving data's to be compared initial state."
	}

	process {
		Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Beginning process loop"
		[System.Management.Automation.PSObject[]]$results = $null
		[System.Management.Automation.PSObject[]]$initialState = $null
		[System.Management.Automation.PSObject[]]$currentState = $null
		[string]$savedFile = ""

		$results = New-Object System.Management.Automation.PSObject

		$results = $initialState = (((get-content -Path "$($filepath+$filename)-initialState.json" | ConvertFrom-Json).payload) | ConvertFrom-Json)
		
		<#$payload | Add-Member -MemberType NoteProperty "jobID" $jobID

		$results | Add-Member -MemberType NoteProperty "payload" ($payload | ConvertTo-Json | Out-String)

		$savedFile = $results | ConvertTo-Json | Out-String

		$savedFile | Out-File -FilePath "$($filepath+$filename)-initialState.json"#>
		
		Write-Output ($results)

	}
}

# expose functions when someone imports this module
Export-ModuleMember -Function Save-InitialState
Export-ModuleMember -Function CompareWith-InitialState
#endregion
