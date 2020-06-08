# See Get-JCRadiusServer.Tests.ps1
Describe -Tag:('JCRadiusServer') 'Set-JCRadiusServer 1.15.3' {
    # $RadiusServerTemplate = @{
    #     'networkSourceIp' = '254.254.254.254'
    #     'sharedSecret'    = 'f3TkHSK2GT4JR!W9tugRPp2zQnAVObv'
    #     'name'            = 'PesterTest_RadiusServer'
    # }
    $RadiusServerTemplate = Get-JCRadiusServer -Name:($PesterParams_RadiusServerName); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
    Context 'Set-JCRadiusServer params' {
        It ('Should ENABLE mfa on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($RadiusServerTemplate.name) -mfa:('ENABLED') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.mfa | Should -Be 'ENABLED'
        }
        It ('Should DISABLE mfa on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($RadiusServerTemplate.name) -mfa:('DISABLED') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.mfa | Should -Be 'DISABLED'
        }
        It ('Should ENABLE mfa on a radius server by ID.') {
            $RadiusServer = Set-JCRadiusServer -id:($RadiusServerTemplate.id) -mfa:('ENABLED') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.mfa | Should -Be 'ENABLED'
        }
        It ('Should DISABLE mfa on a radius server by ID.') {
            $RadiusServer = Set-JCRadiusServer -id:($RadiusServerTemplate.id) -mfa:('DISABLED') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.mfa | Should -Be 'DISABLED'
        }

        It ('Should set userLockoutAction to REMOVE on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($RadiusServerTemplate.name) -userLockoutAction:('REMOVE') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userLockoutAction | Should -Be 'REMOVE'
        }
        It ('Should set userLockoutAction to MAINTAIN on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($RadiusServerTemplate.name) -userLockoutAction:('MAINTAIN') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userLockoutAction | Should -Be 'MAINTAIN'
        }
        It ('Should set userLockoutAction to REMOVE on a radius server by id.') {
            $RadiusServer = Set-JCRadiusServer -id:($RadiusServerTemplate.id) -userLockoutAction:('REMOVE') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userLockoutAction | Should -Be 'REMOVE'
        }
        It ('Should set userLockoutAction to MAINTAIN on a radius server by id.') {
            $RadiusServer = Set-JCRadiusServer -id:($RadiusServerTemplate.id) -userLockoutAction:('MAINTAIN') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userLockoutAction | Should -Be 'MAINTAIN'
        }

        It ('Should set userPasswordExpirationAction to REMOVE on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($RadiusServerTemplate.name) -userPasswordExpirationAction:('REMOVE') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userPasswordExpirationAction | Should -Be 'REMOVE'
        }
        It ('Should set userPasswordExpirationAction to MAINTAIN on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($RadiusServerTemplate.name) -userPasswordExpirationAction:('MAINTAIN') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userPasswordExpirationAction | Should -Be 'MAINTAIN'
        }
        It ('Should set userPasswordExpirationAction to REMOVE on a radius server by id.') {
            $RadiusServer = Set-JCRadiusServer -id:($RadiusServerTemplate.id) -userPasswordExpirationAction:('REMOVE') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userPasswordExpirationAction | Should -Be 'REMOVE'
        }
        It ('Should set userPasswordExpirationAction to MAINTAIN on a radius server by id.') {
            $RadiusServer = Set-JCRadiusServer -id:($RadiusServerTemplate.id) -userPasswordExpirationAction:('MAINTAIN') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userPasswordExpirationAction | Should -Be 'MAINTAIN'
        }

    }
}
