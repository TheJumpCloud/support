Describe -Tag:('JCOnline') 'Connect-JCOnline Tests' {
    BeforeAll {
        $StartingApiKey = If (-not [System.String]::IsNullOrEmpty($env:JCApiKey)) { $env:JCApiKey }
        $StartingOrgId = If (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) { $env:JCOrgId }
    }
    Context 'Single Org Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -JumpCloudOrgId:($PesterParams_Org.OrgID) -force
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_Org.OrgID | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_Org.OrgID | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams_ApiKey) -force
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_Org.OrgID | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_Org.OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
    }
    AfterAll {
        If (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -JumpCloudOrgId:($StartingOrgId) -force | Out-Null }
        ElseIf (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -force | Out-Null }
        ElseIf ([System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudOrgId:($StartingOrgId) -force | Out-Null }
        Else { Write-Error ('Unknown scenario encountered') }
    }
}
