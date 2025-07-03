Describe -Tag:('JCRadiusServer') 'Get-JCRadiusServer Tests' {
    BeforeAll {
        $NewRadiusServer = @{
            networkSourceIp = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
            sharedSecret    = "$(Get-Random)"
            name            = "PesterTest_RadiusServer_$(Get-Random)"
            authIdp         = 'JUMPCLOUD'

        };

        $RadiusServerTemplate = Create-RadiusServerTryCatch $NewRadiusServer
    }
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
        # It ('Should return a specific radius server ByValue (ById).') {
        #     $RadiusServer = Get-JCRadiusServer -SearchBy:('ById') -SearchByValue:($RadiusServerTemplate.id); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
        #     $RadiusServer | Should -Not -BeNullOrEmpty
        #     $RadiusServer.id | Should -Be $RadiusServerTemplate.id
        # }
        # It ('Should return a specific radius server ByValue (ByName).') {
        #     $RadiusServer = Get-JCRadiusServer -SearchBy:('ByName') -SearchByValue:($RadiusServerTemplate.name); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
        #     $RadiusServer | Should -Not -BeNullOrEmpty
        #     $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        # }
    }
}
