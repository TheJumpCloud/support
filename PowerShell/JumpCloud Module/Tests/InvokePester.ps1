Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$TestOrgAPIKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$MultiTenantAPIKey
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$ExcludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][System.String[]]$IncludeTagList
)
$ScriptRoot = $PSScriptRoot
$ModuleManifestName = 'JumpCloud.psd1'
$ModuleManifestPath = "$ScriptRoot/../$ModuleManifestName"
# # Install Pester
Install-Module -Name:('Pester') -Force
# Install NuGet
If (!(Get-PackageProvider -Name:('NuGet') -ErrorAction:('SilentlyContinue')))
{
    Install-PackageProvider NuGet -ForceBootstrap -Force | Out-Null
}
# Load required modules
$RequiredModules = (Import-LocalizedData -BaseDirectory:("$ScriptRoot/..") -FileName:($ModuleManifestName)).RequiredModules
If ($RequiredModules)
{
    $RequiredModules | ForEach-Object {
        If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $_ })))
        {
            Write-Host ('Installing: ' + $_)
            Install-Module -Name:($_) -Force
        }
        If (!(Get-Module -Name:($_)))
        {
            Write-Host ('Importing: ' + $_)
            Import-Module -Name:($_) -Force
        }
    }
}
# Import the module
Import-Module -Name:($ModuleManifestPath) -Force
# Load private functions
Get-ChildItem -Path:("$ScriptRoot/../Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
# Load TestEnvironmentVariables
. ("$ScriptRoot/TestEnvironmentVariables.ps1") -TestOrgAPIKey:($TestOrgAPIKey) -MultiTenantAPIKey:($MultiTenantAPIKey)
# Load HelperFunctions
. ("$ScriptRoot/HelperFunctions.ps1")
# Get list of tags and validate that tags have been applied
$PesterTests = Get-ChildItem -Path:($ScriptRoot + '/*.Tests.ps1') -Recurse
$Tags = ForEach ($PesterTest In $PesterTests)
{
    $PesterTestFullName = $PesterTest.FullName
    $FileContent = Get-Content -Path:($PesterTestFullName)
    $DescribeLines = $FileContent | Select-String -Pattern:([RegEx]'(Describe)')#.Matches.Value
    ForEach ($DescribeLine In $DescribeLines)
    {
        If ($DescribeLine.Line -match 'Tag')
        {
            $TagParameterValue = ($DescribeLine.Line | Select-String -Pattern:([RegEx]'(?<=-Tag)(.*?)(?=\s)')).Matches.Value
            @(":", "(", ")", "'") | ForEach-Object { If ($TagParameterValue -like ('*' + $_ + '*')) { $TagParameterValue = $TagParameterValue.Replace($_, '') } }
            $TagParameterValue
        }
        Else
        {
            Write-Error ('Tag missing in "' + $PesterTestFullName + '" on line number "' + $DescribeLine.LineNumber + '" value "' + ($DescribeLine.Line).Trim() + '"')
        }
    }
}
# Filters on tags
$IncludeTags = If ($IncludeTagList)
{
    $IncludeTagList
}
Else
{
    $Tags | Where-Object { $_ -notin $ExcludeTags } | Select-Object -Unique
}
# "'" + ($IncludeTags -join "','") + "'"
# Run Pester tests
Write-Host ("[RUN COMMAND] Invoke-Pester -Path:($ScriptRoot) -TagFilter:($IncludeTags) -ExcludeTagFilter:($ExcludeTagList) -PassThru") -BackgroundColor:('Black') -ForegroundColor:('Magenta')
If (Test-Path -Path:($PesterParams_PesterResultsFileXml)) { Remove-Item -Path:($PesterParams_PesterResultsFileXml) -Force }
$PesterResults = Invoke-Pester -PassThru -Path:($ScriptRoot) -TagFilter:($IncludeTags) -ExcludeTagFilter:($ExcludeTagList)
$PesterResults | Export-NUnitReport -Path:($PesterParams_PesterResultsFileXml)
If (Test-Path -Path:($PesterParams_PesterResultsFileXml))
{
    [xml]$PesterResults = Get-Content -Path:($PesterParams_PesterResultsFileXml)
    $FailedTests = $PesterResults.'test-results'.'test-suite'.'results'.'test-suite' | Where-Object { $_.success -eq 'False' }
    If ($FailedTests)
    {
        Write-Host ('')
        Write-Host ('##############################################################################################################')
        Write-Host ('##############################Error Description###############################################################')
        Write-Host ('##############################################################################################################')
        Write-Host ('')
        $FailedTests | ForEach-Object { $_.InnerText + ';' }
        Write-Error -Message:('Tests Failed: ' + [string]($FailedTests | Measure-Object).Count)
    }
}
