Describe -Tag:('JCRadiusServer') 'Remove-JCRadiusServer Tests' {
    BeforeAll {
        $PesterParams_RadiusServer = Get-JCRadiusServer -Name:($PesterParams_RadiusServer.name)
        If (-not $PesterParams_RadiusServer) {
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