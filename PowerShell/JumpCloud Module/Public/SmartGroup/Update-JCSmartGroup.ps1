# This function will update the group memebership of a group by ID/ Name/ ALL
# This function will update the attributes of a saved smartGroup
Function Update-JCSmartGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "Name", Mandatory)]
        [ValidateSet('System', 'User')]
        [System.String]
        ${GroupType},
        [Parameter(ParameterSetName = "Name", Mandatory)]
        [System.String]
        ${Name},
        [Parameter(ParameterSetName = "ID", Mandatory)]
        [System.String]
        ${ID},
        [Parameter(ParameterSetName = "All", Mandatory)]
        [System.String]
        ${All}
    )
    begin {
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline -Force | Out-Null
        }
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $configFilePath) {
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json
        } else {
            New-JCSettingsFile
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json
        }

        # Config should have autogroup settings:
        If (!$config.smartGroups) {
            "No Smart Groups found"
            $object = [PSCustomObject]@{
                UserGroups   = @{}
                SystemGroups = @{}
            }
            Add-Member -InputObject $config -Type NoteProperty -Name SmartGroups -Value $object
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ID' {
                If ($id -notin $config.SmartGroups."$($GroupType)Groups".PSObject.Properties.Name) {
                    "ID Not found in confifg, please run New-JCSmartGroup with the desired name of your smart group"
                } else {
                    switch ($GroupType) {
                        'System' {
                            # TODO: Update Group Membership
                        }
                        'User' {
                            # TODO: Update Group Membership
                        }
                        Default {
                        }
                    }
                }
            }
            'Name' {
                $group = Get-JCGroup -Type $GroupType -Name $Name -ErrorAction SilentlyContinue
                # if group doesn't exist, create it.
                if (!$group) {
                    "Group not found in confifg, please run New-JCSmartGroup with the desired name of your smart group"
                } else {
                    "Group already exists"
                    If ($group.id -in $config.SmartGroups."$($GroupType)Groups".PSObject.Properties.Name) {
                        "Found ID in confifg already"
                        switch ($GroupType) {
                            'System' {
                                # TODO: Update Group Membership
                            }
                            'User' {
                                # TODO: Update Group Membership
                            }
                            Default {
                            }
                        }
                    }
                }
            }
            'All' {
                Foreach ($GroupID in $($config.SmartGroups.SystemGroups.PSObject.Properties.Name)) {
                    #TODO: Update GroupMembership

                }
                Foreach ($GroupID in $($config.SmartGroups.UserGroups.PSObject.Properties.Name)) {
                    #TODO: Update GroupMembership

                }
            }
            Default {
            }
        }
    }
    end {
        # Write out the new settings
        $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        # Update Global Variable
        $Global:JCConfig = Get-JCSettingsFile
    }

}