[![powerJobs Client](https://img.shields.io/badge/powerJobs_Client-22.0.4-orange.svg)](https://www.coolorange.com/powerjobs)

# Update File Properties on lifecycle state change

## Description
Automatically updates file properties when a file lifecycle state changes. This workflow requires the Vault User Defined Properties (UDPs) "Checked By", "Checked On", "Approved By" and "Approved On" to be present in Vault.

This workflow demonstrates how PreUpdate and PostUpdate actions are used to update properties depending on the users permissions. A file property cannot be updated when the file is locked because in a  released state. Therefore the update needs to be executed either before the file is released or after the file is transitioned from a released state to a non-released state.

The properties `$file._State`,  `$file._NewState`, or `$file._OldState` are used to dethermine the from-state and the to-state, depending on whether the file properties get updated before or after the lifecycle state transition.

The function ***PreUpdateFileStates*** is used when there **is write permission** in the **Initial** state.  
* When the file is set from state "Work in Progress" to "For Review", the UDPs "Checked By" and "Checked On" get filled.  
* When the file is set from state "For Review" to "Released", the UDPs "Approved By" and "Approved On" get filled.


The function ***PostUpdateFileStates*** is used when there **is no write permission** in the **Initial** state, but in the **Target** state.  
The  4 UDPs are are emptied in the function ***PostUpdateFileStates*** after the file was set from state "Released" to "Work in Progress".

The sample uses the file category name "Engineering" as a 'condition'. Other categories as well as other objects like file extesnsions can be used as a 'condition'.

## Benefit ##
One of the most important reasons to use a PDM system like Autodesk Vault is that it serves as a permanent record of who created, checked and approved each change to each design file. It also keeps permanent records of changes to other metadata in the form of Properties. This critical information can also be mapped into your CAD files where it can be used to populate things like title block records. Without this property mapping you can't be sure that your drawings accurately reflect the true state of your data's lifecycle. This can be critical in applications where the provenance of design changes must be accurate for regulatory or industry standard best practices.

## Prerequisites
[powerJobs Client](https://www.coolorange.com/powerjobs) version 22.0.4 or later must be installed on the Vault Explorer machine(s)  

## Event Settings
The following settings must be adjusted in the events script:

```powershell
#region Settings
# Lifecycle State for Review from which the file is changed
$WIP_State = "Work in Progress"
# Target Lifecycle State for Review to which the file is changed
$Review_State = "For Review"
# Target Lifecycle State for Release to which the file is changed
$Released_State = "Released"
# Category for drawings 
$DrawingCategory = "Engineering" #"Drawing Inventor"
# UDP for User who has put the file from $WIP_State to $Review_State
$udp_CheckedBy = "Checked By"
# UDP for Date when the file was set from $WIP_State to $Review_State
$udp_CheckedOn = "Checked On"
# UDP for User who has put the file from $WIP_State to $Review_State
$udp_ApprovedBy = "Approved By"
# UDP for Date when the file was set from $WIP_State to $Review_State
$udp_ApprovedOn = "Approved On"
#endregion
```

## Additional Ressources

### Code Reference: UpdateFileStates
[https://doc.coolorange.com/projects/powerevents/en/stable/code_reference/objects/event_mappings/file_events/updatefilestates/](https://doc.coolorange.com/projects/powerevents/en/stable/code_reference/objects/event_mappings/file_events/updatefilestates/)

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)
