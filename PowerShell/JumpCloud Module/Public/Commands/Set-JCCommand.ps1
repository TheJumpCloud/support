Function Set-JCCommand
{
    [CmdletBinding()]

    param (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $CommandID,

        [Parameter(
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $name,

        [Parameter(
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $command,

        [Parameter(
            ValueFromPipelineByPropertyName = $True)]
        [string]
        [ValidateSet('trigger', 'manual')]
        $launchType,

        [Parameter(
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $timeout

    )

    DynamicParam
    {

        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary


        If ($launchType -eq "trigger")
        {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter a trigger name. Triggers must be unique"
            $attr.ValueFromPipelineByPropertyName = $true
            $attr.Mandatory = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('trigger', [string], $attrColl)
            $dict.Add('trigger', $param)

        }

        return $dict

    }

    begin
    {

        Write-Verbose 'Verifying JCAPI Key'
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

        $URL = "$JCUrlBasePath/api/commands/$($CommandID)"

        Write-Verbose 'Initilizing NewCommandsArray'
        $NewCommandsArray = @()

    }

    process
    {

        $body = @{}

        foreach ($param in $PSBoundParameters.GetEnumerator())
        {

            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

            if ($param.key -eq 'CommandID', 'JCAPIKey') { continue }

            $body.add($param.Key, $param.Value)

        }

        $jsonbody = $body | ConvertTo-Json

        $NewCommand = Invoke-RestMethod -Uri $URL -Method PUT -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        $NewCommandsArray += $NewCommand

    }

    end
    {

        Return $NewCommandsArray

    }
}