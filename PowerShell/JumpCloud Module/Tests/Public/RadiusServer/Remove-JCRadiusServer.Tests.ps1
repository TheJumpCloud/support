Describe -Tag:('JCRadiusServer') 'Remove-JCRadiusServer Tests' {
    BeforeAll {
        If (-not (Get-JCRadiusServer -Name:($PesterParams_RadiusServer.name)))
        {
            $PesterParams_RadiusServer = New-JCRadiusServer @PesterParams_NewRadiusServer
        }
    }
    Context 'Remove-JCRadiusServer' {
        It ('Should remove a specific radius server.') {
            $RadiusServer = Remove-JCRadiusServer -Id:($PesterParams_RadiusServer.id) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $PesterParams_RadiusServer.name
        }
    }
}