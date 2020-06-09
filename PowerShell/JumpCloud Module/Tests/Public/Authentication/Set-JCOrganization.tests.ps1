Describe -Tag:('JCOrganization') 'Set-JCOrganization Tests' {
    BeforeAll {
        # Prevent the Update-JCModule from running
        $env:JcUpdateModule = $false
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
            $Connect = Set-JCOrganization -JumpCloudApiKey:($PesterParams_ApiKey) -JumpCloudOrgId:($PesterParams_OrgId)
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_OrgId
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($PesterParams_ApiKey)
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_OrgId
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($PesterParams_ApiKey)
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_OrgId
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Set-JCOrganization
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_OrgId
        }
    }
    Context 'MSP OrgId 1 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($PesterParams_ApiKeyMsp) -JumpCloudOrgId:($PesterParams_OrgIdMsp1)
            $PesterParams_ApiKeyMsp | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_OrgIdMsp1
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($PesterParams_OrgIdMsp1)
            $PesterParams_ApiKeyMsp | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_OrgIdMsp1
        }
    }
    Context 'MSP OrgId 2 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($PesterParams_ApiKeyMsp) -JumpCloudOrgId:($PesterParams_OrgIdMsp2)
            $PesterParams_ApiKeyMsp | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_OrgIdMsp2
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($PesterParams_OrgIdMsp2)
            $PesterParams_ApiKeyMsp | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_OrgIdMsp2
        }
    }
}
