Function New-JCPolicyGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'FromTemplateID',
            Mandatory = $true,
            HelpMessage = 'The Policy Template ID to apply to this MTP org. This parameter will only work in MTP organizations'
        )]
        [system.string]
        $TemplateID,
        [Parameter(
            ParameterSetName = 'Name',
            Mandatory = $true,
            HelpMessage = 'The name of the policy group to create'
        )]
        [system.string]
        $Name,
        [Parameter(
            ParameterSetName = 'Name',
            Mandatory = $false,
            HelpMessage = 'The description of the policy group to create'
        )]
        [system.string]
        $Description
    )
    begin {
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

        switch ($PSCmdlet.ParameterSetName) {
            "FromTemplateID" {
                $URL = "$JCUrlBasePath/api/v2/organizations/$env:JCOrgId/policygroups/fromtemplate"
                $BODY = @{
                    templateId = $TemplateID
                } | ConvertTo-Json
            }
            "Name" {
                $URL = "$JCUrlBasePath/api/v2/policygroups"
                $BODY = @{
                    name        = "$Name"
                    description = if ($Description) { $Description } else { $null }

                } | ConvertTo-Json
            }

        }
    }
    process {
        # TODO: CUT-4439 eventually Invoke-JCAPI should have a dynamic list of policy endpoints that do not accept ORGIDs in the headers.
        Invoke-JCApi -URL:("$URL") -Method:("POST") -Body:($Body)
    }
    end {
        return $response
    }
}