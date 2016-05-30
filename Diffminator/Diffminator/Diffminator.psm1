#Requires -Version 4

<#
 Author				:			Nicolas Belanger

 FileName			:			Diffminator.ps1

 Description		:			Entry point for Diffminator Module

 Creation Date		:			2016-05-05

 Modification Date	:			2016-05-30
#>

Set-StrictMode -Version Latest

[string]$dp0 = Split-Path -Path $MyInvocation.MyCommand.Path
[string]$dp0Script = $MyInvocation.MyCommand.Definition
[string]$dp0Module = $MyInvocation.MyCommand.Name.Split('.')[0]

#$VerbosePreference = 'SilentlyContinue' 
#$DebugPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Suspend'

#region Module Functions

Function HasInitialStateSaved {
	<#
	.SYNOPSIS
	Return true if their is an existant initial state saved.
	.DESCRIPTION
	Return true if their is an existant initial state saved.
	.EXAMPLE
	HasInitialStateSaved ........ TO BE COMPLETED
	.EXAMPLE
	HasInitialStateSaved ........ TO BE COMPLETED SECOND EXAMPLE
	.PARAMETER $filePath
	Where is the file.
	.PARAMETER $filename
	The file's name
	#>
[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param (

		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="Where to save the file.")]
		#[ValidateLength(0,30)]
		[string]$filepath,

		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The file's name")]
		#[ValidateLength(0,30)]
		[string]$filename
	)

	[string]$file = "$($filepath+$filename)-initialState.json"
	[boolean]$hasInitialState = $false

	$hasInitialState = Test-Path -Path $file

	return $hasInitialState

}

<#Function Reset-AllStates {
	<#
	.SYNOPSIS
	Rename the initial, current and last state to $filepath\$filename-$jobID.json in order to keep
	them for further study, but at the same time continue futur run of the script with new initial state.
	.DESCRIPTION
	Rename the initial, current and last state to $filepath\$filename-$jobID.json in order to keep
	them for further study, but at the same time continue futur run of the script with new initial state.
	.EXAMPLE
	Reset-AllStates ........ TO BE COMPLETED
	.EXAMPLE
	Reset-AllStates ........ TO BE COMPLETED SECOND EXAMPLE
	.PARAMETER $filePath
	Where the files are.
	.PARAMETER $filename
	The files part of the name common to all files ($filepath\$filename-)
	#>
<#[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param (
		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="Where to save the file.")]
		#[ValidateLength(0,30)]
		[string]$filepath,

		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The file's name")]
		#[ValidateLength(0,30)]
		[string]$filename
	)
	[System.Management.Automation.PSObject[]]$initialState = $null
	[System.Management.Automation.PSObject[]]$currentState = $null
	[System.Management.Automation.PSObject[]]$lastState = $null
	[string]$initialStateFile = "$($filepath+$filename)-initialState.json"
	[string]$lastStateFile = "$($filepath+$filename)-lastState.json"
	[string]$currentStateFile = "$($filepath+$filename)-currentState.json"

	if(Test-Path $initialStateFile){
		$initialState = Get-Content -Raw -Path "$($initialStateFile)" 
		[string]$jID = (($initialState | ConvertFrom-xml).JobID).ToLocalTime().ToString().Replace(' ','_').Replace('/','_').Replace(":","_")
		[string]$nState = "$($filepath+$filename)-$($jID).json"
		Rename-Item -Path $initialStateFile -NewName $nState | Out-Null
	}

	if(Test-Path $lastStateFile){
		$lastState = Get-Content -Raw -Path "$($lastStateFile)" 
		[string]$jID = (($lastState | ConvertFrom-xml).JobID).ToLocalTime().ToString().Replace(' ','_').Replace('/','_').Replace(":","_")
		[string]$nState = "$($filepath+$filename)-$($jID).json"
		Rename-Item -Path $lastStateFile -NewName $nState | Out-Null
	}

	if(Test-Path $currentStateFile){
		$currentState = Get-Content -Raw -Path "$($currentStateFile)" 
		[string]$jID = (($currentState | ConvertFrom-xml).JobID).ToLocalTime().ToString().Replace(' ','_').Replace('/','_').Replace(":","_")
		[string]$nState = "$($filepath+$filename)-$($jID).json"
		Rename-Item -Path $currentStateFile -NewName $nState | Out-Null
	}

}#>

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

		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="Where to save the file.")]
		#[ValidateLength(0,30)]
		[string]$filepath,

		[Parameter(Mandatory=$True,
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
		[System.Management.Automation.PSObject[]]$savedFile = ""

		$results = New-Object System.Management.Automation.PSObject
		
		$results | Add-Member -MemberType NoteProperty "jobID" $jobID

		$results | Add-Member -MemberType NoteProperty "payload" $payload

        New-Item -Type directory -path $filepath -Force

		$results | ConvertTo-Json -Depth 1000 | Out-String | Out-File -FilePath "$($filepath+$filename)-initialState.json"
		
		$savedFile = Get-Content -Raw -Path "$($filepath+$filename)-initialState.json" | ConvertFrom-Json

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

		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="Where to save the file.")]
		#[ValidateLength(0,30)]
		[string]$filepath,

		[Parameter(Mandatory=$True,
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
			$initialState = Get-Content -Raw -Path "$($initialStateFile)" | ConvertFrom-Json
		}
		else {
			Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Initial state do not exist, so we create the initial state from the current state"
			$initialState = Save-InitialState -jobID $jobID -payload $payload -filepath $filepath -filename $filename
		}

		#Retreive the state from the previous run and rename it to lastState and write the current state
		if (Test-Path $currentStateFile){
			Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Retrieving the last state and renaming its name to reflect it is not the current state anymore"

			$lastState = Get-Content -Raw -Path "$($currentStateFile)" 
			
			#Rename the previous last state
			if (Test-Path $lastStateFile){
				[string]$previousLastStateFile = ""
				$previousLastState = Get-Content -Raw -Path "$($lastStateFile)" | ConvertFrom-Json
				[string]$jID = ($previousLastState.JobID).ToLocalTime().ToString().Replace(' ','_').Replace('/','_').Replace(":","_")
				$previousLastStateFile = "$($filepath+$filename)-$($jID).json"
				Rename-Item -Path $lastStateFile -NewName $previousLastStateFile
			}
			Rename-Item -Path $currentStateFile -NewName $lastStateFile

			#Write the new current state
			[System.Management.Automation.PSObject] $c = New-Object System.Management.Automation.PSObject
			$c | Add-Member -MemberType NoteProperty "jobID" $jobID
			$c | Add-Member -MemberType NoteProperty "payload" $payload
            New-Item -type directory -path $filepath -Force | Out-Null
			$c | ConvertTo-Json -Depth 1000 | Out-String | Out-File -Filepath "$($filepath+$filename)-currentState.json"
			$currentState = Get-Content -Raw -Path "$($filepath+$filename)-currentState.json" | ConvertFrom-Json
		}
		#if the last state do not exist only write the current state
		else {
			Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Last state do not exist, so only saving the current state"
			[System.Management.Automation.PSObject] $c = New-Object System.Management.Automation.PSObject
			$c | Add-Member -MemberType NoteProperty "jobID" $jobID
			$c | Add-Member -MemberType NoteProperty "payload" $payload
            New-Item -type directory -path $filepath -Force | Out-Null
			$savedFile = $c | ConvertTo-Json -Depth 1000 | Out-String | Out-File -Filepath "$($filepath+$filename)-currentState.json"
			$currentState = Get-Content -Raw -Path "$($filepath+$filename)-currentState.json" | ConvertFrom-Json
		}

		$results = $null
		
		$results = Compare-State -state1 $initialState -state2 $currentState
		
		Write-Output ($results)

	}
}

Function Compare-State {
	<#
	.SYNOPSIS
	Compare two state and return the difference if applicable.
	.DESCRIPTION
	Compare two state and return the difference if applicable.
	.EXAMPLE
	Compare-State ........ TO BE COMPLETED
	.EXAMPLE
	Compare-State ........ TO BE COMPLETED SECOND EXAMPLE
	.PARAMETER state1
	The first state to compare.
	.PARAMETER state2
	The second state to compare.
	#>
[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param (
		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The first state to compare.")]
		[PSObject[]]$state1,
					
		[Parameter(Mandatory=$True,
		#ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True,
		HelpMessage="The second state to compare.")]
		#[ValidateLength(0,30)]
		[PSObject[]]$state2
	)

	begin {
		Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Looking for difference between two state"
	}

	process {
		Log-Verbose "$($dp0Module).$($MyInvocation.MyCommand) : Beginning process loop"
		[System.Management.Automation.PSObject[]]$results = $null
		[Object[]]$payloadState1 = $null
		[Object[]]$payloadState2 = $null
        [int[]] $hashCodePayloadState1 = @()
        [int[]] $hashCodePayloadState2 = @()

        $payloadState1 = ($state1.payload.psobject.properties.value)
		$payloadState2 = ($state2.payload.psobject.properties.value)

        $results = @()

        #$results | Add-Member -MemberType NoteProperty "SideIndicator" $jobID

        foreach ($h1 in $payloadState1){
           $hashCodePayloadState1 += ([string]$h1).GetHashCode()
        }

        foreach ($h2 in $payloadState2){
           $hashCodePayloadState2 += ([string]$h2).GetHashCode()
        }

        #Search for deleted objects
        for ($i=0; $i -lt $hashCodePayloadState1.Count; $i++){
            if (!($hashCodePayloadState1[$i] -in $hashCodePayloadState2)){
                $d = New-Object 'System.Management.Automation.PSObject'
                $d | Add-Member -MemberType NoteProperty "InputObject" $payloadState1[$i]
                $d | Add-Member -MemberType NoteProperty "SideIndicator" "<="
                $results += $d
            }
        }

        #Search for added objects
        for ($j=0; $j -lt $hashCodePayloadState2.Count; $j++){
            if (!($hashCodePayloadState2[$j] -in $hashCodePayloadState1)){
                $a = New-Object 'System.Management.Automation.PSObject'
                $a | Add-Member -MemberType NoteProperty "InputObject" $payloadState2[$j]
                $a | Add-Member -MemberType NoteProperty "SideIndicator" "=>"
                $results += $a
            }
        }


		Write-Output ($results)
	}
}

# expose functions when someone imports this module
Export-ModuleMember -Function HasInitialStateSaved
Export-ModuleMember -Function Reset-AllStates
Export-ModuleMember -Function Save-InitialState
Export-ModuleMember -Function CompareWith-InitialState
#endregion
