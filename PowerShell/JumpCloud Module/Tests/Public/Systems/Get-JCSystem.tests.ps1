Describe -Tag:('JCSystem') 'Get-JCSystem 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Gets all JumpCloud systems" {
        $Systems = Get-JCSystem
        $Systems._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud system" {
        $SingleSystem = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $SingleSystem.id.Count | Should -Be 1
    }

}


Describe -Tag:('JCSystem') "Get-JCSystem 1.4" {

    It "Gets a JumpCloud system by system ID" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -SystemID $SystemInfo._id
        $PesterSystem._id | Should -Be $PesterParams_SystemLinux._id
    }

    It "Returns all JumpCloud systems" {

        $Systems = Get-JCSystem
        $Systems.count | Should -BeGreaterThan 1

    }

    It "Searches for JumpCloud system by hostname wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -hostname "$($SystemInfo.hostname.Substring(0,$SystemInfo.hostname.Length-1))*"
        $PesterSystem.hostname.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by hostname wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -hostname "*$($SystemInfo.hostname.Substring(1))"
        $PesterSystem.hostname.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by hostname wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -hostname "*$($($SystemInfo.hostname.Substring(0,$SystemInfo.hostname.Length-1)).Substring(1))*"
        $PesterSystem.hostname.count | Should -BeGreaterThan 0
    }


    It "Searches for JumpCloud system by displayname wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -displayname "$($SystemInfo.displayname.Substring(0,$SystemInfo.displayname.Length-1))*"
        $PesterSystem.displayname.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by displayname wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -displayname "*$($SystemInfo.displayname.Substring(1))"
        $PesterSystem.displayname.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by displayname wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -displayname "*$($($SystemInfo.displayname.Substring(0,$SystemInfo.displayname.Length-1)).Substring(1))*"
        $PesterSystem.displayname.count | Should -BeGreaterThan 0
    }


    It "Searches for JumpCloud system by version" {


        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -version $SystemInfo.version
        $PesterSystem.version | Select-Object -Unique | Should -Be $($SystemInfo.version)
    }

    It "Searches for JumpCloud system by templateName wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -templateName "$($SystemInfo.templateName.Substring(0,$SystemInfo.templateName.Length-1))*"
        $PesterSystem.templateName.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by templateName wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -templateName "*$($SystemInfo.templateName.Substring(1))"
        $PesterSystem.templateName.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by templateName wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -templateName "*$($($SystemInfo.templateName.Substring(0,$SystemInfo.templateName.Length-1)).Substring(1))*"
        $PesterSystem.templateName.count | Should -BeGreaterThan 0
    }


    It "Searches for JumpCloud system by os wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -os "$($SystemInfo.os.Substring(0,$SystemInfo.os.Length-1))*"
        $PesterSystem.os.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by os wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -os "*$($SystemInfo.os.Substring(1))"
        $PesterSystem.os.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by os wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -os "*$($($SystemInfo.os.Substring(0,$SystemInfo.os.Length-1)).Substring(1))*"
        $PesterSystem.os.count | Should -BeGreaterThan 0
    }


    It "Searches for JumpCloud system by remoteIP wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -remoteIP "$($SystemInfo.remoteIP.Substring(0,$SystemInfo.remoteIP.Length-1))*"
        $PesterSystem.remoteIP.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by remoteIP wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -remoteIP "*$($SystemInfo.remoteIP.Substring(1))"
        $PesterSystem.remoteIP.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by remoteIP wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -remoteIP "*$($($SystemInfo.remoteIP.Substring(0,$SystemInfo.remoteIP.Length-1)).Substring(1))*"
        $PesterSystem.remoteIP.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by serialNumber wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -serialNumber "$($SystemInfo.serialNumber.Substring(0,$SystemInfo.serialNumber.Length-1))*"
        $PesterSystem.serialNumber.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by serialNumber wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -serialNumber "*$($SystemInfo.serialNumber.Substring(1))"
        $PesterSystem.serialNumber.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by serialNumber wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -serialNumber "*$($($SystemInfo.serialNumber.Substring(0,$SystemInfo.serialNumber.Length-1)).Substring(1))*"
        $PesterSystem.serialNumber.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by agentVersion wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -agentVersion "$($SystemInfo.agentVersion.Substring(0,$SystemInfo.agentVersion.Length-1))*"
        $PesterSystem.agentVersion.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by agentVersion wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -agentVersion "*$($SystemInfo.agentVersion.Substring(1))"
        $PesterSystem.agentVersion.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by agentVersion wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -agentVersion "*$($($SystemInfo.agentVersion.Substring(0,$SystemInfo.agentVersion.Length-1)).Substring(1))*"
        $PesterSystem.agentVersion.count | Should -BeGreaterThan 0
    }



    ## Cannot use wildcards on system timezone

    It "Searches for JumpCloud system by systemTimezone" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams_SystemLinux._id
        $PesterSystem = Get-JCSystem -systemTimezone $SystemInfo.systemTimezone
        $PesterSystem.systemTimezone | Select-Object -Unique | Should -Be $SystemInfo.systemTimezone
    }

    ## Boolean searches

    It "Searches for JumpCloud system by active" {

        $PesterSystem = Get-JCSystem -active $False
        $PesterSystem.active | Select-Object -Unique | Should -Be $False
    }

    It "Searches for JumpCloud system by allowMultiFactorAuthentication" {
        $PesterSystem = Get-JCSystem -allowMultiFactorAuthentication $False
        $PesterSystem.allowMultiFactorAuthentication | Select-Object -Unique | Should -Be $False
    }

    It "Searches for JumpCloud system by allowPublicKeyAuthentication" {
        $PesterSystem = Get-JCSystem -allowPublicKeyAuthentication $False
        $PesterSystem.allowPublicKeyAuthentication | Select-Object -Unique | Should -Be $False
    }

    It "Searches for JumpCloud system by allowSshPasswordAuthentication" {
        $PesterSystem = Get-JCSystem -allowSshPasswordAuthentication $False
        $PesterSystem.allowSshPasswordAuthentication | Select-Object -Unique | Should -Be $False
    }

    It "Searches for JumpCloud system by allowSshRootLogin" {
        $PesterSystem = Get-JCSystem -allowSshRootLogin $False
        $PesterSystem.allowSshRootLogin | Select-Object -Unique | Should -Be $False
    }

    It "Searches for JumpCloud system by modifySSHDConfig" {
        $PesterSystem = Get-JCSystem -modifySSHDConfig $False
        $PesterSystem.modifySSHDConfig | Select-Object -Unique | Should -Be $False
    }




    It "Searches for a JumpCloud system using hostname, filterDateProperty created and before" {

        $NewestSystemDate = Get-JCSystem -returnProperties created | Sort-Object created | Select-Object -Last 1 | Select-Object -ExpandProperty created
        $PesterSystem = Get-JCSystem -filterDateProperty created -dateFilter before -date $NewestSystemDate
        $PesterSystem._id.count | Should -BeGreaterThan 0

    }

    It "Searches for a JumpCloud system using hostname, filterDateProperty created and after" {
        $OldestSystemDate = Get-JCSystem -returnProperties created | Sort-Object created | Select-Object -First 1 | Select-Object -ExpandProperty created
        $PesterSystem = Get-JCSystem -filterDateProperty created -dateFilter after -date $OldestSystemDate
        $PesterSystem._id.count | Should -BeGreaterThan 0

    }

    It "Searches for a JumpCloud system and uses returns properties created" {
        $PesterSystem = Get-JCSystem  -returnProperties created
        $PesterSystem.created | Should -Not -Be $null
    }

    It "Searches for a JumpCloud system and uses return properties active" {
        $PesterSystem = Get-JCSystem -returnProperties active
        $PesterSystem.active | Should -Not -Be $null
    }

    It "Searches for a JumpCloud system using returns properties agentVersion" {
        $PesterSystem = Get-JCSystem -returnProperties agentVersion
        $PesterSystem.agentVersion | Should -Not -Be $null
    }

    It "Searches for a JumpCloud system using returns properties allowMultiFactorAuthentication" {
        $PesterSystem = Get-JCSystem -returnProperties allowMultiFactorAuthentication
        $PesterSystem.allowMultiFactorAuthentication | Should -Not -Be $null
    }

    It "Searches for a JumpCloud system using hostname and returns all properties " {
        $Sys = Get-JCSystem -systemID $PesterParams_SystemLinux._id

        $PesterSystem = Get-JCSystem -hostname $Sys.hostname -returnProperties 'created', 'active', 'agentVersion', 'allowMultiFactorAuthentication', 'allowPublicKeyAuthentication', 'allowSshPasswordAuthentication', 'allowSshRootLogin', 'arch', 'created', 'displayName', 'hostname', 'lastContact', 'modifySSHDConfig', 'organization', 'os', 'remoteIP', 'serialNumber', 'systemTimezone', 'templateName', 'version'
        $PesterSystem.created | Should -Not -Be $null
        $PesterSystem.active | Should -Not -Be $null
        $PesterSystem.agentVersion | Should -Not -Be $null
        $PesterSystem.allowMultiFactorAuthentication | Should -Not -Be $null
        $PesterSystem.allowPublicKeyAuthentication | Should -Not -Be $null
        $PesterSystem.allowSshPasswordAuthentication | Should -Not -Be $null
        $PesterSystem.allowSshRootLogin | Should -Not -Be $null
        $PesterSystem.arch | Should -Not -Be $null
        $PesterSystem.created | Should -Not -Be $null
        $PesterSystem.displayName | Should -Not -Be $null
        $PesterSystem.hostname | Should -Not -Be $null
        $PesterSystem.lastContact | Should -Not -Be $null
        $PesterSystem.modifySSHDConfig | Should -Not -Be $null
        $PesterSystem.organization | Should -Not -Be $null
        $PesterSystem.os | Should -Not -Be $null
        $PesterSystem.remoteIP | Should -Not -Be $null
        $PesterSystem.serialNumber | Should -Not -Be $null
        $PesterSystem.systemTimezone | Should -Not -Be $null
        $PesterSystem.templateName | Should -Not -Be $null
        $PesterSystem.version | Should -Not -Be $null
    }

}

Describe -Tag:('JCSystem') "Get-JCSystem 1.15.2" {
    It "Searches for a JumpCloud system using filterDateProperty lastContact and after" {
        $NewestSystemlastContact = ([DateTime]::Parse((Get-JCSystem -active $false -returnProperties lastContact | Where-Object lastContact -ne $null | Select-Object -Last 1 -ExpandProperty lastContact))).ToUniversalTime()
        $NewestSystemlastContactVerify = ([DateTime]::Parse((Get-JCSystem -active $false -filterDateProperty lastContact -dateFilter after -date $NewestSystemlastContact.addDays(-1) | Select-Object -Last 1 -ExpandProperty lastContact))).ToUniversalTime()
        $NewestSystemlastContact | Should -Be $NewestSystemlastContactVerify
    }
    It "Searches for a JumpCloud system using filterDateProperty lastContact and before" {
        $OldestSystemlastContact = ([DateTime]::Parse((Get-JCSystem -active $false -returnProperties lastContact | Where-Object lastContact -ne $null | Select-Object -First 1 -ExpandProperty lastContact))).ToUniversalTime()
        $OldestSystemlastContactVerify = ([DateTime]::Parse((Get-JCSystem -active $false -filterDateProperty lastContact -dateFilter before -date $OldestSystemlastContact.addDays(1) | Select-Object -First 1 -ExpandProperty lastContact))).ToUniversalTime()
        $OldestSystemlastContact | Should -Be $OldestSystemlastContactVerify
    }
}

Describe -Tag:('JCSystem') "Case Insensitivity Tests" {
    It "Searches parameters dynamically with mixed, lower and upper capitalaztion" {
        $commandParameters = (GCM Get-JCSystem).Parameters
        $gmr = Get-JCSystem -SystemID $PesterParams_SystemLinux._id | GM
        # Get parameters that are not ID, ORGID and have a string following the param name
        $parameters = $gmr | Where-Object { ($_.Definition -notmatch "organization") -And ($_.Definition -notmatch "id") -And ($_.Definition -match "string\s\w+=(\w+)") -And ($_.Name -In $commandParameters.Keys) }

        foreach ($param in $parameters.Name) {
            # Write-host "Testing $param"
            $string = $PesterParams_SystemLinux.$param.toLower()
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

            $mixedCaseSearch = "Get-JCSystem -$($param) `"$stringFinal`""
            $lowerCaseSearch = "Get-JCSystem -$($param) `"$($stringFinal.toLower())`""
            $upperCaseSearch = "Get-JCSystem -$($param) `"$($stringFinal.TOUpper())`""
            # Write-Host $mixedCaseSearch
            # Write-Host $lowerCaseSearch
            # Write-Host $upperCaseSearch
            $systemSearchMixed = Invoke-Expression -Command:($mixedCaseSearch)
            $systemSearchLower = Invoke-Expression -Command:($lowerCaseSearch)
            $systemSearchUpper = Invoke-Expression -Command:($upperCaseSearch)
            # DefaultSearch is the expression without text formatting
            $defaultSearch = "Get-JCSystem -$($param) `"$($PesterParams_SystemLinux.$param)`""
            $userSearchDefault = Invoke-Expression -Command:($defaultSearch)
            # Ids returned here should return the same restuls
            $systemSearchUpper._id | Should -Be $userSearchDefault._id
            $systemSearchLower._id | Should -Be $userSearchDefault._id
            $systemSearchMixed._id | Should -Be $userSearchDefault._id
        }
    }
    It "Searches parameters after setting values to include special characters like \|{[()^$.#" {
        $commandParameters = (GCM Get-JCSystem).Parameters
        $gmr = Get-JCSystem -SystemID $PesterParams_SystemWindows._id | GM
        # Get parameters that are not ID, ORGID and have a string following the param name
        $parameters = $gmr | Where-Object { ($_.Definition -notmatch "organization") -And ($_.Definition -notmatch "id") -And ($_.Definition -match "string\s\w+=(\w+)") -And ($_.Name -In $commandParameters.Keys) }

        foreach ($param in $parameters.Name) {
            # Special character tests for displayName and description
            if (($param -eq "description")) {
                $originalParam = $PesterParams_SystemWindows.$param
                $randomParamInput = "$(New-RandomString -NumberOfChars 8)\+?|{[()^$.#"
                $SetSystem = "Set-JCSystem -systemId $($PesterParams_SystemWindows._id) -$($param) `"$randomParamInput`""
                $systemInvoke = Invoke-Expression -Command:($SetSystem)
                $SearchSystem = "Get-JCSystem -$($param) `"$randomParamInput`""
                $SearchSystemInvoke = Invoke-Expression -Command:($SearchSystem)
                $systemInvoke.$param | Should -Be $SearchSystemInvoke.$param

                #Set PesterLinux displayName and description to original
                $setSystemToOriginal = "Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -$($param) `"$originalParam`""
                Invoke-Expression -Command:($setSystemToOriginal)
            }
        }
    }
}