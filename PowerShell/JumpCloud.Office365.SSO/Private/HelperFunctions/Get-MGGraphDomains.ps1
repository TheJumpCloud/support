function Get-MgGraphDomains () {

    Connect-MgGraph -Scopes "Domain.Read.All"

    $DomainHash = @{}

    $Domains = Get-MgDomain -Property id, authenticationType, isVerified | Where-Object { $_.IsVerified -eq $true }

    Foreach ($D in $Domains) {
        $DomainHash.Add($D.id, $D.authenticationType)
    }

    Return $DomainHash
}
