Write-Host ("---------------------------------------------------------------------------------------")
Write-Host ('Host Information') -BackgroundColor:('Green') -ForegroundColor:('Black')
Write-Host ("---------------------------------------------------------------------------------------")
Get-Host | Select-Object *
Write-Host ("---------------------------------------------------------------------------------------")
Write-Host ('Imported Environment Variables') -BackgroundColor:('Green') -ForegroundColor:('Black')
Write-Host ("---------------------------------------------------------------------------------------")
Get-ChildItem Env: | Format-Table
Write-Host ("---------------------------------------------------------------------------------------")
Write-Host ('PsBoundParameters') -BackgroundColor:('Green') -ForegroundColor:('Black')
Write-Host ("---------------------------------------------------------------------------------------")
$PsBoundParameters.GetEnumerator()
Write-Host ("---------------------------------------------------------------------------------------")
Write-Host ('Imported Variables') -BackgroundColor:('Green') -ForegroundColor:('Black')
Write-Host ("---------------------------------------------------------------------------------------")
Get-Variable | Format-Table