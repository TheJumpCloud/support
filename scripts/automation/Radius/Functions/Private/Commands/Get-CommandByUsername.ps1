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
            fields     = @('name', 'trigger', 'commandType')
        }

    }

    process {
        # Get command Results
        $commandResults = Search-JcSdkCommand -SearchFilter $SearchFilter -Fields "name trigger commandType"
    }

    end {
        return $commandResults
    }
}