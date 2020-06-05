Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$TestOrgAPIKey,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$MultiTenantAPIKey,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$ExcludeTagList,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][System.String[]]$IncludeTagList
)
$ModuleManifestName = 'JumpCloud.psd1'
$ModuleManifestPath = "$PSScriptRoot/../$ModuleManifestName"
$RequiredModules = (Import-LocalizedData -BaseDirectory:("$PSScriptRoot/..") -FileName:($ModuleManifestName)).RequiredModules
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
# Install NuGet
If (!(Get-PackageProvider -Name:('NuGet') -ErrorAction:('SilentlyContinue')))
{
    Install-PackageProvider NuGet -ForceBootstrap -Force | Out-Null
}
# Load config and helper files
. ($PSScriptRoot + '/HelperFunctions.ps1')
. ($PSScriptRoot + '/TestEnvironmentVariables.ps1')
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
# Run Pester tests
$PesterResultsFileXml = $PSScriptRoot + '/Pester.Tests.Results.xml'
$PesterResultsFileCsv = $PSScriptRoot + '/Pester.Tests.Results.csv'
#$PesterResults = Invoke-Pester -Script:(@{ Path = $PSScriptRoot; Parameters = $PesterParams; }) -PassThru -Tag:($IncludeTags) -ExcludeTag:($ExcludeTagList) -OutputFormat:('NUnitXml') -OutputFile:($PesterResultsFileXml) ## ToDo: Have pester tests export to file
$PesterResults = Invoke-Pester -Script ($PSScriptRoot) -PassThru -Tag:($IncludeTags) -ExcludeTag:($ExcludeTagList)
$PesterResults | ConvertTo-NUnitReport -AsString | out-file -FilePath "$modulename + '-TestResults.xml'" | Set-Content -Path:($testModulePath)

# $PesterResults.TestResult | Where-Object {$_.Passed -eq $false} | Export-Csv $PesterResultsFileCsv
$FailedTests = $PesterResults.TestResult | Where-Object { $_.Passed -eq $false }
If ($FailedTests)
{
    Write-Host ('')
    Write-Host ('##############################################################################################################')
    Write-Host ('##############################Error Description###############################################################')
    Write-Host ('##############################################################################################################')
    Write-Host ('')
    $FailedTests | ForEach-Object { $_.Name + '; ' + $_.FailureMessage + '; ' }
    Write-Error -Message:('Tests Failed: ' + [string]($FailedTests | Measure-Object).Count)
}

### Notes for future reporting dashboard for pester
# Install-PackageProvider -Name:('NuGet')
# Install-Package -Name:('extent')
# Install-Package extent
# $Package = Get-Package -Name:('ReportUnit')
# $ReportUnitExePath = ($Package.Source).Replace($Package.PackageFilename, 'toolsReportUnit.exe')
# # $ReportUnitExePath = '{PathTo}\extent.exe'
# # Invoke-Pester -Path:('PesterTests.ps1') -OutputFormat:('NUnitXml') -OutputFile:($PesterResultsFileXml) -Show None -PassThru -Strict
# $ReportUnitCommand = '"' + $ReportUnitExePath + '" "' + $PesterResultsFileXml + '"'
# Invoke-Expression -Command:($ReportUnitCommand)
# Start-Process chrome $htmlFile
