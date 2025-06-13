function Get-JCRUserAgent {
    $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
    $psd1Path = Join-Path -Path $ModuleRoot -ChildPath 'JumpCloud.Radius.psd1'
    $psd1 = Import-PowerShellDataFile -Path $psd1Path
    $UserAgent_ModuleVersion = $psd1.ModuleVersion
    $UserAgent_ModuleName = 'PasswordlessRadiusConfig'
    #Build the UserAgent string
    $UserAgent_ModuleName = "JumpCloud_$($UserAgent_ModuleName).PowerShellModule"
    $Template_UserAgent = "{0}/{1}"
    $UserAgent = $Template_UserAgent -f $UserAgent_ModuleName, $UserAgent_ModuleVersion
    # When we import this config, this function will run and validate the openSSL binary location
    return $UserAgent
}