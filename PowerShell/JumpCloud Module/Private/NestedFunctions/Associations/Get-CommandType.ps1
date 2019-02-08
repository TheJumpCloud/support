Function Get-CommandType
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        # Any other parameters can go here
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][string]$Type,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][string]$SearchBy,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][string]$SearchByValue
    )
    $TypeCommand = @()
    $TypeCommand += [PSCustomObject]@{'Type' = @('system', 'systems'); 'JCFunction' = 'Get-JCSystem'; 'ById' = '_id'; 'ByName' = 'DisplayName'; }
    $TypeCommand += [PSCustomObject]@{'Type' = @('user', 'users'); 'JCFunction' = 'Get-JCUser'; 'ById' = '_id'; 'ByName' = 'UserName'; }
    $TypeCommand += [PSCustomObject]@{'Type' = @('radiusservers'); 'JCFunction' = 'Get-JCRadiusServer'; 'ById' = '_id'; 'ByName' = 'name'; }
    $TypeCommand += [PSCustomObject]@{'Type' = @('system_group', 'user_group'); 'JCFunction' = 'Get-JCGroup2'; 'ById' = 'id'; 'ByName' = 'name'; }
    # Identify the command type to run to get the object for the specified item
    $TypeCommandItem = $TypeCommand | Where-Object {$Type -in $_.Type}
    If ($TypeCommandItem)
    {
        $TypeCommandItem.Type = $Type
        $JCFunction = $TypeCommandItem.JCFunction
        $PropertyIdentifier = Switch ($SearchBy)
        {
            'ById' {$TypeCommandItem.ById};
            'ByName' {$TypeCommandItem.ByName};
        }
        $Command_Template = "{0} -{1}:('{2}');"
        $Object_Command = $Command_Template -f $JCFunction, $PropertyIdentifier, $SearchByValue
        Return $TypeCommandItem | Select-Object *, @{Name = 'PropertyIdentifier'; Expression = {$PropertyIdentifier}}, @{Name = 'Command'; Expression = {$Object_Command}}
    }
    Else
    {
        Write-Error ('$Type of "' + $Type + '" not found. $Type must be:' + $TypeCommand.Type -join ',')
    }
}