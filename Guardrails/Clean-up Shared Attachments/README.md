[![powerJobs Client](https://img.shields.io/badge/powerJobs_Client-22.0.4-orange.svg)](https://www.coolorange.com/powerjobs)

# Clean-up shared Attachments when a new revision is released


## Description
PDFs are often shared in a **network folder for production** to be accessed by people without access to Vault. These are often considered the **official** version of that drawing. In order for this to always be true, the old version of the PDF must deleted and replaced each time a new official version is released. If the old PDF cannot be deleted, perhaps because someone has it opened or locked, the release must be prevented and the user notified so they can fix the shared file.
This workflow uses coolOrange **powerJobs Client** to restrict the release of the selected file when the deletion of the shared PDF file fails.

***Note:*** The script assumes that the PDF on the network folder is also linked as an attachment to the drawing in Vault in order to determine the file name of the PDF. If this is not the case, the PDF filename must be adjusted in the script. There are, of course, variations on this general approach that can be achieved by modifying the scripts.

## Benefit:
Having valid artifacts on shared drives is crucial to downstream processes of all kinds. Out of date drawings - or other files - on shared drives can cause very expensive production, procurement and tooling mistakes including buying the wrong parts, making out of spec parts to stock or retooling machines incorrectly. All of these cause waste of time, money and materials.

## Prerequisites
[powerJobs Client](https://www.coolorange.com/powerjobs) version 22.0.4 or later must be installed on the Vault Explorer machine(s)  
The PDF on the network folder is a copy of the linked attachment of the drawing in Vault.

## Event Settings
The following settings must be adjusted in the events script:

```powershell
#region Settings
# Specify a network share into which the PDFs are copied by powerJobs Processor (e.g. \\SERVERNAME\Share\Public\PDFs\)
$networkFolder = "\\SERVERNAME\Share\Public\PDFs"
#endregion
```

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)
