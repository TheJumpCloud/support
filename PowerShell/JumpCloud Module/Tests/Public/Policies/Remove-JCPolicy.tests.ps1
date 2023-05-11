Describe -Tag:('JCPolicy') 'Remove-JCPolicy 1.10' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It 'Remove Policy by PolicyID' {
        # Create test policy for removal
        $policyTemplates = Get-JcSdkPolicyTemplate
        $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
        $templateId = $policyTemplate.id
        $stringPolicy = New-JCPolicy -Name "Pester - Remove Policy Test" -templateID $templateId -ADMINISTRATORSTRING "Test String"

        $DeletedPolicy = Remove-JCPolicy -Id $stringPolicy.Id -Force
        $DeletedPolicy.results | Should -Be 'Deleted'
    }
    It 'Remove Policy by Name' {
        # Create test policy for removal
        $policyTemplates = Get-JcSdkPolicyTemplate
        $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
        $templateId = $policyTemplate.id
        $stringPolicy = New-JCPolicy -Name "Pester - Remove Policy Test" -templateID $templateId -ADMINISTRATORSTRING "Test String"

        $DeletedPolicy = Remove-JCPolicy -Name $stringPolicy.Name -Force
        $DeletedPolicy.results | Should -Be 'Deleted'
    }
    It "Remove Policy by Non-existant Name" {
        $DeletedPolicy = { Remove-JCPolicy -Name "Pester - Fake Policy Test" -Force -ErrorAction Stop } | Should -Throw
    }
}