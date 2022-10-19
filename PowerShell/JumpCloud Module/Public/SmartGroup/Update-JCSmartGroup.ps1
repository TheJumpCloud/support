# This function will update the group memebership of a group by ID/ Name/ ALL
# This function will update the attributes of a saved smartGroup
Function Update-JCSmartGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('System', 'User')]
        [System.String]
        ${GroupType},
        [Parameter(ParameterSetName = "Name", Mandatory)]
        [System.String]
        ${Name},
        [Parameter(ParameterSetName = "ID", Mandatory)]
        [System.String]
        ${ID}
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
                $SmartGroupDetails = Get-JCSmartGroup -GroupType $GroupType -ByID $ID
                switch ($GroupType) {
                    'System' {
                        # TODO: Update Group Membership
                        Update-JCSmartGroupMembership -GroupType System -ID $SmartGroupDetails.ID
                    }
                    'User' {
                        Update-JCSmartGroupMembership -GroupType User -ID $SmartGroupDetails.ID
                        # TODO: Update Group Membership
                    }
                    Default {
                    }
                }
            }
            'Name' {
                $SmartGroupDetails = Get-JCSmartGroup -GroupType $GroupType -ByName $Name
                # $group = Get-JCGroup -Type $GroupType -Name $Name -ErrorAction SilentlyContinue
                switch ($GroupType) {
                    'System' {
                        # TODO: Update Group Membership
                        Update-JCSmartGroupMembership -GroupType System -ID $SmartGroupDetails.Id
                    }
                    'User' {
                        # TODO: Update Group Membership
                        Update-JCSmartGroupMembership -GroupType User -ID $SmartGroupDetails.Id
                    }
                    Default {
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
        $config | ConvertTo-Json -Depth 99 | Out-File -FilePath $configFilePath
        # Update Global Variable
        $Global:JCConfig = Get-JCSettingsFile
    }

}