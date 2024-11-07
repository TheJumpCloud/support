Describe -Tag:('JCRadiusServer') 'Set-JCRadiusServer Tests' {
    BeforeAll {
        $NewRadiusServer = @{
            networkSourceIp = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
            sharedSecret    = "$(Get-Random)"
            name            = "PesterTest_RadiusServer_$(Get-Random)"
            authIdp         = 'JUMPCLOUD'

        };

        $RadiusServerTemplate = Create-RadiusServerTryCatch $NewRadiusServer

    }
    Context 'Set-JCRadiusServer' {
        It ('Should update a radius server ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($RadiusServerTemplate.name) -newName:('Something') -networkSourceIp:($PesterParams_networkSourceIpUpdate) -sharedSecret:('kldFaSDfAdgfAgxcxWEQTRDS') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be 'Something'
            $RadiusServer.networkSourceIp | Should -Be $PesterParams_networkSourceIpUpdate
            $RadiusServer.sharedSecret | Should -Be 'kldFaSDfAdgfAgxcxWEQTRDS'
        }
        It ('Should update a radius server ById.') {
            $RadiusServer = Set-JCRadiusServer -Id:($RadiusServerTemplate.id) -newName:('SomethingElse') -networkSourceIp:($PesterParams_networkSourceIpInitial) -sharedSecret:('aseRDGsDFGSDfgBsdRFTygSW') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be 'SomethingElse'
            $RadiusServer.networkSourceIp | Should -Be $PesterParams_networkSourceIpInitial
            $RadiusServer.sharedSecret | Should -Be 'aseRDGsDFGSDfgBsdRFTygSW'
        }
    }
}
Describe -Tag:('JCRadiusServer') 'Set-JCRadiusServer 1.15.3' {
    BeforeAll {
        $NewRadiusServer = @{
            networkSourceIp = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
            sharedSecret    = "$(Get-Random)"
            name            = "PesterTest_RadiusServer_$(Get-Random)"
            authIdp         = 'JUMPCLOUD'
        };
        $RadiusServerTemplate = Create-RadiusServerTryCatch $NewRadiusServer
    }
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
