Function Invoke-JCRadiusServer
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The verb of the command calling it. Different verbs will make different parameters required.')][ValidateSet('add', 'get', 'new', 'remove', 'set')][System.String]$Action
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
        # Load color scheme
        $JCColorConfig = Get-JCColorConfig
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try
        {
            $Uri_RadiusServers = '/api/radiusservers'
            If ($Action -in ('add', 'new'))
            {
                $Method = 'POST'
                # Build body to be sent to RadiusServers endpoint.
                $JsonBody = '{"name":"' + $Name + '","networkSourceIp":"' + $networkSourceIp + '","sharedSecret":"' + $sharedSecret + '"}'
                $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
            }
            Else
            {
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
                    'ByValue'
                    {
                        Get-JCObject -Type:($Type) -SearchBy:($SearchBy) -SearchByValue:($SearchByValue);
                    }
                    default
                    {
                        Write-Error ('Unknown parameter set name.')
                    }
                }
                If (-not ([System.String]::IsNullOrEmpty($JCObject)))
                {
                    If ($Action -eq 'GET')
                    {
                        $Results = $JCObject
                    }
                    ElseIf ($Action -eq 'remove')
                    {
                        $Uri_RadiusServers = $Uri_RadiusServers + '/' + $JCObject.($JCObject.ById)
                        $Method = 'DELETE'
                        If (!($Force))
                        {
                            Do
                            {
                                Write-Host ('Are you sure you want to "' + $Action + '" the "' + $Type + '": "' + $JCObject.($JCObject.ByName) + '"?[Y/N]') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
                                Write-Host (' ') -NoNewLine
                                $HostResponse = Read-Host
                            }
                            Until ($HostResponse -in ('y', 'n'))
                        }
                        If ($HostResponse -eq 'y' -or $Force)
                        {
                            # Send body to RadiusServers endpoint.
                            $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers)
                        }
                    }
                    ElseIf ($Action -eq 'set')
                    {
                        $Uri_RadiusServers = $Uri_RadiusServers + '/' + $JCObject.($JCObject.ById)
                        $Method = 'PUT'
                        # Build Json body
                        If (!($newName)) { $newName = $JCObject.($JCObject.ByName) }
                        If (!($networkSourceIp)) { $networkSourceIp = $JCObject.networkSourceIp }
                        If (!($sharedSecret)) { $sharedSecret = $JCObject.sharedSecret }
                        $JsonBody = '{"name":"' + $newName + '","networkSourceIp":"' + $networkSourceIp + '","sharedSecret":"' + $sharedSecret + '"}'
                        $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
                    }
                    Else
                    {
                        Write-Error ('Unknown $Action specified.')
                    }
                }
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