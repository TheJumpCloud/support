Function Get-JCUserAgent
{
    # Get information about the module
    $ModuleName = $MyInvocation.MyCommand.Module.Name
    $ModuleVersion = $MyInvocation.MyCommand.Module.Version
    # Get information about the version of PowerShell
    $PSVersion = [System.String]$PSVersionTable.PSVersion
    $PSEdition = [System.String]$PSVersionTable.PSEdition
    $OS = [System.String]$PSVersionTable.OS
    $Platform = [System.String]$PSVersionTable.Platform
    # Get information about the functions that were used to make the web request
    $PSCallStack = Get-PSCallStack
    $PrimaryFunction = $PSCallStack.Command[-2]
    $NestedFunction = $PSCallStack.Command[1]
    # Get information about who is running the command
    $IS_CUSTOMER = $JCSettings.IS_CUSTOMER
    # Build UserAgent string
    $Template_UserAgent = '{0}/{1} (PSVersion:{2}; PSEdition:{3}; OS:{4}; Platform:{5}; IS_CUSTOMER:{6}; PrimaryFunction:{7}; NestedFunction:{8};)'
    $CustomUserAgent = $Template_UserAgent -f $ModuleName, $ModuleVersion, $PSVersion, $PSEdition, $OS, $Platform, $IS_CUSTOMER, $PrimaryFunction, $NestedFunction
    Write-Host ($CustomUserAgent + "`n") -BackgroundColor:('Cyan') -ForegroundColor:('Black')
    Return $CustomUserAgent
}
