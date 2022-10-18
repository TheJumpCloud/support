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
                do {
                    # Get desired attribute
                    Write-Host "======================================" -ForeGroundColor Green
                    Write-Host "Please select a user attribute: " -ForeGroundColor Green
                    Write-Host "======================================" -ForeGroundColor Green
                    for ($i = 0; $i -lt $attributes.Length; $i++) {
                        # List available attributes in host
                        Write-Host "$($i): $($attributes[$i])"
                    }
                    do {
                        $AttributeChoice = Read-Host -Prompt "Enter the number corresponding with the attribute"
                    } until ($attributes[$AttributeChoice])

                    # Store attribute
                    $desiredAttribute = $attributes[$AttributeChoice]

                    # Get desired conditional statement
                    Write-Host "======================================" -ForeGroundColor Green
                    Write-Host "Please enter your conditional statement:" -ForeGroundColor Green
                    Write-Host "Example: -eq 'Sales'" -ForeGroundColor Green
                    Write-Host "======================================" -ForeGroundColor Green

                    $statement = Read-Host -Prompt "Finish the statement: $($desiredAttribute)"

                    $ValidateTitle = "Is the following statement correct?"
                    $ValidateMessage = "$($desiredAttribute) $($statement)"
                    $YesChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
                    $NoChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
                    $options = [System.Management.Automation.Host.ChoiceDescription[]]($YesChoice, $NoChoice)
                    $finalChoice = $host.ui.PromptForChoice($ValidateTitle, $ValidateMessage, $options, 0)
                } until ($finalChoice -eq 0)

                return $ValidateMessage
            }

            SystemGroup {
                # Gather system attributes that can be filtered/searched by
                $ParameterList = (Get-Command -Name Get-JCSystem).Parameters
                $attributes = $ParameterList['returnProperties'].Attributes.ValidValues | Sort-Object

                do {
                    # Get desired attribute
                    Write-Host "======================================" -ForeGroundColor Green
                    Write-Host "Please select a system attribute: " -ForeGroundColor Green
                    Write-Host "======================================" -ForeGroundColor Green
                    for ($i = 0; $i -lt $attributes.Length; $i++) {
                        # List available attributes in host
                        Write-Host "$($i): $($attributes[$i])"
                    }
                    do {
                        $AttributeChoice = Read-Host -Prompt "Enter the number corresponding with the attribute"
                    } until ($attributes[$AttributeChoice])

                    # Store attribute
                    $desiredAttribute = $attributes[$AttributeChoice]

                    # Get desired conditional statement
                    Write-Host "======================================" -ForeGroundColor Green
                    Write-Host "Please enter your conditional statement:" -ForeGroundColor Green
                    Write-Host "Example: -eq 'macOS'" -ForeGroundColor Green
                    Write-Host "======================================" -ForeGroundColor Green

                    $statement = Read-Host -Prompt "Finish the statement: $($desiredAttribute)"

                    $ValidateTitle = "Is the following statement correct?"
                    $ValidateMessage = "$($desiredAttribute) $($statement)"
                    $YesChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
                    $NoChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
                    $options = [System.Management.Automation.Host.ChoiceDescription[]]($YesChoice, $NoChoice)
                    $finalChoice = $host.ui.PromptForChoice($ValidateTitle, $ValidateMessage, $options, 0)
                } until ($finalChoice -eq 0)

                return $ValidateMessage
            }
        }
    }
}