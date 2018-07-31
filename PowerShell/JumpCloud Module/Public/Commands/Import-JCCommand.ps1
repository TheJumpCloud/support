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
        [ValidateScript( {
                If (Invoke-Webrequest $_ -UseBasicParsing)
                {
                    $True
                }
                else
                {
                    Throw "You are either offline or $_ is not a URL. Enter a URL"
                }
            })]
        $URL

    )
    
    begin
    { 

       
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