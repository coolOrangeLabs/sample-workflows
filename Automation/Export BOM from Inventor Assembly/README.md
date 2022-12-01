[![powerJobs](https://img.shields.io/badge/powerJobs_Processor-22.0.19-orange.svg)](https://www.coolorange.com/powerjobs)
[![powerJobs Client](https://img.shields.io/badge/powerJobs_Client-22.0.4-orange.svg)](https://www.coolorange.com/powerjobs)

# Export BOM from Inventor Assembly

## Description

This workflow uses coolOrange **powerJobs Client** to check if the structured BOM is enabled when releasing an Inventor assembly. If the Structured BOM is disabled, the file cannot be released, otherwise a job is triggered automatically. 

<img src="https://user-images.githubusercontent.com/5640189/159670406-4da7e053-c622-4107-80ad-43c56e7d77c8.PNG" width="400">

When the corresponding job is executed by coolOrange **powerJobs Processor** it extracts the Structured BOM data from the vaulted assembly, creates a CSV file with this information and saves the CSV file to a shared folder so that it can be consumed by other software such as an ERP system.

<img src="https://user-images.githubusercontent.com/5640189/159669328-dd70fd63-38f1-487e-a06f-66ab90160761.png" width="700">

## Benefit

CAD wielding engineers almost never work in a vacuum. The result of their work often initiates a chain of actions by other people with other jobs related to product design, but who don't use CAD or Vault. Often these folks just need a precise list of all the parts that the engineer specified. This can be for procurement, inventory management, shop floor and machine station scheduling and even as input to other enterprise software systems like ERP. 

Wether the next user reads the BOM into Excel for ad-hoc processing or feeds it directly into their ERP or Procurement system it is absolutely vital that the engineer doesn't forget to generate the structured BOM in Inventor. Failure to update the BOM can have consequences ranging from the minor annoyance - like the engineer having to respond to email asking for it from a purchasing agent - to the catestrophic - that same purchasing agent orders thousands of the wrong parts because they didn't even know there *was* a new BOM.


## Prerequisites
[powerJobs Processor](https://www.coolorange.com/powerjobs) version 22.0.19 or later must be installed on the Vault Job Processor machine(s)  
[powerJobs Client](https://www.coolorange.com/powerjobs) version 22.0.4 or later must be installed on the Vault Explorer machine(s)  


## Job Settings
The settings of jobs can be adjusted using the [powerJobs  settings dialog](https://doc.coolorange.com/projects/coolorange-powerjobsprocessordocs/en/stable/job_configuration/#powerjobs-settings-dialog).

## Job Trigger
There is no need to configure "Custom Job Types" in Vault as **powerJobs Client** intelligently triggers the jobs for Inventor assemblies only when the file is released.

## Additional Ressources

### COOLORANGE Blog: Everything you need to know about the BOM
[https://www.coolorange.com/en/blog/everything-you-need-to-know-about-the-bom-coolorange](https://www.coolorange.com/en/blog/everything-you-need-to-know-about-the-bom-coolorange)

### Autodesk AU Online: Share Your Bill of Materials: Connecting PDM, PLM, and ERP
[https://www.autodesk.com/autodesk-university/class/Share-Your-Bill-Materials-Connecting-PDM-PLM-and-ERP-2021](https://www.autodesk.com/autodesk-university/class/Share-Your-Bill-Materials-Connecting-PDM-PLM-and-ERP-2021)


## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)
