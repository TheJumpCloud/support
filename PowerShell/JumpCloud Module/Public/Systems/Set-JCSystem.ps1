Function Set-JCSystem ()
{
    [CmdletBinding()]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string]
        [Alias('_id', 'id')]
        $SystemID,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $displayName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]
        $allowSshPasswordAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]
        $allowSshRootLogin,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]
        $allowMultiFactorAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]
        $allowPublicKeyAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Setting this value to $true will enable systemInsights and collect data for this system. Setting this value to $false will disable systemInsights and data collection for the system.')]
        [bool]
        $systemInsights
    )

    begin

    {

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JConline }

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        $UpdatedSystems = @()
    }

    process
    {
        $body = @{ }

        foreach ($param in $PSBoundParameters.GetEnumerator())
        {

            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

            if ($param.key -eq 'SystemID', 'JCAPIKey') { continue }

            if ($param.key -eq 'systemInsights')
            {
                $state = switch ($systemInsights)
                {
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

    end
    {
        return $UpdatedSystems

    }

}
