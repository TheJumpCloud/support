#Requires -Modules Pester, JumpCloud
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
            @(":", "(", ")", "'") | ForEach-Object { If ($TagParameterValue -like ('*' + $_ + '*')) { $TagParameterValue = $TagParameterValue.Replace($_, '') }}
            $TagParameterValue
        }
        Else
        {
            Write-Error ('Tag missing in "' + $PesterTestFullName + '" on line number "' + $DescribeLine.LineNumber + '" value "' + ($DescribeLine.Line).Trim() + '"')
        }
    }
}
# Filters on tags
$ExcludeTagList = ('')
$IncludeTagList = ('')
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
$PesterResults = Invoke-Pester -Script:(@{ Path = $PSScriptRoot; Parameters = $PesterParams; }) -PassThru -Tag:($IncludeTags) -ExcludeTag:($ExcludeTagList) -OutputFormat:('NUnitXml') -OutputFile:($PesterResultsFileXml)
# $PesterResults.TestResult | Where-Object {$_.Passed -eq $false} | Export-Csv $PesterResultsFileCsv


## Notes for future reporting dashboard for pester
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
