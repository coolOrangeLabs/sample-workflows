# samples

[![Windows](https://img.shields.io/badge/Platform-Windows-lightgray.svg)](https://www.microsoft.com/en-us/windows/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5-blue.svg)](https://microsoft.com/PowerShell/)
[![Vault](https://img.shields.io/badge/Autodesk%20Vault-2022-yellow.svg)](https://www.autodesk.com/products/vault/)

[![powerJobs](https://img.shields.io/badge/coolOrange%20powerJobs-22-orange.svg)](https://www.coolorange.com/powerjobs)
[![powerEvents](https://img.shields.io/badge/coolOrange%20powerEvents-22-orange.svg)](https://www.coolorange.com/powerevents)
[![powerGate](https://img.shields.io/badge/coolOrange%20powerGate-22-orange.svg)](https://www.coolorange.com/powergate)
[![powerPLM](https://img.shields.io/badge/coolOrange%20powerPLM-22-orange.svg)](https://www.coolorange.com/powerplm)

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.

THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

## Description

This repository contains various jobs and scripts that demonstrate the power and flexibility of the AUTOMATE products *powerJobs* and *powerEvents* as well as the CONNECT products *powerGate* and *powerPLM*. You can use the sample workflows to add additional value to these products.

## Debugging with powerJobs

In order to obtain a file from Vault and with that running the script in a code editor such as 'Windows PowerShell ISE' or 'Visual Studio Code' instead of powerJobs, the following code can be added to the ps1 scripts.

```powershell
if (-not $IAmRunningInJobProcessor) {
    Import-Module powerJobs
    Open-VaultConnection -Server "localhost" -Vault "Vault" -User "Administrator" -Password ""
    $file = Get-VaultFile -Properties @{Name="Scissors.idw"}
}
```

This additional code establishes a connection to Vault and uses the file 'Scissors.idw' for the particular job if the script gets executed by anything other than powerJobs.

## At your own risk
The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit https://doc.coolorange.com/ for product documentations or you can start a conversation in our support forum at http://support.coolorange.com/support/discussions

## Author
coolOrange S.r.l.  

![coolOrange](https://i.ibb.co/NmnmjDT/Logo-CO-Full-colore-RGB-short-Payoff.png)
