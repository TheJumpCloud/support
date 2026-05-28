Function New-JCImportSystemTemplate {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, HelpMessage = 'Path to save the generated CSV template.')]
        [string]$Path = "$Home/Desktop",

        [Parameter(Mandatory = $false, HelpMessage = 'Number of custom attributes columns to seed in the template.')]
        [int]$NumberOfCustomAttributes = 0
    )

    process {
        $headers = [System.Collections.Generic.List[string]]::new()
        $headers.Add('SystemID')
        $headers.Add('description')

        if ($NumberOfCustomAttributes -gt 0) {
            for ($i = 1; $i -le $NumberOfCustomAttributes; $i++) {
                $headers.Add("Attribute$($i)_name")
                $headers.Add("Attribute$($i)_value")
            }
        }

        $csvContent = $headers -join ','
        $finalPath = Join-Path $Path "JCImportSystemTemplate.csv"

        $csvContent | Out-File -FilePath $finalPath -Encoding utf8 -Force
        Write-Verbose "Systems Import Template successfully created at $finalPath"
    }
}