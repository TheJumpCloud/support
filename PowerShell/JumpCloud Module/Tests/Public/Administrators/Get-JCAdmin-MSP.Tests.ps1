Describe -Tag:('MSP') 'Get-JCAdmin Tests' {
    BeforeAll {
        $StartingApiKey = If (-not [System.String]::IsNullOrEmpty($env:JCApiKey)) {
            $env:JCApiKey
        }
        $StartingOrgId = If (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
            $env:JCOrgId
        }
        $orgs = Get-JCOrganization
    }
    Context 'Get-JCAdmin Tests' {
        It ('Get all administrators') {
            $Admins = Get-JCAdmin
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get a specific administrator by email address') {
            $Admins = Get-JCAdmin -email 'solutions-architecture+pestermtp@jumpcloud.com'
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get a specific administrator by email address with wildcard') {
            $Admins = Get-JCAdmin -email 'solutions-architecture*'
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get administrators by enableMultifactor') {
            $Admins = Get-JCAdmin -enableMultifactor $true
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get administrators by totpEnrolled') {
            $Admins = Get-JCAdmin -totpEnrolled $true
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get administrators by roleName') {
            $Admins = Get-JCAdmin -roleName 'Administrator With Billing'
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get administrators by organization') {
            $Admins = Get-JCAdmin -organization $orgs[0].OrgID
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get administrators by email, enableMultifactor, totpEnrolled, roleName and organization') {
            $Admins = Get-JCAdmin -email 'solutions-architecture*' -enableMultifactor $true -totpEnrolled $true -roleName 'Administrator With Billing' -organization $orgs[0].OrgID
            $Admins | Should -Not -BeNullOrEmpty
        }
    }
}