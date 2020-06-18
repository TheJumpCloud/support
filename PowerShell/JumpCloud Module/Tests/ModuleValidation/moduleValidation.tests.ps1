Describe -Tag:('ModuleValidation') 'Module Manifest Tests' {
    It ('Passes Test-ModuleManifest') {
        Test-ModuleManifest -Path $PesterParams_ModuleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be true
    }
}