Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudMspOrg
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$ExcludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][System.String[]]$IncludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][System.String]$RequiredModulesRepo = 'PSGallery'
)
# Load Get-Config.ps1
. "$PSScriptRoot/../../Deploy/Get-Config.ps1" -RequiredModulesRepo:($RequiredModulesRepo)

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

# Setup folder for test results
$PesterResultsFileXmldir = "$PSScriptRoot/test_results/"
if (-not (Test-Path $PesterResultsFileXmldir)) {
    New-Item -Path $PesterResultsFileXmldir -ItemType Directory
}

# Store all Pester variables for use in parallel block
$LoadPesterParams = Get-Variable PesterParams*
$PesterTestsPaths = Get-ChildItem -Path $PSScriptRoot -Filter *.Tests.ps1 -Recurse | Where-Object size -GT 0 | Sort-Object -Property Name
Write-Host "[status]Found $($PesterTestsPaths.Count) Test Files"
# create a hash of tests to track progress
$hash = New-Object System.Collections.ArrayList
for ($i = 0; $i -lt $PesterTestsPaths.Count; $i++) {
    $hash.Add(
        [PSCustomObject]@{
            Name = ($PesterTestsPaths[$i].BaseName)
            Path = ($PesterTestsPaths[$i].FullName)
            ID   = ($i)
        }
    ) | Out-Null
}


# Create a hashtable for process.
# Keys should be ID's of the processes
$origin = @{}
$hash | ForEach-Object { $origin.($_.Id) = @{} }
$sync = [System.Collections.Hashtable]::Synchronized($origin)

# Run Pester tests in Parallel
Write-Host '[status]Beginning Parallel Pester Invocations'
$PesterJobs = $hash | ForEach-Object -ThrottleLimit 10 -AsJob -Parallel {
    # parallel output
    $syncCopy = $using:sync
    $process = $syncCopy.$($PSItem.Id)
    $process.Id = $PSItem.Id
    $process.Activity = "$($PSItem.Name) Test Setup"
    $process.PercentComplete = ((0 / 100) * 100)
    $process.Status = "Initializing"

    $JumpCloudApiKey = $using:JumpCloudApiKey
    $JumpCloudApiKeyMsp = $using:JumpCloudApiKeyMsp
    $JumpCloudMspOrg = $using:JumpCloudMspOrg
    #Load all pester params
    $using:LoadPesterParams | ForEach-Object {
        Set-Variable -Name $_.Name -Value $_.Value
    }
    $process.Activity = "$($PSItem.Name) Importing Modules"
    # Import JC Module
    # Import-Module JumpCloud.SDK.V1
    # Import-Module JumpCloud.SDK.V2
    Import-Module "$using:PSScriptRoot/../JumpCloud.psd1"
    $process.Status = "Connecting"
    $process.PercentComplete = ((10 / 100) * 100)
    # Authenticate to JumpCloud
    if (-not [string]::IsNullOrEmpty($using:JumpCloudMspOrg)) {
        Connect-JCOnline -JumpCloudApiKey:($using:JumpCloudApiKey) -JumpCloudOrgId:($using:JumpCloudMspOrg) -force | Out-Null
    } else {
        Connect-JCOnline -JumpCloudApiKey:($using:JumpCloudApiKey) -force | Out-Null
    }
    # Load private functions
    Get-ChildItem -Path:("$using:PSScriptRoot/../Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
    # Load HelperFunctions
    . ("$using:PSScriptRoot/HelperFunctions.ps1")

    $process.PercentComplete = ((20 / 100) * 100)
    $configuration = [PesterConfiguration]::Default
    $configuration.Run.Path = "$($_.Path)"
    $configuration.Run.PassThru = $true
    $configuration.Should.ErrorAction = 'Continue'
    $configuration.Filter.Tag = $using:IncludeTags
    $configuration.Filter.ExcludeTag = $using:ExcludeTagList

    #Write-Host ("[RUN COMMAND] Invoke-Pester -Path:('$_') -TagFilter:('$($using:IncludeTags -join "','")') -ExcludeTagFilter:('$($using:ExcludeTagList -join "','")') -PassThru") -BackgroundColor:('Black') -ForegroundColor:('Magenta')
    $process.Activity = "$($PSItem.Name) Tests Running"
    $process.Status = "Running"

    $process.PercentComplete = ((25 / 100) * 100)
    Invoke-Pester -Configuration $configuration
    $process.PercentComplete = ((100 / 100) * 100)
    $process.Completed = $true

}

while ($PesterJobs.State -eq 'Running') {
    $sync.Keys | ForEach-Object {
        # If key is not defined, ignore
        if (![string]::IsNullOrEmpty($sync.$_.keys)) {
            # Create parameter hashtable to splat
            $param = $sync.$_

            # Execute Write-Progress
            Write-Progress @param
        }
    }

    # Wait to refresh to not overload gui
    if ($CIRCLECI) {
        Start-Sleep -Seconds 60
    } else {
        Start-Sleep -Seconds 0.1
    }
}
# Aggregate test results
$PesterJobResults = ($PesterJobs | Wait-Job | Receive-Job -Keep)
$PesterResultsObject = [Pester.Run]::new()
$PesterJobResults | ForEach-Object {
    $PesterResultsObject.Containers += $_.Containers
    $PesterResultsObject.DiscoveryDuration += $_.DiscoveryDuration
    $PesterResultsObject.Duration += $_.Duration
    $PesterResultsObject.Executed += $_.Executed
    $PesterResultsObject.Failed += $_.Failed
    $PesterResultsObject.FailedBlocks += $_.FailedBlocks
    $PesterResultsObject.FailedBlocksCount += $_.FailedBlocksCount
    $PesterResultsObject.FailedContainers += $_.FailedContainers
    $PesterResultsObject.FailedContainersCount += $_.FailedContainersCount
    $PesterResultsObject.FailedCount += $_.FailedCount
    $PesterResultsObject.FrameworkDuration += $_.FrameworkDuration
    $PesterResultsObject.NotRun += $_.NotRun
    $PesterResultsObject.NotRunCount += $_.NotRunCount
    $PesterResultsObject.Passed += $_.Passed
    $PesterResultsObject.PassedCount += $_.PassedCount
    $PesterResultsObject.Result += $_.Result
    $PesterResultsObject.Skipped += $_.Skipped
    $PesterResultsObject.SkippedCount += $_.SkippedCount
    $PesterResultsObject.Tests += $_.Tests
    $PesterResultsObject.TotalCount += $_.TotalCount
    $PesterResultsObject.UserDuration += $_.UserDuration
}
$PesterResultsObject | Export-JUnitReport -Path ($PesterResultsFileXmldir + 'results.xml')
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