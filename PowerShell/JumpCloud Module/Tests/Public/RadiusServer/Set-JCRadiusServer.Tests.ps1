Describe -Tag:('JCRadiusServer') 'Set-JCRadiusServer Tests' {
    BeforeAll {
        $RadiusServerTemplate = Get-JCRadiusServer -Name:($PesterParams_RadiusServerName); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
        If (-not $RadiusServerTemplate)
        {
            $RadiusServerTemplate = New-JCRadiusServer @PesterParams_NewRadiusServer
        }
    }
    Context 'Set-JCRadiusServer' {
        It ('Should update a radius server ByName.') {
            $RadiusServer = Set-JCRadiusServer -Name:($RadiusServerTemplate.name) -newName:('Something') -networkSourceIp:('246.246.246.246') -sharedSecret:('kldFaSDfAdgfAgxcxWEQTRDS') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be 'Something'
            $RadiusServer.networkSourceIp | Should -Be '246.246.246.246'
            $RadiusServer.sharedSecret | Should -Be 'kldFaSDfAdgfAgxcxWEQTRDS'
        }
        It ('Should update a radius server ById.') {
            $RadiusServer = Set-JCRadiusServer -Id:($RadiusServerTemplate.id) -newName:('SomethingElse') -networkSourceIp:('246.246.246.247') -sharedSecret:('aseRDGsDFGSDfgBsdRFTygSW') -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be 'SomethingElse'
            $RadiusServer.networkSourceIp | Should -Be '246.246.246.247'
            $RadiusServer.sharedSecret | Should -Be 'aseRDGsDFGSDfgBsdRFTygSW'
        }
        # It ('Should return a specific radius server ByValue (ById).') {
        #     $RadiusServer = Set-JCRadiusServer -SearchBy:('ById') -SearchByValue:('') -newName:('') -networkSourceIp:('') -sharedSecret:('') -Force;
        #     $RadiusServer | Should -Not -BeNullOrEmpty
        #     $RadiusServer.id | Should -Be $RadiusServerTemplate.id
        # }
        # It ('Should return a specific radius server ByValue (ByName).') {
        #     $RadiusServer = Set-JCRadiusServer -SearchBy:('ByName') -SearchByValue:('') -newName:('') -networkSourceIp:('') -sharedSecret:('') -Force;
        #     $RadiusServer | Should -Not -BeNullOrEmpty
        #     $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        # }
    }
}
Describe -Tag:('JCRadiusServer') 'Set-JCRadiusServer 1.15.3' {
    BeforeAll {
        $RadiusServerTemplate = Get-JCRadiusServer -Name:($PesterParams_RadiusServerName); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
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
