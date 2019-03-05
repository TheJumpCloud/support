Function Get-JCRadiusServerGroup ()
{
    # This endpoint allows you to get a list of all RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
    }
    Process
    {
        $Results = Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                Get-JCAssociation -InputObjectType:('radiusservers') -InputObjectId:($RadiusServerId)  -TargetObjectType:('user_group');
            }
            'ByName'
            {
                Get-JCAssociation -InputObjectType:('radiusservers') -InputObjectName:($RadiusServerName)  -TargetObjectType:('user_group');
            }
        }
    }
    End
    {
        Return $Results
    }
}
############################################################
#######################Splatting############################
############################################################
# Function Get-JCRadiusServerGroup ()
# {
#     # This endpoint allows you to get a list of all RADIUS servers in your organization.
#     [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
#     Param
#     (
#         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
#         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName
#     )
#     Begin
#     {
#         $InputObjectType = 'radiusservers'
#         $TargetObjectType = 'user_group'
#     }
#     Process
#     {
#         # Create $FunctionParameters hashtable for splatting
#         $FunctionParameters = [ordered]@{}
#         # Get function parameters and filter out unnecessary parameters
#         $PSBoundParameters.GetEnumerator() | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
#         # Add parameters from the script to the FunctionParameters hashtable
#         $FunctionParameters.Add('InputObjectType', $InputObjectType) | Out-Null
#         $FunctionParameters.Add('TargetObjectType', $TargetObjectType) | Out-Null
#         # Rename parameters in the FunctionParameters hashtable
#         If ($FunctionParameters.Contains('RadiusServerId'))
#         {
#             $FunctionParameters.Add('InputObjectId', $FunctionParameters['RadiusServerId']) | Out-Null
#             $FunctionParameters.Remove('RadiusServerId') | Out-Null
#         }
#         If ($FunctionParameters.Contains('RadiusServerName'))
#         {
#             $FunctionParameters.Add('InputObjectName', $FunctionParameters['RadiusServerName']) | Out-Null
#             $FunctionParameters.Remove('RadiusServerName') | Out-Null
#         }
#         Write-Verbose ('Get-JCAssociation ' + ($FunctionParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
#         $Results = Get-JCAssociation @FunctionParameters
#     }
#     End
#     {
#         Return $Results
#     }
# } 