Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudMspOrg
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$ExcludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][System.String[]]$IncludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][System.String]$RequiredModulesRepo = 'PSGallery'
)
$stopwatch = [System.Diagnostics.Stopwatch]::new()
$stopwatch.Start()
# Load Get-Config.ps1
. "$PSScriptRoot/../../Deploy/Get-Config.ps1" -RequiredModulesRepo:($RequiredModulesRepo)
# . (Join-Path -Path:((Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName) -ChildPath:('Deploy/Get-Config.ps1') -Resolve)
# Get list of tags and validate that tags have been applied
$PesterTests = Get-ChildItem -Path:($PSScriptRoot + '/*.Tests.ps1') -Recurse
$Tags = ForEach ($PesterTest In $PesterTests) {
    $PesterTestFullName = $PesterTest.FullName
    $FileContent = Get-Content -Path:($PesterTestFullName)
    $DescribeLines = $FileContent | Select-String -Pattern:([RegEx]'(Describe)')#.Matches.Value
    ForEach ($DescribeLine In $DescribeLines) {
        If ($DescribeLine.Line -match 'Tag') {
            $TagParameterValue = ($DescribeLine.Line | Select-String -Pattern:([RegEx]'(?<=-Tag)(.*?)(?=\s)')).Matches.Value
            @(":", "(", ")", "'") | ForEach-Object { If ($TagParameterValue -like ('*' + $_ + '*')) {
                    $TagParameterValue = $TagParameterValue.Replace($_, '')
                } }
            $TagParameterValue
        } Else {
            Write-Error ('Tag missing in "' + $PesterTestFullName + '" on line number "' + $DescribeLine.LineNumber + '" value "' + ($DescribeLine.Line).Trim() + '"')
        }
    }
}
# Filters on tags
$IncludeTags = If ($IncludeTagList) {
    $IncludeTagList
} Else {
    $Tags | Where-Object { $_ -notin $ExcludeTags } | Select-Object -Unique
}
# Load DefineEnvironment
. ("$PSScriptRoot/DefineEnvironment.ps1") -JumpCloudApiKey:($JumpCloudApiKey) -JumpCloudApiKeyMsp:($JumpCloudApiKeyMsp) -RequiredModulesRepo:($RequiredModulesRepo)
# Load private functions
Write-Host ('[status]Load private functions: ' + "$PSScriptRoot/../Private/*.ps1")
Get-ChildItem -Path:("$PSScriptRoot/../Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
# Load HelperFunctions
Write-Host ('[status]Load HelperFunctions: ' + "$PSScriptRoot/HelperFunctions.ps1")
. ("$PSScriptRoot/HelperFunctions.ps1")
# Load SetupOrg
if ("MSP" -in $IncludeTags) {
    Write-Host ('[status]MSP Tests setting API Key, OrgID')
    $env:JCApiKey = $JumpCloudApiKeyMsp
    $env:JCOrgId = $JumpCloudMspOrg
    $env:JCProviderID = $env:XPROVIDER_ID
    # . ("$PSScriptRoot/SetupOrg.ps1") -JumpCloudApiKey:($JumpCloudApiKey) -JumpCloudApiKeyMsp:($JumpCloudApiKeyMsp) -JumpCloudMspOrg:($JumpCloudMspOrg)
} else {
    Write-Host ('[status]Setting up org: ' + "$PSScriptRoot/SetupOrg.ps1")
    . ("$PSScriptRoot/SetupOrg.ps1") -JumpCloudApiKey:($JumpCloudApiKey) -JumpCloudApiKeyMsp:($JumpCloudApiKeyMsp)
}
$PesterResultsFileXmldir = "$PSScriptRoot/test_results/"
# $PesterResultsFileXml = $PesterResultsFileXmldir + "results.xml"
if (-not (Test-Path $PesterResultsFileXmldir)) {
    New-Item -Path $PesterResultsFileXmldir -ItemType Directory
}
# Remove old test results file if exists (not needed)
# If (Test-Path -Path:("$PSScriptRoot/test_results/$PesterParams_PesterResultsFileXml")) { Remove-Item -Path:("$PSScriptRoot/test_results/$PesterParams_PesterResultsFileXml") -Force }
# Run Pester tests

# Parallel Pester Testing
$PesterParams = Get-Variable Pester*
$PesterTestsPaths = Get-ChildItem -Path $PSScriptRoot -Filter *.Tests.ps1 -Recurse | Where-Object size -GT 0

$PesterTestsPaths | ForEach-Object -Parallel {
    $JumpCloudApiKey = $using:JumpCloudApiKey
    $JumpCloudApiKeyMsp = $using:JumpCloudApiKeyMsp
    $JumpCloudMspOrg = $using:JumpCloudMspOrg
    #Load all pester params
    $using:PesterParams | ForEach-Object {
        Set-Variable -Name $_.Name -Value $_.Value
    }
    # Import JC Module
    Import-Module JumpCloud.SDK.V1
    Import-Module JumpCloud.SDK.V2
    Import-Module "$using:PSScriptRoot/../JumpCloud.psd1"
    # Authenticate to JumpCloud
    if (-not [string]::IsNullOrEmpty($using:JumpCloudMspOrg)) {
        Connect-JCOnline -JumpCloudApiKey:($using:JumpCloudApiKey) -JumpCloudOrgId:($using:JumpCloudMspOrg) -force | Out-Null
    } else {
        Connect-JCOnline -JumpCloudApiKey:($using:JumpCloudApiKey) -force | Out-Null
    }
    # Load DefineEnvironment
    . ("$using:PSScriptRoot/DefineEnvironment.ps1") -JumpCloudApiKey:($using:JumpCloudApiKey) -JumpCloudApiKeyMsp:($using:JumpCloudApiKeyMsp) -RequiredModulesRepo:($using:RequiredModulesRepo)
    # Load private functions
    Write-Host ('[status]Load private functions: ' + "$using:PSScriptRoot/../Private/*.ps1")
    Get-ChildItem -Path:("$using:PSScriptRoot/../Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
    # Load HelperFunctions
    Write-Host ('[status]Load HelperFunctions: ' + "$using:PSScriptRoot/HelperFunctions.ps1")
    . ("$using:PSScriptRoot/HelperFunctions.ps1")

    $FileName = $_.Name -replace '.Tests.ps1'

    $configuration = [PesterConfiguration]::Default
    $configuration.Run.Path = "$_"
    $configuration.Should.ErrorAction = 'Continue'
    $configuration.CodeCoverage.Enabled = $true
    $configuration.testresult.Enabled = $true
    $configuration.testresult.OutputFormat = 'JUnitXml'
    $configuration.Filter.Tag = $using:IncludeTags
    $configuration.Filter.ExcludeTag = $using:ExcludeTagList
    $configuration.CodeCoverage.OutputPath = ($using:PesterResultsFileXmldir + "$($FileName)-coverage.xml")
    $configuration.testresult.OutputPath = ($using:PesterResultsFileXmldir + "$($FileName)-results.xml")

    Write-Host ("[RUN COMMAND] Invoke-Pester -Path:('$_') -TagFilter:('$($using:IncludeTags -join "','")') -ExcludeTagFilter:('$($using:ExcludeTagList -join "','")') -PassThru") -BackgroundColor:('Black') -ForegroundColor:('Magenta')
    Invoke-Pester -Configuration $configuration
} -ThrottleLimit 10

$PesterTestResultPath = (Get-ChildItem -Path:("$($PesterResultsFileXmldir)")).FullName | Where-Object { $_ -match "results.xml" }
If (Test-Path -Path:($PesterTestResultPath)) {
    # Counter for failures/errors
    $totalFailures = 0
    $totalErrors = 0

    $PesterTestResultPath | ForEach-Object {
        [xml]$PesterResults = Get-Content -Path:($_)
        If ($PesterResults.ChildNodes.failures -gt 0) {
            $totalFailures++
        }
        If ($PesterResults.ChildNodes.errors -gt 0) {
            $totalErrors++
        }
    }
    if ($totalFailures -gt 0) {
        Write-Error ("Test Failures: $($totalFailures)")
    }
    if ($totalErrors -gt 0) {
        Write-Error ("Test Errors: $($totalErrors)")
    }
} Else {
    Write-Error ("Unable to find file path: $PesterTestResultPath")
}
$stopwatch.Stop()
$Stopwatch.Elapsed
Write-Host -ForegroundColor Green '-------------Done-------------'