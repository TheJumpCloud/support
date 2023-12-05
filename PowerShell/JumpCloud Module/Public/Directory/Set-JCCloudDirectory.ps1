function Set-JCCloudDirectory () {
    param (
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', HelpMessage = 'The name of cloud directory instance')]
        [String]$Name,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The ID of cloud directory instance')]
        [Alias('_id')]
        [String]$ID,
        [Parameter(HelpMessage = 'A string value that will change the name of the Cloud Directory instance')]
        [String]$NewName,
        [Parameter(HelpMessage = 'A boolean $true/$false value that enable or disable groups for the Cloud Directory Instance')]
        [Boolean]$GroupsEnabled,
        [Parameter(HelpMessage = 'A string value that will change the lockout action for users; valid options: suspend, maintain')]
        [ValidateSet('suspend', 'maintain')]
        [String]$UserLockoutAction,
        [Parameter(HelpMessage = 'A string value that will change the password expiration action for users; valid options: suspend, maintain or remove_access (remove_access is only available for Gsuite directories)')]
        [ValidateSet('suspend', 'maintain', 'remove_access')]
        [String]$UserPasswordExpirationAction
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }

        $resultsArray = [System.Collections.Generic.List[PSObject]]::new()

        $DirectoryHash = Get-JcSdkDirectory | Select-Object id, type, name

        $body = @{}
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            ByName {
                $CloudDirectory = $DirectoryHash | Where-Object name -EQ $Name
                if (!$CloudDirectory) {
                    throw "$Name was not found. Please try again"
                } elseif ($CloudDirectory.count -gt 1) {
                    throw "Multiple directories with the same name detected, please use the -id parameter to specify which directory to edit. Use Get-JCCloudDirectory to find all directories"
                }
            }
            ByID {
                $CloudDirectory = $DirectoryHash | Where-Object Id -EQ $ID
                if (!$CloudDirectory) {
                    throw "$ID was not found. Please try again"
                }
            }
        }

        if ($NewName) {
            $body.Add('name', $NewName)
        }
        if (-not [System.String]::IsNullOrEmpty($GroupsEnabled)) {
            $body.Add('groupsEnabled', $GroupsEnabled)
        }
        if ($UserLockoutAction) {
            $body.Add('userLockoutAction', $UserLockoutAction)
        }
        if ($UserPasswordExpirationAction) {
            if (($CloudDirectory.Type -eq 'office_365') -and $UserPasswordExpirationAction -eq 'remove_access') {
                throw 'remove_access is not a valid User Password Expiriation action for office_365 instances'
            } else {
                $body.Add('userPasswordExpirationAction', $UserPasswordExpirationAction)
            }
        }

        if ($Debug) {
            $body.GetEnumerator() | ForEach-Object {
                $message = '{0} {1}' -f $_.key, $_.value
                Write-Debug $message
            }
        }

        $body = $body | ConvertTo-Json

        if ($CloudDirectory.Type -eq 'office_365') {
            $resultsArray = Update-JcSdkOffice365 -Office365Id $CloudDirectory.Id -Body $body
        } elseif ($CloudDirectory.Type -eq 'g_suite') {
            $resultsArray = Update-JcSdkGSuite -Id $CloudDirectory.Id -Body $body
        }
    }
    end {
        return $resultsArray
    }
}