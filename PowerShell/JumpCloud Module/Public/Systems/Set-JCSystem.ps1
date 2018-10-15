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
        $allowPublicKeyAuthentication
    )

    begin

    {

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

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
        $body = @{}

        foreach ($param in $PSBoundParameters.GetEnumerator())
        {

            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

            if ($param.key -eq 'SystemID', 'JCAPIKey') { continue }

            $body.add($param.Key, $param.Value)

        }

        $jsonbody = $body | ConvertTo-Json

        Write-Debug $jsonbody

        $URL = "https://console.jumpcloud.com/api/systems/$SystemID"

        Write-Debug $URL

        $System = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.8.2'

        $UpdatedSystems += $System
    }

    end
    {
        return $UpdatedSystems

    }

}