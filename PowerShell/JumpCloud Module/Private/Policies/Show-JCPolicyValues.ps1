function Show-JCPolicyValues {
    [CmdletBinding()]
    param (
        # Policy Object
        [Parameter(Mandatory = $true)]
        [System.Object]
        $policyObject,
        # optional values object
        [Parameter(Mandatory = $false)]
        [System.Object]
        $policyValues,
        # only output table
        [Parameter(Mandatory = $false)]
        [boolean]
        $ShowTable = $false,
        # hide all option
        [Parameter(Mandatory = $false)]
        [boolean]
        $HideAll = $false
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
            $policyValue = [PSCustomObject]@{
                fieldIndex  = $counter
                field       = $_.label
                value       = If ($policyValues) {
                    $cid = $_.configFieldID; ($policyValues | Where-Object { $_.configFieldID -eq $cid }).value
                } else {
                    $_.value
                }
                helpMessage = $_.help
            }

            # Add object to object array and increment counter
            $policyArray.Add($policyValue) | Out-Null
            $counter++
        }

        # If the policy is a registry policy, do not display value table
        if ($policyObject.configFieldName -notcontains "customRegTable") {
            # Display policy object array
            $policyArray | Format-Table | Out-Host
        }

        if ($ShowTable -eq $false) {
            # if policy w/o payload return, else continue
            if ($policyArray.count -eq 0) {
                return
            } else {
                $fieldCount = $policyArray.Count - 1
            }

            # Check to see if there is only one editable field
            if ($fieldCount -eq 0) {
                $fieldSelection = 'A'
                return
            }

            # Prompt for user input
            $Title = "JumpCloud Policy Field Editor"
            $Message = "How would you like to edit the policy values?"
            $All = New-Object System.Management.Automation.Host.ChoiceDescription "&All Fields", "All"
            $Individual = New-Object System.Management.Automation.Host.ChoiceDescription "&Individual Field", "Individual"
            $Save = New-Object System.Management.Automation.Host.ChoiceDescription "&Save Edits", "Save"

            if ($HideAll -eq $true) {
                $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Individual, $Save)
            } else {
                $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Individual, $All, $Save)
            }

            $choice = $host.ui.PromptForChoice($title, $message, $options, 0)

            if ($HideAll -eq $true) {
                switch ($choice) {
                    0 {
                        do {
                            $fieldSelection = (Read-Host "Please enter field index you wish to modify (0 - $fieldCount)")
                        } until ($policyArray.fieldIndex -contains $fieldSelection)
                    }
                    1 {
                        $fieldSelection = 'C'
                    }
                }
            } else {
                switch ($choice) {
                    0 {
                        do {
                            $fieldSelection = (Read-Host "Please enter field index you wish to modify (0 - $fieldCount)")
                        } until ($policyArray.fieldIndex -contains $fieldSelection)
                    }
                    1 {
                        $fieldSelection = 'A'
                    }
                    2 {
                        $fieldSelection = 'C'
                    }
                }
            }
        }
    }
    end {
        if ($ShowTable -eq $false) {
            # Returns field index
            return [PSCustomObject]@{
                fieldSelection = $fieldSelection
                fieldCount     = $fieldCount
            }
        }
    }
}