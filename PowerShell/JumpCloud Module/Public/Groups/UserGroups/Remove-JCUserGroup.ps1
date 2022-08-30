Function Remove-JCUserGroup () {
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'warn',
            Position = 0,
            HelpMessage = 'The name of the User Group you want to remove.')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'force',
            Position = 0,
            HelpMessage = 'The name of the User Group you want to remove.')]

        [Alias('name')]
        [String]$GroupName,

        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud User Group.')]
        [Switch]
        $force
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
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
        $GroupNameHash = Get-DynamicHash -Object Group -GroupType User -returnProperties name


    }


    process {
        if ($PSCmdlet.ParameterSetName -eq 'warn') {
            ForEach ($Gname in $GroupName) {
                if ($GroupNameHash.Values.names -contains ($Gname)) {
                    $GID = $GroupNameHash.GetEnumerator().Where({ $_.Value.name -contains ($Gname) }).Name

                    Write-Warning "Are you sure you want to delete group: $Gname ?" -WarningAction Inquire

                    $URI = "$JCUrlBasePath/api/v2/usergroups/$GID"

                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                    $Status = 'Deleted'

                    $FormattedResults = [PSCustomObject]@{

                        'Name'   = $Gname
                        'Result' = $Status

                    }

                    $resultsArray += $FormattedResults
                }

                else {
                    Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'force') {
            ForEach ($Gname in $GroupName) {

                $GID = $GroupNameHash.GetEnumerator().Where({ $_.Value.name -contains ($Gname) }).Name

                try {
                    $URI = "$JCUrlBasePath/api/v2/usergroups/$GID"
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
            }

        }
    }
    end {
        return $resultsArray
    }
}