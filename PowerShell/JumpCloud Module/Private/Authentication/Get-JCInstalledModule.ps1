Function Get-JCInstalledModule {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $ModuleName,
        [Parameter(ParameterSetName = 'CodeArtifact', HelpMessage = 'Switch to toggle CodeArtifact Updates')][Switch]$CodeArtifact

    )
    begin {
        $list = @()
    }
    process {
        if ($CodeArtifact) {
            $InstalledModule = Get-PSResource -Name:($ModuleName) -ErrorAction:('Ignore')
            # Transform PSResource to ModuleObject
            foreach ($FoundModule in $InstalledModule) {
                PublishedDate = (Get-Date -Year $FoundModule.Prerelease.Substring(0, 4) -Month $FoundModule.Prerelease.Substring(4, 2) -Day $FoundModule.Prerelease.Substring(6, 2) -Hour $FoundModule.Prerelease.Substring(8, 2) -Minute $InstalledModule.Prerelease.Substring(10, 2))
                $list += [PSCustomObject]@{
                    Version       = $FoundModule.Version
                    Prerelease    = $FoundModule.Prerelease
                    PublishedDate = $PublishedDate
                    Name          = $FoundModule.Name
                    Repository    = $FoundModule.Repository
                }
            }
        } else {
            $InstalledModule = Get-InstalledModule -Name:($ModuleName) -AllVersions -ErrorAction:('Ignore')
            foreach ($FoundModule in $InstalledModule) {
                $list += [PSCustomObject]@{
                    Version       = $FoundModule.Version
                    PublishedDate = $FoundModule.PublishedDate
                    Name          = $FoundModule.Name
                    Repository    = $FoundModule.Repository
                }
            }
        }

    }
    end {
        return $list
    }
}