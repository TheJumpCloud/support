Function Remove-JCRadiusServer ()
{
    # This endpoint allows you to update RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(ParameterSetName = 'force')][Switch]$force
    )
    Begin
    {
        $Method = 'DELETE'
        $Uri_RadiusServers = '/api/radiusservers'
    }
    Process
    {
        $FunctionParameters = [ordered]@{}
        # Get function parameters
        $PSBoundParameters.GetEnumerator() | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
        # Remove PowerShell CommonParameters
        @($FunctionParameters.Keys)| ForEach-Object {If ($_ -in @([System.Management.Automation.PSCmdlet]::CommonParameters)) {$FunctionParameters.Remove($_) | Out-Null}};
        # Run command
        Write-Verbose ('Invoke-JCApi ' + ($FunctionParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        $JCRadiusServers = Get-JCRadiusServer @FunctionParameters
        If ($JCRadiusServers)
        {
            # Build body to be sent to RadiusServers endpoint.
            $JsonBody = '{"isSelectAll":false,"models":[{"_id":"' + $JCRadiusServers._id + '"}]}'
            # Send body to RadiusServers endpoint.
            If ($force) {Write-Warning "Are you sure you wish to delete object: $result ?" -WarningAction:('Inquire')}
            $Results_RadiusServers = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
        }
        Else
        {
            Write-Error ('Unable to find radius server "' + $RadiusServerName + '". Run Get-JCRadiusServers to get a list of all radius servers.')
        }
    }
    End
    {
        Return $Results_RadiusServers
    }
}
# Get-JCRadiusServer
# Remove-JCRadiusServer -RadiusServerName:('Test Me 2') -Verbose
# Remove-JCRadiusServer -RadiusServerId:('5c7db960de58b81706a68edd')
# New-JCRadiusServer -networkSourceIp:('233.233.233.233') -sharedSecret:('HqySCjDJU!7YsQTG2cTHNRV9pF6lSc5') -name:('Test Me 2') -Verbose
