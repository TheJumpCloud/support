Function New-DynamicParameter ()
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param
    (
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$ParameterName,
        [Parameter(Mandatory = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('string', 'char', 'byte', 'int', 'long', 'bool', 'decimal', 'single', 'double', 'DateTime', 'xml', 'array', 'hashtable')][string]$ParameterType,
        [Parameter(Mandatory = $false, Position = 2)][ValidateNotNullOrEmpty()][bool]$DontShow = $false,
        [Parameter(Mandatory = $false, Position = 3)][ValidateNotNullOrEmpty()][string]$HelpMessage,
        [Parameter(Mandatory = $false, Position = 4)][ValidateNotNullOrEmpty()][bool]$Mandatory = $false,
        [Parameter(Mandatory = $false, Position = 5)][ValidateNotNullOrEmpty()][string]$ParameterSetName = '__AllParameterSets',
        [Parameter(Mandatory = $false, Position = 6)][ValidateNotNullOrEmpty()][int]$Position = 0,
        [Parameter(Mandatory = $false, Position = 7)][ValidateNotNullOrEmpty()][array]$Alias = @(),
        [Parameter(Mandatory = $false, Position = 8)][ValidateNotNullOrEmpty()][bool]$ValueFromPipeline = $false,
        [Parameter(Mandatory = $false, Position = 9)][ValidateNotNullOrEmpty()][bool]$ValueFromPipelineByPropertyName = $false,
        [Parameter(Mandatory = $false, Position = 10)][ValidateNotNullOrEmpty()][bool]$ValueFromRemainingArguments = $false,
        [Parameter(Mandatory = $false, Position = 11)][ValidateNotNullOrEmpty()][array]$ValidateSet = @(),
        [Parameter(Mandatory = $false, Position = 12)][ValidateNotNullOrEmpty()][ValidateCount(2, 2)][array]$ValidateLength = $null,
        [Parameter(Mandatory = $false, Position = 13)][ValidateNotNullOrEmpty()][bool]$ValidateNotNullOrEmpty = $false,
        [Parameter(Mandatory = $false, Position = 14)][ValidateScript( {
                If (-not ( $_ -is [System.Management.Automation.RuntimeDefinedParameterDictionary] -or -not $_) )
                {
                    Throw 'RuntimeDefinedParameterDictionary must be a System.Management.Automation.RuntimeDefinedParameterDictionary object, or not exist'
                }
                $True
            })]
        $RuntimeDefinedParameterDictionary = $false
    )
    # Create the parameters attributes
    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    # Create the collection of attributes
    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

    # Set the parameters attributes
    If ($DontShow) {$ParameterAttribute.DontShow = $DontShow}
    If ($HelpMessage) {$ParameterAttribute.HelpMessage = $HelpMessage}
    If ($Mandatory) {$ParameterAttribute.Mandatory = $Mandatory}
    If ($ParameterSetName) {$ParameterAttribute.ParameterSetName = $ParameterSetName}
    If ($Position) {$ParameterAttribute.Position = $Position}
    If ($ValueFromPipeline) {$ParameterAttribute.ValueFromPipeline = $ValueFromPipeline}
    If ($ValueFromPipelineByPropertyName) {$ParameterAttribute.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName}
    If ($ValueFromRemainingArguments) {$ParameterAttribute.ValueFromRemainingArguments = $ValueFromRemainingArguments}
    # $ParameterAttribute.ExperimentAction = 'None'
    # $ParameterAttribute.ExperimentName = $null
    # $ParameterAttribute.HelpMessageBaseName = $null
    # $ParameterAttribute.HelpMessageResourceId = $null
    # $ParameterAttribute.TypeId
    # Add the attributes to the attributes collection
    $AttributeCollection.Add($ParameterAttribute)

    # Set the ValidateNotNullOrEmpty
    If ($Alias)
    {
        $AliasAttribute = New-Object -TypeName System.Management.Automation.AliasAttribute($Alias)
        $AttributeCollection.Add($AliasAttribute)
    }
    # Set the ValidateNotNullOrEmpty
    If ($ValidateNotNullOrEmpty)
    {
        # Set the ValidateNotNullOrEmpty
        $ValidateNotNullOrEmptyAttribute = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute
        # Add the ValidateNotNullOrEmpty to the attributes collection
        $AttributeCollection.Add($ValidateNotNullOrEmptyAttribute)
    }
    # Set the ValidateSet
    If ($ValidateSet)
    {
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet);
        $AttributeCollection.Add($ValidateSetAttribute)
    }
    # Set the ValidateLengthAttribute
    If ($ValidateLength)
    {
        $ValidateLengthAttribute = New-Object -TypeName System.Management.Automation.ValidateLengthAttribute($ValidateLength[0], $ValidateLength[1])
        $AttributeCollection.Add($ValidateLengthAttribute)
    }
    # Create the dynamic parameter
    $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, $ParameterType, $AttributeCollection)

    #Add the dynamic parameter to an existing dynamic parameter dictionary, or create the dictionary and add it
    If ($RuntimeDefinedParameterDictionary)
    {
        $RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeParameter)
    }
    Else
    {
        $RuntimeDefinedParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeParameter)
        Return $RuntimeDefinedParameterDictionary
    }
}