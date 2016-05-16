#Requires -Version 4
#Requires -Modules Logmanagement

<#
 Author				:			Nicolas Belanger

 FileName			:			Diffminator.ps1

 Description		:			Entry point for Diffminator Module

 Creation Date		:			2016-05-05

 Modification Date	:			2016-05-16
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
		
		$results | Add-Member -MemberType NoteProperty "jobID" $jobID

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
		[System.Management.Automation.PSObject[]]$lastState = $null
		[string]$savedFile = ""
		[string]$initialStateFile = "$($filepath+$filename)-initialState.json"
		[string]$lastStateFile = "$($filepath+$filename)-lastState.json"
		[string]$currentStateFile = "$($filepath+$filename)-currentState.json"
		[string]$initialStateFile = "$($filepath+$filename)-initialState.json"

		$results = New-Object System.Management.Automation.PSObject

		#Retreive the initial state
		if (Test-Path $initialStateFile){
			Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Retrieving the initial state"
			$initialState = Get-Content -Path "$($initialStateFile)" -Raw
		}
		else {
			Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Initial state do not exist, so we create the initial state from the current state"
			$initialState = Save-InitialState -jobID $jobID -payload $payload -filepath $filepath -filename $filename
		}

		#Retreive the state from the previous run and rename it to lastState and write the current state
		if (Test-Path $currentStateFile){
			Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Retrieving the last state and renaming its name to reflect it is not the current state anymore"

			$lastState = get-content -Path "$($currentStateFile)" -Raw
			
			#Rename the previous last state
			if (Test-Path $lastStateFile){
				[string]$previousLastStateFile = ""
				$previousLastState = get-content -Path "$($lastStateFile)" -Raw
				[string]$jID = (($previousLastState | ConvertFrom-json).JobID).ToLocalTime().ToString().Replace(' ','_').Replace('/','_').Replace(":","_")
				$previousLastStateFile = "$($filepath+$filename)-$($jID).json"
				Rename-Item -Path $lastStateFile -NewName $previousLastStateFile
			}
			Rename-Item -Path $currentStateFile -NewName $lastStateFile

			#Write the new current state
			[System.Management.Automation.PSObject] $c = New-Object System.Management.Automation.PSObject
			$c | Add-Member -MemberType NoteProperty "jobID" $jobID
			$c | Add-Member -MemberType NoteProperty "payload" ($payload | ConvertTo-Json | Out-String)
			$savedFile = $c | ConvertTo-Json | Out-String
			$savedFile | Out-File -FilePath "$($filepath+$filename)-currentState.json"
			$currentState = $savedFile
		}
		#if the last state do not exist only write the current state
		else {
			Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Last state do not exist, so only saving the current state"
			[System.Management.Automation.PSObject] $c = New-Object System.Management.Automation.PSObject
			$c | Add-Member -MemberType NoteProperty "jobID" $jobID
			$c | Add-Member -MemberType NoteProperty "payload" ($payload | ConvertTo-Json | Out-String)
			$savedFile = $c | ConvertTo-Json | Out-String
			$savedFile | Out-File -FilePath "$($filepath+$filename)-currentState.json"
			$currentState = $savedFile
		}

		$results = New-Object System.Management.Automation.PSObject
		<#$payload | Add-Member -MemberType NoteProperty "jobID" $jobID

		$results | Add-Member -MemberType NoteProperty "payload" ($payload | ConvertTo-Json | Out-String)

		$savedFile = $results | ConvertTo-Json | Out-String

		$savedFile | Out-File -FilePath "$($filepath+$filename)-current.json"#>
		
		Write-Output ($results)

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
		Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Looking for difference between two state"
	}

	process {
		Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Beginning process loop"
		[System.Management.Automation.PSObject[]]$results = $null

	}
}

# expose functions when someone imports this module
Export-ModuleMember -Function Save-InitialState
Export-ModuleMember -Function CompareWith-InitialState
#endregion
