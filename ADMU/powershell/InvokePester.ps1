# Load functions
. ($PSScriptRoot + '/Functions.ps1')

# Run Pester tests
$PesterResults = Invoke-Pester -Script:(@{ Path = $PSScriptRoot + '/Tests/'; }) -PassThru
$FailedTests = $PesterResults.TestResult | Where-Object {$_.Passed -eq $false}
If ($FailedTests)
{
    Write-Host ('')
    Write-Host ('##############################################################################################################')
    Write-Host ('##############################Error Description###############################################################')
    Write-Host ('##############################################################################################################')
    Write-Host ('')
    $FailedTests | ForEach-Object {$_.Name + '; ' + $_.FailureMessage + '; '}
    Write-Error -Message:('Tests Failed: ' + [string]($FailedTests | Measure-Object).Count)
}

# Write-Output $error.Count
# if ($error.count -gt 0){
#     Write-Output $error
#     exit 1
# } else {
#     exit 0
# }