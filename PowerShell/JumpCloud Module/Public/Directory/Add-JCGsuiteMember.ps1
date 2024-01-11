function Add-JCGsuiteMember () {
    param(
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', HelpMessage = 'The name of cloud directory instance')]
        [String]$Name,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The ID of cloud directory instance')]
        [Alias('_id')]
        [String]$ID,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'A username to add to the directory')]
        [String]$Username,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'A UserID to add to the directory')]
        [String]$UserID,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'A UserGroup ID to add to the directory')]
        [String]$GroupID,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'A UserGroup name to add to the directory')]
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
            throw "Please add one type of association per call"
        } elseif ($Username -and $UserID) {
            throw "Please use either a username or a userID"
        } elseif ($GroupID -and $GroupName) {
            throw "Please use either a UserGroup Name or a UserGroup ID"
        } elseif ($Username -or $UserID) {
            Write-Debug 'Populating UserHash'
            $UserHash = Get-DynamicHash -Object User -returnProperties username
        } elseif ($GroupID -or $GroupName) {
            Write-Debug 'Populating UserGroupHash'
            $UserGroupHash = Get-DynamicHash -Object Group -GroupType User -returnProperties name
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
                if ($UserHash.Values.username -contains ($Username)) {
                    $UserID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
                } else {
                    throw "Username: $Username was not found."
                }
            }
            Set-JcSdkGSuiteAssociation -GsuiteId $CloudDirectory.Id -Op 'add' -Type 'user' -Id $UserID -ErrorVariable addError -ErrorAction SilentlyContinue
            if ($addError) {
                $Status = $addError.ErrorDetails.Message
            } else {
                $Status = 'Added'
            }
            $FormattedResults = [PSCustomObject]@{

                'DirectoryName' = $CloudDirectory.Name
                'UserID'        = $UserID
                'Status'        = $Status

            }
            $resultsArray += $FormattedResults
        } else {
            if ($GroupName) {
                if ($UserGroupHash.Values.Name -contains ($GroupName)) {
                    $GroupID = $UserGroupHash.GetEnumerator().Where({ $_.Value.name -contains ($GroupName) }).Name
                } else {
                    throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."
                }
            }
            Set-JcSdkGSuiteAssociation -GsuiteId $CloudDirectory.Id -Op 'add' -Type 'user_group' -Id $GroupID -ErrorVariable addError -ErrorAction SilentlyContinue
            if ($addError) {
                $Status = $addError.ErrorDetails.Message
            } else {
                $Status = 'Added'
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