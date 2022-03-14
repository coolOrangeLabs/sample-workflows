#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

#region Settings
# Lifecycle State from which the file is changed
$FromState = "For Review"
# Target Lifecycle State to which the file is changed
$ToState = "Released"
#endregion

function FourEyesCheck ($files) {
    foreach ($file in $files) {
        if ($file._State -eq $FromState -and $file._NewState -eq $ToState) { 
            $allFileVersions = $vault.DocumentService.GetFilesByMasterId($file.MasterId)
            [array]::Reverse($allFileVersions)
            foreach ($version in $allFileVersions) {
                if ($version.FileLfCyc.LfCycStateName -eq $FromState) { 
                    if ($version.CreateUserName -eq $vaultConnection.UserName) {
                        Add-VaultRestriction -EntityName $version.Name -Message "File can not be reviewed and released by the same user"
                        break
                    }
                    else {
                        break
                    }       
                }
            }
        }
    }
}

Register-VaultEvent -EventName UpdateFileStates_Restrictions -Action 'FourEyesCheck'