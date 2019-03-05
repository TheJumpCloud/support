Function Invoke-JCRadiusServer ()
{
    # This endpoint allows you to update Radius Servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Action
    )
    DynamicParam
    {
        # Create the parameter dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Define the new parameters
        New-DynamicParameter -ParameterName:('RadiusServerId') -ParameterType:('string') -Position:(0) -Mandatory:($true) -ValueFromPipelineByPropertyName:($true) -ParameterSetName:('ById') -ValidateNotNullOrEmpty:($true) -Alias:(@('_id', 'id')) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
        New-DynamicParameter -ParameterName:('RadiusServerName') -ParameterType:('string') -Position:(0) -Mandatory:($true) -ValueFromPipelineByPropertyName:($true) -ParameterSetName:('ByName') -ValidateNotNullOrEmpty:($true) -Alias:('Name') -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
        If ($Action -eq 'GET')
        {
        }
        ElseIf ($Action -eq 'PUT')
        {
            New-DynamicParameter -ParameterName:('NewRadiusServerName') -ParameterType:('string') -Position:(1) -Mandatory:($false) -ValueFromPipelineByPropertyName:($true)  -ValidateNotNullOrEmpty:($true) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
            New-DynamicParameter -ParameterName:('NewNetworkSourceIp') -ParameterType:('string') -Position:(2) -Mandatory:($false) -ValueFromPipelineByPropertyName:($true) -ValidateNotNullOrEmpty:($true) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
            New-DynamicParameter -ParameterName:('NewSharedSecret') -ParameterType:('string') -Position:(3) -Mandatory:($false) -ValueFromPipelineByPropertyName:($true) -ValidateNotNullOrEmpty:($true) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
        }
        ElseIf ($Action -eq 'DELETE')
        {
            New-DynamicParameter -ParameterName:('force') -ParameterType:('switch') -Position:(1) -Mandatory:($false) -ValueFromPipelineByPropertyName:($true) -ValidateNotNullOrEmpty:($true) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
        }
        ElseIf ($Action -eq 'POST')
        {
            New-DynamicParameter -ParameterName:('networkSourceIp') -ParameterType:('string') -Position:(1) -Mandatory:($false) -ValueFromPipelineByPropertyName:($true) -ValidateNotNullOrEmpty:($true) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
            New-DynamicParameter -ParameterName:('sharedSecret') -ParameterType:('string') -Position:(2) -Mandatory:($false) -ValueFromPipelineByPropertyName:($true) -ValidateNotNullOrEmpty:($true) -ValidateLength:(@(1, 31)) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
        }
        # Return functions parameters
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        # Show all parameters
        # $PsBoundParameters.GetEnumerator()
        # Bind the parameter to a friendly variable
        $RadiusServerId = $PsBoundParameters.RadiusServerId
        $RadiusServerName = $PsBoundParameters.RadiusServerName
        $NewRadiusServerName = $PsBoundParameters.NewRadiusServerName
        $NewNetworkSourceIp = $PsBoundParameters.NewNetworkSourceIp
        $NewSharedSecret = $PsBoundParameters.NewSharedSecret
        $force = $PsBoundParameters.force
        $networkSourceIp = $PsBoundParameters.networkSourceIp
        $sharedSecret = $PsBoundParameters.sharedSecret
        $Method = $Action
    }
    Process
    {
        $Uri_RadiusServers = '/api/radiusservers'
        $RadiusServerObject = Switch ($PSCmdlet.ParameterSetName)
        {
            'ReturnAll'
            {
                Get-JCObject -Type:('radiusservers');
            }
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
            If ($Action -eq 'GET')
            {
                $Results = $RadiusServerObject
            }
            ElseIf ($Action -eq 'PUT')
            {
                # Build Url
                $Uri_RadiusServers = $Uri_RadiusServers + '/' + $RadiusServerObject.($RadiusServerObject.ById)
                # Build Json body
                If (!($NewRadiusServerName)) {$NewRadiusServerName = $RadiusServerObject.($RadiusServerObject.ByName)}
                If (!($NewNetworkSourceIp)) {$NewNetworkSourceIp = $RadiusServerObject.networkSourceIp}
                If (!($NewSharedSecret)) {$NewSharedSecret = $RadiusServerObject.sharedSecret}
                $JsonBody = '{"name":"' + $NewRadiusServerName + '","networkSourceIp":"' + $NewNetworkSourceIp + '","sharedSecret":"' + $NewSharedSecret + '"}'
            }
            ElseIf ($Action -eq 'DELETE')
            {
                # Send body to RadiusServers endpoint.
                If (!($force)) {Write-Warning ('Are you sure you wish to delete object: ' + $RadiusServerObject.($RadiusServerObject.ByName) + ' ?') -WarningAction:('Inquire')}
                # Build body to be sent to RadiusServers endpoint.
                $JsonBody = '{"isSelectAll":false,"models":[{"_id":"' + $RadiusServerObject.($RadiusServerObject.ById) + '"}]}'
            }
            ElseIf ($Action -eq 'POST')
            {
                # Build body to be sent to RadiusServers endpoint.
                $JsonBody = '{"name":"' + $RadiusServerName + '","networkSourceIp":"' + $networkSourceIp + '","sharedSecret":"' + $sharedSecret + '"}'
            }
            # Send body to RadiusServers endpoint.
            $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
        }
        Else
        {
            Write-Error ('Unable to find radius server. Run Get-JCRadiusServer to get a list of all radius servers.')
        }
    }
    End
    {
        Return $Results
    }
}