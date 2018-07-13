Function Set-JCSystem ()
{
    [CmdletBinding()]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string]
        [Alias('_id', 'id')]
        $SystemID,

        [Parameter()]
        [string]
        $displayName,

        [Parameter()]
        [bool]
        $allowSshPasswordAuthentication,

        [Parameter()]
        [bool]
        $allowSshRootLogin,

        [Parameter()]
        [bool]
        $allowMultiFactorAuthentication,

        [Parameter()]
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

        $System = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.4.1'

        $UpdatedSystems += $System
    }

    end
    {
        return $UpdatedSystems

    }

}