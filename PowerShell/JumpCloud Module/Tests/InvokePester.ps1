Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$ExcludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][System.String[]]$IncludeTagList
)
# Install Pester
Install-Module -Repository:('PSGallery') -Name:('Pester') -Force
# Get list of tags and validate that tags have been applied
$PesterTests = Get-ChildItem -Path:($PSScriptRoot + '/*.Tests.ps1') -Recurse
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
# Load DefineEnvironment
. ("$PSScriptRoot/DefineEnvironment.ps1") -JumpCloudApiKey:($JumpCloudApiKey) -JumpCloudApiKeyMsp:($JumpCloudApiKeyMsp)
# Load required modules
$RequiredModules = (Import-LocalizedData -BaseDirectory:($PesterParams_ModuleManifestPath) -FileName:($PesterParams_ModuleManifestName)).RequiredModules
If ($RequiredModules)
{
    $RequiredModules | ForEach-Object {
        If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $_ })))
        {
            Write-Host ('Installing: ' + $_)
            Install-Module -Repository:('PSGallery') -Name:($_) -Force
        }
        If (!(Get-Module -Name:($_)))
        {
            Write-Host ('Importing: ' + $_)
            Import-Module -Name:($_) -Force
        }
    }
}
# Import the module
Import-Module -Name:("$PesterParams_ModuleManifestPath/$PesterParams_ModuleManifestName") -Force
# Load private functions
Get-ChildItem -Path:("$PSScriptRoot/../Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
# Load SetupOrg
. ("$PSScriptRoot/SetupOrg.ps1") -JumpCloudApiKey:($JumpCloudApiKey) -JumpCloudApiKeyMsp:($JumpCloudApiKeyMsp)
# Load HelperFunctions
. ("$PSScriptRoot/HelperFunctions.ps1")
# Run Pester tests
Write-Host ("[RUN COMMAND] Invoke-Pester -Path:($PSScriptRoot) -TagFilter:($IncludeTags) -ExcludeTagFilter:($ExcludeTagList) -PassThru") -BackgroundColor:('Black') -ForegroundColor:('Magenta')
If (Test-Path -Path:($PesterParams_PesterResultsFileXml)) { Remove-Item -Path:($PesterParams_PesterResultsFileXml) -Force }
$PesterResults = Invoke-Pester -PassThru -Path:($PSScriptRoot) -TagFilter:($IncludeTags) -ExcludeTagFilter:($ExcludeTagList)
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