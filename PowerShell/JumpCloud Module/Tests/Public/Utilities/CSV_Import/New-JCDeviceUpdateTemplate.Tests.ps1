Describe -Tag:('JCDeviceFromCSV') 'New-JCDeviceUpdateTemplate' {
    BeforeAll { }

    It "Forcefully creates a CSV Import Template" {
        try {
            New-JCDeviceUpdateTemplate -Force
        } catch {
            # Se a sua função estourar um erro interno, este assert vai capturar e mostrar no GitHub
            $_ | Should -Be $null
        }

        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }

        $items | Should -Not -BeNullOrEmpty
        if ($items) {
            $items | ForEach-Object { Remove-Item -Path $_.FullName -Force }
        }
    }

    It "Creates a CSV Import Template with custom attributes" {
        try {
            New-JCDeviceUpdateTemplate -Force
        } catch {
            $_ | Should -Be $null
        }

        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }

        # Valida amigavelmente se o arquivo existe antes de tentar ler o conteúdo
        $items | Should -Not -BeNullOrEmpty

        if ($items) {
            $firstLine = Get-Content -Path $items[0].FullName -First 1
            $firstLine | Should -Match "NumberOfCustomAttributes"
            $items | ForEach-Object { Remove-Item -Path $_.FullName -Force }
        }
    }
}