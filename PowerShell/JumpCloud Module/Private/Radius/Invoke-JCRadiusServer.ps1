Function Invoke-JCRadiusServer ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('GET', 'PUT', 'DELETE', 'POST')][string]$Action
    )
    DynamicParam
    {
        # Build parameter array
        $Params = @()
        # Define the new parameters
        If ($Action -eq 'GET')
        {
            $Params += @{'Name' = 'RadiusServerId'; 'Type' = [System.String]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; 'ParameterSets' = @('ById'); 'ValidateNotNullOrEmpty' = $true; 'Alias' = @('_id', 'id'); }
            $Params += @{'Name' = 'RadiusServerName'; 'Type' = [System.String]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; 'ParameterSets' = @('ByName'); 'ValidateNotNullOrEmpty' = $true; 'Alias' = @('Name'); }
        }
        Else
        {
            $Params += @{'Name' = 'RadiusServerId'; 'Type' = [System.String]; 'Position' = 1; 'Mandatory' = $true; 'ValueFromPipelineByPropertyName' = $true; 'ParameterSets' = @('ById'); 'ValidateNotNullOrEmpty' = $true; 'Alias' = @('_id', 'id'); }
            $Params += @{'Name' = 'RadiusServerName'; 'Type' = [System.String]; 'Position' = 1; 'Mandatory' = $true; 'ValueFromPipelineByPropertyName' = $true; 'ParameterSets' = @('ByName'); 'ValidateNotNullOrEmpty' = $true; 'Alias' = @('Name'); }
            If ($Action -eq 'PUT')
            {
                $Params += @{'Name' = 'NewRadiusServerName'; 'Type' = [System.String]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; }
                $Params += @{'Name' = 'NewNetworkSourceIp'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; }
                $Params += @{'Name' = 'NewSharedSecret'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; }
            }
            ElseIf ($Action -eq 'DELETE')
            {
                $Params += @{'Name' = 'force'; 'Type' = [bool]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; 'ValidateNotNullOrEmpty' = $true; }
            }
            ElseIf ($Action -eq 'POST')
            {
                $Params += @{'Name' = 'networkSourceIp'; 'Type' = [System.String]; 'Position' = 1; 'Mandatory' = $true; 'ValueFromPipelineByPropertyName' = $true; 'ValidateNotNullOrEmpty' = $true; }
                $Params += @{'Name' = 'sharedSecret'; 'Type' = [System.String]; 'Position' = 2; 'Mandatory' = $true; 'ValueFromPipelineByPropertyName' = $true; 'ValidateNotNullOrEmpty' = $true; 'ValidateLength' = @(1, 31); }
            }
        }
        # Create new parameters
        Return $Params | ForEach-Object {
            New-Object PSObject -Property:($_)
        } | New-DynamicParameter
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {New-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
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
                # Send body to RadiusServers endpoint.
                $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
            }
            ElseIf ($Action -eq 'DELETE')
            {
                # Send body to RadiusServers endpoint.
                If (!($force)) {Write-Warning ('Are you sure you wish to delete object: ' + $RadiusServerObject.($RadiusServerObject.ByName) + ' ?') -WarningAction:('Inquire')}
                # Build body to be sent to RadiusServers endpoint.
                $JsonBody = '{"isSelectAll":false,"models":[{"_id":"' + $RadiusServerObject.($RadiusServerObject.ById) + '"}]}'
                # Send body to RadiusServers endpoint.
                $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
            }
        }
        Else
        {
            If ($Action -eq 'POST')
            {
                # Build body to be sent to RadiusServers endpoint.
                $JsonBody = '{"name":"' + $RadiusServerName + '","networkSourceIp":"' + $networkSourceIp + '","sharedSecret":"' + $sharedSecret + '"}'
                # Send body to RadiusServers endpoint.
                $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
            }
            Else
            {
                Write-Error ('Unable to find radius server. Run Get-JCRadiusServer to get a list of all radius servers.')
            }
        }
    }
    End
    {
        Return $Results
    }
}