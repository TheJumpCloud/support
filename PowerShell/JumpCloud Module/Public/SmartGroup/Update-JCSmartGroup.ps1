# This function will update the group memebership of a group by ID/ Name/ ALL
# This function will update the attributes of a saved smartGroup
Function Update-JCSmartGroup {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('System', 'User')]
        [System.String]
        ${GroupType},
        [Parameter(ParameterSetName = "Name")]
        [System.String]
        ${Name},
        [Parameter(ParameterSetName = "ID")]
        [System.String]
        ${ID},
        [Parameter(ParameterSetName = "All")]
        [switch]
        $All
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
                        Update-JCSmartGroupMembership -GroupType System -ID $SmartGroupDetails.ID
                    }
                    'User' {
                        Update-JCSmartGroupMembership -GroupType User -ID $SmartGroupDetails.ID
                    }
                    Default {
                    }
                }
            }
            'Name' {
                $SmartGroupDetails = Get-JCSmartGroup -GroupType $GroupType -GroupName $Name
                # $group = Get-JCGroup -Type $GroupType -Name $Name -ErrorAction SilentlyContinue
                switch ($GroupType) {
                    'System' {
                        Update-JCSmartGroupMembership -GroupType System -ID $SmartGroupDetails.ID
                    }
                    'User' {
                        Update-JCSmartGroupMembership -GroupType User -ID $SmartGroupDetails.ID
                    }
                    Default {
                    }
                }

            }
            'All' {
                $SmartGroupDetails = Get-JCSmartGroup -All
                foreach ($group in $SmartGroupDetails) {
                    # Write-Host "updating $($group.ID)"
                    if ($group.GroupType -eq 'SystemGroup') {
                        Update-JCSmartGroupMembership -Grouptype System -ID "$($group.ID)"
                    } else {
                        Update-JCSmartGroupMembership -Grouptype User -ID "$($group.ID)"
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