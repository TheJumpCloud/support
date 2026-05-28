Function Update-JCSystemFromCSV {
    [CmdletBinding(DefaultParameterSetName = 'GUI')]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'GUI', HelpMessage = 'The full path to the Systems CSV file.')]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'force', HelpMessage = 'The full path to the Systems CSV file.')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [ValidatePattern( '\.csv$' )]
        [string]$CSVFilePath,

        [Parameter(ParameterSetName = 'force', HelpMessage = 'Suppresses confirmation prompts.')]
        [Switch]$force
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'GUI') {
            if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
                Connect-JCOnline
            }
        }
        $UpdateSystems = Import-Csv -Path $CSVFilePath
        $ResultsArrayList = New-Object System.Collections.ArrayList
    }

    process {
        foreach ($SystemUpdate in $UpdateSystems) {
            if ([string]::IsNullOrEmpty($SystemUpdate.SystemID)) {
                Write-Warning "Row missing SystemID. Skipping."
                continue
            }

            $UpdateParams = @{
                SystemID = $SystemUpdate.SystemID
            }

            if ($SystemUpdate.description) {
                $UpdateParams.Add('description', $SystemUpdate.description)
            }

            $AttrCount = $SystemUpdate.psobject.properties | Where-Object { $_.Name -match "Attribute\d+_name" -and $_.Value } | Measure-Object | Select-Object -ExpandProperty Count

            if ($AttrCount -gt 0) {
                $UpdateParams.Add('NumberOfCustomAttributes', $AttrCount)
                for ($i = 1; $i -le $AttrCount; $i++) {
                    if ($SystemUpdate."Attribute$($i)_name") {
                        $UpdateParams.Add("Attribute$($i)_name", $SystemUpdate."Attribute$($i)_name")
                        $UpdateParams.Add("Attribute$($i)_value", $SystemUpdate."Attribute$($i)_value")
                    }
                }
            }

            try {
                $Result = Set-JCSystem @UpdateParams
                $ResultsArrayList.Add([PSCustomObject]@{
                    SystemID = $SystemUpdate.SystemID
                    Status   = 'System Updated Successfully'
                }) | Out-Null
            } catch {
                $ResultsArrayList.Add([PSCustomObject]@{
                    SystemID = $SystemUpdate.SystemID
                    Status   = $_.Exception.Message
                }) | Out-Null
            }
        }
    }

    end {
        return $ResultsArrayList
    }
}