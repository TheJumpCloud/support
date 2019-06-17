$Public = @( Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -Recurse )

$Private = @( Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -Recurse)

Foreach ($Import in @($Public + $Private))
{
    Try
    {
        . $Import.FullName
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}
# Function Aliases
Set-Alias -Name:('New-JCAssociation') -Value:('Add-JCAssociation')
# Export Module Member
Export-ModuleMember -Function $Public.BaseName -Alias *