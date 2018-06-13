function Show-JumpCloud.Office365.SSO
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
        if ($PSCmdlet.ParameterSetName -eq 'xml')
        {
            $Metadata = Get-MetaDataFromXML -XMLFilePath $XMLFilePath
            $Domain = $Metadata.Domain
            
        }
        
        $Test = Test-MSOnline

        if ($Test -eq 1)
        {
            Return
        }
       
    }
    
    process
    {

      
        $Results = Get-MsolDomainFederationSettings -DomainName $domain -ErrorAction SilentlyContinue -ErrorVariable ProcessError
     
        if ($ProcessError)
        {
            Connect-MsolService
            $Results = Get-MsolDomainFederationSettings -DomainName $domain
        }
           

        if ($Results -eq $null)
        {
            
            $Results = "Federation is not configured for domain: $domain"
        }
    }
    
    end
    {
        Return $Results
    }
}
