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
                            }
                            Add-Member -InputObject $config.SmartGroups.UserGroups -NotePropertyName $smartGroup.id -NotePropertyValue $groupObject
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
                            }
                            Add-Member -InputObject $config.SmartGroups.SystemGroups -NotePropertyName $smartGroup.id -NotePropertyValue $groupObject
                            # array for attributes
                            $array = @()
                            Do {
                                $array += New-JCSmartGroupPrompt -SystemGroup
                                $ValidateTitle = "Would you like to add another attribute to the Smart Group"
                                $ValidateMessage = "Current Attributes :`n $array"
                                $YesChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
                                $NoChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
                                $quitChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", "Quit"
                                $options = [System.Management.Automation.Host.ChoiceDescription[]]($NoChoice, $YesChoice, $quitChoice)
                                $finalChoice = $host.ui.PromptForChoice($ValidateTitle, $ValidateMessage, $options, 0)
                            } until (($finalChoice -eq 0) -OR ($finalChoice -eq 2))

                            $filterObject = [PSCustomObject]@{
                                And = [PSCustomObject]@{}
                                Or  = [PSCustomObject]@{}
                            }

                            foreach ($item in $array) {
                                $1, $2 = $item -split ':', 2
                                Add-Member -InputObject $filterObject.And -NotePropertyName $1 -NotePropertyValue $2
                            }
                            $config.SmartGroups.SystemGroups."$($smartGroup.id)".Attributes = $filterObject

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
        $config | ConvertTo-Json -Depth 99 | Out-File -FilePath $configFilePath
        # Update Global Variable
        $Global:JCConfig = Get-JCSettingsFile
    }

}