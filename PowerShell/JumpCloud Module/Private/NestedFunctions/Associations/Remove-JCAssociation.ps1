Function Remove-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][string]$InputObjectType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][string]$TargetObjectType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 2)][ValidateNotNullOrEmpty()][string]$InputObjectId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 3)][ValidateNotNullOrEmpty()][string]$TargetObjectId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 2)][ValidateNotNullOrEmpty()][string]$InputObjectName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 3)][ValidateNotNullOrEmpty()][string]$TargetObjectName
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        $Action = 'remove'
    }
    Process
    {
        $FunctionParameters = [ordered]@{}
        # Get function parameters and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | ForEach-Object {
            $FunctionParameters.Add($_.Key, $_.Value) | Out-Null
        }
        # Add parameters from the script to the FunctionParameters hashtable
        $FunctionParameters.Add('Action', $Action) | Out-Null
        # Run command
        Write-Verbose ('Invoke-JCAssociation ' + ($FunctionParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        $Results_Associations = Invoke-JCAssociation @FunctionParameters
    }
    End
    {
        Return $Results_Associations
    }
}