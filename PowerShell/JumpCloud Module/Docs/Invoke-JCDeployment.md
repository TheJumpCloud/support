---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Invoke-JCDeployment
schema: 2.0.0
---

# Invoke-JCDeployment

## SYNOPSIS
Triggers a JumpCloud Command Deployment using the CommandID and a filled out deployment CSV file.

## SYNTAX

```
Invoke-JCDeployment [-CommandID] <String> -CSVFilePath <String> [<CommonParameters>]
```

## DESCRIPTION
JumpCloud command deployments are commands that are configured with system specific unique variables. These variables are deployed within the payload of the JumpCloud command from the values populated in the command deployment CSV file and create a 1:1 association between the payload of a JumpCloud command and the target system it is being run on. Using JumpCloud command deployments administrators can craft a single command that deploys with a system specific payload.
Deployment commands must have zero system associations at time of deployment. If any associations exist the command will alert the admin and prompt to remove any associations to continue.
This is because under the hood the Invoke-JCDeployment command makes three API calls for each target system in the CSV file.
The first add the system to the target command.
The second triggers the command with the system specific variables using the command 'Invoke-JCCommand' and the '-NumberOfVariables' parameter.
The third removes the system from the target command.
This process occurs for each system within the deployment CSV input file.
A progress bar shows a status of the deployment. *Note* systems must be online and reporting as Active to receive the deployment command.

## EXAMPLES

### Example 1
```powershell
Invoke-JCDeployment -CommandID 5f6r55es2189782h48091999 -CSVFilePath ./JCDeployment_UsernameUpdate.csv

SystemID                 CommandID                Status
--------                 ---------                ------
5t5o055171de492597ath123 5f6r55es2189782h48091999 Deployed
6t7o055171de492597ath456 5f6r55es2189782h48091999 Deployed
8t9o055171de492597ath789 5f6r55es2189782h48091999 Deployed
1t0o015171de492597ath101 5f6r55es2189782h48091999 Deployed
```

Invokes the JumpCloud command with command ID '5f6r55es2189782h48091999' using the deployment csv file 'JCDeployment_UsernameUpdate.csv'. The output shows that the deployment CSV file contained four systems.

## PARAMETERS

### -CSVFilePath
The full path to the CSV deployment file.
You can use tab complete to search for .csv files.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandID
The _id of the JumpCloud command you wish to deploy.
To find a JumpCloud CommandID run the command: PS C:\\\> Get-JCCommand | Select name, _id

The CommandID will be the 24 character string populated for the _id field.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
