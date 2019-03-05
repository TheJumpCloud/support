Function Remove-JCRadiusServer ()
{
    # This endpoint allows you to delete a Radius Server in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][Switch]$force
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        $Method = 'DELETE'
        $Uri_RadiusServers = '/api/radiusservers'
    }
    Process
    {
        $RadiusServerObject = Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                Get-JCObject -Type:('radiusservers') -SearchBy:('ById') -SearchByValue:($RadiusServerId);
            }
            'ByName'
            {
                Get-JCObject -Type:('radiusservers') -SearchBy:('ByName') -SearchByValue:($RadiusServerName);
            }
        }
        If ($RadiusServerObject)
        {
            # Send body to RadiusServers endpoint.
            If (!($force)) {Write-Warning "Are you sure you wish to delete object: $result ?" -WarningAction:('Inquire')}
            # Build body to be sent to RadiusServers endpoint.
            $JsonBody = '{"isSelectAll":false,"models":[{"_id":"' + $RadiusServerObject.($RadiusServerObject.ById) + '"}]}'
            # Send body to RadiusServers endpoint.
            $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
        }
        Else
        {
            Write-Error ('Unable to find radius server "' + $RadiusServerName + '". Run Get-JCRadiusServer to get a list of all radius servers.')
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
# Function Remove-JCRadiusServer ()
# {
#     # This endpoint allows you to update RADIUS servers in your organization.
#     [CmdletBinding(DefaultParameterSetName = 'ById')]
#     param
#     (
#         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
#         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
#         [Parameter(ParameterSetName = 'force')][Switch]$force
#     )
#     Begin
#     {
#         Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
#         $Method = 'DELETE'
#         $Uri_RadiusServers = '/api/radiusservers'
#     }
#     Process
#     {
#         $FunctionParameters = [ordered]@{}
#         # Get function parameters
#         $PSBoundParameters.GetEnumerator() | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
#         # Remove PowerShell CommonParameters
#         @($FunctionParameters.Keys)| ForEach-Object {If ($_ -in @([System.Management.Automation.PSCmdlet]::CommonParameters)) {$FunctionParameters.Remove($_) | Out-Null}};
#         # Run command
#         Write-Verbose ('Invoke-JCApi ' + ($FunctionParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
#         $JCRadiusServers = Get-JCRadiusServer @FunctionParameters
#         If ($JCRadiusServers)
#         {
#             # Build body to be sent to RadiusServers endpoint.
#             $JsonBody = '{"isSelectAll":false,"models":[{"_id":"' + $JCRadiusServers._id + '"}]}'
#             # Send body to RadiusServers endpoint.
#             If ($force) {Write-Warning "Are you sure you wish to delete object: $result ?" -WarningAction:('Inquire')}
#             $Results_RadiusServers = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
#         }
#         Else
#         {
#             Write-Error ('Unable to find radius server "' + $RadiusServerName + '". Run Get-JCRadiusServers to get a list of all radius servers.')
#         }
#     }
#     End
#     {
#         Return $Results_RadiusServers
#     }
# }