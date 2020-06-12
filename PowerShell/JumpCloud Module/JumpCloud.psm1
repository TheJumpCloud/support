# Load all functions from public and private folders
$Public = @( Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -Recurse )
$Private = @( Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -Recurse)
Foreach ($Import in @($Public + $Private))
{
    Try
    {
        . $Import.FullName
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}










# Set default values for function parameters
$PSDefaultParameterValues['Invoke-RestMethod:ContentType'] = 'application/json; charset=utf-8'
$PSDefaultParameterValues['Invoke-WebRequest:ContentType'] = 'application/json; charset=utf-8'
If ($PSVersionTable.PSEdition -eq 'Core')
{
    $PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
    $PSDefaultParameterValues['Invoke-RestMethod:SkipHttpErrorCheck'] = $true
    $PSDefaultParameterValues['Invoke-RestMethod:SkipHeaderValidation'] = $true

    $PSDefaultParameterValues['Invoke-WebRequest:SkipCertificateCheck'] = $true
    $PSDefaultParameterValues['Invoke-WebRequest:SkipHttpErrorCheck'] = $true
    $PSDefaultParameterValues['Invoke-WebRequest:SkipHeaderValidation'] = $true
}
Else
{
    #Ignore SSL errors
    Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

}
# https://docs.microsoft.com/en-us/dotnet/api/system.net.servicepointmanager?view=netcore-3.1
[System.Net.ServicePointManager]::CheckCertificateRevocationList = $true;
# [System.Net.ServicePointManager]::DefaultConnectionLimit = 999999;
# [System.Net.ServicePointManager]::DefaultNonPersistentConnectionLimit
# [System.Net.ServicePointManager]::DefaultPersistentConnectionLimit
# [System.Net.ServicePointManager]::DnsRefreshTimeout
# [System.Net.ServicePointManager]::EnableDnsRoundRobin
# [System.Net.ServicePointManager]::EncryptionPolicy
[System.Net.ServicePointManager]::Expect100Continue = $true;
# [System.Net.ServicePointManager]::MaxServicePointIdleTime
# [System.Net.ServicePointManager]::MaxServicePoints
# [System.Net.ServicePointManager]::ReusePort
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12, [System.Net.SecurityProtocolType]::Tls, [System.Net.SecurityProtocolType]::Tls
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true } ; # Allow the use of self-signed SSL certificates.
[System.Net.ServicePointManager]::UseNagleAlgorithm = $true;
# [System.Net.ServicePointManager]::Equals()
# [System.Net.ServicePointManager]::FindServicePoint()
# [System.Net.ServicePointManager]::ReferenceEquals()
# [System.Net.ServicePointManager]::SetTcpKeepAlive()

# Set function aliases
Set-Alias -Name:('New-JCAssociation') -Value:('Add-JCAssociation')
# Export module member
Export-ModuleMember -Function $Public.BaseName -Alias *