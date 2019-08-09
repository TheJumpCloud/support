$TestOrgAPIKey = 'ff6006d0cd75d4c52eacf9da2aa7205595ef97bf'
$MultiTenantAPIKey = '70a96c7196db6d4dac8a375b32686d07a641d671'
$PesterParams = @{
    # Specific to MTP portal
    'SingleTernateOrgId' = '5a4bff7ab17d0c9f63bcd277'
    'MultiTernateOrgId1' = "5b5a13f06fefdb0a29b0d306"
    'MultiTernateOrgId2' = "5b5a14d13f852310b1d689b1"
}
Describe -Tag:('JCOnline') 'Connect-JCOnline Tests' {
    BeforeAll {
        $StartingApiKey = If (-not [System.String]::IsNullOrEmpty($env:JCApiKey)) {$env:JCApiKey}
        $StartingOrgId = If (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) {$env:JCOrgId}
    }
    AfterAll {
        If (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) {Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -JumpCloudOrgId:($StartingOrgId) -force | Out-Null}
        ElseIf (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and [System.String]::IsNullOrEmpty($StartingOrgId)) {Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -force | Out-Null}
        ElseIf ([System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) {Connect-JCOnline -JumpCloudOrgId:($StartingOrgId) -force | Out-Null}
        Else {Write-Error ('Unknown scenario encountered')}
    }
    Context 'Single Org Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -JumpCloudOrgId:($PesterParams.SingleTernateOrgId) -force
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($TestOrgAPIKey) -force
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
        }
    }
    Context 'MSP OrgId 1 Tests' {

        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId1) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId1
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId1
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams.MultiTernateOrgId1) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId1
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
        }
    }
    Context 'MSP OrgId 2 Tests' {

        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId2) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId2
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId2
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams.MultiTernateOrgId2) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId2
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
        }
    }
}