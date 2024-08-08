Describe -Tag:('JCAdmin') 'Get-JCAdmin Tests' {
    Context 'Get-JCAdmin Tests' {
        It ('Get all administrators') {
            $Admins = Get-JCAdmin
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get a specific administrator by email address with wildcard') {
            $Admins = Get-JCAdmin -email 'solutions-architecture*'
            $Admins | Should -Not -BeNullOrEmpty
        }
        It ('Get administrators by enableMultifactor') {
            $Admins = Get-JCAdmin -enableMultifactor $false
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
        It ('Get administrators by email, enableMultifactor, totpEnrolled, roleName') {
            $Admins = Get-JCAdmin -email 'solutions-architecture*' -enableMultifactor $false -totpEnrolled $true -roleName 'Administrator'
            $Admins | Should -Not -BeNullOrEmpty
        }
    }
}