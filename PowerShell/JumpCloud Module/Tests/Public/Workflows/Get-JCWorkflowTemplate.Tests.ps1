Describe -Tag('JCWorkflow') 'Get-JCWorkflowTemplate 1.0' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../../../JumpCloud.psd1" -Force

        if ([string]::IsNullOrEmpty($global:JCAPIKEY) -and [string]::IsNullOrEmpty($env:JCAPIKEY)) {
            [void](Connect-JCOnline)
        } else {
            [void](Connect-JCOnline -JumpCloudAPIKey ($global:JCAPIKEY ?? $env:JCAPIKEY) -Force)
        }

        $script:allTemplates = Get-JCWorkflowTemplate
        if ($script:allTemplates -and (@($script:allTemplates).Count -gt 0)) {
            $script:sampleTemplate = @($script:allTemplates)[0]
        }
    }

    It "Returns all workflow templates when no parameters are specified" {
        { Get-JCWorkflowTemplate } | Should -Not -Throw
        $script:allTemplates | Should -Not -BeNullOrEmpty
    }

    It "Returns a workflow template by ID (using -Id and -TemplateID alias)" {
        if ($script:sampleTemplate.id) {
            $result = Get-JCWorkflowTemplate -Id $script:sampleTemplate.id
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $script:sampleTemplate.id

            $resultAlias = Get-JCWorkflowTemplate -TemplateID $script:sampleTemplate.id
            $resultAlias.id | Should -Be $script:sampleTemplate.id
        }
    }

    It "Returns a workflow template by Name (using -Name and -TemplateName alias)" {
        if ($script:sampleTemplate.name) {
            $result = Get-JCWorkflowTemplate -Name $script:sampleTemplate.name
            $result | Should -Not -BeNullOrEmpty
            $result.name | Should -Be $script:sampleTemplate.name

            $resultAlias = Get-JCWorkflowTemplate -TemplateName $script:sampleTemplate.name
            $resultAlias.name | Should -Be $script:sampleTemplate.name
        }
    }

    It "Filters workflow templates by Category (using -Category and -TemplateCategory alias)" {
        $category = $script:sampleTemplate.category ?? $script:sampleTemplate.categoryName
        if ($category) {
            $result = Get-JCWorkflowTemplate -Category $category
            $result | Should -Not -BeNullOrEmpty

            $resultAlias = Get-JCWorkflowTemplate -TemplateCategory $category
            $resultAlias | Should -Not -BeNullOrEmpty
        }
    }

    It "Accepts template object via pipeline" {
        if ($script:sampleTemplate.id) {
            $result = $script:sampleTemplate | Get-JCWorkflowTemplate
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Throws when workflow template ID or Name is invalid" {
        { Get-JCWorkflowTemplate -Id "invalid-template-id-99999" } | Should -Throw "*Failed to get workflow template*"
        { Get-JCWorkflowTemplate -Name "NonExistentWorkflowTemplate_99999" } | Should -Throw "*was not found*"
    }
}