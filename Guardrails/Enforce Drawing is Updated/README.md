[![powerJobs Client](https://img.shields.io/badge/powerJobs_Client-22.0.4-orange.svg)](https://www.coolorange.com/powerjobs)

# Enforce Drawing is Updated

## Description
When a PDF or any other neutral format of an Inventor drawing is created by a Job Processor there is the chance that an outdated Inventor drawing is used to publish the PDF. This can happen if a change is performed to a part or an assembly that is used in the drawing and the drawing is not opened and updated after the model was changed.  

This workflow uses coolOrange **powerJobs Client** to restrict the release of a drawing file - and with that the generation of the neutral format - when when the drawing is older than any of the parts or assemblies that are used in the drawing's structure. For performance reasons, the workflow does not open the drawing file but analyses the references stored in the Vault database to find all files that are involved in the structure of the drawings that are about to be released.

## Benefit
This workflow improves the reliability of your publishing process by ensuring the drawing is up-to-date before it can be released and that published artifacts, like PDFs, are always done with valid drawings. It also means that the publishing step, when done on the Job Processor, need not Get and download all the refrenced model files to make a valid drawing. Instead, the "fastopen" option can be used to create the PDF using only the (usually much smaller) IDW or DWG file as its sole input. For drawings of large complex models this can be a significant time savings.

## Prerequisites
[powerJobs Client](https://www.coolorange.com/powerjobs) version 22.0.4 or later must be installed on the Vault Explorer machine(s)

## Disclaimer
THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)
