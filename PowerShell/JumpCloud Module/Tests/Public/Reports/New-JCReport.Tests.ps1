Describe -Tag:('JCReport') 'New-JCReport Tests' {
    It ('Should generate reports') {
        { $browserPatchPolicy = New-JCReport -ReportType "browser-patch-policy" } | Should -Not -Throw
        { $osPatchPolicy = New-JCReport -ReportType "os-patch-policy" } | Should -Not -Throw
        { $usersToDevices = New-JCReport -ReportType "users-to-devices" } | Should -Not -Throw
        { $usersToDirectories = New-JCReport -ReportType "users-to-directories" } | Should -Not -Throw
        { $usersToLdapServers = New-JCReport -ReportType "users-to-ldap-servers" } | Should -Not -Throw
        { $usersToRadiusServers = New-JCReport -ReportType "users-to-radius-servers" } | Should -Not -Throw
        { $usersToSsoApps = New-JCReport -ReportType "users-to-sso-applications" } | Should -Not -Throw
        { $usersToUserGroups = New-JCReport -ReportType "users-to-user-groups" } | Should -Not -Throw
    }
    It ('Should throw when not using a valid reportType') {
        { $testreport = New-JCReport -ReportType 'randomReport' } | Should -Throw
    }
}