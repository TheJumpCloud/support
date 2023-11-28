function Get-JCCloudDirectory () {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param (
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'The type of cloud directory')]
        [ValidateSet('g_suite', 'office_365')]
        [String]$Type,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', HelpMessage = 'The name of cloud directory instance')]
        [String]$Name,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The ID of cloud directory instance')]
        [Alias('_id')]
        [String]$ID
    )

    DynamicParam {
        if ($Name -or $ID) {
            # Create the dictionary
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

            # Generate and set the ValidateSet
            $arrSet = @('Users', 'UserGroups')
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create the Association param attributes
            $AssociationAttribute = New-Object System.Management.Automation.ParameterAttribute
            $AssociationAttribute.HelpMessage = "Type of association to query"

            # Add the Association param attributes to attribute collection
            $AttributeCollection.Add($AssociationAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('Association', [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add('Association', $RuntimeParameter)
            return $RuntimeParameterDictionary
        }
    }
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }

        $resultsArray = [System.Collections.Generic.List[PSObject]]::new()

        $DirectoryHash = Get-JcSdkDirectory | Select-Object id, type, name

        # Check to see if Association param is set and build respective hashtables
        if ($PSBoundParameters.ContainsKey('Association')) {
            switch ($PSBoundParameters.Association) {
                Users {
                    Write-Debug 'Populating UserHash'
                    $UserHash = Get-DynamicHash -Object User -returnProperties username, email, firstname, lastname
                }
                UserGroups {
                    Write-Debug 'Populating UserGroupHash'
                    $UserGroupHash = Get-DynamicHash -Object Group -GroupType User -returnProperties name
                }
            }
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            ReturnAll {
                if ($Type) {
                    $resultsArray = Get-JcSdkDirectory | Where-Object { ($_.Type -eq $Type) } | Select-Object Id, Name, Type
                } else {
                    $resultsArray = Get-JcSdkDirectory | Where-Object { ($_.Type -eq 'g_suite' -or $_.Type -eq 'office_365') } | Select-Object Id, Name, Type
                }
            }
            ByName {
                Write-Debug "Finding directory by Name"
                $CloudDirectory = $DirectoryHash | Where-Object name -EQ $Name
                if (!$CloudDirectory) {
                    throw "$Name was not found. Please try again"
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
        if ($CloudDirectory.type -eq 'g_suite') {
            if ($PSBoundParameters.ContainsKey('Association')) {
                switch ($PSBoundParameters.Association) {
                    Users {
                        $Users = Get-JcSdkGSuiteTraverseUser -GsuiteId $CloudDirectory.Id
                        $Users | ForEach-Object {
                            $UserId = $_.Id
                            $user = $UserHash.GetEnumerator().Where({ $_.Key -contains ($UserId) })
                            $user = $user | Select-Object @{
                                name = 'Id'
                                expr = { $_.Name }
                            } -ExpandProperty Value
                            $resultsArray.Add($user)
                        }
                    }
                    UserGroups {
                        $UserGroups = Get-JcSdkGSuiteTraverseUserGroup -GsuiteId $CloudDirectory.Id
                        $UserGroups | ForEach-Object {
                            $UserGroupId = $_.Id
                            $UserGroup = $UserGroupHash.GetEnumerator().Where({ $_.Key -contains ($UserGroupId) })
                            $UserGroup = $UserGroup | Select-Object @{
                                name = 'Id'
                                expr = { $_.Name }
                            } -ExpandProperty Value
                            $resultsArray.Add($UserGroup)
                        }
                    }
                }
            } else {
                $resultsArray = Get-JcSdkGSuite -Id $CloudDirectory.Id
            }
        } elseif ($CloudDirectory.type -eq 'office_365') {
            if ($PSBoundParameters.ContainsKey('Association')) {
                switch ($PSBoundParameters.Association) {
                    Users {
                        $UserId = $_.Id
                        $user = $UserHash.GetEnumerator().Where({ $_.Key -contains ($UserId) })
                        $user = $user | Select-Object @{
                            name = 'Id'
                            expr = { $_.Name }
                        } -ExpandProperty Value
                        $resultsArray.Add($user)
                    }
                    UserGroups {
                        $UserGroupId = $_.Id
                        $UserGroup = $UserGroupHash.GetEnumerator().Where({ $_.Key -contains ($UserGroupId) })
                        $UserGroup = $UserGroup | Select-Object @{
                            name = 'Id'
                            expr = { $_.Name }
                        } -ExpandProperty Value
                        $resultsArray.Add($UserGroup)
                    }
                }
            } else {
                $resultsArray = Get-JcSdkOffice365 -Id $CloudDirectory.Id
            }
        }
    }
    end {
        return $resultsArray
    }

}