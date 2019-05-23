Function Get-JCUserAgent
{
    # Get information about the module
    If ($MyInvocation.MyCommand.Module)
    {
        $UserAgent_ModuleName = $MyInvocation.MyCommand.Module.Name
        $UserAgent_ModuleVersion = $MyInvocation.MyCommand.Module.Version
    }
    Else
    {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent
        $ModulePsd1 = Get-ChildItem -Path:($ModuleRoot) -Filter:('*.psd1')
        If ($ModulePsd1)
        {
            $Psd1Info = Import-LocalizedData -BaseDirectory:($ModulePsd1.Directory) -FileName:($ModulePsd1.Name)
            $UserAgent_ModuleName = $Psd1Info.RootModule.Replace('.psm1', '')
            $UserAgent_ModuleVersion = $Psd1Info.ModuleVersion
        }
        Else
        {
            Write-Error ('Unable to locate the module psd1 file!')
        }
    }
    # Get information about the version of PowerShell
    $UserAgent_PSVersion = [System.String]$PSVersionTable.PSVersion
    $UserAgent_PSEdition = [System.String]$PSVersionTable.PSEdition
    $UserAgent_OS = [System.String]$PSVersionTable.OS
    $UserAgent_Platform = [System.String]$PSVersionTable.Platform
    # Get information about the functions that were used to make the web request
    $UserAgent_PSCallStack = Get-PSCallStack
    $UserAgent_PrimaryFunction = $UserAgent_PSCallStack.Command[-2]
    $UserAgent_NestedFunction = $UserAgent_PSCallStack.Command[1]
    # Get information about who is running the command
    $UserAgent_IS_CUSTOMER = $JCSettings.IS_CUSTOMER
    # Build UserAgent string
    $Template_UserAgent = '{0}/{1} (PSVersion:{2}; PSEdition:{3}; OS:{4}; Platform:{5}; IS_CUSTOMER:{6}; PrimaryFunction:{7}; NestedFunction:{8};)'
    $CustomUserAgent = $Template_UserAgent -f $UserAgent_ModuleName, $UserAgent_ModuleVersion, $UserAgent_PSVersion, $UserAgent_PSEdition, $UserAgent_OS, $UserAgent_Platform, $UserAgent_IS_CUSTOMER, $UserAgent_PrimaryFunction, $UserAgent_NestedFunction
    # Uncomment if you want to see what the UserAgent string looks like
    # Write-Host ($CustomUserAgent + "`n") -BackgroundColor:('Green') -ForegroundColor:('Black')
    Return $CustomUserAgent
}
