#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

function EnforceStructuredBomEnabled($files) {
	$affectedObjectsList = New-Object System.Collections.Generic.List[string]

	#$releasedFiles = @($files | Where-Object { $_._Extension -eq "iam" })
	$releasedFiles = @($files | Where-Object { $_._Extension -eq "iam" -and $_._ReleasedRevision -eq $true })

	foreach ($file in $releasedFiles) {
		$structuredBomEnabled = $false
		$bom = $vault.DocumentService.GetBOMByFileId($file.Id)
		foreach ($schm in $bom.SchmArray) {
			if ($schm.SchmTyp -eq "Structured") {
				$structuredBomEnabled = $true
			}
		}

		if (-not $structuredBomEnabled) {
			if (-not $affectedObjectsList.Contains($file._Name)) {
				$message = "The Structured BOM is not enabled for file '$($file._Name)'. Please open the file in Inventor and enable the Structured BOM to release this file!"
				Add-VaultRestriction -EntityName $file._Name -Message $message
				$affectedObjectsList.Add($file._Name)
			}
		}
	}
}

function SubmitExportBomJob($files, $successful) {
	if (-not $successful) { return }

	#$releasedFiles = @($files | Where-Object { $_._Extension -eq "iam" })
	$releasedFiles = @($files | Where-Object { $_._Extension -eq "iam" -and $_._ReleasedRevision -eq $true })
	
	foreach ($file in $releasedFiles) {
		$jobType = "COOLORANGE.Export.BOM"
		Write-Host "Adding job '$jobType' for file '$($file._Name)' to queue."
		Add-VaultJob -Name $jobType -Parameters @{ "EntityId" = $file.Id; "EntityClassId" = "FILE" } -Description "Export BOM for file '$($file._Name)'"
	}
}

Register-VaultEvent -EventName UpdateFileStates_Restrictions -Action 'EnforceStructuredBomEnabled'
Register-VaultEvent -EventName UpdateFileStates_Post -Action 'SubmitExportBomJob'