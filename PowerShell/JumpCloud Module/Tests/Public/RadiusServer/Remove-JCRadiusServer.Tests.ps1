Describe -Tag:('JCRadiusServer') 'Remove-JCRadiusServer Tests' {
    BeforeAll {
        $NewRadiusServer = @{
            networkSourceIp = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
            sharedSecret    = "$(Get-Random)"
            name            = "PesterTest_RadiusServer_$(Get-Random)"
            authIdp         = 'JUMPCLOUD'

        };
        $RadiusServerTemplate = Create-RadiusServerTryCatch $NewRadiusServer
    }
    Context 'Remove-JCRadiusServer' {
        It ('Should remove a specific radius server.') {
            $RadiusServer = Remove-JCRadiusServer -Id:($RadiusServerTemplate.id) -Force;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $RadiusServerTemplate.name
        }
    }
}
