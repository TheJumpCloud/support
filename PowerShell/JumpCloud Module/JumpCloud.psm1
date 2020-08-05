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
# Populate values for function parameters
$SystemInsightsPrefix = 'Get-JcSdkSystemInsight'
$SystemInsightsTables = @{}
$Commands = Get-Command -Module:('JumpCloud.SDK.V2') -Name:("$SystemInsightsPrefix*")
ForEach ($Command In $Commands)
{
    $Help = Get-Help -Name:($Command)
    $SystemInsightsTables.Add($Command.Name.Replace($SystemInsightsPrefix, ''), $Help.Description.Text + ' ' + $Help.parameters.parameter.Where( { $_.Name -eq 'filter' }).Description.Text + ' EX: {field}:{operator}:{searchValue}' )
}
Register-ArgumentCompleter -CommandName Get-JCSystemInsightsElliott -ParameterName Table -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $FilterFilter = $fakeBoundParameter.Filter
    $SystemInsightsTables.Keys | Where-Object { $_ -like "${wordToComplete}*" } | Where-Object {
        $SystemInsightsTables.$_ -like "${FilterFilter}*"
    } | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
Register-ArgumentCompleter -CommandName Get-JCSystemInsightsElliott -ParameterName Filter -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $TypeFilter = $fakeBoundParameter.Table
    $SystemInsightsTables.Keys | Where-Object { $_ -like "${TypeFilter}*" } | ForEach-Object { $SystemInsightsTables.$_ |
        Where-Object { $_ -like "${wordToComplete}*" } } |
    Sort-Object -Unique | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
# https://docs.microsoft.com/en-us/dotnet/api/system.net.servicepointmanager?view=netcore-3.1
# Required
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls, [System.Net.SecurityProtocolType]::Tls11, [System.Net.SecurityProtocolType]::Tls12
# Might help resolve misc. 500 status code issues
[System.Net.ServicePointManager]::DefaultConnectionLimit = 999999;
[System.Net.ServicePointManager]::MaxServicePointIdleTime = 600000;
[System.Net.ServicePointManager]::MaxServicePoints = 999999;
If ($PSVersionTable.PSEdition -eq 'Core')
{
    $PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
    $PSDefaultParameterValues['Invoke-RestMethod:SkipHeaderValidation'] = $true
    $PSDefaultParameterValues['Invoke-RestMethod:MaximumRetryCount'] = 5
    $PSDefaultParameterValues['Invoke-RestMethod:RetryIntervalSec'] = 5

    $PSDefaultParameterValues['Invoke-WebRequest:SkipCertificateCheck'] = $true
    $PSDefaultParameterValues['Invoke-WebRequest:SkipHeaderValidation'] = $true
    $PSDefaultParameterValues['Invoke-WebRequest:MaximumRetryCount'] = 5
    $PSDefaultParameterValues['Invoke-WebRequest:RetryIntervalSec'] = 5
}
Else
{
    #Ignore SSL errors / do not add policy if it exists
    if (-Not [System.Net.ServicePointManager]::CertificatePolicy)
    {
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
# Export module member
Export-ModuleMember -Function $Public.BaseName -Alias *
