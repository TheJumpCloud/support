Function Remove-JCSystemGroup () {
    [CmdletBinding(DefaultParameterSetName = 'byName')]
    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'byName',
            Position = 0,
            HelpMessage = 'The name of the System Group you want to remove.')]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            HelpMessage = 'The _id of the group which you want to remove. GroupID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically.')]
        [Alias('_id', 'id')]
        [String]$GroupID,

        [Parameter(ParameterSetName = 'byName')]
        [Parameter(
            ParameterSetName = 'ByID',
            HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud System  Group.')]
        [Switch]
        $force
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JConline
        }

        Write-Debug 'Populating API headers'
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Debug 'Initilizing rawResults and results resultsArray'
        $resultsArray = @()

        Write-Debug 'Populating GroupNameHash'
        $GroupNameHash = Get-DynamicHash -Object Group -GroupType System -returnProperties name
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            if ($GroupNameHash.Values.name -contains ($GroupName)) {
                $GID = $GroupNameHash.GetEnumerator().Where({ $_.Value.name -contains ($GroupName) }).Name

                if ('force' -notin $PSBoundParameters.keys) {
                    Write-Warning "Are you sure you want to delete group: $GroupName ?" -WarningAction Inquire
                }
                try {
                    $URI = "$JCUrlBasePath/api/v2/systemgroups/$GID"
                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                    $Status = 'Deleted'
                } catch {
                    $Status = $_.ErrorDetails
                }
                $FormattedResults = [PSCustomObject]@{
                    'Name'   = $Gname
                    'Result' = $Status
                }
                $resultsArray += $FormattedResults
            } else {
                Throw "Group does not exist. Run 'Get-JCGroup -type system' to see a list of all your JumpCloud system groups."
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            if ($GroupNameHash[$groupID]) {
                if ('force' -notin $PSBoundParameters.keys) {
                    Write-Warning "Are you sure you want to delete group: $($GroupNameHash[$groupID].name) ?" -WarningAction Inquire
                }
                try {
                    $URI = "$JCUrlBasePath/api/v2/systemgroups/$groupID"
                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                    $Status = 'Deleted'
                } catch {
                    $Status = $_.ErrorDetails
                }
                $FormattedResults = [PSCustomObject]@{
                    'Name'   = $GroupNameHash[$groupID].name
                    'Result' = $Status
                }
                $resultsArray += $FormattedResults
            } else {
                Throw "Group does not exist. Run 'Get-JCGroup -type system' to see a list of all your JumpCloud system groups."
            }
        }
    }
    end {
        return $resultsArray
    }
}