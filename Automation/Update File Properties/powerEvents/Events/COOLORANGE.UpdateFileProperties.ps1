#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

#TODO: Category assigned to $DrawingCategory must exist in Vault
#TODO: UDPs configured below must exist in Vault

#region Settings
# Lifecycle State for Review from which the file is changed
$WIP_State = "Work in Progress"
# Target Lifecycle State for Review to which the file is changed
$Review_State = "For Review"
# Target Lifecycle State for Release to which the file is changed
$Released_State = "Released"
# Category for drawings 
$DrawingCategory = "Engineering" #"Drawing Inventor"
# UDP for User who has put the file from $WIP_State to $Review_State
$udp_CheckedBy = "Checked By"
# UDP for Date when the file was set from $WIP_State to $Review_State
$udp_CheckedOn = "Checked On"
# UDP for User who has put the file from $WIP_State to $Review_State
$udp_ApprovedBy = "Approved By"
# UDP for Date when the file was set from $WIP_State to $Review_State
$udp_ApprovedOn = "Approved On"
#endregion


function PreUpdateFileStates($files) {
    foreach ($file in $files) {
        if ($file._CategoryName -eq $DrawingCategory -and $file._NewState -eq $Review_State -and $file._State -eq $WIP_State) {
            Update-VaultFile -File $file._FullPath -Properties @{
                $udp_CheckedBy = $vaultConnection.UserName; 
                $udp_CheckedOn = [System.DateTime]::Now
            }
        }

        if ($file._CategoryName -eq $DrawingCategory -and $file._NewState -eq $Released_State -and $file._State -eq $Review_State) {
            Update-VaultFile -File $file._FullPath -Properties @{
                $udp_ApprovedBy = $vaultConnection.UserName; 
                $udp_ApprovedOn = [System.DateTime]::Now
            }
        }
    }
}
 
function PostUpdateFileStates($files, $successful) {
    foreach ($file in $files) {
        if ($file._CategoryName -eq $DrawingCategory -and $file._OldState -eq $Released_State -and $file._State -eq $WIP_State) {
            Update-VaultFile -File $file._FullPath -Properties @{
                $udp_CheckedBy = ""; 
                $udp_CheckedOn = $null
                $udp_ApprovedBy = ""; 
                $udp_ApprovedOn = $null
            }
        }
    }
}

Register-VaultEvent -EventName UpdateFileStates_Pre -Action 'PreUpdateFileStates'
Register-VaultEvent -EventName UpdateFileStates_Post -Action 'PostUpdateFileStates'
