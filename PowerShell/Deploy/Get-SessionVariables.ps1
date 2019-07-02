Write-Host ('Imported Environment Variables') -BackgroundColor:('Green') -ForegroundColor:('Black')
Get-ChildItem Env: | Format-Table

Write-Host ('PsBoundParameters') -BackgroundColor:('Green') -ForegroundColor:('Black')
$PsBoundParameters.GetEnumerator()

Write-Host ('Imported Variables') -BackgroundColor:('Green') -ForegroundColor:('Black')
Get-Variable | Format-Table