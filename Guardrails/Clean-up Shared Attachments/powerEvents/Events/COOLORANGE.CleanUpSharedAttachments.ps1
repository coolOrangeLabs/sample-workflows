#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Do not delete the next line. Required for the powerJobs Settings Dialog to determine the entity type for lifecycle state change triggers.
# JobEntityType = FILE

#region Settings
# Specify a network share into which the PDFs are copied by powerJobs Processor (e.g. \\SERVERNAME\Share\Public\PDFs\)
$networkFolder = "\\SERVERNAME\Share\Public\PDFs\"
#endregion

function DeleteAttachments($files) {
    $releasedFiles = $files | Where-Object {
        $newLifecycleState = Get-VaultLifecycleState -LifecycleDefinition $_._NewLifeCycleDefinition -State $_._NewState
        $newLifecycleState.ReleasedState -eq $true
    }

    foreach ($file in $releasedFiles) {
        Write-Host $file.Name
		$attachments = Get-VaultFileAssociations -File $file._FullPath -Attachments
        foreach ($attachment in $attachments) {
            $fileToDelete = [System.IO.Path]::Combine($networkFolder, $attachment._Name)
            if ([System.IO.File]::Exists($fileToDelete)) {
                try {
                    Remove-Item -Path $fileToDelete -Force -ErrorAction Stop
                } catch {
                    Add-VaultRestriction -EntityName $file._Name -Message $Error[0].ToString()
                }
            }
        }
    }
}

Register-VaultEvent -EventName UpdateFileStates_Restrictions -Action 'DeleteAttachments'
