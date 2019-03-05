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
        $Method = 'POST'
        $Uri_RadiusServers = '/api/radiusservers'
    }
    Process
    {
        # Build body to be sent to RadiusServers endpoint.
        $JsonBody = '{"name":"' + $RadiusServerName + '","networkSourceIp":"' + $networkSourceIp + '","sharedSecret":"' + $sharedSecret + '"}'
        # Send body to RadiusServers endpoint.
        $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
    }
    End
    {
        Return $Results
    }
}
############################################################
#######################Splatting############################
############################################################
# Function New-JCRadiusServer ()
# {
#     # This endpoint allows you to create RADIUS servers in your organization.
#     [CmdletBinding(DefaultParameterSetName = 'Default')]
#     param
#     (
#         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
#         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][Alias('Ip')][string]$networkSourceIp,
#         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][ValidateLength(1, 31)][string]$sharedSecret
#     )
#     Begin
#     {
#         $Method = 'POST'
#         $Uri_RadiusServers = '/api/radiusservers'
#     }
#     Process
#     {
#         # Build body to be sent to RadiusServers endpoint.
#         $FunctionParameters = [ordered]@{}
#         # Get function parameters
#         $PSBoundParameters.GetEnumerator() | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
#         # Remove PowerShell CommonParameters
#         @($FunctionParameters.Keys)| ForEach-Object {If ($_ -in @([System.Management.Automation.PSCmdlet]::CommonParameters)) {$FunctionParameters.Remove($_) | Out-Null}};
#         # Rename parameters in the FunctionParameters hashtable
#         If ($FunctionParameters.Contains('RadiusServerName'))
#         {
#             $FunctionParameters.Add('name', $FunctionParameters['RadiusServerName']) | Out-Null
#             $FunctionParameters.Remove('RadiusServerName') | Out-Null
#         }
#         # Convert body to json.
#         $JsonBody = $FunctionParameters | ConvertTo-Json -Depth 10 -Compress
#         # Run command
#         Write-Verbose ("Invoke-JCApi -Method:('$Method') -Url:('$Uri_RadiusServers') -Body:('$JsonBody')")
#         $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
#     }
#     End
#     {
#         Return $Results
#     }
# }