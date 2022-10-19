function New-JCSmartGroupPrompt {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Initialize', Position = 0, HelpMessage = 'The introductory prompt for the initial menu')]
        [switch]$Initialize,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'UserGroup', Position = 1, HelpMessage = 'The prompts for the user to create a conditional statement for a Smart UserGroup')]
        [switch]$UserGroup,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SystemGroup', Position = 2, HelpMessage = 'The prompts for the user to create a conditional statement for a Smart SystemGroup')]
        [switch]$SystemGroup
    )
    process {
        $filterObject = [PSCustomObject]@{
            And = [PSCustomObject]@{}
            Or  = [PSCustomObject]@{}
        }
        switch ($PSCmdlet.ParameterSetName) {
            Initialize {
                $OpeningTitle = "Welcome to the JumpCloud SmartGroup Configurator!"
                $OpeningMessage = "Please select which type of group you would like to create:"
                $UgChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&UserGroup", "UserGroup"
                $SgChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&SystemGroup", "SystemGroup"
                $quitChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", "Quit"
                $options = [System.Management.Automation.Host.ChoiceDescription[]]($UgChoice, $SgChoice, $quitChoice)
                $choice = $host.ui.PromptForChoice($OpeningTitle, $OpeningMessage, $options, 2)

                switch ($choice) {
                    0 {
                        #New-JCSmartGroupPrompt -UserGroup
                        return "UserGroup"
                    }
                    1 {
                        #New-JCSmartGroupPrompt -SystemGroup
                        return "SystemGroup"
                    }
                    2 {
                        exit
                    }
                }
            }

            UserGroup {
                # Gather user attributes that can be filtered/searched by
                $ParameterList = (Get-Command -Name Get-JCUser).Parameters
                $attributes = $ParameterList['returnProperties'].Attributes.ValidValues | Sort-Object
                Do {
                    do {
                        # Get attribute Type (AND? OR)
                        $aTypes = @('AND', 'OR')
                        Write-Host "======================================" -ForeGroundColor Green
                        Write-Host "Please select an attribute type: " -ForeGroundColor Green
                        Write-Host "======================================" -ForeGroundColor Green
                        for ($i = 0; $i -lt $aTypes.Length; $i++) {
                            # List available attributes in host
                            Write-Host "$($i+1): $($aTypes[$i])"
                        }
                        do {
                            $attrChoice = Read-Host -Prompt "Enter the number corresponding with the operator"
                        } until ($aTypes[$attrChoice - 1])
                        $desiredAttrChoice = $aTypes[$attrChoice - 1]

                        # Get desired attribute
                        Write-Host "======================================" -ForeGroundColor Green
                        Write-Host "Please select a user attribute: " -ForeGroundColor Green
                        Write-Host "======================================" -ForeGroundColor Green
                        for ($i = 0; $i -lt $attributes.Length; $i++) {
                            # List available attributes in host
                            Write-Host "$($i+1): $($attributes[$i])"
                        }
                        do {
                            $AttributeChoice = Read-Host -Prompt "Enter the number corresponding with the attribute"
                        } until ($attributes[$AttributeChoice - 1])

                        # Store attribute
                        $desiredAttribute = $attributes[$AttributeChoice - 1]

                        # Get desired conditional operator
                        $operators = @('eq', 'ne', 'gt ', 'gte', 'lt', 'lte')
                        Write-Host "======================================" -ForeGroundColor Green
                        Write-Host "Please select your conditional operator:" -ForeGroundColor Green
                        Write-Host "======================================" -ForeGroundColor Green
                        for ($i = 0; $i -lt $operators.Length; $i++) {
                            # List available attributes in host
                            Write-Host "$($i+1): $($operators[$i])"
                        }
                        do {
                            $OperatorChoice = Read-Host -Prompt "Enter the number corresponding with the operator"
                        } until ($operators[$OperatorChoice - 1])

                        # Store conditional operator
                        $desiredOperator = $operators[$OperatorChoice - 1]

                        # Get desired conditional value
                        Write-Host "======================================" -ForeGroundColor Green
                        Write-Host "Please enter your conditional value:" -ForeGroundColor Green
                        Write-Host "Ex: department `$eq Accounting" -ForeGroundColor Green
                        Write-Host "======================================" -ForeGroundColor Green

                        $desiredValue = Read-Host -Prompt "Finish the statement: $($desiredAttribute) $($desiredOperator)"

                        $ValidateTitle = "Is the following statement correct?"
                        $ValidateMessage = "$($desiredAttribute) $($desiredOperator) $($desiredValue)"
                        $YesChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
                        $NoChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
                        $quitChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", "Quit"
                        $options = [System.Management.Automation.Host.ChoiceDescription[]]($YesChoice, $NoChoice, $quitChoice)
                        $finalChoice = $host.ui.PromptForChoice($ValidateTitle, $ValidateMessage, $options, 0)
                    } until (($finalChoice -eq 0) -OR ($finalChoice -eq 2))

                    if ($finalCHoice -eq 2) {
                        exit
                    } else {
                        Add-Member -InputObject $filterObject.$desiredAttrChoice -NotePropertyName $desiredAttribute -NotePropertyValue "$($desiredOperator):$($desiredValue)"
                        # return "$($desiredAttribute):$($desiredOperator):$($desiredValue)"
                    }

                    $ValidateTitle = "Would you like to add another attribute to the Smart Group"
                    $ValidateMessage = "Current Attributes :`n $filterObject"
                    $YesChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
                    $NoChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
                    $quitChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", "Quit"
                    $options = [System.Management.Automation.Host.ChoiceDescription[]]($NoChoice, $YesChoice, $quitChoice)
                    $exitChoice = $host.ui.PromptForChoice($ValidateTitle, $ValidateMessage, $options, 0)
                } until (($exitChoice -eq 0) -OR ($exitChoice -eq 2))
            }

            SystemGroup {

                # Gather system attributes that can be filtered/searched by
                $ParameterList = (Get-Command -Name Get-JCSystem).Parameters
                $attributes = $ParameterList['returnProperties'].Attributes.ValidValues | Sort-Object

                Do {
                    do {
                        # Get attribute Type (AND? OR)
                        $aTypes = @('AND', 'OR')
                        Write-Host "======================================" -ForeGroundColor Green
                        Write-Host "Please select an attribute type: " -ForeGroundColor Green
                        Write-Host "======================================" -ForeGroundColor Green
                        for ($i = 0; $i -lt $aTypes.Length; $i++) {
                            # List available attributes in host
                            Write-Host "$($i+1): $($aTypes[$i])"
                        }
                        do {
                            $attrChoice = Read-Host -Prompt "Enter the number corresponding with the operator"
                        } until ($aTypes[$attrChoice - 1])
                        $desiredAttrChoice = $aTypes[$attrChoice - 1]
                        # Get desired attribute
                        Write-Host "======================================" -ForeGroundColor Green
                        Write-Host "Please select a system attribute: " -ForeGroundColor Green
                        Write-Host "======================================" -ForeGroundColor Green
                        for ($i = 0; $i -lt $attributes.Length; $i++) {
                            # List available attributes in host
                            Write-Host "$($i+1): $($attributes[$i])"
                        }
                        do {
                            $AttributeChoice = Read-Host -Prompt "Enter the number corresponding with the attribute"
                        } until ($attributes[$AttributeChoice - 1])

                        # Store attribute
                        $desiredAttribute = $attributes[$AttributeChoice - 1]

                        # Get desired conditional operator
                        $operators = @('eq', 'ne', 'gt ', 'gte', 'lt', 'lte')
                        Write-Host "======================================" -ForeGroundColor Green
                        Write-Host "Please select your conditional operator:" -ForeGroundColor Green
                        Write-Host "======================================" -ForeGroundColor Green
                        for ($i = 0; $i -lt $operators.Length; $i++) {
                            # List available attributes in host
                            Write-Host "$($i+1): $($operators[$i])"
                        }
                        do {
                            $OperatorChoice = Read-Host -Prompt "Enter the number corresponding with the operator"
                        } until ($operators[$OperatorChoice - 1])

                        # Store conditional operator
                        $desiredOperator = $operators[$OperatorChoice - 1]

                        # Get desired conditional value
                        Write-Host "======================================" -ForeGroundColor Green
                        Write-Host "Please enter your conditional value:" -ForeGroundColor Green
                        Write-Host "Ex: os `$eq macOS" -ForeGroundColor Green
                        Write-Host "======================================" -ForeGroundColor Green

                        $desiredValue = Read-Host -Prompt "Finish the statement: $($desiredAttribute) $($desiredOperator)"

                        $ValidateTitle = "Is the following statement correct?"
                        $ValidateMessage = "$($desiredAttribute) $($desiredOperator) $($desiredValue)"
                        $YesChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
                        $NoChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
                        $quitChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", "Quit"
                        $options = [System.Management.Automation.Host.ChoiceDescription[]]($YesChoice, $NoChoice, $quitChoice)
                        $finalChoice = $host.ui.PromptForChoice($ValidateTitle, $ValidateMessage, $options, 0)
                    } until (($finalChoice -eq 0) -OR ($finalChoice -eq 2))
                    if ($finalCHoice -eq 2) {
                        exit
                    } else {
                        Add-Member -InputObject $filterObject.$desiredAttrChoice -NotePropertyName $desiredAttribute -NotePropertyValue "$($desiredOperator):$($desiredValue)"
                        # return "$($desiredAttribute):$($desiredOperator):$($desiredValue)"
                    }
                    $ValidateTitle = "Would you like to add another attribute to the Smart Group"
                    $ValidateMessage = "Current Attributes :`n $filterObject"
                    $YesChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
                    $NoChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
                    $quitChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", "Quit"
                    $options = [System.Management.Automation.Host.ChoiceDescription[]]($NoChoice, $YesChoice, $quitChoice)
                    $exitChoice = $host.ui.PromptForChoice($ValidateTitle, $ValidateMessage, $options, 0)
                } until (($exitChoice -eq 0) -OR ($exitChoice -eq 2))
            }
        }
    }
    end {
        return $filterObject
    }
}