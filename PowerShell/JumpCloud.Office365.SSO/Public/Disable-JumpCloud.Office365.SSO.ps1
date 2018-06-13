function Disable-JumpCloud.Office365.SSO
{
    [CmdletBinding(DefaultParameterSetName = 'domain')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'xml')]
        [ValidateScript( { Test-Path -Path $_ -PathType leaf })]
        [ValidatePattern( '\.xml$' )]
        [string]$XMLFilePath,

        [Parameter(Mandatory, position = 0, ParameterSetName = 'domain')]
        [string]$Domain
    )
    
    begin
    {
        $Test = Test-MSOnline

        if ($Test -eq 1)
        {
            Return
        }
        
        if ($PSCmdlet.ParameterSetName -eq 'xml')
        {
            $Metadata = Get-MetaDataFromXML -XMLFilePath $XMLFilePath
            $Domain = $Metadata.Domain
            
        } 
    }
    
    process
    {
      
        Set-MsolDomainAuthentication -DomainName $Domain -Authentication "Managed" -ErrorAction SilentlyContinue -ErrorVariable ProcessError

        if ($ProcessError)
        {
            Connect-MsolService
           
            try
            {
                Set-MsolDomainAuthentication -DomainName $Domain -Authentication "Managed"  
                Write-Host "SSO disabled for domain: $Domain" -ForegroundColor Green
                Write-Warning "It can take up to 20 minutes for the Office 365 sign in process to revert back to normal. You may return sign in errors during this time."
            }
            catch
            {
                Return $_.ErrorDetails
            }

        }
        else
        {
            Write-Host "SSO disabled for domain: $Domain" -ForegroundColor Green
            Write-Warning "It can take up to 20 minutes for the Office 365 sign in process to revert back to normal. You may return sign in errors during this time."
        }
    }
    
    end
    {
    }
}
