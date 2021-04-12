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
# Map to define how JCAssociation & JcSdk types relate
$global:JcTypesMap = @{
    ActiveDirectory      = [PSCustomObject]@{Name = 'active_directory'; Identifier_Id = 'id'; Identifier_Name = 'domain'; };
    AppleMdm             = [PSCustomObject]@{Name = 'apple_mdm'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    Application          = [PSCustomObject]@{Name = 'application'; Identifier_Id = '_id'; Identifier_Name = 'displayName'; };
    AuthenticationPolicy = [PSCustomObject]@{Name = 'authentication_policy'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    Command              = [PSCustomObject]@{Name = 'command'; Identifier_Id = '_id'; Identifier_Name = 'name'; };
    Directory            = [PSCustomObject]@{Name = 'directory'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    Group                = [PSCustomObject]@{Name = 'group'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    GSuite               = [PSCustomObject]@{Name = 'g_suite'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    IPList               = [PSCustomObject]@{Name = 'ip_list'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    LdapServer           = [PSCustomObject]@{Name = 'ldap_server'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    Office365            = [PSCustomObject]@{Name = 'office_365'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    Organization         = [PSCustomObject]@{Name = 'organization'; Identifier_Id = '_id'; Identifier_Name = 'displayName'; };
    Policy               = [PSCustomObject]@{Name = 'policy'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    RadiusServer         = [PSCustomObject]@{Name = 'radius_server'; Identifier_Id = '_id'; Identifier_Name = 'name'; };
    SoftwareApp          = [PSCustomObject]@{Name = 'software_app'; Identifier_Id = 'id'; Identifier_Name = 'displayName'; };
    System               = [PSCustomObject]@{Name = 'system'; Identifier_Id = '_id'; Identifier_Name = 'displayName'; };
    SystemGroup          = [PSCustomObject]@{Name = 'system_group'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
    User                 = [PSCustomObject]@{Name = 'user'; Identifier_Id = '_id'; Identifier_Name = 'username'; };
    UserGroup            = [PSCustomObject]@{Name = 'user_group'; Identifier_Id = 'id'; Identifier_Name = 'name'; };
}
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
# Argument completers
# Populate values for function parameters. "Dynamic ValidateSet"
$SystemInsightsPrefix = 'Get-JcSdkSystemInsight';
$SystemInsightsDataSet = [Ordered]@{}
Get-Command -Module:('JumpCloud.SDK.V2') -Name:("$($SystemInsightsPrefix)*") | ForEach-Object {
    $Help = Get-Help -Name:($_.Name);
    $Table = $_.Name.Replace($SystemInsightsPrefix, '')
    $HelpDescription = $Help.Description.Text
    $FilterDescription = ($Help.parameters.parameter | Where-Object { $_.Name -eq 'filter' }).Description.Text
    $FilterNames = ($HelpDescription | Select-String -Pattern:([Regex]'(?<=\ `)(.*?)(?=\`)') -AllMatches).Matches.Value
    $Operators = ($FilterDescription -Replace ('Supported operators are: ', '')).Trim()
    If ([System.String]::IsNullOrEmpty($HelpDescription) -or [System.String]::IsNullOrEmpty($FilterNames) -or [System.String]::IsNullOrEmpty($Operators))
    {
        Write-Error ('Get-JCSystemInsights parameter help info is missing.')
    }
    Else
    {
        $Filters = $FilterNames | ForEach-Object {
            $FilterName = $_
            $Operators | ForEach-Object {
                $Operator = $_
                ("'{0}:{1}:{2}'" -f $FilterName, $Operator, '[SearchValue <String>]');
            }
        }
        $SystemInsightsDataSet.Add($Table, $Filters )
    }
};
Register-ArgumentCompleter -CommandName Get-JCSystemInsights -ParameterName Table -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $FilterFilter = $fakeBoundParameter.Filter;
    $SystemInsightsDataSet.Keys | Where-Object { $_ -like "${wordToComplete}*" } | Where-Object { $SystemInsightsDataSet.$_ -like "${FilterFilter}*" } | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
Register-ArgumentCompleter -CommandName Get-JCSystemInsights -ParameterName Filter -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $TypeFilter = $fakeBoundParameter.Table;
    $SystemInsightsDataSet.Keys | Where-Object { $_ -like "${TypeFilter}*" } | ForEach-Object { $SystemInsightsDataSet.$_ | Where-Object { $_ -like "${wordToComplete}*" } } | Sort-Object -Unique | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
# Export module member
Export-ModuleMember -Function $Public.BaseName -Alias *
