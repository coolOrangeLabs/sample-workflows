#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

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

function GetParts($partList, $parent, $parentPosition="", $multiplicator = 1) {
    $children = Get-VaultFileBom -File $parent._FullPath -Recursive
	foreach ($child in $children) {
        if ($usePositionNumber) {
            $position = $parentPosition + "." + $child.Bom_PositionNumber
        } else {
            $position = $parentPosition + "." + $child.Bom_RowOrder
        }
        $position = $position.TrimStart('.')
        $quantity = $child.Bom_Quantity

        $child | Add-Member -NotePropertyName Position -NotePropertyValue $position
        $child | Add-Member -NotePropertyName Multiplicator -NotePropertyValue $multiplicator
        $child | Add-Member -NotePropertyName Quantity -NotePropertyValue ($quantity)
        $child | Add-Member -NotePropertyName TotalQuantity -NotePropertyValue ($multiplicator * $quantity)
        $partList.Add($child)

		if ($child._Extension -eq "iam") {
			GetParts $partList $child $position ($multiplicator * $quantity)
		}
	}
}

$files = New-Object System.Collections.Generic.List[PSCustomObject]
GetParts $files $file

if ($files.Count -le 0) {
    throw "Cannot find a Structured BOM in Vault for file '$($file._Name)'. Please open the file in Inventor and make sure the Structued BOM is enabled."
}

if (-not (Test-Path -Path $csvNetworkFolder)) {
    New-Item -ItemType "directory" -Path $csvNetworkFolder
}

$csvFullFileName = [System.IO.Path]::Combine($csvNetworkFolder, $csvFileName)
$files | Select-Object -Property Bom_Number, Position, Quantity, TotalQuantity, Bom_ItemQuantity, Bom_UnitQuantity, Bom_Structure | Export-Csv -Path $csvFullFileName -NoTypeInformation

Write-Host "Completed job '$($job.Name)'"