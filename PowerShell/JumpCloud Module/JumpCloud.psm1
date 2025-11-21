# Load all functions from public and private folders
$Public = @( Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -Recurse )
$Private = @( Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -Recurse)
foreach ($Import in @($Public + $Private)) {
    try {
        . $Import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

# Check to see if parallel processing is available for the session
$global:JCConfig = Get-JCSettingsFile
$PSDefaultParameterValues = $global:PSDefaultParameterValues.Clone()

# Set default values for function parameters
$PSDefaultParameterValues['Invoke-RestMethod:ContentType'] = 'application/json; charset=utf-8'
$PSDefaultParameterValues['Invoke-WebRequest:ContentType'] = 'application/json; charset=utf-8'
# https://docs.microsoft.com/en-us/dotnet/api/system.net.servicepointmanager?view=netcore-3.1
# Required
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls, [System.Net.SecurityProtocolType]::Tls11, [System.Net.SecurityProtocolType]::Tls12
# Might help resolve misc. 500 status code issues
[System.Net.ServicePointManager]::DefaultConnectionLimit = 999999;
[System.Net.ServicePointManager]::MaxServicePointIdleTime = 600000;
[System.Net.ServicePointManager]::MaxServicePoints = 999999;
if ($PSVersionTable.PSEdition -eq 'Core') {
    $PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
    $PSDefaultParameterValues['Invoke-RestMethod:SkipHeaderValidation'] = $true
    $PSDefaultParameterValues['Invoke-RestMethod:MaximumRetryCount'] = 1
    $PSDefaultParameterValues['Invoke-RestMethod:RetryIntervalSec'] = 1

    $PSDefaultParameterValues['Invoke-WebRequest:SkipCertificateCheck'] = $true
    $PSDefaultParameterValues['Invoke-WebRequest:SkipHeaderValidation'] = $true
    $PSDefaultParameterValues['Invoke-WebRequest:MaximumRetryCount'] = 1
    $PSDefaultParameterValues['Invoke-WebRequest:RetryIntervalSec'] = 1
} else {
    #Ignore SSL errors / do not add policy if it exists
    if (-not [System.Net.ServicePointManager]::CertificatePolicy) {
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
}
# Set function aliases
Set-Alias -Name:('New-JCAssociation') -Value:('Add-JCAssociation')
# Argument completers
# set Argument Completer(s) which no not require authentication
$SystemInsightsPrefix = 'Get-JcSdkSystemInsight';
$sdkCommands = Get-Command -Module:('JumpCloud.SDK.V2') -Name:("$($SystemInsightsPrefix)*")
$global:SystemInsightsDataSet = New-Object System.Collections.ArrayList
foreach ($command in $sdkCommands) {
    $templateHashObject = [PSCustomObject]@{
        Name = $command.Name.Replace($SystemInsightsPrefix, '')
        Id   = $template.Id
    }
    $SystemInsightsDataSet.Add($templateHashObject) | Out-Null
}
Register-ArgumentCompleter -CommandName Get-JCSystemInsights -ParameterName Table -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $TypeFilter = $fakeBoundParameter.Name;
    $SystemInsightsDataSet.Name | Where-Object { $_ -like "${TypeFilter}*" } | Where-Object { $_ -like "${wordToComplete}*" } | Sort-Object -Unique | ForEach-Object { $_ }
}
# Export module member
Export-ModuleMember -Function $Public.BaseName -Alias *
