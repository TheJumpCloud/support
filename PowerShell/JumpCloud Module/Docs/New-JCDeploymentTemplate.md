---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/New-JCDeploymentTemplate
schema: 2.0.0
---

# New-JCDeploymentTemplate

## SYNOPSIS
A guided walk through that creates a command deployment CSV file on your local machine.

## SYNTAX

```
New-JCDeploymentTemplate [<CommonParameters>]
```

## DESCRIPTION
The New-JCDeploymentTemplate command is a menu driven interactive function that guides admins through the process of creating a command deployment CSV file and assists in gathering the required information needed to populate the command deployment CSV file.

Note: Windows commands and Mac/Linux commands interpret variables differently. Windows commands with variables you wish to replace during Invoke-JCDeployment should be written as '${ENV:$variableToReplace}' within the command body. The header variables of Windows Command Deployment CSVs should be prefixed with '$'

Example valid Windows PowerShell command:
```powershell
#!bin/bash
# Download Employee CSV:
$url = https://companyFileshare/employee/handbook.pdf
# save file to userpath/filename defined in jcdeployment csv
Invoke-WebRequest -Uri $url -OutFile ${ENV:$UserPath}\${ENV:$FileName}
```

Example Valid Mac/Linux CSV:
| "SystemID"               	| "$UserPath"              	| "$FileName"             |
|--------------------------	|-------------------------	|----------------------- |
| 602c4806e87bc117c434fb71 	| "C:\Users\Joe\Desktop"   	| "PDF_JoeToSign.pdf"    |
| 60623c9d0bab5a18614d4d6d 	| "C:\Users\Bob\Desktop"   	| "PDF_BobToSign.pdf"    |
| 6025b5aa115b9917f6903436 	| "C:\Users\Steve\Desktop" 	| "PDF_SteveToSign.pdf"  |

Mac and Linux commands work similarly in the sense that command body variables such as '$variableToReplace' will be replaced when running Invoke-JCDeployment. The header variables of a Mac/Linux Command Deployment CSV do not need to be prefixed with '$'

Example valid Mac/Linux command:
```sh
#!bin/bash
# Download Employee CSV:
$url = https://companyFileshare/employee/handbook.pdf
# save file to userpath/filename defined in jcdeployment csv
curl -L -o $UserPath/$FileName $url >/dev/null
```

Example Valid Mac/Linux CSV:
| "SystemID"               	| "UserPath"              	| "FileName"             |
|--------------------------	|-------------------------	|----------------------- |
| 602c4806e87bc117c434fb71 	| "/Users/Joe/Desktop"   	| "PDF_JoeToSign.pdf"    |
| 60623c9d0bab5a18614d4d6d 	| "/Users/Bob/Desktop"   	| "PDF_BobToSign.pdf"    |
| 6025b5aa115b9917f6903436 	| "/Users/Steve/Desktop" 	| "PDF_SteveToSign.pdf"  |

## EXAMPLES

### Example 1
```powershell
PS C:\> New-JCDeploymentTemplate
```

Launches the New-JCDeploymentTemplate menu

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
