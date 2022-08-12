Function Get-JCInstalledModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $ModuleName,
        [Parameter(ParameterSetName = 'CodeArtifact', HelpMessage = 'Switch to toggle CodeArtifact Updates')][Switch]$CodeArtifact

    )
    begin {
        $ModuleObject = [PSCustomObject]@{
            Version       = ""
            Prerelease    = ""
            PublishedDate = ""
            Name          = ""
            Repository    = ""
        }
    }
    process {
        if ($CodeArtifact) {
            $InstalledModule = Get-PSResource -Name:($ModuleName) -ErrorAction:('Ignore')
            # Transform PSResource to ModuleObject
            $ModuleObject.Version = $InstalledModule.Version
            $ModuleObject.Prerelease = $InstalledModule.Prerelease
            $PublishedDate = (Get-Date -Year $InstalledModule.Prerelease.Substring(0, 4) -Month $InstalledModule.Prerelease.Substring(4, 2) -Day $InstalledModule.Prerelease.Substring(6, 2) -Hour $InstalledModule.Prerelease.Substring(8, 2) -Minute $InstalledModule.Prerelease.Substring(10, 2))
            $ModuleObject.PublishedDate = $PublishedDate
            $ModuleObject.Name = $InstalledModule.Name
            $ModuleObject.Repository = $InstalledModule.Repository
        } else {
            $InstalledModule = Get-InstalledModule -Name:($ModuleName) -AllVersions -ErrorAction:('Ignore')
            # Copy PSModule to ModuleObject
            $ModuleObject.Version = $InstalledModule.Version
            $ModuleObject.PublishedDate = $InstalledModule.PublishedDate
            $ModuleObject.Name = $InstalledModule.Name
            $ModuleObject.Repository = $InstalledModule.Repository
        }

    }
    end {
        return $ModuleObject
    }
}