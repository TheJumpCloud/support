Function Import-JCCommand
{
    [CmdletBinding(DefaultParameterSetName = 'URL')]
    param (

        [Parameter(
            ParameterSetName = 'URL',
            Mandatory,
            Position = 0,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $URL

    )
    
    begin
    { 

        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}
        $NewCommandsArray = @() #Output new commands
        
    }
    
    process 
    {

        if ($PSCmdlet.ParameterSetName -eq 'URL')
        {

            $NewCommand = New-JCCommandFromURL -GitHubURL $URL
            
            $NewCommandsArray += $NewCommand
        }

    } #End process
        
    end
    {

        Return $NewCommandsArray
    }
}