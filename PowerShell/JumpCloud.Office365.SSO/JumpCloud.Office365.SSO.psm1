
$Public = @( Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" )

$Private = @( Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse)

Foreach ($Import in @($Public + $Private)) {
    Try {
        . $Import.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($Import.FullName)"
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Enable-JumpCloud.Office365.SSO, Disable-JumpCloud.Office365.SSO, Show-JumpCloud.Office365.SSO