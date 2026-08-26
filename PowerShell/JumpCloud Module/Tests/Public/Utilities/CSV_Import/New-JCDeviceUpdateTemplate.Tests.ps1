Describe -Tag:('JCDeviceFromCSV') 'New-JCDeviceUpdateTemplate' {
    BeforeAll { }

    It "Forcefully creates a CSV Import Template" {
        New-JCDeviceUpdateTemplate -Force

        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }
        $items | Should -Exist
        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }

    It "Creates a CSV Import Template with custom attributes" {
        # Passamos o parâmetro da sua feature para o template gerar as novas colunas
        New-JCDeviceUpdateTemplate -NumberOfCustomAttributes 1 -Force

        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }
        $items | Should -Exist

        # Valida se a coluna customizada foi incluída no cabeçalho do arquivo gerado
        $firstLine = Get-Content -Path $items[0].FullName -First 1
        $firstLine | Should -Match "Attribute1_name"

        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }
}