Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$ExcludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][System.String[]]$IncludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][System.String]$RequiredModulesRepo = 'PSGallery'
)
# Load Get-Config.ps1
. (Join-Path -Path:((Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName) -ChildPath:('Deploy/Get-Config.ps1') -Resolve)
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
# Load private functions
Write-Host ('[status]Load private functions: ' + "$PSScriptRoot/../Private/*.ps1")
Get-ChildItem -Path:("$PSScriptRoot/../Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
# Load SetupOrg
Write-Host ('[status]Setting up org: ' + "$PSScriptRoot/SetupOrg.ps1")
. ("$PSScriptRoot/SetupOrg.ps1") -JumpCloudApiKey:($JumpCloudApiKey) -JumpCloudApiKeyMsp:($JumpCloudApiKeyMsp)
# Load HelperFunctions
Write-Host ('[status]Load HelperFunctions: ' + "$PSScriptRoot/HelperFunctions.ps1")
. ("$PSScriptRoot/HelperFunctions.ps1")
$PesterResultsFileXmldir = "$PSScriptRoot/test_results/"
# $PesterResultsFileXml = $PesterResultsFileXmldir + "results.xml"
if (-not (Test-Path $PesterResultsFileXmldir))
{
    new-item -path $PesterResultsFileXmldir -ItemType Directory
}
# Remove old test results file if exists
If (Test-Path -Path:("$PSScriptRoot/test_results/$PesterParams_PesterResultsFileXml")) { Remove-Item -Path:("$PSScriptRoot/test_results/$PesterParams_PesterResultsFileXml") -Force }
# Run Pester tests

$configuration = [PesterConfiguration]::Default
$configuration.Run.Path = "$PSScriptRoot"
$configuration.Should.ErrorAction = 'Continue'
$configuration.CodeCoverage.Enabled = $true
$configuration.testresult.Enabled = $true
$configuration.testresult.OutputFormat = 'JUnitXml'
$configuration.Filter.Tag = $IncludeTags
$configuration.Filter.ExcludeTag = $ExcludeTagList
$configuration.CodeCoverage.OutputPath = ($PesterResultsFileXmldir + 'coverage.xml')
$configuration.testresult.OutputPath = ($PesterResultsFileXmldir + 'results.xml')

Invoke-Pester -configuration $configuration

Write-Host ("[RUN COMMAND] Invoke-Pester -Path:('$PSScriptRoot') -TagFilter:('$($IncludeTags -join "','")') -ExcludeTagFilter:('$($ExcludeTagList -join "','")') -PassThru") -BackgroundColor:('Black') -ForegroundColor:('Magenta')
# $PesterResults = Invoke-Pester -PassThru -Path:($PSScriptRoot) -TagFilter:($IncludeTags) -ExcludeTagFilter:($ExcludeTagList)
# $PesterResults | Export-JUnitReport -Path:("$PSScriptRoot/test_results/text.xml")
# $PesterResults | Export-JUnitReport -Path:("$PSScriptRoot/test_results/$PesterParams_PesterResultsFileXml")
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