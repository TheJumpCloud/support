Function Import-JCCommand
{
    [CmdletBinding(DefaultParameterSetName = 'URL')]
    Param (
        [Parameter(ParameterSetName = 'URL', Mandatory, Position = 0, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The URL of the JumpCloud command to import into a JumpCloud tenant.')]
        [string]$URL
    )
    Begin
    {
        Write-Verbose 'Verifying JCAPI Key'
        If ($JCAPIKEY.length -ne 40) {Connect-JConline}
        $NewCommandsArray = @() #Output new commands
    }
    Process
    {
        If ($PSCmdlet.ParameterSetName -eq 'URL')
        {
            $NewCommand = New-JCCommandFromURL -GitHubURL $URL
            $NewCommandsArray += $NewCommand
        }
    } #End process
    End
    {
        Return $NewCommandsArray
    }
}