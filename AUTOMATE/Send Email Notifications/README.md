[![powerJobs](https://img.shields.io/badge/powerJobs_Processor-22.0.19-orange.svg)](https://www.coolorange.com/powerjobs)
[![powerJobs Client](https://img.shields.io/badge/powerJobs_Client-22.0.4-orange.svg)](https://www.coolorange.com/powerjobs)

# Send Email Notifications

## Description
This workflow uses coolOrange **powerJobs Client** to expose a dialog where users can select one or multiple user groups from Vault when file state changes.


After the group has been selected a job is automaticall triggered. The job is executed by coolOrange **powerJobs Processor** and sends an email notification to all users of the selected groups.


## Prerequisites
[powerJobs Processor](https://www.coolorange.com/powerjobs) version 22.0.19 or later must be installed on the Vault Job Processor machine(s)  
[powerJobs Client](https://www.coolorange.com/powerjobs) version 22.0.4 or later must be installed on the Vault Explorer machine(s)  

## Event Settings
The following settings must be adjusted in the events script COOLORANGE.EmailNotificatiton.Trigger.ps1:

```powershell
#region Settings
# List of valid Lifecycle Definitions. The dialog gets exposed only if at least one file gets transitioned within this definitions
$lifecycleDefinitions = @("Flexible Release Process","Basic Release Process")
# List of valid Lifecycle States. The dialog gets exposed only if at least one file gets transitioned to this states
$lifecycleStates = @("For Review", "Released")
# List of user groups for the user to select when the dialog gets exposed
$groups = @("Administrators", "Designers", "Project Managers")
#endregion
```

## Job Settings
The settings of jobs can be adjusted using the [powerJobs  settings dialog](https://doc.coolorange.com/projects/coolorange-powerjobsprocessordocs/en/stable/job_configuration/#powerjobs-settings-dialog).

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)