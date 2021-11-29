Function Global:New-DynamicParameter ()
{
    <#
  .SYNOPSIS
   Expedites creating PowerShell cmdlet dynamic parameters.
  .DESCRIPTION
   This cmdlet facilitates the easy creation of dynamic parameters.
  .PARAMETER Name
   The name of the parameter.
  .PARAMETER Type
   The type of the parameter, this defaults to System.String.
  .PARAMETER Mandatory
   Indicates whether the parameter is required when the cmdlet or function is run.
  .PARAMETER ParameterSets
   The name of the parameter sets to which this parameter belongs. This defaults to __AllParameterSets.
  .PARAMETER Position
   The position of the parameter in the command-line string.
  .PARAMETER ValueFromPipeline
   Indicates whether the parameter can take values from incoming pipeline objects.
  .PARAMETER ValueFromPipelineByPropertyName
   Indicates that the parameter can take values from a property of the incoming pipeline object that has the same name as this parameter. For example, if the name of the cmdlet or function parameter is userName, the parameter can take values from the userName property of incoming objects.
  .PARAMETER ValueFromRemainingArguments
   Indicates whether the cmdlet parameter accepts all the remaining command-line arguments that are associated with this parameter.
  .PARAMETER HelpMessage
   A short description of the parameter.
  .PARAMETER DontShow
   Indicates that this parameter should not be shown to the user in this like intellisense. This is primarily to be used in functions that are implementing the logic for dynamic keywords.
  .PARAMETER Alias
   Declares a alternative namea for the parameter.
  .PARAMETER ValidateNotNull
   Validates that the argument of an optional parameter is not null.
  .PARAMETER ValidateNotNullOrEmpty
   Validates that the argument of an optional parameter is not null, an empty string, or an empty collection.
  .PARAMETER AllowEmptyString
   Allows Empty strings.
  .PARAMETER AllowNull
   Allows null values.
  .PARAMETER AllowEmptyCollection
   Allows empty collections.
  .PARAMETER ValidateScript
   Defines an attribute that uses a script to validate a parameter of any Windows PowerShell function.
  .PARAMETER ValidateSet
   Defines an attribute that uses a set of values to validate a cmdlet parameter argument.
  .PARAMETER ValidateRange
   Defines an attribute that uses minimum and maximum values to validate a cmdlet parameter argument.
  .PARAMETER ValidateCount
   Defines an attribute that uses maximum and minimum limits to validate the number of arguments that a cmdlet parameter accepts.
  .PARAMETER ValidateLength
   Defines an attribute that uses minimum and maximum limits to validate the number of characters in a cmdlet parameter argument.
  .PARAMETER ValidatePattern
   Defines an attribute that uses a regular expression to validate the character pattern of a cmdlet parameter argument.
  .PARAMETER RuntimeParameterDictionary
   The dictionary to add the new parameter to. If one is not provided, a new dictionary is created and returned to the pipeline.
  .EXAMPLE
   DynamicParam {
    ...
    $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    New-DynamicParameter -Name "Numbers" -ValidateSet @(1, 2, 3) -Type [System.Int32] -Mandatory -RuntimeParameterDictionary $RuntimeParameterDictionary | Out-Null
    ...
    return $RuntimeParameterDictionary
   }
   A new parameter named "Numbers" is added to the cmdlet. The parameter is mandatory and must be 1, 2, or 3. The dictionary sent in is modified and does not need to be received.
  .EXAMPLE
   DynamicParam {
    ...
    $Params = @(
     @{
      "Name" = "Numbers";
      "ValidateSet" = @(1, 2, 3);
      "Type" = [System.Int32]
     },
     @{
      "Name" = "FirstName";
      "Type" = [System.String];
      "Mandatory" = $true;
      "ParameterSets" = @("Names")
     }
    )
    $Params | ForEach-Object {
     New-Object PSObject -Property $_
    } | New-DynamicParameter
   }
   The example creates an array of two hashtables. These hashtables are converted into PSObjects so they can match the parameters by property name, then new dynamic parameters are created. All of the
   parameters are fed to New-DynamicParameter which returns a single new RuntimeParameterDictionary to the pipeline, which is returned from the DynamicParam section.
   .EXAMPLE
    Function Invoke-NewDynamicParameterTest
    {
        [CmdletBinding()]
        Param()
        DynamicParam
        {
            # Define new parameters
            $Params = @(
                @{'Name' = 'Numbers'; 'ValidateSet' = @(1, 2, 3); 'Type' = [System.Int32]},
                @{'Name' = 'FirstName'; 'Type' = [System.String]; 'Mandatory' = $true; 'ParameterSets' = @('Names')}
            )
            # Create new parameters
            Return $Params | ForEach-Object {
                New-Object PSObject -Property:($_)
            } | New-DynamicParameter
        }
        Begin
        {
            # Create new variables for script
            $PsBoundParameters.GetEnumerator() | ForEach-Object {Set-Variable -Name:($_.Key) -Value:($_.Value) -Force}
            # Debug message for parameter call
            Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False')}) )
            If($PSCmdlet.ParameterSetName -ne '__AllParameterSets'){Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
        }
        Process
        {
            Write-Output ('')
            Write-Output ('Numbers: ' + [string]$Numbers + '; FirstName: ' + $FirstName + ';')
        }
        End
        {
        }
    }
    Invoke-NewDynamicParameterTest -Numbers:(1) -FirstName:('hello')
  .INPUTS
   System.Management.Automation.PSObject
  .OUTPUTS
   System.Management.Automation.RuntimeDefinedParameterDictionary
  .NOTES
    AUTHOR: Michael Haken
    LAST UPDATE: 2/6/2018
    WEBSITE: https://www.powershellgallery.com/packages/BAMCIS.DynamicParam/1.0.0.0/Content/BAMCIS.DynamicParam.psm1
 #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][System.String]$Name,
        # These parameters are part of the standard ParameterAttribute
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNull()][System.Type]$Type = [System.String],
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$Mandatory,
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateCount(1, [System.Int32]::MaxValue)][System.String[]]$ParameterSets = @("__AllParameterSets"),
        [Parameter(ValueFromPipelineByPropertyName = $true)][System.Int32]$Position = [System.Int32]::MinValue,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$ValueFromPipeline,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$ValueFromPipelineByPropertyName,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$ValueFromRemainingArguments,
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][System.String]$HelpMessage,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$DontShow,
        # These parameters are each their own attribute
        [Parameter(ValueFromPipelineByPropertyName = $true)][System.String[]]$Alias = @(),
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$ValidateNotNull,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$ValidateNotNullOrEmpty,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$AllowEmptyString,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$AllowNull,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Switch]$AllowEmptyCollection,
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][System.Management.Automation.ScriptBlock]$ValidateScript,
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNull()][System.String[]]$ValidateSet = @(),
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][ValidateCount(2, 2)][System.Int32[]]$ValidateRange = $null,
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][ValidateCount(2, 2)][System.Int32[]]$ValidateCount = $null,
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][ValidateCount(2, 2)][System.Int32[]]$ValidateLength = $null,
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][System.String]$ValidatePattern = $null,
        [Parameter(ValueFromPipelineByPropertyName = $true)][ValidateNotNull()][System.Management.Automation.RuntimeDefinedParameterDictionary]$RuntimeParameterDictionary = $null
    )
    Begin
    {
        If ($RuntimeParameterDictionary -eq $null)
        {
            $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        }
    }
    Process
    {
        # Create the collection of attributes
        $AttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        ForEach ($Set In $ParameterSets)
        {
            # Create and set the parameter's attributes
            $ParameterAttribute = New-Object -TypeName System.Management.Automation.PARAMETERAttribute
            If (-not [System.String]::IsNullOrEmpty($Set))
            {
                $ParameterAttribute.ParameterSetName = $Set
            }
            If ($Position -ne $null)
            {
                $ParameterAttribute.Position = $Position
            }
            If ($Mandatory)
            {
                $ParameterAttribute.Mandatory = $true
            }
            If ($ValueFromPipeline)
            {
                $ParameterAttribute.ValueFromPipeline = $true
            }
            If ($ValueFromPipelineByPropertyName)
            {
                $ParameterAttribute.ValueFromPipelineByPropertyName = $true
            }
            If ($ValueFromRemainingArguments)
            {
                $ParameterAttribute.ValueFromRemainingArguments = $true
            }
            If (-not [System.String]::IsNullOrEmpty($HelpMessage))
            {
                $ParameterAttribute.HelpMessage = $HelpMessage
            }
            If ($DontShow)
            {
                $ParameterAttribute.DontShow = $true
            }
            $AttributeCollection.Add($ParameterAttribute)
        }
        If ($Alias.Length -gt 0)
        {
            $AliasAttribute = New-Object -TypeName System.Management.Automation.AliasAttribute($Alias)
            $AttributeCollection.Add($AliasAttribute)
        }
        If ($ValidateSet.Length -gt 0)
        {
            $ValidateSetAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute($ValidateSet)
            $AttributeCollection.Add($ValidateSetAttribute)
        }
        If ($ValidateScript -ne $null)
        {
            $ValidateScriptAttribute = New-Object -TypeName System.Management.Automation.ValidateScriptAttribute($ValidateScript)
            $AttributeCollection.Add($ValidateScriptAttribute)
        }
        If ($ValidateCount -ne $null -and $ValidateCount.Length -eq 2)
        {
            $ValidateCountAttribute = New-Object -TypeName System.Management.Automation.ValidateCountAttribute($ValidateCount[0], $ValidateCount[1])
            $AttributeCollection.Add($ValidateCountAttribute)
        }
        If ($ValidateLength -ne $null -and $ValidateLength -eq 2)
        {
            $ValidateLengthAttribute = New-Object -TypeName System.Management.Automation.ValidateLengthAttribute($ValidateLength[0], $ValidateLength[1])
            $AttributeCollection.Add($ValidateLengthAttribute)
        }
        If (-not [System.String]::IsNullOrEmpty($ValidatePattern))
        {
            $ValidatePatternAttribute = New-Object -TypeName System.Management.Automation.ValidatePatternAttribute($ValidatePattern)
            $AttributeCollection.Add($ValidatePatternAttribute)
        }
        If ($ValidateRange -ne $null -and $ValidateRange.Length -eq 2)
        {
            $ValidateRangeAttribute = New-Object -TypeName System.Management.Automation.ValidateRangeAttribute($ValidateRange)
            $AttributeCollection.Add($ValidateRangeAttribute)
        }
        If ($ValidateNotNull)
        {
            $NotNullAttribute = New-Object -TypeName System.Management.Automation.ValidateNotNullAttribute
            $AttributeCollection.Add($NotNullAttribute)
        }
        If ($ValidateNotNullOrEmpty)
        {
            $NotNullOrEmptyAttribute = New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute
            $AttributeCollection.Add($NotNullOrEmptyAttribute)
        }
        If ($AllowEmptyString)
        {
            $AllowEmptyStringAttribute = New-Object -TypeName System.Management.Automation.AllowEmptyStringAttribute
            $AttributeCollection.Add($AllowEmptyStringAttribute)
        }
        If ($AllowEmptyCollection)
        {
            $AllowEmptyCollectionAttribute = New-Object -TypeName System.Management.Automation.AllowEmptyCollectionAttribute
            $AttributeCollection.Add($AllowEmptyCollectionAttribute)
        }
        If ($AllowNull)
        {
            $AllowNullAttribute = New-Object -TypeName System.Management.Automation.AllowNullAttribute
            $AttributeCollection.Add($AllowNullAttribute)
        }
        If (-not $RuntimeParameterDictionary.ContainsKey($Name))
        {
            $RuntimeParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($Name, $Type, $AttributeCollection)
            $RuntimeParameterDictionary.Add($Name, $RuntimeParameter)
        }
        Else
        {
            ForEach ($Attr In $AttributeCollection.GetEnumerator())
            {
                If (-not $RuntimeParameterDictionary.$Name.Attributes.Contains($Attr))
                {
                    $RuntimeParameterDictionary.$Name.Attributes.Add($Attr)
                }
            }
        }
    }
    End
    {
        Write-Output -InputObject $RuntimeParameterDictionary
    }
}
