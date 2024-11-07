Describe -Tag:('JCRadiusServer') 'New-JCRadiusServer Tests' {
    BeforeAll {
        $NewRadiusServer = @{
            # networkSourceIp = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
            networkSourceIp = "119.213.49.186"
            sharedSecret    = "$(Get-Random)"
            name            = "PesterTest_RadiusServer_$(Get-Random)"
            authIdp         = 'JUMPCLOUD'

        };
        $NewAzureRadiusServer = @{
            networkSourceIp = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
            sharedSecret    = "$(Get-Random)"
            name            = "PesterTest_AzureRadiusServer_$(Get-Random)"
            authIdp         = 'AZURE'
        };

        $RadiusServerTemplate = Create-RadiusServerTryCatch $NewRadiusServer
        $AzureRadiusServerTemplate = Create-RadiusServerTryCatch $NewAzureRadiusServer
    }
    Context 'New-JCRadiusServer' {
        It ('Should create a new radius server.') {
            $RadiusServerTemplate | Remove-JCRadiusServer -Force
            $RadiusServer = $RadiusServerTemplate | New-JCRadiusServer # -Name:('') -networkSourceIp:('') -sharedSecret:('') -Force ;
            $RadiusServer | Should -Not -BeNullOrEmpty
            $RadiusServer.name | Should -Be $RadiusServerTemplate.name
            $RadiusServer.authIdp | Should -Be 'JUMPCLOUD' # This is the defulat authIdp
        }
        It ('Should create a new radius server.') {
            $AzureRadiusServerTemplate | Remove-JCRadiusServer -Force
            $AzureRadiusServer = $AzureRadiusServerTemplate | New-JCRadiusServer # -Name:('') -networkSourceIp:('') -sharedSecret:('') -Force ;
            $AzureRadiusServer | Should -Not -BeNullOrEmpty
            $AzureRadiusServer.name | Should -Be $AzureRadiusServerTemplate.name
            $AzureRadiusServer.authIdp | Should -Be $AzureRadiusServerTemplate.authIdp
            # clean up
            Remove-JCRadiusServer -id $AzureRadiusServer.id -Force
        }
    }
}
