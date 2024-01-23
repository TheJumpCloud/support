function Get-CommandByUsername {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [system.string]
        $username
    )

    begin {
        # define searchFilter
        $SearchFilter = @{
            searchTerm = "RadiusCert-Install:${username}:"
            fields     = @('name')
        }

    }

    process {
        # Get command Results
        $commandResults = Search-JcSdkCommand -SearchFilter $SearchFilter -Fields name
    }

    end {
        return $commandResults
    }
}
