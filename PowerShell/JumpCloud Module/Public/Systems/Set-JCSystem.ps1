Function Set-JCSystem {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The _id of the System which you want to update in JumpCloud.')]
        [string]
        [Alias('_id', 'id')]
        $SystemID,

        [Parameter(ValueFromPipelineByPropertyName = $true)][string]$displayName,
        [Parameter(ValueFromPipelineByPropertyName = $true)][string]$description,
        [Parameter(ValueFromPipelineByPropertyName = $true)][bool]$allowSshPasswordAuthentication,
        [Parameter(ValueFromPipelineByPropertyName = $true)][bool]$allowSshRootLogin,
        [Parameter(ValueFromPipelineByPropertyName = $true)][bool]$allowMultiFactorAuthentication,
        [Parameter(ValueFromPipelineByPropertyName = $true)][bool]$allowPublicKeyAuthentication,
        [Parameter(ValueFromPipelineByPropertyName = $true)][bool]$systemInsights,
        [Parameter(ValueFromPipelineByPropertyName = $false)]$primarySystemUser,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The number of custom attributes to add or update.')]
        [int]$NumberOfCustomAttributes,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The name of the custom attributes to remove.')]
        [string[]][Alias('RemoveAttribute')]$RemoveCustomAttribute
    )

    DynamicParam {
        # Inicializa o dicionário nativo para evitar falhas de compilação no macOS
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        if ($PSBoundParameters.ContainsKey('NumberOfCustomAttributes') -and $PSBoundParameters['NumberOfCustomAttributes'] -gt 0) {
            [int]$NumberOfCustomAttributes = $PSBoundParameters['NumberOfCustomAttributes']

            for ($ParamNumber = 1; $ParamNumber -le $NumberOfCustomAttributes; $ParamNumber++) {
                $attr = New-Object System.Management.Automation.ParameterAttribute
                $attr.Mandatory = $true
                $attr.ValueFromPipelineByPropertyName = $true
                $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl.Add($attr)
                $param = New-Object System.Management.Automation.RuntimeDefinedParameter("Attribute$ParamNumber`_name", [string], $attrColl)
                $dict.Add("Attribute$ParamNumber`_name", $param)

                $attr1 = New-Object System.Management.Automation.ParameterAttribute
                $attr1.Mandatory = $true
                $attr1.ValueFromPipelineByPropertyName = $true
                $attrColl1 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl1.Add($attr1)
                $param1 = New-Object System.Management.Automation.RuntimeDefinedParameter("Attribute$ParamNumber`_value", [string], $attrColl1)
                $dict.Add("Attribute$ParamNumber`_value", $param1)
            }
        }
        # Sempre retorna o objeto (preenchido ou vazio), neutralizando o bug de binding do Mac
        return $dict
    }

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        $UpdatedSystems = @()
    }

    process {
        $body = @{ }

        foreach ($param in $PSBoundParameters.GetEnumerator()) {
            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.Key) {
                continue
            }
            if ($param.Key -in ('SystemID', 'JCAPIKey', 'NumberOfCustomAttributes', 'RemoveCustomAttribute')) {
                continue
            }
            if ($param.Key -like 'Attribute*') {
                continue
            }
            if ($param.Key -eq 'systemInsights') {
                $state = switch ($systemInsights) {
                    true { 'enabled' }
                    false { 'deferred' }
                }
                $body.add('systemInsights', @{'state' = $state })
                continue
            }
            if ($param.Key -eq "primarySystemUser") {
                $userInfo = $param.Value
                if ($param.Value -eq $null -or $param.Value -eq "") {
                    $body.add("primarySystemUser.id", $null)
                    continue
                } else {
                    try {
                        $primarySystemUserValue = Convert-JCUserToID -UserIdentifier $userInfo
                        $body.add("primarySystemUser.id", $primarySystemUserValue)
                    } catch {
                        Write-Warning "Could not validate $userinfo. Please ensure the user information is correct"
                    }
                    continue
                }
            }
            $body.add($param.Key, $param.Value)
        }

        if ($NumberOfCustomAttributes -or $RemoveCustomAttribute) {
            $CurrentSystem = Get-JCSystem -SystemID $SystemID
            $CurrentAttributesHash = @{ }
            if ($CurrentSystem.attributes) {
                foreach ($CurrentA in $CurrentSystem.attributes) {
                    if ($CurrentA.name) { $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value) }
                }
            }

            if ($NumberOfCustomAttributes -gt 0) {
                for ($i = 1; $i -le $NumberOfCustomAttributes; $i++) {
                    $nameKey = "Attribute$($i)_name"
                    $valueKey = "Attribute$($i)_value"
                    if ($PSBoundParameters.ContainsKey($nameKey)) {
                        $attrName = $PSBoundParameters[$nameKey]
                        $attrValue = $PSBoundParameters[$valueKey]
                        if ($attrName) {
                            $CurrentAttributesHash[$attrName] = $attrValue
                        }
                    }
                }
            }

            if ($RemoveCustomAttribute) {
                foreach ($Remove in $RemoveCustomAttribute) {
                    if ($CurrentAttributesHash.ContainsKey($Remove)) {
                        $CurrentAttributesHash.Remove($Remove)
                    }
                }
            }

            $UpdatedAttributeArrayList = New-Object System.Collections.ArrayList
            foreach ($key in $CurrentAttributesHash.Keys) {
                $temp = [pscustomobject]@{
                    name  = $key
                    value = $CurrentAttributesHash[$key]
                }
                $UpdatedAttributeArrayList.Add($temp) | Out-Null
            }

            $body.add('attributes', $UpdatedAttributeArrayList)
        }

        $jsonbody = $body | ConvertTo-Json
        $URL = "$global:JCUrlBasePath/api/systems/$SystemID"
        $System = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        $UpdatedSystems += $System
    }
    end {
        return $UpdatedSystems
    }
}