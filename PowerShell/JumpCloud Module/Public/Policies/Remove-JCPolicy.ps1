Function Remove-JCPolicy () {
    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0,
            HelpMessage = 'The PolicyID of the JumpCloud policy you wish to remove.')]
        [Alias('_id', 'id')]
        [String[]]$PolicyID,
        [Parameter(
            ParameterSetName = 'Name',
            HelpMessage = 'The Name of the JumpCloud policy you wish to remove.')]
        [String[]]$Name,
        [Parameter(HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud Policy.')]
        [Switch]
        $force
    )
    begin {}
    process {}
    end {}
}