function Get-JCRadiusReplyAttribute () {

    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]
    param
    (

        [Parameter(Mandatory, position = 0, ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup',
            HelpMessage = 'The JumpCloud user group to query for Radius attributes.')]
        [Alias('name')]
        [String]$GroupName

    )


    begin {

        Write-Verbose 'Verifying Connection to JumpCloud...'
        if (Test-JCConnection) {
            Connect-JConline
        }

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup') {
            Write-Verbose 'Populating GroupNameHash'
            $GroupNameHash = Get-DynamicHash -Object Group -GroupType User -returnProperties name

        }

    }

    process {

        if ($GroupNameHash.Values.name -contains ($GroupName)) {
            $CurrentAttributes = Get-JCGroup -Type User -Name $GroupName | Select-Object @{Name = "RadiusAttributes"; Expression = { $_.attributes.radius.reply } } | Select-Object -ExpandProperty RadiusAttributes

        } else {
            throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."
        }


    }

    end {
        return $CurrentAttributes
    }

}
