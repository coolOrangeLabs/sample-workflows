[![powerJobs](https://img.shields.io/badge/powerJobs_Processor-22.0.19-orange.svg)](https://www.coolorange.com/powerjobs)

# Create PDFs with Watermarks

## Description
This workflow uses coolOrange **powerJobs** to create a PDF file from a CAD drawing and stamp a watermark to the PDF file. Such a watermark can be e.g. the state of the drawing that is used in the shop floor for production. Settings like the text size, color, orientation or aligment can be easily configured in the script of **settings dialog**. Thus, this workflow helps to build reliable processes and reduces unnecessary costs.  
There are two flavors of this workflow:

* *COOLORANGE.CreatePDFAndWatermark* creates a PDF file from a CAD drawing and adds a watermark in the middle of the drawing.  
![PDF-Watermark_1](https://user-images.githubusercontent.com/36193155/165478911-ba3c2837-7efc-4290-be23-6eabd1844702.jpg)  
* *COOLORANGE.CreatePDFAndWatermarkBottom* creates a PDF file from a CAD drawing and adds a watermark to the botton right corner.  
![PDF-Watermark_3](https://user-images.githubusercontent.com/36193155/165480615-f54f6841-c003-4033-a10c-16f699267b8b.jpg)

## Prerequisites
[powerJobs Processor](https://www.coolorange.com/powerjobs) version 22.0.19 or later must be installed on the Vault Job Processor machine(s)  

## Job Settings
The settings of jobs can be adjusted using the [powerJobs  settings dialog](https://doc.coolorange.com/projects/coolorange-powerjobsprocessordocs/en/stable/job_configuration/#powerjobs-settings-dialog).

## Job Trigger
In order to configure the job to be executed on a file lifecycle state transition, Vault's Custom Job Types functionality can be used. [More information](https://doc.coolorange.com/projects/coolorange-powerjobsprocessordocs/en/stable/getting_started/#how-to-embed-the-job-in-a-status-change)

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)
