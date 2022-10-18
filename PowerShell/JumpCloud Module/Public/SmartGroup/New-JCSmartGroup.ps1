Function New-JCSmartGroup {
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
        # TODO: validate attribtues object if passed in:
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ID' {
                If ($id -in $config.SmartGroups."$($GroupType)Groups".PSObject.Properties.Name) {
                    "Found ID in confifg already"
                } else {
                    switch ($GroupType) {
                        'System' {
                            $smartGroup = Get-JCSDKSystemGroup -ID $ID
                            Add-Member -InputObject $config.SmartGroups.SystemGroups -Type NoteProperty -Name $smartGroup.id -Value $groupObject

                        }
                        'User' {
                            $smartGroup = Get-JCSDKUserGroup -ID $ID
                            Add-Member -InputObject $config.SmartGroups.UserGroups -Type NoteProperty -Name $smartGroup.id -Value $groupObject

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
                    switch ($GroupType) {
                        'User' {
                            $smartGroup = New-JCUserGroup -GroupName $Name
                            "Creating SmartGroup Record for Group $($smartGroup.id)"
                            $groupObject = [PSCustomObject]@{
                                ID         = $smartGroup.id
                                Name       = $smartGroup.Name
                                Attributes = @{}
                                Timestamp  = Get-Date
                            } | ConvertTo-Json
                            Add-Member -InputObject $config.SmartGroups.UserGroups -Type NoteProperty -Name $smartGroup.id -Value $groupObject
                            #TODO: Prompt for attributes

                        }
                        'System' {
                            $smartGroup = New-JCSystemGroup -GroupName $Name
                            "Creating SmartGroup Record for Group $($smartGroup.id)"
                            $groupObject = [PSCustomObject]@{
                                ID         = $smartGroup.id
                                Name       = $smartGroup.Name
                                Attributes = @{}
                                Timestamp  = Get-Date
                            } | ConvertTo-Json
                            Add-Member -InputObject $config.SmartGroups.SystemGroups -Type NoteProperty -Name $smartGroup.id -Value $groupObject
                            #TODO: Prompt for attributes
                        }
                        Default {
                        }
                    }
                } else {
                    "Group already exists"
                    If ($group.id -in $config.SmartGroups."$($GroupType)Groups".PSObject.Properties.Name) {
                        "Found ID in confifg already"
                    } else {
                        switch ($GroupType) {
                            'System' {
                                $smartGroup = Get-JCSDKSystemGroup -ID $group.id
                                Add-Member -InputObject $config.SmartGroups.SystemGroups -Type NoteProperty -Name $smartGroup.id -Value $groupObject

                            }
                            'User' {
                                $smartGroup = Get-JCSDKUserGroup -ID $group.id
                                Add-Member -InputObject $config.SmartGroups.UserGroups -Type NoteProperty -Name $smartGroup.id -Value $groupObject

                            }
                            Default {
                            }
                        }
                    }
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