Describe -Tag:('JCSystemKB') 'Get-JCSystemKB' {
    BeforeAll {
        $systems = Get-JCSystem
        $windows = $systems | Where-Object { $_.osFamily -match "windows" }
    }
    It "Gets all available KBs on all systems" {
        { Get-JCSystemKB } | Should -Not -Throw
        $KB = Get-JCSystemKB
        $KB | Should -Not -BeNullOrEmpty
    }
    It "Gets all KBs from one system" {
        $windowsMachine = $windows | Select-Object -First 1
        { Get-JCSystemKB -SystemID $windowsMachine._id } | Should -Not -Throw
        Get-JCSystemKB -SystemID $windowsMachine._id | Should -Not -BeNullOrEmpty
    }
    It "Gets one KB from all systems" {
        $SingleKB = Get-JCSystemKB | Select-Object hotfix_id -First 1
        { Get-JCSystemKB -KB $SingleKB.hotfix_id } | Should -Not -Throw
        Get-JCSystemKB -KB $SingleKB.hotfix_id | Should -Not -BeNullOrEmpty
    }
    It "Gets one KB from one system" {
        $SingleKB = Get-JCSystemKB | Select-Object -First 1
        { Get-JCSystemKB -SystemID $SingleKB.system_id -KB $SingleKB.hotfix_id } | Should -Not -Throw
        Get-JCSystemKB -SystemID $SingleKB.system_id -KB $SingleKB.hotfix_id | Should -Not -BeNullOrEmpty
    }
    It "Accepts pipeline input from Get-JCSystem" {
        $windowsMachine = $windows | Select-Object -First 1
        { $windowsMachine | Get-JCSystemKB } | Should -Not -Throw
    }
}