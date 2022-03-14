# Sample Workflows

[![Windows](https://img.shields.io/badge/Platform-Windows-lightgray.svg)](https://www.microsoft.com/en-us/windows/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5-blue.svg)](https://microsoft.com/PowerShell/)
[![Vault](https://img.shields.io/badge/Autodesk%20Vault-2022-yellow.svg)](https://www.autodesk.com/products/vault/)

[![powerJobs Processor](https://img.shields.io/badge/coolOrange%20powerJobs%20Processor-22-orange.svg)](https://www.coolorange.com/powerjobs)
[![powerJobs Client](https://img.shields.io/badge/coolOrange%20powerJobs%20Client-22-orange.svg)](https://www.coolorange.com/powerjobs)
[![powerGate](https://img.shields.io/badge/coolOrange%20powerGate-22-orange.svg)](https://www.coolorange.com/powergate)
[![powerPLM](https://img.shields.io/badge/coolOrange%20powerPLM-22-orange.svg)](https://www.coolorange.com/powerplm)

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

## Description

This repository contains various jobs and scripts that demonstrate the power and flexibility of the AUTOMATE products *powerJobs Processor* and *powerJobs Client* as well as the CONNECT products *powerGate* and *powerPLM*. You can use the workflows to add additional value to your installations.

## Installation

Each workflow can be downloaded and copied to the Vault Client or Vault JobProcessor machines. To speed up that process a workflow installer is available that guides you through the installation process. The workflow installer can be downloaded [here](https://github.com/coolOrangeLabs/sample-workflows/releases/latest).
The workflow installer does not distinguish between server and client components and cannot not be used for deployments. It should only be used to install the workflows on a test- or demo-environment where powerJobs Processor and powerJobs Client are installed on a single machine.

If you need help with the customization or the deployment of a sample workflow and want to use it for productive puropses please contact sales@coolorange.com.

## Debugging
powerJobs Processor and powerJobs Client scripts can run independently from Vault in a PowerShell code editor such as 'Windows PowerShell ISE' or 'Visual Studio Code'.
This is handy when a script needs to be changed to modify the business logic.

To provide a context when executed independently, the scripts need to establish a connection to Vault and retrieve a file or any other entity. This would usually be done automatically by powerJobs Processor or powerJobs Client.

### powerJobs Processor Scripts

```powershell
if (-not $IAmRunningInJobProcessor) {
    Import-Module powerJobs
    
    Open-VaultConnection -Server "localhost" -Vault "Vault" -User "Administrator" -Password ""
    
    $file = Get-VaultFile -Properties @{Name="Scissors.idw"}
}
```

This additional code needs to be placed on top of a powerJobs job script. It imports the required PowerShell modules, performs a sign-in to Vault, and uses the file 'Scissors.idw' every time the script gets executed by anything other than powerJobs Processor.

### powerJobs Client (a.k.a. powerEvents) Scripts

```powershell
if ($Host.Name -ne "powerEvents Webservice Extension") { 
    Import-Module powerEvents
    
    function Register-VaultEvent($EventName, $Action) {}
    function Add-VaultRestriction($EntityName, $Message) { Write-Error "$($EntityName): $($Message)" }

    Open-VaultConnection -Server "localhost" -Vault "Vault" -User "Administrator" -Password ""

    $file = Get-VaultFiles -Properties @{ Name = "Blower.idw" }
    $file | Add-Member NoteProperty "_NewLifeCycleDefinition" "Flexible Release Process"
    $file | Add-Member NoteProperty "_NewState" "Released"
    $files = @($file)

    YourFunctionThatWouldNormallyByExecutedByTheEvent $files $true
}
```

This additional code needs to be placed before the 'Register-VaultEvent' cmdlet and after the function that is executed by the event (in the example above this would be *YourFunctionThatWouldNormallyByExecutedByTheEvent*). The code imports the required PowerShell modules, introduces temporary functions, performs a sign-in to Vault, and uses the file 'Blower.idw' every time the script gets executed by anything other than powerJobs Client. In addition it temorarily adds the properties "_NewLifeCycleDefinition" and "_NewState" to the Blower.idw file for the business logic to mimic a lifecycle state transition for debugging purposes.

## Author
coolOrange S.r.l.

<img src="https://i.ibb.co/NmnmjDT/Logo-CO-Full-colore-RGB-short-Payoff.png" width="250">
