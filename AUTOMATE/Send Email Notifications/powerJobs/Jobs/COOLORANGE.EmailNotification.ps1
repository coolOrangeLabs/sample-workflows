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
    $f = Get-VaultFiles -Properties @{ Name = "Blower.idw" }
    $job = New-Object PSObject -Property @{ Name = "COOLORANGE.EmailNotification"; GroupNames = "Administrators;Project Managers"; FileIds = $f.Id }
    $user = $vault.AdminService.GetUserByUserId($vaultConnection.UserID)
} 
#endregion

if (-not $user) {
    $jobs = $vault.JobService.GetJobsByDate([int]::MaxValue, [DateTime]::MinValue)
    $user = $vault.AdminService.GetUserByUserId(($jobs | Where-Object { $_.Id -eq $job.Id }).CreateUserId)
}

Write-Host "Starting job '$($job.Name)'..."

#region Functions
function GetAllEmailsFromGroup($groupName) {
    $results = @()
    try {
        $group = $vault.AdminService.GetGroupByName($groupName)
        $groupInfo = $vault.AdminService.GetGroupInfoByGroupId($group.Id)
        foreach ($user in $groupInfo.Users) {
            if ($user.Email) {
                $results += $user.Email
            } else {
                Write-Host "No email configured for user '$($user.Name)'"
            }
        }
        foreach ($g in $groupInfo.Groups) {
            $results += @(GetAllEmailsFromGroup $g.Name)
        }        
    }
    catch {
        Write-Host "Group '$($groupName)' not found in Vault"
    }

    return $results
}

function GetVaultThickClientLink($file) {
    $objectId = [System.Web.HttpUtility]::UrlEncode($file._FullPath)
    $objectType = "File"
    $serverUri = New-Object Uri -ArgumentList $vault.InformationService.Url
    $hostname = $serverUri.Host
    if ($hostname -ieq "localhost") { $hostname = [System.Net.Dns]::GetHostName() }
    return "$($serverUri.Scheme)://$($hostname)/AutodeskDM/Services/EntityDataCommandRequest.aspx?Vault=$($vaultConnection.Vault)&ObjectId=$($objectId)&ObjectType=$($objectType)&Command=Select"
}
#endregion

$links = @()
foreach ($fileId in $job.FileIds.Split(";")) {
    $file = Get-VaultFile -FileId $fileId
    $url = GetVaultThickClientLink $file
    $links += "<a href=""$($url)"">$($file._Name)</a><br>"
}

#region Settings
# The subject of the email
$subject = "File states changed in Vault"
# The body of the email
$body = "<body><p>The state of the following file(s) has been changed by the user '$($user.Name)':</p><p>$($links)</p><p>Please check the latest changes!</p></body>"
# The email address used to send out the email
$from = "youruser@hotmail.com"
# The SMTP user used to authenticate when sending out the email
$user = "youruser@hotmail.com"
# The SMTP users password used to authenticate when sending out the email
$password = "yourpassword"
# The SMTP server name
$smtpServer = "smtp.office365.com"
# The SMTP server port
$port = 587
# To use SSL when sending out the email $true, otherwise $false
$useSSL = $true
#endregion

$receivers = @()
foreach ($groupName in $job.GroupNames.Split(";")) {
    $receivers += @(GetAllEmailsFromGroup $groupName)
}

$emails = $receivers | Select-Object -Unique
if ($emails.Length -gt 0) {
    $credential = New-Object Management.Automation.PSCredential @($user, (ConvertTo-SecureString -AsPlainText $password -Force))
    foreach($email in $emails) {
        if ($useSSL) {
            Send-MailMessage -From $from -To $email -Subject $subject -Body $body -BodyAsHtml -SmtpServer $smtpServer -Port $port -Credential $credential -UseSsl
        } else {
            Send-MailMessage -From $from -To $email -Subject $subject -Body $body -BodyAsHtml -SmtpServer $smtpServer -Port $port -Credential $credential
        }
    }    
} else {
    Write-Host "No email recipients found in the specified groups."
}

Write-Host "Completed job '$($job.Name)'"