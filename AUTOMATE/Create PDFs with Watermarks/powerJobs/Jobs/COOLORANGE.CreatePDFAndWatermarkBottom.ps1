#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

#region Debug
if (-not $IAmRunningInJobProcessor) { # Only used for debugging purposes!
    Import-Module powerJobs
    # https://doc.coolorange.com/projects/coolorange-powervaultdocs/en/stable/code_reference/commandlets/open-vaultconnection.html
    Open-VaultConnection
    $file = Get-VaultFiles -Properties @{ Name = "Blower.idw" }
} 
#endregion

#region Settings
# PDF settings
# To include the Revision of the main file in the PDF name set $true, otherwise $false
$pdfFileNameWithRevision = $false
# The character used to separate file name and Revision label in the PDF name such as hyphen (-) or underscore (_)
$pdfFileNameRevisionSeparator = "_"
# To include the file extension of the main file in the PDF name set $true, otherwise $false
$pdfFileNameWithExtension = $true
# To add the PDF to Vault set $true, to keep it out set $false
$addPDFToVault = $true
# To attach the PDF to the main file set $true, otherwise $false
$attachPDFToVaultFile = $true
# Specify a Vault folder in which the PDF should be stored (e.g. $/Designs/PDF), or leave the setting empty to store the PDF next to the main file
$pdfVaultFolder = ""
# Specify a network share into which the PDF should be copied (e.g. \\SERVERNAME\Share\Public\PDFs\)
$pdfNetworkFolder = ""
# To enable faster opening of released Inventor drawings without downloading and opening their model files set $true, otherwise $false
$openReleasedDrawingsFast = $true

# Watermark settings
# Watermark color
$Color = "Orange"
# Horizontal alignment of Watermark
$HorizontalAlignment = "Right"
# Vertical Alignment of Watermark
$VerticalAlignment = "Bottom"
# Transparency in % for Watermark text 
$Opacity = 50
# Watermark offset in x direction
$OffsetX = -2
# Watermark offset in y direction
$OffsetY = 0
# Angle of Watermark
$Angle = 0
#endregion

$pdfFileName = [System.IO.Path]::GetFileNameWithoutExtension($file._Name)
if ($pdfFileNameWithRevision) {
    $pdfFileName += $pdfFileNameRevisionSeparator + $file._Revision
}
if ($pdfFileNameWithExtension) {
    $pdfFileName += "." + $file._Extension
}
$pdfFileName += ".pdf"

if ([string]::IsNullOrWhiteSpace($pdfVaultFolder)) {
    $pdfVaultFolder = $file._EntityPath
}

Write-Host "Starting job '$($job.Name)' for file '$($file._Name)' ..."

if ( @("idw", "dwg") -notcontains $file._Extension -or $File._Provider -eq "AutoCAD"){
    Write-Host "File not supported! This job only works for Inventor drawings!"
    return
}
if (-not $addPDFToVault -and -not $pdfNetworkFolder) {
    throw("No output for the PDF is defined in ps1 file!")
}
if ($pdfNetworkFolder -and -not (Test-Path $pdfNetworkFolder)) {
    throw("The network folder '$pdfNetworkFolder' does not exist! Correct pdfNetworkFolder in ps1 file!")
}

$fastOpen = $openReleasedDrawingsFast -and $file._ReleasedRevision
$file = (Save-VaultFile -File $file._FullPath -DownloadDirectory $workingDirectory -ExcludeChildren:$fastOpen -ExcludeLibraryContents:$fastOpen)[0]
$openResult = Open-Document -LocalFile $file.LocalPath -Options @{ FastOpen = $fastOpen }
$size=$openResult.document.instance.activesheet.size

# Calculating Font Size depending on sheet format in Inventor
$SizeMapping = @{
    "9986" = 50.0 #Custom Format
    "9987" = 30.0 #Format A
    "9988" = 40.0 #Format B
    "9989" = 50.0 #Format C
    "9990" = 60.0 #Format D
    "9991" = 70.0 #Format E
    "9992" = 80.0 #Format F
    "9993" = 80.0 #Format A0
    "9994" = 70.0 #Format A1
    "9995" = 60.0 #Format A2
    "9996" = 50.0 #Format A3
    "9997" = 40.0 #Format A4
    "9998" = 30.0 #Format 9 in x 12 in
    "9999" = 40.0 #Format 12 in x 18
    "10000" = 50.0 #Format 18 in x 24
    "10001" = 60.0 #Format 24 in x 36
    "10002" = 70.0 #Format 36 in x 48
    "10003" = 65.0 #Format 30 in x 42
}

foreach($i in $SizeMapping.Keys) {
    if($i -eq $size) {
        $FontSize = $SizeMapping[$i]
    }
}

if ($openResult) {
    $localPDFfileLocation = "$workingDirectory\$pdfFileName"

    $configFile = "$($env:POWERJOBS_MODULESDIR)Export\PDF_2D.ini"
    $exportResult = Export-Document -Format 'PDF' -To $localPDFfileLocation -Options $configFile

    try {
        $text = $file._State
        Add-WaterMark -Path $localPDFfileLocation -WaterMark $text -FontSize $FontSize -Angle $Angle -HorizontalAlignment $HorizontalAlignment -VerticalAlignment $VerticalAlignment -Color $Color -Opacity $Opacity -OffSetX $OffsetX -OffSetY $OffsetY
    } catch [System.Exception] {
        throw($error[0])
    }

    if ($exportResult) {
        if ($addPDFToVault) {
            $pdfVaultFolder = $pdfVaultFolder.TrimEnd('/')
            Write-Host "Add PDF '$pdfFileName' to Vault: $pdfVaultFolder"
            $PDFfile = Add-VaultFile -From $localPDFfileLocation -To "$pdfVaultFolder/$pdfFileName" -FileClassification DesignVisualization
            if ($attachPDFToVaultFile) {
                $file = Update-VaultFile -File $file._FullPath -AddAttachments @($PDFfile._FullPath)
            }
        }
        if ($pdfNetworkFolder) {
            Write-Host "Copy PDF '$pdfFileName' to network folder: $pdfNetworkFolder"
            Copy-Item -Path $localPDFfileLocation -Destination $pdfNetworkFolder -ErrorAction Continue -ErrorVariable "ErrorCopyPDFToNetworkFolder"
        }
    }
    $closeResult = Close-Document
}

if (-not $openResult) {
    throw("Failed to open document $($file.LocalPath)! Reason: $($openResult.Error.Message)")
}
if (-not $exportResult) {
    throw("Failed to export document $($file.LocalPath) to $localPDFfileLocation! Reason: $($exportResult.Error.Message)")
}
if (-not $closeResult) {
    throw("Failed to close document $($file.LocalPath)! Reason: $($closeResult.Error.Message))")
}
if ($ErrorCopyPDFToNetworkFolder) {
    throw("Failed to copy PDF file to network folder '$pdfNetworkFolder'! Reason: $($ErrorCopyPDFToNetworkFolder)")
}

Write-Host "Completed job '$($job.Name)'"