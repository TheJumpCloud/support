Function Get-PipelineDetails {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $line

    )
    Begin {
        $funcArray = @()
        $pipelines = $line.split('|')
        $pipelineCount = $pipelines.count

    }
    Process {
        foreach ($pipe in $pipelines) {
            $pipe = $pipe.TrimStart(" ")
            # Write-Host $pipe
            $fixed = $pipe -match '^([\S]+)'
            if ($matches) {
                # Write-host $matches[0]
                $funcArray += [PSCustomObject]@{
                    Function = $matches[0];
                    Position = $pipelines.IndexOf($pipe)
                }
            }
        }
    }
    End {
        return $pipelineCount, $funcArray
    }
}
