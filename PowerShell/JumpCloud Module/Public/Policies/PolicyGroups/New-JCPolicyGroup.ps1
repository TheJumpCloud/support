Function New-JCPolicyGroup {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'FromTemplateID')]
        [system.string]
        $TemplateID,
        [Parameter(ParameterSetName = 'Name')]
        [system.string]
        $Name
    )
    begin {

        switch ($PSCmdlet.ParameterSetName) {
            "FromTemplateID" {
                $headers = @{
                    "x-api-key" = $env:JCApiKey
                }
                $URL = "$JCUrlBasePath/api/v2/organizations/$env:JCOrgId/policygroups/fromtemplate"
                $BODY = @{
                    templateId = $TemplateID
                } | ConvertTo-Json
            }
            "Name" {
                $headers = @{
                    "x-api-key" = $env:JCApiKey
                    "x-org-id"  = $env:JCOrgId
                }
                $URL = "$JCUrlBasePath/api/v2/policygroups"
                $BODY = @{
                    name = "$Name"
                } | ConvertTo-Json
            }

        }
    }
    process {
        # TODO: CUT-4439 eventually Invoke-JCAPI should have a dynamic list of policy endpoints that do not accept ORGIDs in the headers.
        $response = Invoke-RestMethod -Uri $URL -Method POST -Headers $headers -ContentType 'application/json' -Body $BODY

    }
    end {
        return $response
    }
}