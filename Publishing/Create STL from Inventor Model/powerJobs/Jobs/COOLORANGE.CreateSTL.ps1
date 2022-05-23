#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

if (-not $IAmRunningInJobProcessor) {
    # for manual script execution
    Import-Module powerJobs
    Open-VaultConnection
    $file = Get-VaultFile -Properties @{Name="Wheel.ipt"}
    $workingDirectory = "C:\TEMP\powerJobs Processor\" + (New-Object System.Guid).ToString()
}

# Do not delete the next line. Required for the powerJobs Settings Dialog to determine the entity type for lifecycle state change triggers.
# JobEntityType = FILE

#region Settings
# To include the Revision of the main file in the STL name set $true, otherwise $false
$stlFileNameWithRevision = $true

# The character used to separate file name and Revision label in the STL name such as hyphen (-) or underscore (_)
$stlFileNameRevisionSeparator = "_"

# To include the file extension of the main file in the STL name set $true, otherwise $false
$stlFileNameWithExtension = $false

# To add the STL to Vault set $true, to keep it out set $false
$addSTLToVault = $true

# To attach the STL to the main file set $true, otherwise $false
$attachSTLToVaultFile = $true

# Specify a Vault folder in which the STL should be stored (e.g. $/Designs/STL), or leave the setting empty to store the STL next to the main file
$stlVaultFolder = ""

# Specify a network share into which the STL should be copied (e.g. \\SERVERNAME\Share\Public\STLs\)
$stlNetworkFolder = ""

# STL specific settings - details can be found in Inventor API help
# Format: 0=binary, 1=ASCII
$stlOutputFileType = 0  

# Resolution: 4=Brep, 3=Custom, 2=High, 1=Medium, 0=Low
$stlResulution = 1

#  Allow to move Internal Mesh Nodes; set $true, otherwise $false
$stlAllowMoveMeshNode = $true

# Units: INCH = 2, FOOT = 3, CENTIMETER = 4, MILLIMETER = 5, METER = 6, MICRON = 7
$stlExportUnits = 4 
#endregion

#STL settings - details can be found in Inventor API help
$stlSurfaceDeviation = 60  # Range 0 to 100, the value has precision of 0.0001. None-zero value is used if Resolution is CUSTOM (3), otherwise value is ignored.
$stlNormalDeviation = 14  # Range 0 to 41. Non-zero value is used if Resolution is CUSTOM (3), otherwise value is ignored. Any input value out of this range will be changed to 14 by force.
$stlMaxEdgeLength = 100  # Range 0 to 100. Non-zero value is used if Resolution is CUSTOM (3), otherwise value is ignored. 
$stlAspectRatio = 40  # Range 0 to 21.5. Non-zero value is used if Resolution is CUSTOM (3), otherwise value is ignored.
$stlExportFileStructure = 0 # ONE FILE = 0, ONE FILE PER PART INSTANCE = 1
$stlExportColor = $true # Write color information to STL binary file.

$stlFileName = [System.IO.Path]::GetFileNameWithoutExtension($file._Name)
if ($stlFileNameWithRevision) {
    $stlFileName += $stlFileNameRevisionSeparator + $file._Revision
}
if ($stlFileNameWithExtension) {
    $stlFileName += "." + $file._Extension
}
$stlFileName += ".stl"

if ([string]::IsNullOrWhiteSpace($stlVaultFolder)) {
    $stlVaultFolder = $file._EntityPath
}

Write-Host "Starting job 'Create STL as attachment' for file '$($file._Name)' ..."

if ( @("iam", "ipt") -notcontains $file._Extension ) {
    Write-Host "Files with extension: '$($file._Extension)' are not supported"
    return
}
if (-not $addSTLToVault -and -not $stlNetworkFolder) {
    throw("No output for the STL is defined in ps1 file!")
}
if ($stlNetworkFolder -and -not (Test-Path $stlNetworkFolder)) {
    throw("The network folder '$stlNetworkFolder' does not exist! Correct stlNetworkFolder in ps1 file!")
}

$file = (Save-VaultFile -File $file._FullPath -DownloadDirectory $workingDirectory)[0]
$localSTLfileLocation = "$workingDirectory\$stlFileName"

$openResult = Open-Document -LocalFile $file.LocalPath #-Application InventorServer
if ($openResult) {
    try {
        $InvApp = $openResult.Application.Instance
        $STLAddin = $InvApp.ApplicationAddIns | Where-Object { $_.ClassIdString -eq "{533E9A98-FC3B-11D4-8E7E-0010B541CD80}" }
        $Context = $InvApp.TransientObjects.CreateTranslationContext()
        $Options = $InvApp.TransientObjects.CreateNameValueMap()

        if($openResult.Application.Name -eq "Inventor") {
            Write-Host "Using Inventor..."
            $SourceObject = $InvApp.ActiveDocument
        } elseif ($openResult.Application.Name -eq "InventorServer") {
            Write-Host "Using Inventor Server..."
            $SourceObject = $InvApp.Documents[1]
        } else {
            throw "$($openResult.Application.Name) not supported"
        }

        if ($STLAddin.HasSaveCopyAsOptions($SourceObject, $Context, $Options)) {
            $Options.Value("Resulution") = $STLResulution
            $Options.Value("ExportUnits") = $stlExportUnits
            $Options.Value("AllowMoveMeshNode") = $stlAllowMoveMeshNode
            $Options.Value("SurfaceDeviation") = $stlSurfaceDeviation
            $Options.Value("NormalDeviation") = $stlNormalDeviation
            $Options.Value("MaxEdgeLength") = $stlMaxEdgeLength
            $Options.Value("AspectRatio") = $stlAspectRatio
            $Options.Value("ExportFileStructure") = $stlExportFileStructure
            $Options.Value("OutputFileType") = $stlOutputFileType 
            $Options.Value("ExportColor") = $stlExportColor
        }

        $oData = $InvApp.TransientObjects.CreateDataMedium()
        $Context.Type = 13059       #kFileBrowseIOMechanism
        $oData.MediumType = 56577   #kFileNameMedium
        $oData.FileName = $localSTLfileLocation
        $STLAddin.SaveCopyAs($SourceObject, $Context, $Options, $oData)
        $exportResult = $true

        $STLfile = Add-VaultFile -From $localSTLfileLocation -To "$stlVaultFolder/$stlFileName" -FileClassification DesignVisualization #None  
        $file = Update-VaultFile -File $file._FullPath -AddAttachments @($STLfile._FullPath)
    }
    catch {
        $exportResult = $false
        $exportResult | Add-Member -NotePropertyName Error -NotePropertyValue $_.Exception
    }
    
    $closeResult = Close-Document
}

if (-not $openResult) {
    throw("Failed to open document $($file.LocalPath)! Reason: $($openResult.Error.Message)")
}
if (-not $exportResult) {
    throw("Failed to export document $($file.LocalPath) to $localSTLfileLocation! Reason: $($exportResult.Error.Message)")
}
if (-not $closeResult) {
    throw("Failed to close document $($file.LocalPath)! Reason: $($closeResult.Error.Message))")
}
if ($ErrorCopySTLToNetworkFolder) {
    throw("Failed to copy STL file to network folder '$stlNetworkFolder'! Reason: $($ErrorCopySTLToNetworkFolder)")
}

Write-Host "Completed job 'Create STL as attachment'"
