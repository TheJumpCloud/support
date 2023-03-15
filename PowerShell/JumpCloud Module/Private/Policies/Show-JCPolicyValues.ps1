function Show-JCPolicyValues {
    [CmdletBinding()]
    param (
        # Policy Object
        [Parameter(Mandatory = $true)]
        [System.Object]
        $policyObject
    )
    begin {
        # Array to store custom policy objects for display
        $policyArray = New-Object System.Collections.ArrayList
    }
    process {
        # counter for increments
        $counter = 0

        # Create custom object containing counter/label/value
        $policyObject | ForEach-Object {
            if ($_ -contains "label") {
                $policyValue = [PSCustomObject]@{
                    fieldIndex = $counter
                    field      = $_.label
                    value      = $_.value
                }
            } else {
                $policyValue = [PSCustomObject]@{
                    fieldIndex = $counter
                    field      = $_.configFieldName
                    value      = $_.value
                }
            }

            # Add object to object array and increment counter
            $policyArray.Add($policyValue) | Out-Null
            $counter++
        }

        # Display policy object array
        $policyArray | Format-Table | Out-Host

        # Prompt for user input
        do {
            $fieldSelection = (Read-Host "Please enter field index you wish to modify (0 - $($policyArray.Count - 1))")
        } While ($policyArray.fieldIndex -notcontains $fieldSelection)
    }
    end {
        # Returns field index
        return $fieldSelection
    }
}