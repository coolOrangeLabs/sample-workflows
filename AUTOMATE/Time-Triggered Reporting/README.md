[![powerJobs](https://img.shields.io/badge/powerJobs-22-orange.svg)](https://www.coolorange.com/powerjobs)

# Time-Triggered Reporting

## Description
This sample workflow uses coolOrange **powerJobs** to automatically query files from Vault, based on an existing "Saved Search". It uses the search result to render a Vault Report to a PDF file. Finally, the generated PDF file gets checked-in to Vault and exported to a network share.

## Prerequisites
[powerJobs](https://www.coolorange.com/powerjobs) must be installed on the Vault Job Processor machine(s)

## Installation
Download all files from the current subdirectory of this repository to *C:\ProgramData\coolOrange

## Job Settings

### ReportFileLocation
Full Path of the RDLC report template file. This file needs to accessible by powerJobs on the Vault Job Processor machine  
Defaults to: C:\Program Files\Autodesk\Vault Client 2022\Explorer\Report Templates\File Transmittal.rdlc

### SavedSearchName
Name of the Saved Search. This Saved Search needs to available on the Vault Job Processor machine with the exact same server name and Vault name

### PdfFileName
Name of the Report exported to PDF  
E.g.: AllCheckedOutFiles.pdf

### PdfVaultFolder
Specify a Vault folder in which the PDF should be stored (e.g. \$/Designs/PDF), or leave the setting empty to not store the report in Vault  
Defaults to: \$/Designs/Reports

### PdfNetworkFolder
Specify a network share into which the PDF should be copied (e.g. \\\\SERVERNAME\Share\Public\Reports\), or leave the setting empty to not copy the report to a shared folder

## Job Trigger

In order to configure the workflow to be executed in a specific interval the file *C:\ProgramData\coolOrange\powerJobs\Jobs\Sample.Report.settings* must be configured:

```javascript
{
 "Trigger":
  {
    "TimeBased":	"0 0 8 ? * MON,TUE,WED,THU,FRI *",
    "Vault":		"Vault",
    "Priority":		100,
    "Description":	"Queries Vault and creates a Report as PDF"
  }
}
```
The following settings have to be adjusted:

| Setting | Description | Default |
| --- | --- | --- |
| Time Based | Indicates when / how often the job should be triggered (cron syntax) | Every weekday at 8am |
| Vault | Name of the Vault the job should be triggered for  |  |
| Priority | Priority of the job | 100 |

## Additional Ressources

### powerJobs Time Triggered Jobs
https://doc.coolorange.com/projects/powerjobsprocessor/en/stable/jobprocessor.html?highlight=time#time-triggered-jobs

### Autodesk Knowledge Network: Saving a Search
https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/CloudHelp/cloudhelp/2019/ENU/Vault-Essentials/files/GUID-6B47BD0B-67EB-42B5-B6EC-199D9C4143EF-htm.html

### Autodesk Knowledge Network: Create a Report Template
https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/CloudHelp/cloudhelp/2019/ENU/Vault-Admin/files/GUID-6D1DF94C-7498-4836-9CA8-FFFB25C002EA-htm.html

### Autodesk Knowledge Network: What software can be used to edit Vaults RDLC Report Templates?
https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/sfdcarticles/sfdcarticles/We-need-a-BOM-Editor-to-edit-Vaults-rdlc-Report-templates.html

### How to update Vault Report Templates with new Properties
https://knowledge.autodesk.com/search-result/caas/screencast/Main/Details/96ef1c8f-80b8-4a6c-90e9-621a325bfb63.html

### Autodesk AU Online: Custom Reporting in Vault 2019: Dress Up Your Vault Data to Meet the World
https://www.autodesk.com/autodesk-university/class/Custom-Reporting-Vault-2019-Dress-Your-Vault-Data-Meet-World-2018


## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit https://doc.coolorange.com/ for product documentations or you can start a conversation in our support forum at http://support.coolorange.com/support/discussions
