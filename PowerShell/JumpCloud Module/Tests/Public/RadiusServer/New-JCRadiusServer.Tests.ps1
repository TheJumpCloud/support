Describe -Tag:('JCRadiusServer') 'New-JCRadiusServer Tests' {
    BeforeAll {
        $RadiusServerTemplate = Get-JCRadiusServer -Name:($PesterParams_RadiusServerName); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
    }
    Context 'New-JCRadiusServer' {
        It ('Should create a new radius server.') {
            $RadiusServerTemplate | Remove-JCRadiusServer -Force
            $RadiusServer = $RadiusServerTemplate | New-JCRadiusServer # -Name:('') -networkSourceIp:('') -sharedSecret:('') -Force ;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        }
    }
}