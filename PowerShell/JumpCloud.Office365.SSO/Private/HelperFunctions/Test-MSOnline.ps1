function Test-MSOnline ()
{
    [int]$PSVersion = $PSVersionTable.PSVersion.Major

    switch ($PSVersion)
    {
        {$_ -lt 3} 
        { Write-Error "You must be running at least PowerShell version 3 to use the commands in this module."}
        {$_ -ge 3 -and $_ -le 4}
        {
            if (Get-Command Connect-MsolService -eq '$true'-ErrorAction SilentlyContinue)
            {
                Write-Debug -Message "MSOnline module loaded"
                
            }
        
            else
            {
                Write-Host "You must manually install the following items:" -ForegroundColor Red
                Write-Host "https://www.microsoft.com/en-us/download/details.aspx?id=41950" -ForegroundColor Yellow
                Write-Host "https://docs.microsoft.com/en-us/powershell/gallery/installing-psget" -ForegroundColor Yellow
                Write-Host "Follow the above links in a web browser to install these items and then try again" -ForegroundColor Green
                Return 1
            }

        }
        {$_ -ge 5}
        {   
            if (Get-Command Connect-MsolService -eq '$true'-ErrorAction SilentlyContinue)
            {
                Write-Debug -Message "MSOnline module loaded"         
            }
        
            else
            {
                Write-Debug -Message "MSOnline module is not loaded" 
                Install-Module MSOnline -Scope CurrentUser -Force
                if (Get-Command Connect-MsolService -ne '$true'-ErrorAction SilentlyContinue)
                {
                    Return 1
                }
            }
        }
    }
   
}