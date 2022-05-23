[![powerJobs](https://img.shields.io/badge/powerJobs_Processor-22.0.19-orange.svg)](https://www.coolorange.com/powerjobs)

# Create STL from Inventor Model

## Description
This workflow uses coolOrange **powerJobs** to create a STL file from an Inventor model (IPT or IAM). The generated STL file can be shared through Vault or by copying it to a configurable network folder. The automated generation and sharing of the STL file on a state change reduces time and costs.

## Prerequisites
[powerJobs Processor](https://www.coolorange.com/powerjobs) version 22.0.19 or later must be installed on the Vault Job Processor machine(s)  

## Job Settings
The settings of the job and especially common STL settings can be adjusted using the [powerJobs  settings dialog](https://doc.coolorange.com/projects/coolorange-powerjobsprocessordocs/en/stable/job_configuration/#powerjobs-settings-dialog).

## Job Trigger
In order to configure the job to be executed on a file lifecycle state transition, Vault's Custom Job Types functionality can be used. [More information](https://doc.coolorange.com/projects/coolorange-powerjobsprocessordocs/en/stable/getting_started/#how-to-embed-the-job-in-a-status-change)

## Additional Ressources

### STL File Format
[https://en.wikipedia.org/wiki/STL_(file_format)](https://en.wikipedia.org/wiki/STL_(file_format))

### STL File Save As Options reference
[https://knowledge.autodesk.com/support/inventor-products/learn-explore/caas/CloudHelp/cloudhelp/2015/ENU/Inventor-Help/files/GUID-59FB702C-F37A-4DEA-ADCF-51AD8A219C9B-htm.html](https://knowledge.autodesk.com/support/inventor-products/learn-explore/caas/CloudHelp/cloudhelp/2015/ENU/Inventor-Help/files/GUID-59FB702C-F37A-4DEA-ADCF-51AD8A219C9B-htm.html)

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)
