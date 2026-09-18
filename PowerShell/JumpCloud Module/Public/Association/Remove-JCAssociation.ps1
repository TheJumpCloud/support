function Remove-JCAssociation {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    dynamicparam {
        $Action = 'remove'
        $RuntimeParameterDictionary = if ($Type) {
            Get-DynamicParamAssociation -Action:($Action) -Force:($Force) -Type:($Type)
        } else {
            Get-DynamicParamAssociation -Action:($Action) -Force:($Force)
        }
        return $RuntimeParameterDictionary
    }
    begin {
        Connect-JCOnline -force | Out-Null
        $PSBoundParameters | Out-DebugParameter | Write-Debug
        $Results = @()
    }
    process {
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        $FunctionParameters = [ordered]@{}

        #check if $PSBoundParameters is array of objects or a single object and convert to array if not
        if ($PSBoundParameters -isnot [array]) {
            $jc_list = @($PSBoundParameters)
        }

        $jc_list | ForEach-Object {
            # Add input parameters from function in to hash table and filter out unnecessary parameters
            $_.GetEnumerator() | Where-Object { -not [System.String]::IsNullOrEmpty($_.Value) } | ForEach-Object { $FunctionParameters.Add($_.Key, $_.Value) | Out-Null }
            ($FunctionParameters).Add('Action', $Action) | Out-Null

            @('TargetType', 'TargetId', 'Id', 'Type') | ForEach-Object {
                if (-not $FunctionParameters.Contains($_)) {
                    throw "Missing required parameter: $_"
                }

                # If the value is an array, extract the first item and overwrite the hashtable value
                if ($FunctionParameters[$_] -is [array]) {
                    $FunctionParameters[$_] = $FunctionParameters[$_] | Select-Object -First 1
                }
            }
            $CleanType = $FunctionParameters['type']
            $CleanTargetId = $FunctionParameters['targetid']
            $CleanId = $FunctionParameters['id']

            # Write-Host $FunctionParameters
            if (Test-JCDynamicGroupMembership -Type:($CleanType) -TargetId:($CleanTargetId) -Id:($CleanId)) {
                Write-Verbose ('Skipping removal of association with dynamic group. Dynamic associations cannot be manually removed from dynamic groups.')
                return
            }

            $Results += Invoke-JCAssociation @FunctionParameters
        }
    }
    end {
        return $Results
    }
}