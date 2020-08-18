function Test-MSOnline ()
{
    if (Get-Command Connect-MsolService -eq '$true'-ErrorAction SilentlyContinue)
    {
        Write-Debug -Message "MSOnline module loaded"
    }

    else
    {
        Write-Debug -Message "MSOnline module is not loaded"

        try
        {
            Install-Module MSOnline -Repository:('PSGallery') -Scope CurrentUser -Force
        }
        catch
        {
            Return 1
        }

    }

}