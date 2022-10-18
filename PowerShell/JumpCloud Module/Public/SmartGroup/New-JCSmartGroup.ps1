Function New-JCSmartGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('System', 'User')]
        [System.String]
        ${GroupType},
        [Parameter()]
        [System.String]
        ${Name},
        [Parameter()]
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
        # TODO: Create case for ID Param, if ID passed in, go get the group and add it to the Config.Json, instead of creating a group
    }

    process {
        $group = Get-JCGroup -Type $GroupType -Name $Name -ErrorAction SilentlyContinue
        # if group doesn't exist, create it.
        #TODO: Turn into cases because that makes more sense
        if (!$group -And $GroupType -eq 'User') {
            $smartGroup = New-JCUserGroup -GroupName $Name
            "Creating SmartGroup Record for Group $($smartGroup.id)"
            $groupObject = [PSCustomObject]@{
                ID         = $smartGroup.id
                Name       = $smartGroup.Name
                Attributes = @{}
                Timestamp  = Get-Date
            }
            Add-Member -InputObject $config.SmartGroups.UserGroups -Type NoteProperty -Name $smartGroup.id -Value $groupObject
            #TODO: Prompt for attributes
        }
        if (!$group -And $GroupType -eq 'System') {
            $smartGroup = New-JCSystemGroup -GroupName $Name
            "Creating SmartGroup Record for Group $($smartGroup.id)"
            $groupObject = [PSCustomObject]@{
                ID         = $smartGroup.id
                Name       = $smartGroup.Name
                Attributes = @{}
                Timestamp  = Get-Date
            }
            Add-Member -InputObject $config.SmartGroups.SystemGroups -Type NoteProperty -Name $smartGroup.id -Value $groupObject
            #TODO: Prompt for attributes
        }
    }
    end {
        # Write out the new settings
        $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        # Update Global Variable
        $Global:JCConfig = Get-JCSettingsFile
    }

}