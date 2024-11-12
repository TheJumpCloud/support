function Add-JCOffice365Member () {
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
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        $resultsArray = [System.Collections.Generic.List[PSObject]]::new()
        $DirectoryHash = Get-JcSdkDirectory | Where-Object type -EQ 'office_365' | Select-Object id, name
        if (($Username -or $UserID) -and ($GroupID -or $GroupName)) {
            throw "Please add one type of association per call"
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
                Set-JcSdkOffice365Association -Office365Id $CloudDirectory.Id -Op 'add' -Type 'user' -Id $UserID
                $Status = 'Added'
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
                Set-JcSdkOffice365Association -Office365Id $CloudDirectory.Id -Op 'add' -Type 'user_group' -Id $GroupID
                $Status = 'Added'
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