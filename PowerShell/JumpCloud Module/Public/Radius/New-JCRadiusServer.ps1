Function New-JCRadiusServer ()
{
    # This endpoint allows you to create new Radius Servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][Alias('Ip')][string]$networkSourceIp,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][ValidateLength(1, 31)][string]$sharedSecret
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
    }
    Process
    {
        $Results = Invoke-JCRadiusServer -Action:('POST') -RadiusServerName:($RadiusServerName) -networkSourceIp:($networkSourceIp) -sharedSecret:($sharedSecret)
    }
    End
    {
        Return $Results
    }
}