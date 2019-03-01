Function Get-JCCommandType
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
# # # Example
# # Get Source object.
# $SourceObject_CommandType = Get-JCCommandType -Type:($SourceType) -SearchBy:($SearchBy) -SearchByValue:($SourceSearchByValue)
# $SourceObject_Command = $SourceObject_CommandType.Command
# $SourceObject_ByName = $SourceObject_CommandType.ByName
# $SourceObject_ById = $SourceObject_CommandType.ById
# Write-Verbose ('Running command: ' + $SourceObject_Command)
# $SourceObject = Invoke-Expression -Command:($SourceObject_Command)
# $SourceObjectId = $SourceObject.$SourceObject_ById
# $SourceObjectName = $SourceObject.$SourceObject_ByName
# # Get Target object.
# $TargetObject_CommandType = Get-JCCommandType -Type:($TargetTypeOption) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
# $TargetObject_Command = $TargetObject_CommandType.Command
# $TargetObject_ByName = $TargetObject_CommandType.ByName
# $TargetObject_ById = $TargetObject_CommandType.ById
# Write-Verbose ('Running command: ' + $TargetObject_Command)
# $TargetObject = Invoke-Expression -Command:($TargetObject_Command)
# $TargetObjectId = $TargetObject.$TargetObject_ById
# $TargetObjectName = $TargetObject.$TargetObject_ByName