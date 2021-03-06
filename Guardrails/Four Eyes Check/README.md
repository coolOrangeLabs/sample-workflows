[![powerJobs Client](https://img.shields.io/badge/powerJobs_Client-22.0.4-orange.svg)](https://www.coolorange.com/powerjobs)

# Four Eyes Check

## Description
For a release process that involves approval step(s) it is generally considered a best practice to require a different person for successive steps. In the example, we show how **powerJobs Client** can be used to enforce a workflow where the person who releases a file is different than the one who reviews it. Variations on this theme can be configured to match your particular best practices, of course. 
![DLG_4eyesCheck](https://user-images.githubusercontent.com/36193155/167151141-3294b521-d102-4358-a3b8-ca550b75a5b9.jpg)

## Benefit
This is yet another examples of **powerJobs Client** acting as "guardrails" for your engineering processes. Assuring that no one ignores this kind of best practice "just this once" is the only way you can be sure that you maintain process integrity and your data stays clean.
## Prerequisites
[powerJobs Client](https://www.coolorange.com/powerjobs) version 22.0.4 or later must be installed on the Vault Explorer machine(s)

## Event Settings
The following settings must be adjusted in the events script:

```powershell
#region Settings
# Lifecycle State from which the file is changed
$FromState = "For Review"
# Target Lifecycle State to which the file is changed
$ToState = "Released"
#endregion
```

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND **THERE IS NO SUPPORT** RELATED TO IT.

The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have any questions, you can visit [https://doc.coolorange.com/](https://doc.coolorange.com/) for product documentations or you can start a conversation in our support forum at [http://support.coolorange.com/support/discussions](http://support.coolorange.com/support/discussions)
