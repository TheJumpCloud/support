Function Invoke-JCRadiusServer
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][System.String]$Action
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    DynamicParam
    {
        # Build dynamic parameters
        $RuntimeParameterDictionary = Get-DynamicParamRadiusServer -Action:($Action) -Type:($Type) -Force:($true)
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
        $Results = @()
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try
        {
            # $PsBoundParameters
            # Write-Host ($PSCmdlet.ParameterSetName) -BackgroundColor Cyan
            $JCObject = Switch ($PSCmdlet.ParameterSetName)
            {
                'Default'
                {
                    Get-JCObject -Type:($Type);
                }
                'ById'
                {
                    Get-JCObject -Type:($Type) -SearchBy:($PSCmdlet.ParameterSetName) -SearchByValue:($Id);
                }
                'ByName'
                {
                    Get-JCObject -Type:($Type) -SearchBy:($PSCmdlet.ParameterSetName) -SearchByValue:($Name);
                }
            }
            If ($Action -eq 'GET')
            {
                $Results = $JCObject
            }
            Else
            {
                $Uri_RadiusServers = '/api/radiusservers'
                $Uri_RadiusServers = $Uri_RadiusServers + '/' + $JCObject.($JCObject.ById)
                If ($Action -eq 'PUT')
                {
                    # Build Json body
                    If (!($Name)) { $Name = $JCObject.($JCObject.ByName) }
                    If (!($NetworkSourceIp)) { $NetworkSourceIp = $JCObject.networkSourceIp }
                    If (!($SharedSecret)) { $SharedSecret = $JCObject.SharedSecret }
                    $JsonBody = '{"name":"' + $Name + '","networkSourceIp":"' + $NetworkSourceIp + '","SharedSecret":"' + $SharedSecret + '"}'
                }
                ElseIf ($Action -eq 'DELETE')
                {
                    # Build body to be sent to RadiusServers endpoint.
                    $JsonBody = '{"isSelectAll":false,"models":[{"_id":"' + $JCObject.($JCObject.ById) + '"}]}'
                    If (!($force)) { Write-Warning ('Are you sure you wish to delete object: ' + $JCObject.($JCObject.ByName) + ' ?') -WarningAction:('Inquire') }
                }
                ElseIf ($Action -eq 'POST')
                {
                    # Build body to be sent to RadiusServers endpoint.
                    $JsonBody = '{"name":"' + $RadiusServerName + '","networkSourceIp":"' + $networkSourceIp + '","SharedSecret":"' + $SharedSecret + '"}'
                }
                # Send body to RadiusServers endpoint.
                Write-Host ("Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)") -BackgroundColor:('Cyan')
                # $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
            }
        }
        Catch
        {
            Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_, $true) -NoNewScope
        }
    }
    End
    {
        If ($Results)
        {
            # List values to hide in results
            $HiddenProperties = @('httpMetaData')
            Return Hide-ObjectProperty -Object:($Results) -HiddenProperties:($HiddenProperties)
        }
    }
}