Function Get-PSGalleryModuleVersion
{
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('Major', 'Minor', 'Patch')][string]$RELEASETYPE
    )
    # Check to see if module already exists to set version number
    $PowerShellGalleryModule = Find-Module -Name:($Name) -ErrorAction:('Ignore')
    If ([string]::IsNullOrEmpty($PowerShellGalleryModule))
    {
        $ModuleVersion = [PSCustomObject]@{
            'Name'    = $Name;
            'Version' = 'N/A';
            'Major'   = 'N/A';
            'Minor'   = 'N/A';
            'Patch'   = 'N/A';
        }
        $NextVersion = Switch ($RELEASETYPE)
        {
            'Major' { $ModuleVersion.Major = '1.0.0' }
            'Minor' { $ModuleVersion.Minor = '0.1.0' }
            'Patch' { $ModuleVersion.Patch = '0.0.1' }
        }
    }
    Else
    {
        $ModuleVersion = [PSCustomObject]@{
            'Name'    = $PowerShellGalleryModule.Name;
            'Version' = $PowerShellGalleryModule.Version;
            'Major'   = [int]($PowerShellGalleryModule.Version -split '\.')[0];
            'Minor'   = [int]($PowerShellGalleryModule.Version -split '\.')[1];
            'Patch'   = [int]($PowerShellGalleryModule.Version -split '\.')[2];
        }
        Switch ($RELEASETYPE)
        {
            'Major' { $ModuleVersion.Major = $ModuleVersion.Major + 1 }
            'Minor' { $ModuleVersion.Minor = $ModuleVersion.Minor + 1 }
            'Patch' { $ModuleVersion.Patch = $ModuleVersion.Patch + 1 }
        }

    }
    $NextVersion = ($ModuleVersion.Major, $ModuleVersion.Minor, $ModuleVersion.Patch) -join '.'
    Add-Member -InputObject:($ModuleVersion) -MemberType:('NoteProperty') -Name:('NextVersion') -Value:($NextVersion)
    Return $ModuleVersion
}