#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2022 COOLORANGE S.r.l.                                         #
#==============================================================================#

#region Settings
# List of valid Lifecycle Definitions. The dialog gets exposed only if at least one file gets transitioned within this definitions
$lifecycleDefinitions = @("Flexible Release Process","Basic Release Process")
# List of valid Lifecycle States. The dialog gets exposed only if at least one file gets transitioned to this states
$lifecycleStates = @("For Review", "Released")
# List of user groups for the user to select when the dialog gets exposed
$groups = @("Administrators", "Designers", "Project Managers")
#endregion

#region XAML
$global:xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="COOLORANGE powerJobs Client" 
        Height="350" Width="400" FontFamily="Segoe UI" FontSize="12.5"
        WindowStartupLocation="CenterOwner">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="auto" />
            <RowDefinition Height="*" />
            <RowDefinition Height="auto" />
        </Grid.RowDefinitions>
        <Label Grid.Row="0">
            <TextBlock TextWrapping="WrapWithOverflow">
                Select one or more user groups you want to notify. All users of these groups will receive an e-mail notification to inform about the state change.
            </TextBlock>
        </Label>
        <DataGrid Grid.Row="1" Name="EntityGrid" AutoGenerateColumns="False" HorizontalScrollBarVisibility="Disabled" Margin="0,0,0,20" 
                  CanUserReorderColumns="False" CanUserResizeRows="False" Focusable="False">
            <DataGrid.Columns>
                <DataGridTemplateColumn>
                    <DataGridTemplateColumn.CellTemplate>
                        <DataTemplate>
                            <CheckBox IsChecked="{Binding Path=Checked, UpdateSourceTrigger=PropertyChanged}" />
                        </DataTemplate>
                    </DataGridTemplateColumn.CellTemplate>
                </DataGridTemplateColumn>
                <DataGridTextColumn Binding="{Binding Name}" Header="User Group" Width="1*" IsReadOnly="True"/>
            </DataGrid.Columns>
        </DataGrid>
        <Button Grid.Row="2" x:Name="Ok" VerticalAlignment="Bottom" HorizontalAlignment="Right" Height="26" Width="97" Content="OK" />
    </Grid>
</Window>
"@
#endregion

function SelectGroupAndSubmitJob($files, $successful) {
    if(-not $successful) { return }
    
    $affectedFiles = @($files | Where-Object { $lifecycleDefinitions -contains $_._LifeCycleDefinition -and $lifecycleStates -contains $_._State })
    if (-not $affectedFiles) {
        return
    }

    $data = @()
    foreach ($group in $groups) {
        $data += New-Object PsObject -Property @{ Name=$group; Checked=$false }
    }

    $global:sync = [Hashtable]::Synchronized(@{})
    $global:sync.Host = $Host

    $rs = [RunspaceFactory]::CreateRunspace()
    $rs.ApartmentState,$rs.ThreadOptions = "STA","ReUseThread"
    $rs.Open()
    $rs.SessionStateProxy.SetVariable("sync",$sync)
    $rs.SessionStateProxy.SetVariable("xaml",$xaml)
    $rs.SessionStateProxy.SetVariable("data",$data)
    $cmd = [PowerShell]::Create().AddScript({
        Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
        $global:sync.window = [Windows.Markup.XamlReader]::Parse($global:xaml)
        $global:sync.result = $false
        $global:sync.grid = $global:sync.window.FindName('EntityGrid')
        $global:sync.grid.ItemsSource = $data
        $global:sync.button = $global:sync.window.FindName('Ok')
        $global:sync.button.add_Click({
            $global:sync.result = $true
            $global:sync.window.Close()
        })   
        $global:sync.window.ShowDialog()
    })

    $cmd.Runspace = $rs
    $cmd.Invoke() | Out-Null

    $groupNames = ($data | Where-Object { $_.Checked } | Select-Object -ExpandProperty Name) -join ";"
    if ($global:sync.result -ne $true) {
        [System.Windows.Forms.MessageBox]::Show("No group selected. Please don't forget to inform all relevant stakeholders about your changes!", "COOLORANGE powerJobs Client: Group selection canceled!", "OK", "Warning")
    } elseif (-not $groupNames) {
        [System.Windows.Forms.MessageBox]::Show("No group selected. Please don't forget to inform all relevant stakeholders about your changes!", "COOLORANGE powerJobs Client: No group selected!", "OK", "Warning")
    } else {
        $fileIds = $affectedFiles.Id -join ";"
        $jobType = "COOLORANGE.EmailNotification"
        $jobDescription = "Sends an email notification to Vault group members. The groups were manually selected on state change."
        Add-VaultJob -Name $jobType -Description $jobDescription -Priority High -Parameters @{
            "GroupNames" = $groupNames
            "FileIds" = $fileIds
        }
    }

    $rs.Close()
    $rs.Dispose()
    $cmd.Dispose()
}

#region Debug
if ($Host.Name -ne "powerEvents Webservice Extension") { # Only used for debugging purposes!
    function Register-VaultEvent($EventName, $Action) {}
    # https://doc.coolorange.com/projects/coolorange-powervaultdocs/en/stable/code_reference/commandlets/open-vaultconnection.html
    Open-VaultConnection
    $files = @(Get-VaultFiles -Properties @{ Name = "Blower.idw" })
    SelectGroupAndSubmitJob $files $true
}
#endregion

Register-VaultEvent -EventName UpdateFileStates_Post -Action 'SelectGroupAndSubmitJob'