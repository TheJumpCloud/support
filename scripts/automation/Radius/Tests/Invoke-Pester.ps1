# InvokePester.ps1 is intended to be called directly as a file-function
# There are two parameter sets
Param(
    [Parameter(ParameterSetName = 'SingleOrgTests', Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(ParameterSetName = 'SingleOrgTests', Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][System.String[]]$ExcludeTagList
    , [Parameter(ParameterSetName = 'SingleOrgTests', Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$IncludeTagList
    , [Parameter(ParameterSetName = 'ModuleValidation', Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 3)][switch]$ModuleValidation
)



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
# locally, clear pester run paths if it exists before run:
If ($PesterRunPaths) {
    Clear-Variable -Name PesterRunPaths
}
# Load private functions
Write-Host ('[status]Load private functions: ' + "$PSScriptRoot/../Functions/Private/*.ps1")
Import-Module -Name "$PSScriptRoot/../JumpCloud.Radius.psd1" -Force
Write-Host ('[status]Load public functions: ' + "$PSScriptRoot/../Functions/Public/*.ps1")
Get-ChildItem -Path:("$PSScriptRoot/../Functions/Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }

# Determine the parameter set path
if ($PSCmdlet.ParameterSetName -eq 'ModuleValidation') {
    $IncludeTags = "ModuleValidation"
    $PesterRunPaths = @(
        "$PSScriptRoot/ModuleValidation/"
    )
} else {
    $env:JCAPIKEY = $JumpCloudApiKey
    Connect-JCOnline -JumpCloudApiKey:($env:JCAPIKEY) -force
    Write-Host "Begin Org Setup Before Tests:"
    . "$PSScriptRoot/SetupRadiusOrg.ps1"
}

if (-Not $PesterRunPaths) {
    $PesterRunPaths = @(
        "$PSScriptRoot"
    )
}

# Set the test result directory:
$PesterResultsFileXmldir = "$PSScriptRoot/test_results/"
# create the directory if it does not exist:
if (-not (Test-Path $PesterResultsFileXmldir)) {
    New-Item -Path $PesterResultsFileXmldir -ItemType Directory
}

# define pester configuration
$configuration = New-PesterConfiguration
$configuration.Run.Path = $PesterRunPaths
$configuration.Should.ErrorAction = 'Continue'
$configuration.CodeCoverage.Enabled = $true
$configuration.testresult.Enabled = $true
$configuration.testresult.OutputFormat = 'JUnitXml'
$configuration.Filter.Tag = $IncludeTags
$configuration.Filter.ExcludeTag = $ExcludeTagList
$configuration.CodeCoverage.OutputPath = ($PesterResultsFileXmldir + 'coverage.xml')
$configuration.testresult.OutputPath = ($PesterResultsFileXmldir + 'results.xml')


Write-Host ("[RUN COMMAND] Invoke-Pester -Path:('$PesterRunPaths') -TagFilter:('$($IncludeTags -join "','")') -ExcludeTagFilter:('$($ExcludeTagList -join "','")') -PassThru") -BackgroundColor:('Black') -ForegroundColor:('Magenta')
# Run Pester tests
Invoke-Pester -Configuration $configuration

$PesterTestResultPath = (Get-ChildItem -Path:("$($PesterResultsFileXmldir)")).FullName | Where-Object { $_ -match "results.xml" }
If (Test-Path -Path:($PesterTestResultPath)) {
    [xml]$PesterResults = Get-Content -Path:($PesterTestResultPath)
    If ($PesterResults.ChildNodes.failures -gt 0) {
        Write-Error ("Test Failures: $($PesterResults.ChildNodes.failures)")
    }
    If ($PesterResults.ChildNodes.errors -gt 0) {
        Write-Error ("Test Errors: $($PesterResults.ChildNodes.errors)")
    }
} Else {
    Write-Error ("Unable to find file path: $PesterTestResultPath")
}
Write-Host -ForegroundColor Green '-------------Done-------------'