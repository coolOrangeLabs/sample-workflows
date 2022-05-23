#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

function EnforceDrawingIsUpdated($files) {
    $affectedObjectsList = New-Object System.Collections.Generic.List[string]

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
            [Autodesk.Connectivity.WebServices.FileAssociationTypeEnum]::Dependency,
            $false,
            [Autodesk.Connectivity.WebServices.FileAssociationTypeEnum]::Dependency,
            $true,
            $true,
            $false,
            $false)

        if (-not $fileAssocLites) {
            continue
        }
    
        $children = $vault.DocumentService.GetLatestFilesByIds($fileAssocLites.CldFileId)
        foreach ($child in $children) {
            if ($drawingFile._ModDate -lt $child.ModDate) {
                $affectedObject = "$($drawingFile._Name) - $($($child.Name))"
                if (-not $affectedObjectsList.Contains($affectedObject)) {
                    Add-VaultRestriction -EntityName $affectedObject -Message "The drawing '$($drawingFile._Name)' cannot be released. The child component '$($child.Name)' is has been changed and the drawing is not up-to-date"
                    $affectedObjectsList.Add($affectedObject)
                }
            }
        }
    }
}

Register-VaultEvent -EventName UpdateFileStates_Restrictions -Action 'EnforceDrawingIsUpdated'