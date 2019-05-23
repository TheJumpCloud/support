Function Get-JCUserAgent
{
    param (
        $PSCallStack
    )
    $Template_UserAgent = '{0}/{1} (PSVersion:{2}; PSEdition:{3}; OS:{4}; Platform:{5}; IS_CUSTOMER:{6}; PrimaryFunction:{7}; NestedFunction:{8};)'
    $ModuleName = $MyInvocation.MyCommand.Module.Name
    $ModuleVersion = $MyInvocation.MyCommand.Module.Version
    $PSVersion = [System.String]$PSVersionTable.PSVersion
    $PSEdition = [System.String]$PSVersionTable.PSEdition
    $OS = [System.String]$PSVersionTable.OS
    $Platform = [System.String]$PSVersionTable.Platform
    $PrimaryFunction = $PSCallStack.Command[-2]
    $NestedFunction = $PSCallStack.Command[0]
    $IS_CUSTOMER = $JCSettings.IS_CUSTOMER
    $CustomUserAgent = $Template_UserAgent -f $ModuleName, $ModuleVersion, $PSVersion, $PSEdition, $OS, $Platform, $IS_CUSTOMER, $PrimaryFunction, $NestedFunction
    Write-Host ($CustomUserAgent + "`n") -BackgroundColor:('Cyan') -ForegroundColor:('Black')
    Return $CustomUserAgent
}
