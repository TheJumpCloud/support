@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'JumpCloud.psm1'

    # ID used to uniquely identify this module
    GUID              = '31c023d1-a901-48c4-90a3-082f91b31646'

    # Version number of this module.
    ModuleVersion     = '1.10.1'

    # Author of this module
    Author            = 'Scott Reed'

    # Company or vendor of this module
    CompanyName       = 'JumpCloud'

    # Copyright statement for this module
    Copyright         = '(c) JumpCloud. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'PowerShell functions to manage a JumpCloud Directory-as-a-Service'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(  "Connect-JCOnline",
        "Add-JCSystemGroupMember",
        "Add-JCUserGroupMember",
        "Add-JCSystemUser",
        "Get-JCCommand",
        "Get-JCCommandResult",
        "Get-JCGroup",
        "Get-JCSystem",
        "Get-JCSystemGroupMember",
        "Get-JCSystemUser",
        "Get-JCUser",
        "Get-JCUserGroupMember",
        "Invoke-JCCommand",
        "New-JCSystemGroup",
        "New-JCUser",
        "New-JCUserGroup",
        "Remove-JCCommandResult",
        "Remove-JCSystem",
        "Remove-JCSystemGroup",
        "Remove-JCSystemGroupMember",
        "Remove-JCUser",
        "Remove-JCSystemUser",
        "Remove-JCUserGroup",
        "Remove-JCUserGroupMember",
        "Set-JCSystem",
        "Set-JCUser",
        "Set-JCSystemUser",
        "Remove-JCCommand",
        "New-JCCommand",
        "Import-JCCommand",
        "Add-JCCommandTarget",
        "Get-JCCommandTarget",
        "Remove-JCCommandTarget",
        "Set-JCUserGroupLDAP",
        "Import-JCUsersFromCSV",
        "Get-JCBackup",
        "Send-JCPasswordReset",
        "Get-JCOrganization",
        "Set-JCOrganization",
        "New-JCDeploymentTemplate",
        "Invoke-JCDeployment",
        "Set-JCCommand",
        "New-JCImportTemplate",
        "Update-JCUsersFromCSV",
        "Add-JCRadiusReplyAttribute",
        "Set-JCRadiusReplyAttribute",
        "Get-JCRadiusReplyAttribute",
        "Remove-JCRadiusReplyAttribute",
        "Get-JCPolicy",
        "Get-JCPolicyResult",
        "Get-JCPolicyTargetSystem",
        "Get-JCPolicyTargetGroup",
        "Get-JCAssociation")

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @()


    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('JumpCloud', 'DaaS', 'Jump', 'Cloud', 'Directory')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/TheJumpCloud/support/wiki'

            # A URL to an icon representing this module.
            IconUri      = 'https://avatars1.githubusercontent.com/u/4927461?s=200&v=4'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://git.io/jc-pwsh-releasenotes'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
