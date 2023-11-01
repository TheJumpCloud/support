# InvokePester.ps1 is intended to be called directly as a file-function
# There are two parameter sets

Param(
    [Parameter(ParameterSetName = 'SingleOrgTests', Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(ParameterSetName = 'MSPTests', Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
    , [Parameter(ParameterSetName = 'MSPTests', Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudMspOrg
    , [Parameter(ParameterSetName = 'MSPTests', Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$ProviderID
    , [Parameter(ParameterSetName = 'SingleOrgTests', Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$ExcludeTagList
    , [Parameter(ParameterSetName = 'SingleOrgTests', Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][System.String[]]$IncludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][System.String]$RequiredModulesRepo = 'PSGallery'
    , [Parameter(ParameterSetName = 'ModuleValidation', Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 5)][switch]$ModuleValidation
    , [Parameter(ParameterSetName = 'MSPTests', Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 6)][switch]$MSP
)

# Load Get-Config.ps1
. "$PSScriptRoot/../../Deploy/Get-Config.ps1"

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
# Determine the parameter set path
if ($PSCmdlet.ParameterSetName -eq 'ModuleValidation') {
    $IncludeTags = "ModuleValidation"
    $PesterRunPaths = @(
        "$PSScriptRoot/ModuleValidation/"
    )
} elseif ($PSCmdlet.ParameterSetName -eq 'SingleOrgTests') {
    if ($env:CI) {
        If ($env:job_group) {
            # split tests by job group:
            $PesterTestsPaths = Get-ChildItem -Path $PSScriptRoot -Filter *.Tests.ps1 -Recurse | Where-Object size -GT 0 | Sort-Object -Property Name
            $counter = [pscustomobject] @{ Value = 0 }
            $groupSize = 30
            $PesterGroups = $PesterTestsPaths | Group-Object -Property { [math]::Floor($counter.Value++ / $groupSize) }
            $jobMatrixSet = @{
                0 = $PesterGroups[0].Group.FullName
                1 = $PesterGroups[1].Group.FullName
                2 = $PesterGroups[2].Group.FullName
            }
            Write-Host "[status] Running CI job group $env:job_group"
            $PesterRunPaths = $jobMatrixSet[[int]$($env:job_group)]
        }
    } else {
        # run setup org locally and set variables
        $variables = . ("./PowerShell/JumpCloud Module/Tests/SetupOrg.ps1") -JumpCloudApiKey "$JumpCloudApiKey" -JumpCloudApiKeyMsp "$JumpCloudApiKey"
        Write-Host "[status] Setting Env Variables for tests"
        $variables | Foreach-Object {
            if ($_.Name) {
                Set-Variable -Name $_.Name -Value $_.Value -Scope Global
            }
        }
    }


    $env:JCAPIKEY = $JumpCloudApiKey
    Connect-JCOnline -JumpCloudApiKey:($env:JCAPIKEY) -force
} elseif ($PSCmdlet.ParameterSetName -eq 'MSPTests') {
    # For online tests we need to run setup org and generate resources within an organization
    # Load DefineEnvironment
    $IncludeTags = "MSP"
    $PesterRunPaths = @(
        "$PSScriptRoot"
    )
    $MSPVars = . ("$PSScriptRoot/DefineEnvironment.ps1") -JumpCloudApiKey:($JumpCloudApiKeyMsp) -JumpCloudApiKeyMsp:($JumpCloudApiKeyMsp) -RequiredModulesRepo:($RequiredModulesRepo)
    # Set Env Variables
    $env:JCAPIKEY = $JumpCloudApiKeyMsp
    $env:JCOrgId = $JumpCloudMspOrg
    $env:JCProviderID = $ProviderID
    # force import module
    Import-Module $FilePath_psd1 -Force
    Connect-JCOnline -JumpCloudApiKey:($env:JCAPIKEY) -JumpCloudOrgId:($env:JCOrgId) -force
}
if (-Not $PesterRunPaths) {
    $PesterRunPaths = @(
        "$PSScriptRoot"
    )
}
# Load private functions
Write-Host ('[status]Load private functions: ' + "$PSScriptRoot/../Private/*.ps1")
Get-ChildItem -Path:("$PSScriptRoot/../Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
# Load HelperFunctions
Write-Host ('[status]Load HelperFunctions: ' + "$PSScriptRoot/HelperFunctions.ps1")
. ("$PSScriptRoot/HelperFunctions.ps1")

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