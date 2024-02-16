#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

function EnforceDrawingIsUpdated($files) {
    $affectedObjectsList = @()

    $drawingFiles = @($files | Where-Object { @("idw","dwg") -icontains $_._Extension -and "Inventor" -eq $_._Provider })
    if (-not $drawingFiles) {
        return
    }

    $drawingFiles = $drawingFiles | Where-Object {
        $newLifecycleState = Get-VaultLifecycleState -LifecycleDefinition $_._NewLifeCycleDefinition -State $_._NewState
        $newLifecycleState.ReleasedState -eq $true
    }

    foreach ($drawingFile in $drawingFiles) {
        $fileAssocLites = $vault.DocumentService.GetFileAssociationLitesByIds(
            @($drawingFile.Id),
            [Autodesk.Connectivity.WebServices.FileAssocAlg]::Actual,
            [Autodesk.Connectivity.WebServices.FileAssociationTypeEnum]::None, #include parents
            $false, #recurse parents
            [Autodesk.Connectivity.WebServices.FileAssociationTypeEnum]::Dependency, #include children
            $false, #recuse children
            $true, #include libraries
            $false, #include related documents
            $false) #include hidden

        if (-not $fileAssocLites) {
            continue
        }
    
        $vault.DocumentService.GetFilesByIds($fileAssocLites.CldFileId) | ForEach-Object {
            if ($_.VerNum -lt $_.MaxCkInVerNum) {
                $affectedObject = "$($drawingFile._Name) - $($_.Name)"
                if (-not $affectedObjectsList.Contains($affectedObject) ) {
                    Add-VaultRestriction -EntityName $affectedObject -Message "The drawing '$($drawingFile._Name)' cannot be released. The child component '$($_.Name)' is has been changed and the drawing is not up-to-date"
                    $affectedObjectsList += $affectedObject
                }
            }
        }
    }
}

Register-VaultEvent -EventName UpdateFileStates_Restrictions -Action 'EnforceDrawingIsUpdated'
