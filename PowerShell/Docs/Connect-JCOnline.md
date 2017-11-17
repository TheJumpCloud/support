---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Connect-JCOnline

## SYNOPSIS

The Connect-JCOnline function sets the global variable $JCAPIKEY

## SYNTAX

```PowerShell
Connect-JCOnline [-JumpCloudAPIKey] <String>
```

## DESCRIPTION

By calling the Connect-JConline function you are setting the variable $JCAPIKEY within the global scope. By setting this variable in the global scope the variable $JCAPIKEY can be reused by other functions in the JumpCloud module. If you wish to change the API key to connect to another JumpCloud org simply call the Connect-JConline function and enter the alternative API key.

## EXAMPLES

### Example 1

```PowerShell
Connect-JCOnline lu8792c9d4y2398is1tb6h0b83ebf0e92s97t382
```

## PARAMETERS

### -JumpCloudAPIKey

Your JumpCloud API key.
This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.
Note that each administrator within a JumpCloud tenant has their own unique API key and can reset this API key from this settings page.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS