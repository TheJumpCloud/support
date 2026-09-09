function New-JCWorkflow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'The name of the workflow.')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $false, HelpMessage = 'The description of the workflow.')]
        [System.String]
        $Description
    )

    process {
        try {
            # Construct request body payload
            $body = @{
                name = $Name
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $body.description = $Description
            }

            # Send POST request to JumpCloud API
            $result = Invoke-JCApi -Method POST -Url '/api/v2/workflows' -Body ($body | ConvertTo-Json -Compress)

            return $result
        }
        catch {
            Write-Error $_
        }
    }
}