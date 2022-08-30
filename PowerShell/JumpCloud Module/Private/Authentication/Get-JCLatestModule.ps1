Function Get-JCLatestModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $ModuleName,
        [Parameter(ParameterSetName = 'CodeArtifact')]
        [String]
        $Repository,
        [Parameter(ParameterSetName = 'CodeArtifact')]
        [System.Management.Automation.PSCredential]
        $RepositoryCredentials,
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
            $FoundModule = Find-PSResource -Name:($ModuleName) -Repository:($Repository) -Credential:($RepositoryCredentials) -Prerelease
            # Transform PSResource to ModuleObject
            $ModuleObject.Version = $FoundModule.Version
            $ModuleObject.Prerelease = $FoundModule.Prerelease
            $PublishedDate = (Get-Date -Year $FoundModule.Prerelease.Substring(0, 4) -Month $FoundModule.Prerelease.Substring(4, 2) -Day $FoundModule.Prerelease.Substring(6, 2) -Hour $FoundModule.Prerelease.Substring(8, 2) -Minute $FoundModule.Prerelease.Substring(10, 2))
            $ModuleObject.PublishedDate = $PublishedDate
            $ModuleObject.Name = $FoundModule.Name
            $ModuleObject.Repository = $FoundModule.Repository
        } else {
            $FoundModule = Find-Module -Name:($ModuleName) -Repository:($Repository)
            # Copy PSModule to ModuleObject
            $ModuleObject.Version = $FoundModule.Version
            $ModuleObject.PublishedDate = $FoundModule.PublishedDate
            $ModuleObject.Name = $FoundModule.Name
            $ModuleObject.Repository = $FoundModule.Repository
        }

    }
    end {
        return $ModuleObject
    }
}