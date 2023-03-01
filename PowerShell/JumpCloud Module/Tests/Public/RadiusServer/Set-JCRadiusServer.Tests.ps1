Describe -Tag:('JCRadiusServer') 'Set-JCRadiusServer Tests' {
    BeforeAll {
        $PesterParams_RadiusServer = Get-JCRadiusServer -Name:($PesterParams_RadiusServer.name)
        If (-not $PesterParams_RadiusServer) {
            $PesterParams_RadiusServer = New-JCRadiusServer @PesterParams_NewRadiusServer
        }
    }
    Context 'Set-JCRadiusServer' {
        It ('Should update a radius server ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($PesterParams_RadiusServer.name) -newName:('Something') -networkSourceIp:($PesterParams_networkSourceIpUpdate) -sharedSecret:('kldFaSDfAdgfAgxcxWEQTRDS') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be 'Something'
            $RadiusServer.networkSourceIp | Should -Be $PesterParams_networkSourceIpUpdate
            $RadiusServer.sharedSecret | Should -Be 'kldFaSDfAdgfAgxcxWEQTRDS'
        }
        It ('Should update a radius server ById.') {
            $RadiusServer = Set-JCRadiusServer -Id:($PesterParams_RadiusServer.id) -newName:('SomethingElse') -networkSourceIp:($PesterParams_networkSourceIpInitial) -sharedSecret:('aseRDGsDFGSDfgBsdRFTygSW') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be 'SomethingElse'
            $RadiusServer.networkSourceIp | Should -Be $PesterParams_networkSourceIpInitial
            $RadiusServer.sharedSecret | Should -Be 'aseRDGsDFGSDfgBsdRFTygSW'
        }
        # It ('Should return a specific radius server ByValue (ById).') {
        #     $RadiusServer = Set-JCRadiusServer -SearchBy:('ById') -SearchByValue:('') -newName:('') -networkSourceIp:('') -sharedSecret:('') -Force;
        #     $RadiusServer | Should -Not -BeNullOrEmpty
        #     $RadiusServer.id | Should -Be $PesterParams_RadiusServer.id
        # }
        # It ('Should return a specific radius server ByValue (ByName).') {
        #     $RadiusServer = Set-JCRadiusServer -SearchBy:('ByName') -SearchByValue:('') -newName:('') -networkSourceIp:('') -sharedSecret:('') -Force;
        #     $RadiusServer | Should -Not -BeNullOrEmpty
        #     $RadiusServer.name | Should -Be $PesterParams_RadiusServer.name
        # }
    }
}
Describe -Tag:('JCRadiusServer') 'Set-JCRadiusServer 1.15.3' {
    BeforeAll {
        $PesterParams_RadiusServer = Get-JCRadiusServer -Name:($PesterParams_RadiusServer.name)
        If (-not $PesterParams_RadiusServer) {
            try {
                $PesterParams_RadiusServer = New-JCRadiusServer @PesterParams_NewRadiusServer
            } catch {
                $PesterParams_NewRadiusServer.networkSourceIp = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
                $PesterParams_RadiusServer = New-JCRadiusServer @PesterParams_NewRadiusServer
            }
        }
    }
    Context 'Set-JCRadiusServer params' {
        It ('Should ENABLE mfa on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($PesterParams_RadiusServer.name) -mfa:('ENABLED') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.mfa | Should -Be 'ENABLED'
        }
        It ('Should DISABLE mfa on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($PesterParams_RadiusServer.name) -mfa:('DISABLED') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.mfa | Should -Be 'DISABLED'
        }
        It ('Should ENABLE mfa on a radius server by ID.') {
            $RadiusServer = Set-JCRadiusServer -id:($PesterParams_RadiusServer.id) -mfa:('ENABLED') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.mfa | Should -Be 'ENABLED'
        }
        It ('Should DISABLE mfa on a radius server by ID.') {
            $RadiusServer = Set-JCRadiusServer -id:($PesterParams_RadiusServer.id) -mfa:('DISABLED') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.mfa | Should -Be 'DISABLED'
        }
        It ('Should set userLockoutAction to REMOVE on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($PesterParams_RadiusServer.name) -userLockoutAction:('REMOVE') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userLockoutAction | Should -Be 'REMOVE'
        }
        It ('Should set userLockoutAction to MAINTAIN on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($PesterParams_RadiusServer.name) -userLockoutAction:('MAINTAIN') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userLockoutAction | Should -Be 'MAINTAIN'
        }
        It ('Should set userLockoutAction to REMOVE on a radius server by id.') {
            $RadiusServer = Set-JCRadiusServer -id:($PesterParams_RadiusServer.id) -userLockoutAction:('REMOVE') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userLockoutAction | Should -Be 'REMOVE'
        }
        It ('Should set userLockoutAction to MAINTAIN on a radius server by id.') {
            $RadiusServer = Set-JCRadiusServer -id:($PesterParams_RadiusServer.id) -userLockoutAction:('MAINTAIN') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userLockoutAction | Should -Be 'MAINTAIN'
        }
        It ('Should set userPasswordExpirationAction to REMOVE on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($PesterParams_RadiusServer.name) -userPasswordExpirationAction:('REMOVE') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userPasswordExpirationAction | Should -Be 'REMOVE'
        }
        It ('Should set userPasswordExpirationAction to MAINTAIN on a radius server by ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($PesterParams_RadiusServer.name) -userPasswordExpirationAction:('MAINTAIN') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userPasswordExpirationAction | Should -Be 'MAINTAIN'
        }
        It ('Should set userPasswordExpirationAction to REMOVE on a radius server by id.') {
            $RadiusServer = Set-JCRadiusServer -id:($PesterParams_RadiusServer.id) -userPasswordExpirationAction:('REMOVE') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userPasswordExpirationAction | Should -Be 'REMOVE'
        }
        It ('Should set userPasswordExpirationAction to MAINTAIN on a radius server by id.') {
            $RadiusServer = Set-JCRadiusServer -id:($PesterParams_RadiusServer.id) -userPasswordExpirationAction:('MAINTAIN') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.userPasswordExpirationAction | Should -Be 'MAINTAIN'
        }
    }
}
