Function Set-JCSystem () {
    [CmdletBinding()]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The _id of the System which you want to remove from JumpCloud. The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID. This is shown in EXAMPLE 2')]
        [string]
        [Alias('_id', 'id')]
        $SystemID,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The system displayName. The displayName is set to the hostname of the system during agent installation. When the system hostname updates the displayName does not update.')]
        [string]
        $displayName,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The system description. String param to set system description')]
        [string]
        $description,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to allow for ssh password authentication.')]
        [bool]
        $allowSshPasswordAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to allow for ssh root login.')]
        [bool]
        $allowSshRootLogin,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to allow for MFA during system login. Note this setting only applies systems running Linux or Mac.')]
        [bool]
        $allowMultiFactorAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to allow for public key authentication.')]
        [bool]
        $allowPublicKeyAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'Setting this value to $true will enable systemInsights and collect data for this system. Setting this value to $false will disable systemInsights and data collection for the system.')]
        [bool]
        $systemInsights
    )

    begin {

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JConline }

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

            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

            if ($param.key -eq 'SystemID', 'JCAPIKey') { continue }

            if ($param.key -eq 'systemInsights') {
                $state = switch ($systemInsights) {
                    true { 'enabled' }
                    false { 'deferred' }
                }
                $body.add('systemInsights', @{'state' = $state })

                continue
            }

            $body.add($param.Key, $param.Value)

        }

        $jsonbody = $body | ConvertTo-Json

        Write-Debug $jsonbody

        $URL = "$JCUrlBasePath/api/systems/$SystemID"

        Write-Debug $URL

        $System = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        $UpdatedSystems += $System
    }

    end {
        return $UpdatedSystems

    }

}
