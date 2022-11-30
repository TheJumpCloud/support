Function Get-PipelineDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Pipeline String to test ($myInvocation.line)')]
        [System.String]
        $line
    )
    Begin {
        $funcArray = @()
        # split line by | opperator
        $pipelines = $line.split('|')
        $pipelineCount = $pipelines.count
    }
    Process {
        foreach ($pipe in $pipelines) {
            # trim whitespace
            $pipe = $pipe.TrimStart(" ")
            $functionName = $pipe -match '^([\S]+)'
            if ($matches) {
                # add functionName $matches[0] and position
                $funcArray += [PSCustomObject]@{
                    Function = $matches[0];
                    Position = $pipelines.IndexOf($pipe)
                }
            }
        }
    }
    End {
        # Return num of piped functions, and the array list of functions & positions
        return $pipelineCount, $funcArray
    }
}
