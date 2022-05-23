[![powerJobs](https://img.shields.io/badge/powerJobs_Processor-22.0.19-orange.svg)](https://www.coolorange.com/powerjobs)

# Create Time-Triggered Reports

## Description
This workflow uses coolOrange **powerJobs Processor** to automatically query files from Vault, based on an existing "Saved Search". It uses the search result to render a Vault Report to a PDF file. Finally, the generated PDF file gets checked-in to Vault and exported to a network share. This automated workflow eases the generation of regular reports, reducing the time and cost of creation.

![vault-Report](https://user-images.githubusercontent.com/36193155/166458090-79ebc61e-196e-444f-a353-df77c5a24f37.jpg)

## Prerequisites
[powerJobs](https://www.coolorange.com/powerjobs) version 22.0.19 or later must be installed on the Vault Job Processor machine(s)

## Job Settings
The settings of jobs can be adjusted using the [powerJobs  settings dialog](https://doc.coolorange.com/projects/coolorange-powerjobsprocessordocs/en/stable/job_configuration/#powerjobs-settings-dialog).

## Job Trigger

In order to configure the workflow to be executed in a specific interval the file *C:\ProgramData\coolOrange\powerJobs\Jobs\COOLORANGE.Report.settings* must be configured:

```javascript
{
 "Trigger":
  {
    "TimeBased":	"0 30 8 ? * MON,TUE,WED,THU,FRI *",
    "Vault":		"Vault",
    "Priority":		100,
    "Description":	"Queries Vault and creates a Report as PDF"
  }
}
```
The following settings have to be adjusted:

<table>
  <thead>
    <tr>
      <th>Setting</th>
      <th>Description</th>
      <th>Default</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Time Based</td>
      <td>Indicates when / how often the job should be triggered (cron syntax)</td>
      <td>Every weekday at 8:30 am</td>
    </tr>
    <tr>
      <td>Vault</td>
      <td>Name of the Vault the job should be triggered for</td>
      <td></td>
    </tr>
    <tr>
      <td>Priority</td>
      <td>Priority of the job</td>
      <td>100</td>
    </tr>
  </theaed>
</table>  

**Note**: The powerJobs Processor must be restarted, after you have modified the settings.

## Additional Ressources

### powerJobs Time Triggered Jobs
[https://doc.coolorange.com/projects/powerjobsprocessor/en/stable/jobprocessor.html?highlight=time#time-triggered-jobs](https://doc.coolorange.com/projects/powerjobsprocessor/en/stable/jobprocessor.html?highlight=time#time-triggered-jobs)

### Autodesk Knowledge Network: Saving a Search
[https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/CloudHelp/cloudhelp/2019/ENU/Vault-Essentials/files/GUID-6B47BD0B-67EB-42B5-B6EC-199D9C4143EF-htm.html](https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/CloudHelp/cloudhelp/2019/ENU/Vault-Essentials/files/GUID-6B47BD0B-67EB-42B5-B6EC-199D9C4143EF-htm.html)

### Autodesk Knowledge Network: Create a Report Template
[https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/CloudHelp/cloudhelp/2019/ENU/Vault-Admin/files/GUID-6D1DF94C-7498-4836-9CA8-FFFB25C002EA-htm.html](https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/CloudHelp/cloudhelp/2019/ENU/Vault-Admin/files/GUID-6D1DF94C-7498-4836-9CA8-FFFB25C002EA-htm.html)

### Autodesk Knowledge Network: What software can be used to edit Vaults RDLC Report Templates?
[https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/sfdcarticles/sfdcarticles/We-need-a-BOM-Editor-to-edit-Vaults-rdlc-Report-templates.html](https://knowledge.autodesk.com/support/vault-products/learn-explore/caas/sfdcarticles/sfdcarticles/We-need-a-BOM-Editor-to-edit-Vaults-rdlc-Report-templates.html)

### Autodesk Knowledge Network: How to update Vault Report Templates with new Properties
[https://knowledge.autodesk.com/search-result/caas/screencast/Main/Details/96ef1c8f-80b8-4a6c-90e9-621a325bfb63.html](https://knowledge.autodesk.com/search-result/caas/screencast/Main/Details/96ef1c8f-80b8-4a6c-90e9-621a325bfb63.htm)

### Autodesk AU Online: Custom Reporting in Vault 2019: Dress Up Your Vault Data to Meet the World
[https://www.autodesk.com/autodesk-university/class/Custom-Reporting-Vault-2019-Dress-Your-Vault-Data-Meet-World-2018](https://www.autodesk.com/autodesk-university/class/Custom-Reporting-Vault-2019-Dress-Your-Vault-Data-Meet-World-2018)


## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)
