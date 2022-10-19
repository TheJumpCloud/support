# This function will update the attributes of a saved smartGroup
Function Set-JCSmartGroup {
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
                If ($id -notin $config.SmartGroups."$($GroupType)Groups".PSObject.Properties.Name) {
                    "ID Not found in confifg, please run New-JCSmartGroup with the desired name of your smart group"
                } else {
                    switch ($GroupType) {
                        'System' {
                            # TODO: Follow prompts to Add/ Update Attributes for group record
                        }
                        'User' {
                            # TODO: Follow prompts to Add/ Update Attributes for group record
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
                                # TODO: Follow prompts to Add/ Update Attributes for group record
                            }
                            'User' {
                                # TODO: Follow prompts to Add/ Update Attributes for group record
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