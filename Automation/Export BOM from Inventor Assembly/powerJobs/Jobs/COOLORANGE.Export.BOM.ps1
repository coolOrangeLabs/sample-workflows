#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Do not delete the next line. Required for the powerJobs Settings Dialog to determine the entity type for lifecycle state change triggers.
# JobEntityType = FILE

#region Debug
if (-not $IAmRunningInJobProcessor) {
	Import-Module powerJobs
	# https://doc.coolorange.com/projects/coolorange-powervaultdocs/en/stable/code_reference/commandlets/open-vaultconnection.html
	Open-VaultConnection
	$file = Get-VaultFile -Properties @{Name="Suspension.iam"}
}
#endregion

Write-Host "Starting job '$($job.Name)' for file '$($file._Name)'..."

#region Settings
# If checked the positions are filled with the 'Position Number' property of the Inventor BOM rows, otherwise the property 'Row Order' will be used
$usePositionNumber = $false
# Name of the CSV file that contains the BOM information
$csvFileName = "$($file._Name)_StructuredBOM.csv"
# Specify a network share into which the CSV should be copied (e.g. \\SERVERNAME\Share\Public\BOMs\)
$csvNetworkFolder = "C:\Temp\BOMs"
#endregion

if( @("iam") -notcontains $file._Extension ) {
	Write-Host "Files with extension: '$($file._Extension)' are not supported"
	return
}

function GetParts {
	param(
		$Parent,
		$Multiplicator = 1,
		[bool]$UsePositionNumber
	)

	$parts = @()

	$children = Get-VaultFileBom -File $Parent._FullPath
	foreach ($child in $children) {
		if ($UsePositionNumber) {
			$position = '{0}.{1}' -f $Parent.Bom_PositionNumber, $child.Bom_PositionNumber
		}
		else {
			$position = '{0}.{1}' -f $Parent.Bom_RowOrder, $child.Bom_RowOrder
		}
		$position = $position.TrimStart('.')

		Add-Member -InputObject $child -NotePropertyName Position -NotePropertyValue $position
		Add-Member -InputObject $child -NotePropertyName Quantity -NotePropertyValue $child.Bom_Quantity
		Add-Member -InputObject $child -NotePropertyName TotalQuantity -NotePropertyValue ($Multiplicator * $child.Bom_Quantity)

		$parts += $child

		if ($child._Extension -eq "iam") {
			$childParts = GetParts -Parent $child -Multiplicator ($Multiplicator * $child.Bom_Quantity) -UsePositionNumber $UsePositionNumber
			if($childParts) {
				$parts += $childParts
			}
		}
	}
	return ,$parts
}

$partsList = GetParts -Parent $file -UsePositionNumber $usePositionNumber

if ($partsList.Count -le 0) {
	throw "Cannot find a Structured BOM in Vault for file '$($file._Name)'. Please open the file in Inventor and make sure the Structued BOM is enabled."
}

if (-not (Test-Path -Path $csvNetworkFolder)) {
	$null = New-Item -ItemType Directory -Path $csvNetworkFolder
}

$csvFullFileName = Join-Path -Path $csvNetworkFolder -ChildPath $csvFileName

$partsList `
	| Select-Object -Property Bom_Number, Position, Quantity, TotalQuantity, Bom_ItemQuantity, Bom_UnitQuantity, Bom_Structure `
	| Export-Csv -LiteralPath $csvFullFileName -NoTypeInformation

Write-Host "Completed job '$($job.Name)'"
