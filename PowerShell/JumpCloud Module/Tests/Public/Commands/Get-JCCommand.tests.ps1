Describe -Tag:('JCCommand') 'Get-JCCommand 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Gets all JumpCloud commands" {
        $AllCommands = Get-JCCommand
        $AllCommands._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud command  declaring -CommandID" {
        $SingleCommand = Get-JCCommand | Select-Object -Last 1
        $SingleResult = Get-JCCommand -CommandID $SingleCommand._id
        $SingleResult._id.Count | Should -Be 1

    }

    It "Gets a single JumpCloud command  without declaring -CommandID" {
        $SingleCommand = Get-JCCommand | Select-Object -Last 1
        $SingleResult = Get-JCCommand $SingleCommand._id
        $SingleResult._id.Count | Should -Be 1
    }

    It "Gets a single JumpCloud command using -ByID passed through the pipeline" {
        $SingleResult = Get-JCCommand | Select-Object -Last 1 | Get-JCCommand -ByID
        $SingleResult._id.Count | Should -Be 1
        # Tests param from /commands/id is returned here
        $SingleResult.timeToLiveSeconds | Should -Not -BeNullOrEmpty
    }

    It "Gets all JumpCloud command passed through the pipeline declaring -ByID" {
        $MultiResult = Get-JCCommand | Get-JCCommand -ByID
        $MultiResult._id.Count | Should -BeGreaterThan 1
    }

    It "Gets all JumpCloud command triggers" {
        $Triggers = Get-JCCommand | Where-Object trigger -ne ''
        $Triggers._id.Count | Should -BeGreaterThan 1
    }
}

Describe -Tag('JCCommand') 'Get-JCCommand Search' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        # Get Command3 because it does not contain a wildcard
        $PesterParams_Command3 = Get-JCCommand -CommandID:($PesterParams_Command3.Id)
    }
    It "Searches a JumpCloud command by name" {
        $Command = Get-JCCommand -name $PesterParams_Command3.name
        $Command.name | Should -Be $PesterParams_Command3.name
    }
    It "Searches a JumpCloud command by command" {
        $Command = Get-JCCommand -command $PesterParams_Command3.command
        $Command.command | Should -Be $PesterParams_Command3.command
    }
    It "Searches a JumpCloud command by commandType" {
        $Command = Get-JCCommand -commandType $PesterParams_Command3.commandType
        $Command.commandType | Should -Bein $PesterParams_Command3.commandType
    }
    It "Searches a JumpCloud command by launchType" {
        $Command = Get-JCCommand -launchType $PesterParams_Command3.launchType
        $Command.launchType | Should -Bein $PesterParams_Command3.launchType
    }
    It "Searches a JumpCloud command by trigger" {
        $Command = Get-JCCommand -trigger $PesterParams_Command3.trigger
        $Command.trigger | Should -Be $PesterParams_Command3.trigger
    }
    It "Searches a JumpCloud command by scheduleRepeatType" {
        $Command = Get-JCCommand -scheduleRepeatType $PesterParams_Command3.scheduleRepeatType
        $Command.scheduleRepeatType | Should -Bein $PesterParams_Command3.scheduleRepeatType
    }
}


Describe -Tag:('JCCommand') "Case Insensitivity Tests" {
    It "Searches parameters dynamically with mixed, lower and upper capitalaztion" {
        $commandParameters = (GCM Get-JCCommand).Parameters
        $gmr = Get-JCCommand -ByID $PesterParams_Command3._id | GM
        # Get parameters that are not ID, ORGID, bool, and int
        $parameters = $gmr | Where-Object { ($_.Definition -notmatch "organization") -And ($_.Name -In $commandParameters.Keys) -and ($_.Definition -notmatch "bool") -and ($_.Definition -notmatch "int") }

        foreach ($param in $parameters.Name) {
            # Write-host "Testing $param"
            $string = $PesterParams_Command3.$param.toLower()
            $stringList = @()
            $stringFinal = ""
            # for i in string length, get the letters and capatlize ever other letter
            for ($i = 0; $i -lt $string.length; $i++) {
                <# Action that will repeat until the condition is met #>
                $letter = $string.Substring($i, 1)
                if ($i % 2 -eq 1) {
                    $letter = $letter.TOUpper()
                }
                $stringList += ($letter)
            }
            foreach ($letter in $stringList) {
                <# $letter is the current item #>
                $stringFinal += $letter
            }
            $mixedCaseSearch = "Get-JCCommand -$($param) `"$stringFinal`""
            $lowerCaseSearch = "Get-JCCommand -$($param) `"$($stringFinal.toLower())`""
            $upperCaseSearch = "Get-JCCommand -$($param) `"$($stringFinal.TOUpper())`""
            # Write-Host $mixedCaseSearch
            # Write-Host $lowerCaseSearch
            # Write-Host $upperCaseSearch
            $commandSearchMixed = Invoke-Expression -Command:($mixedCaseSearch)
            $commandSearchLower = Invoke-Expression -Command:($lowerCaseSearch)
            $commandSearchUpper = Invoke-Expression -Command:($upperCaseSearch)
            # DefaultSearch is the expression without text formatting
            $defaultSearch = "Get-JCCommand -$($param) `"$($PesterParams_Command3.$param)`""
            $userSearchDefault = Invoke-Expression -Command:($defaultSearch)
            # Ids returned here should return the same restuls
            $commandSearchUpper._id | Should -Be $userSearchDefault._id
            $commandSearchLower._id | Should -Be $userSearchDefault._id
            $commandSearchMixed._id | Should -Be $userSearchDefault._id

        }
    }
    It "Searches parameters after setting values to include special characters like \|{[()^$.#" {
        $commandParameters = (GCM Get-JCCommand).Parameters
        $gmr = Get-JCCommand -ByID $PesterParams_Command3._id | GM
        # Get parameters that are not ID, ORGID, bool, and int
        $parameters = $gmr | Where-Object { ($_.Definition -notmatch "organization") -And ($_.Name -In $commandParameters.Keys) -and ($_.Definition -notmatch "bool") -and ($_.Definition -notmatch "int") }

        foreach ($param in $parameters.Name) {
            # Test special characters with -name and -command
            if (($param -eq "name") -or ($param -eq "command")) {
                $randomParamInput = "$(New-RandomString -NumberOfChars 8)\+?|{[()^$.#"
                $newCommand = New-JCCommand -name $randomParamInput -command $randomParamInput -commandType linux
                $searchCommand = "Get-JCCommand -$($param) `"$randomParamInput`""
                $InvokeCommand = Invoke-Expression -Command:($searchCommand)
                # search should return the string
                $randomParamInput | Should -Be $InvokeCommand.$param

                # Set to original
                Remove-JCCommand -CommandID $newCommand.id
            }

        }
    }
}