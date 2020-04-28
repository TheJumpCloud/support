# Load all functions from public and private folders
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
# Set default values for function parameters
$PSDefaultParameterValues['Invoke-RestMethod:ContentType'] = 'application/json; charset=utf-8'
$PSDefaultParameterValues['Invoke-WebRequest:ContentType'] = 'application/json; charset=utf-8'
# Set function aliases
Set-Alias -Name:('New-JCAssociation') -Value:('Add-JCAssociation')
# Export module member
Export-ModuleMember -Function $Public.BaseName -Alias *