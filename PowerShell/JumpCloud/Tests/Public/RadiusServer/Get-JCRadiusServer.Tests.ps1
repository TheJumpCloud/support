Describe -Tag:('JCRadiusServer') 'Get-JCRadiusServer Tests' {
    BeforeAll {
        $RadiusServerTemplate = Get-JCRadiusServer -Name:($PesterParams_RadiusServer.name); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
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
