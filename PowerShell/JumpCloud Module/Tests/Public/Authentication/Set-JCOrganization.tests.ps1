Describe -Tag:('JCOrganization') 'Set-JCOrganization Tests' {
    # Prevent the Update-JCModule from running
    $env:JcUpdateModule = $false
    BeforeAll {
        $StartingApiKey = If (-not [System.String]::IsNullOrEmpty($env:JCApiKey)) { $env:JCApiKey }
        $StartingOrgId = If (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) { $env:JCOrgId }
    }
    AfterAll {
        If (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -JumpCloudOrgId:($StartingOrgId) -force | Out-Null }
        ElseIf (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -force | Out-Null }
        ElseIf ([System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudOrgId:($StartingOrgId) -force | Out-Null }
        ElseIf ([System.String]::IsNullOrEmpty($StartingApiKey) -and [System.String]::IsNullOrEmpty($StartingOrgId)) { $null }
        Else { Write-Error ('Unknown scenario encountered') }
    }
    Context 'Single Org Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($TestOrgAPIKey) -JumpCloudOrgId:($PesterParams_SingleTernateOrgId)
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_SingleTernateOrgId
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($TestOrgAPIKey)
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_SingleTernateOrgId
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($TestOrgAPIKey)
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_SingleTernateOrgId
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Set-JCOrganization
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_SingleTernateOrgId
        }
    }
    Context 'MSP OrgId 1 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams_MultiTernateOrgId1)
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId1
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($PesterParams_MultiTernateOrgId1)
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId1
        }
    }
    Context 'MSP OrgId 2 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams_MultiTernateOrgId2)
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId2
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($PesterParams_MultiTernateOrgId2)
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId2
        }
    }
}
