Describe -Tag:('ModuleValidationTest') 'Module Manifest Tests' {
    It ('Passes Test-ModuleManifest') {
        Test-ModuleManifest -Path:(join-path -Path $PesterParams_ModuleManifestPath -ChildPath $PesterParams_ModuleManifestName) | Should -Not -BeNullOrEmpty
        $? | Should -Be true
    }
}