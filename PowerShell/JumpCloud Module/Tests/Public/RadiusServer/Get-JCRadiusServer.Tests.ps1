Describe -Tag:('JCRadiusServer') 'Get-JCRadiusServer Tests' {
    # $RadiusServerTemplate = @{
    #     'networkSourceIp' = '254.254.254.254'
    #     'sharedSecret'    = 'f3TkHSK2GT4JR!W9tugRPp2zQnAVObv'
    #     'name'            = 'PesterTest_RadiusServer'
    # }
    $RadiusServerTemplate = Get-JCRadiusServer -Name:($PesterParams.RadiusServerName); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
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
        It ('Should revert radius server changes.') {
            $RadiusServer = $RadiusServerTemplate | Set-JCRadiusServer -Name:('SomethingElse') -newName:($PesterParams.RadiusServerName) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
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
    Context 'Remove-JCRadiusServer' {
        It ('Should remove a specific radius server.') {
            $RadiusServer = Remove-JCRadiusServer -Id:($RadiusServerTemplate.id) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        }
    }
    Context 'New-JCRadiusServer' {
        It ('Should create a new radius server.') {
            $RadiusServer = $RadiusServerTemplate | New-JCRadiusServer # -Name:('') -networkSourceIp:('') -sharedSecret:('') -Force ;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        }
    }

    $RadiusServerTemplate = Get-JCRadiusServer -Name:($PesterParams.RadiusServerName); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
    Context 'Get-JCRadiusServer' {
        It ('Should return all radius servers.') {
            $RadiusServer = Get-JCRadiusServer; # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
        }
        It ('Should return a specific radius server ById.') {
            $RadiusServer = Get-JCRadiusServer -Id:($RadiusServerTemplate.id); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.id | Should -Be $RadiusServerTemplate.id
        }
        It ('Should return a specific radius server ByName.') {
            $RadiusServer = Get-JCRadiusServer -Name:($RadiusServerTemplate.name); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        }
        It ('Should return a specific radius server ByValue (ById).') {
            $RadiusServer = Get-JCRadiusServer -SearchBy:('ById') -SearchByValue:($RadiusServerTemplate.id); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.id | Should -Be $RadiusServerTemplate.id
        }
        It ('Should return a specific radius server ByValue (ByName).') {
            $RadiusServer = Get-JCRadiusServer -SearchBy:('ByName') -SearchByValue:($RadiusServerTemplate.name); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        }
    }
}