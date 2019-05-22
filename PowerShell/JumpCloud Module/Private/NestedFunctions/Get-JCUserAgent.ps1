Function Get-JCUserAgent
{
    param (
        $PSCallStack
    )
    $Template_UserAgent = '{0}/{1} (PSVersion:{2}; PSEdition:{3}; OS:{4}; Platform:{5}; UserFunction:{6}; LastFunction:{7};)'
    $ModuleName = $MyInvocation.MyCommand.Module.Name
    $ModuleVersion = $MyInvocation.MyCommand.Module.Version
    $PSVersion = [System.String]$PSVersionTable.PSVersion
    $PSEdition = [System.String]$PSVersionTable.PSEdition
    $OS = [System.String]$PSVersionTable.OS
    $Platform = [System.String]$PSVersionTable.Platform
    $UserFunction = $PSCallStack.Command[-2]
    $LastFunction = $PSCallStack.Command[0]
    $CustomUserAgent = $Template_UserAgent -f $ModuleName, $ModuleVersion, $PSVersion, $PSEdition, $OS, $Platform, $UserFunction, $LastFunction
    Write-Host ($CustomUserAgent + "`n") -BackgroundColor:('Cyan') -ForegroundColor:('Black')
    Return $CustomUserAgent
}
