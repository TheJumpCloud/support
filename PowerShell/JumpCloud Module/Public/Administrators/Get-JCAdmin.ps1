function Get-JCAdmin {
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'The email of the JumpCloud admin you wish to search for.')]
        [String]$email,
        [Parameter(ValueFromPipelineByPropertyName, Position = 1, HelpMessage = 'A search filter to search for admins with multifactor enabled/disabled.')]
        [Boolean]$enableMultifactor,
        [Parameter(ValueFromPipelineByPropertyName, Position = 2, HelpMessage = 'A search filter to search for admins with totp enabled/disabled.')]
        [Boolean]$totpEnrolled,
        [Parameter(ValueFromPipelineByPropertyName, Position = 3, HelpMessage = 'A search filter to search for admins based on their role')]
        [ValidateSet('Administrator With Billing', 'Administrator', 'Manager', 'Command Runner With Billing', 'Command Runner', 'Help Desk', 'Billing Only', 'Read Only')]
        [String]$roleName,
        [Parameter(ValueFromPipelineByPropertyName, Position = 4, HelpMessage = 'A search filter to search for admins based on their organization (Only for MTP/MSP tenants)')]
        [Alias("organizationID")]
        [String]$organization
    )
    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }

        # Get all JC Orgs
        $JCOrgs = Get-JCOrganization

        # Check to see if there is more than 1 org returned, if so - set the MTP flag to true
        if ($JCOrgs.Count -gt 1) {
            $MTP = $true

            $headers = @{}
            $headers.Add("x-api-key", $JCAPIKEY)
        } else {
            $MTP = $false
        }

        $resultsArrayList = @()
    }
    process {
        [int]$limit = '100'
        Write-Verbose "Setting limit to $limit"

        [int]$skip = '0'
        Write-Verbose "Setting limit to $limit"

        $URL = "$JCUrlBasePath/api/users"
        Write-Verbose $URL

        if ($MTP) {
            # Iterate through all MTP orgs and get all admins
            $JCOrgs | ForEach-Object {
                if ($headers.keys -contains 'x-org-id') {
                    $headers.Remove("x-org-id")
                }
                $orgId = $_.orgId
                $headers.Add("x-org-id", $orgId)

                $response = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/users' -Method GET -Headers $headers

                # For some reason an admin's organization is not set, manually set
                $response.results | ForEach-Object {
                    $_.organization = $orgId
                }

                $resultsArrayList += $response.results
            }
        } else {
            # Not MTP, just get admins in org
            $results = Get-JCResults -URL $URL -method "GET" -limit $limit
            $resultsArrayList += $results
        }

        # Create a FilterScript scriptblock for use in Where-Object to filter the results based on the params used
        $filterScriptArray = @()
        foreach ($param in $PSBoundParameters.GetEnumerator()) {
            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) {
                continue
            }
            if ($param.value -is [Boolean]) {
                $filterScriptArray += "`$_.$($param.key) -eq `$$($param.value)"
                continue
            }
            if ($param.value -is [String]) {
                if ($param.Key -eq 'organizationID') {
                    $filterScriptArray += "`$_.organization -like '$($param.value)'"
                    continue
                } else {
                    $filterScriptArray += "`$_.$($param.key) -like '$($param.value)'"
                    continue
                }
            }
        }
        $filterScriptString = $filterScriptArray -join " -and "
        $filterScript = [Scriptblock]::Create($filterScriptString)

        # Check to see if any filters were set, if not - do not use where-object
        if (!$filterScriptArray) {
            $admins = $resultsArrayList | Select-Object apiKeyUpdatedAt, created, email, enableMultiFactor, firstname, lastname, organization, roleName, suspended, totpEnrolled, totpUpdatedAt
        } else {
            $admins = $resultsArrayList | Where-Object -FilterScript $filterScript | Select-Object apiKeyUpdatedAt, created, email, enableMultiFactor, firstname, lastname, organization, roleName, suspended, totpEnrolled, totpUpdatedAt
        }
    }
    end {
        return $admins
    }
}