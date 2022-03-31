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
    $workingDirectory = "C:\TEMP\powerJobs Processor\" + (New-Object System.Guid).ToString()
}
#endregion

Write-Host "Starting job '$($job.Name)'..."

#region Settings
# Full Path of the RDLC report template file. This file needs to accessible by powerJobs on the Vault Job Processor machine
$reportFileLocation = "C:\ProgramData\coolOrange\powerJobs\Jobs\COOLORANGE.Report.rdlc"
# Name of the Saved Search. This Saved Search needs to available on the Vault Job Processor machine with the exact same server name and Vault name
$savedSearchName = "NAME_OF_MY_SEARCH_FOLDER"
# Name of the Report exported to PDF
$pdfFileName = "NAME_OF_MY_REPORT.pdf"
# Specify a Vault folder in which the PDF should be stored (e.g. $/Designs/PDF), or leave the setting empty to not store the report in Vault
$pdfVaultFolder = "$/Designs/Reports"
# Specify a network share into which the PDF should be copied (e.g. \\SERVERNAME\Share\Public\Reports\), or leave the setting empty to not copy the report to a shared folder
$pdfNetworkFolder = ""
#endregion

# Name of the Report Data Set. Autodesk report templates default to 'AutodeskVault_ReportDataSource'
$reportDataSet = "AutodeskVault_ReportDataSource"

#region Report Functions
function GetReportColumnType([string]$typeName) {
	switch ($typeName) {
        "String" { return [System.String] }
        "Numeric" { return [System.Double] }
        "Bool" { return [System.Byte] }
        "DateTime" { return [System.DateTime] }
        "Image" { return [System.String] }
        Default { throw ("Type '$typeName' cannot be assigned to a .NET type") }
    }
}

function ReplaceInvalidColumnNameChars([string]$columnName) {
    $pattern = "[^A-Za-z0-9]"
    return [System.Text.RegularExpressions.Regex]::Replace($columnName, $pattern, "_")
}

function GetReportDataSet([Autodesk.Connectivity.WebServices.File[]]$files, [System.String]$reportFileLocation, [System.String]$reportDataSet) {
    $sysNames = @()
    [xml]$reportFileXmlDocument = Get-Content -Path $reportFileLocation
    $dataSets = $reportFileXmlDocument.Report.DataSets.ChildNodes | Where-Object {$_.Name -eq $reportDataSet} 
    $dataSets.Fields.ChildNodes | ForEach-Object {
        $sysNames += $_.DataField
    }
    
    $table = New-Object System.Data.DataTable -ArgumentList @($reportDataSet)
    $table.BeginInit()

    $propDefIds = @()
    $propDefs = $vault.PropertyService.GetPropertyDefinitionsByEntityClassId("FILE")
    $propDefs | ForEach-Object {
		if ($sysNames -icontains $_.SysName) { 
			$propDefIds += $_.Id
	        $type = GetReportColumnType $_.Typ

	        $column = New-Object System.Data.DataColumn -ArgumentList @(($_.SysName), $type)
	        $column.Caption = (ReplaceInvalidColumnNameChars $_.DispName)
	        $column.AllowDBNull = $true
	        $table.Columns.Add($column)
		}
    }

    $colEntityType = New-Object System.Data.DataColumn -ArgumentList @("EntityType", [System.String])
    $colEntityType.Caption = "Entity_Type"
    $colEntityType.DefaultValue = "File"
    $table.Columns.Add($colEntityType)
    
	$colEntityTypeId = New-Object System.Data.DataColumn -ArgumentList @("EntityTypeID", [System.String])
    $colEntityTypeId.Caption = "Entity_Type_ID"
    $colEntityTypeId.DefaultValue = "FILE"
	$table.Columns.Add($colEntityTypeId)

    $fileIds = @($files | Select-Object -ExpandProperty Id)
    $propInsts = $vault.PropertyService.GetProperties("FILE", $fileIds, $propDefIds)
    
    $table.EndInit()	
	$table.BeginLoadData()
    $files | ForEach-Object {
        $file = $_
        $row = $table.NewRow()
        
        $propInsts | Where-Object { $_.EntityId -eq $file.Id } | ForEach-Object {
            if ($_.Val) {
                $propDefId = $_.PropDefId
                $propDef = $propDefs | Where-Object { $_.Id -eq $propDefId }
                if ($propDef) {
                    if ($propDef.Typ -eq "Image") {
                        $val = [System.Convert]::ToBase64String($_.Val)
                    } else {
                        $val = $_.Val
                    }
                    $row."$($propDef.SysName)" = $val
                }
            }
        }
        $table.Rows.Add($row)
    }
	$table.EndLoadData()
	$table.AcceptChanges()
	
    return ,$table
}

function CreateReport($reportFileLocation, $reportDataSet, $files, $localPdfFileName) {
    Write-Host "Creating RDLC report '$($reportFileLocation | Split-Path -Leaf)'..."
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.ReportViewer`.WinForms") | Out-Null
        
    $table = GetReportDataSet $files $reportFileLocation $reportDataSet
    
    $xmlDocument = New-Object System.Xml.XmlDocument
    $xmlDocument.Load($reportFileLocation)
    
    $localReport = New-Object Microsoft.Reporting.WinForms.LocalReport
    $stringReader = New-Object System.IO.StringReader -ArgumentList @($xmlDocument.OuterXml)
    
    $localReport.LoadReportDefinition($stringReader)
    $stringReader.Close()
    $stringReader.Dispose()
    
    $paramNames = $localReport.GetParameters() | Select-Object { $_.Name } -ExpandProperty Name    
    $parameterList = New-Object System.Collections.Generic.List[Microsoft.Reporting.WinForms.ReportParameter]
    foreach($parameter in $parameters.GetEnumerator()) {
		if ($paramNames -contains $parameter.Key) {
	        $param = New-Object Microsoft.Reporting.WinForms.ReportParameter -ArgumentList @($parameter.Key, $parameter.Value)
	        $parameterList.Add($param)
		}
    }
    $localReport.SetParameters($parameterList)
    
    $reportDataSource = New-Object -TypeName Microsoft.Reporting.WinForms.ReportDataSource -ArgumentList @($table.TableName, [System.Data.DataTable]$table)
    $localReport.DataSources.Add($reportDataSource)
    $bytes = $localReport.Render("PDF");
    
    $localPdfFolder = $localPdfFileName | Split-Path -Parent
    if (-not [System.IO.Directory]::Exists($localPdfFolder)) {
        [System.IO.Directory]::CreateDirectory($localPdfFolder) | Out-Null
    }
    
    if ([System.IO.File]::Exists($localPdfFileName)) {
        [System.IO.File]::Delete($localPdfFileName)
    }
    
    [System.IO.File]::WriteAllBytes($localPdfFileName, $bytes)
    Write-Host "Report saved as PDF to '$localPdfFileName'"
}
#endregion

#region Search Functions
function GetSrchCond($s) {
    switch ($s)
    {
        "CONTAINS" { return 1 }
        "DOES_NOT_CONTAIN" { return 2 }
        "TRUE" { return 3 }
        "FALSE" { return 3 }
        "EQUALS" {return 3 }
        "IS_EMPTY" { return 4 }
        "IS_NOT_EMPTY" { return 5 }
        "AFTER" { return 6 }
        "GREATER_THAN" { return 6 }
        "GREATER_THAN_OR_EQUAL" { return 7 }
        "BEFORE" {return 8 }
        "LESS_THAN" { return 8 }
        "LESS_THAN_OR_EQUAL" { return 9 }
        "NOT_EQUAL" { return 10 }
        Default { return 3 }
    }
}

function FindFilesBySavedSearch($savedSearch) {
    Write-Host "Executing Saved Search '$savedSearch'..."

    $searchDirectory = Resolve-Path "$($env:APPDATA)\Autodesk\VaultCommon\Servers\Services_Security*\$($vaultConnection.Server)\Vaults\$($vaultConnection.Vault)\Searches\" | Select-Object -ExpandProperty Path -First 1
    $reportFile = Get-ChildItem $searchDirectory | Where-Object Name -eq $savedSearch
    if (-not $reportFile) {
        throw "Cannot find the Report '$($savedSearch)' in $($searchDirectory)"
    }

    $propDefs = $vault.PropertyService.GetPropertyDefinitionsByEntityClassId("FILE")
    $srchConds = New-Object System.Collections.Generic.List[Autodesk.Connectivity.WebServices.SrchCond]
    [xml]$searchFileContent = Get-Content $reportFile.FullName
    foreach ($condition in $searchFileContent.SearchParameters.SearchConditions.SearchCondition) {
        $propDef = $propDefs | Where-Object SysName -eq $condition.PropertyKey
        $srchCond = New-Object Autodesk.Connectivity.WebServices.SrchCond
        $srchCond.PropDefId = $propDef.Id
        $srchCond.SrchOper = (GetSrchCond $condition.Type)
        $srchCond.SrchTxt = $condition.Value
        $srchCond.PropTyp = [Autodesk.Connectivity.WebServices.PropertySearchType]::SingleProperty
        $srchCond.SrchRule = "Must"
        $srchConds.Add($srchCond)
    }

    $bookmark = ""
    $status = $null
    $totalResults = @()
    while ($null -eq $status -or $totalResults.Count -lt $status.TotalHits) {
        $results = $vault.DocumentService.FindFilesBySearchConditions($srchConds, $null, $null, $false, $true, [ref]$bookmark, [ref]$status)
        if ($null -ne $results) {
            $totalResults += $results
        } else {
            break
        }
    }

    Write-Host "$($totalResults.Count) files found"
    return $totalResults
}
#endregion

$localPdfFileName = [System.IO.Path]::Combine($workingDirectory, $pdfFileName)
$files = FindFilesBySavedSearch $savedSearchName

$parameters = @{
    Report_UserName = $vaultConnection.UserName
    Report_Source = $savedSearchName
    Report_Action = ""
    Report_Destination = $pdfVaultFolder
    Report_Date = Get-Date
    Report_FilesCountAndSize = $files.Count
}

CreateReport $reportFileLocation $reportDataSet $files $localPdfFileName

if ($pdfVaultFolder) {
    Write-Host "Add Report '$pdfFileName' to Vault: $pdfVaultFolder"
    Add-VaultFile -From $localPdfFileName -To ($pdfVaultFolder.TrimEnd('/') + "/" + $pdfFileName) | Out-Null
}

if ($pdfNetworkFolder) {
    Write-Host "Copy Report '$pdfFileName' to network folder: $pdfNetworkFolder"
    Copy-Item $localPdfFileName -Destination $pdfNetworkFolder -ErrorAction Continue -ErrorVariable "ErrorCopyToNetworkFolder"
}

if ($ErrorCopyToNetworkFolder) {
    throw("Failed to copy Report file to network folder '$pdfNetworkFolder'! Reason: $($ErrorCopyToNetworkFolder)")
}

Write-Host "Completed job '$($job.Name)'"