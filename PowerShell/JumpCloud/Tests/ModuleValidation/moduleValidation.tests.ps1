Describe -Tag:('ModuleValidation') 'Module Manifest Tests' {
    It ('Passes Test-ModuleManifest') {
        Test-ModuleManifest -Path:("$PesterParams_ModuleManifestPath/$PesterParams_ModuleManifestName") | Should -Not -BeNullOrEmpty
        $? | Should -Be true
    }
}