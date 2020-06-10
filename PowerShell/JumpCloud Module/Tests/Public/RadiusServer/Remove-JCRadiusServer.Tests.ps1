Describe -Tag:('JCRadiusServer') 'Remove-JCRadiusServer Tests' {
    BeforeAll {
        $RadiusServerTemplate = Get-JCRadiusServer -Name:($PesterParams_RadiusServerName); # -Fields:('') -Filter:('') -Limit:(1) -Skip:(1) -Paginate:($true) -Force;
        If (-not $RadiusServerTemplate)
        {
            $RadiusServerTemplate = New-JCRadiusServer @PesterParams_NewRadiusServer
        }
    }
    Context 'Remove-JCRadiusServer' {
        It ('Should remove a specific radius server.') {
            $RadiusServer = Remove-JCRadiusServer -Id:($RadiusServerTemplate.id) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        }
    }
}