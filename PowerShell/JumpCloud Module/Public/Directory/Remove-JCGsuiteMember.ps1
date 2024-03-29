function Remove-JCGsuiteMember () {
    param(
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', HelpMessage = 'The name of cloud directory instance')]
        [String]$Name,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The ID of cloud directory instance')]
        [Alias('_id')]
        [String]$ID,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'A username to remove to the directory')]
        [String]$Username,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'A UserID to remove to the directory')]
        [String]$UserID,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'A UserGroup ID to remove to the directory')]
        [String]$GroupID,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'A UserGroup name to remove to the directory')]
        [String]$GroupName
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }
        $resultsArray = [System.Collections.Generic.List[PSObject]]::new()
        $DirectoryHash = Get-JcSdkDirectory | Where-Object type -EQ 'g_suite' | Select-Object id, name
        if (($Username -or $UserID) -and ($GroupID -or $GroupName)) {
            throw "Please use one type of association per call"
        } elseif ($Username -and $UserID) {
            throw "Please use either a username or a userID"
        } elseif ($GroupID -and $GroupName) {
            throw "Please use either a UserGroup Name or a UserGroup ID"
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            ByName {
                Write-Debug "Finding directory by Name"
                $CloudDirectory = $DirectoryHash | Where-Object name -EQ $Name
                if (!$CloudDirectory) {
                    throw "$Name was not found. Please try again"
                } elseif ($CloudDirectory.count -gt 1) {
                    throw "Multiple directories with the same name detected, please use the -id parameter to specify which directory to edit"
                }
            }
            ByID {
                Write-Debug "Finding directory by ID"
                $CloudDirectory = $DirectoryHash | Where-Object Id -EQ $ID
                if (!$CloudDirectory) {
                    throw "$ID was not found. Please try again"
                }
            }
        }
        if ($Username -or $UserID) {
            if ($Username) {
                $UserID = Get-JCUser -username $Username -returnProperties username | Select-Object -ExpandProperty _id
                if (!$UserID) {
                    throw "Username: $Username was not found."
                }
            }
            try {
                Set-JcSdkGSuiteAssociation -GsuiteId $CloudDirectory.Id -Op 'remove' -Type 'user' -Id $UserID
                $Status = 'Removed'
            } catch {
                $Status = $_.Exception.Message
            }
            $FormattedResults = [PSCustomObject]@{

                'DirectoryName' = $CloudDirectory.Name
                'UserID'        = $UserID
                'Status'        = $Status

            }
            $resultsArray += $FormattedResults
        } else {
            if ($GroupName) {
                $GroupID = Get-JcSdkUserGroup -Filter "name:search:$GroupName" | Select-Object -ExpandProperty Id
                if (!$GroupID) {
                    throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."
                }
            }
            try {
                Set-JcSdkGSuiteAssociation -GsuiteId $CloudDirectory.Id -Op 'remove' -Type 'user_group' -Id $GroupID
                $Status = 'Removed'
            } catch {
                $Status = $_.Exception.Message
            }

            $FormattedResults = [PSCustomObject]@{

                'DirectoryName' = $CloudDirectory.Name
                'GroupID'       = $GroupID
                'Status'        = $Status

            }
            $resultsArray += $FormattedResults
        }
    }
    end {
        return $resultsArray
    }
}