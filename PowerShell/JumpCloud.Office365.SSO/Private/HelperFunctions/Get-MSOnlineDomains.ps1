function Get-MSOnlineDomains () {

    $DomainHash = @{}

    $Domains = Get-MsolDomain

    Foreach ($D in $Domains) {
        $DomainHash.Add($D.name, $D.Authentication)

    }

    Return $DomainHash
}