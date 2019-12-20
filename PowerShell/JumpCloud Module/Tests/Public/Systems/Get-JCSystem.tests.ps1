Describe -Tag:('JCSystem') 'Get-JCSystem 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Gets all JumpCloud systems" {
        $Systems = Get-JCSystem
        $Systems._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud system" {
        $SingleSystem = Get-JCSystem -SystemID $PesterParams.SystemID
        $SingleSystem.id.Count | Should -be 1
    }

}


Describe -Tag:('JCSystem') "Get-JCSystem 1.4" {

    It "Gets a JumpCloud system by system ID" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -SystemID $SystemInfo._id
        $PesterSystem._id | Should Be $PesterParams.SystemID
    }

    It "Returns all JumpCloud systems" {

        $Systems = Get-JCSystem
        $Systems.count | Should -BeGreaterThan 1

    }

    It "Searches for JumpCloud system by hostname wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -hostname "$($SystemInfo.hostname.Substring(0,$SystemInfo.hostname.Length-1))*"
        $PesterSystem.hostname.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by hostname wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -hostname "*$($SystemInfo.hostname.Substring(1))"
        $PesterSystem.hostname.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by hostname wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -hostname "*$($($SystemInfo.hostname.Substring(0,$SystemInfo.hostname.Length-1)).Substring(1))*"
        $PesterSystem.hostname.count | Should -BeGreaterThan 0
    }


    It "Searches for JumpCloud system by displayname wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -displayname "$($SystemInfo.displayname.Substring(0,$SystemInfo.displayname.Length-1))*"
        $PesterSystem.displayname.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by displayname wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -displayname "*$($SystemInfo.displayname.Substring(1))"
        $PesterSystem.displayname.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by displayname wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -displayname "*$($($SystemInfo.displayname.Substring(0,$SystemInfo.displayname.Length-1)).Substring(1))*"
        $PesterSystem.displayname.count | Should -BeGreaterThan 0
    }


    It "Searches for JumpCloud system by version" {


        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -version $SystemInfo.version
        $PesterSystem.version | Select-Object -Unique | Should -Be $($SystemInfo.version)
    }

    It "Searches for JumpCloud system by templateName wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -templateName "$($SystemInfo.templateName.Substring(0,$SystemInfo.templateName.Length-1))*"
        $PesterSystem.templateName.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by templateName wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -templateName "*$($SystemInfo.templateName.Substring(1))"
        $PesterSystem.templateName.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by templateName wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -templateName "*$($($SystemInfo.templateName.Substring(0,$SystemInfo.templateName.Length-1)).Substring(1))*"
        $PesterSystem.templateName.count | Should -BeGreaterThan 0
    }


    It "Searches for JumpCloud system by os wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -os "$($SystemInfo.os.Substring(0,$SystemInfo.os.Length-1))*"
        $PesterSystem.os.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by os wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -os "*$($SystemInfo.os.Substring(1))"
        $PesterSystem.os.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by os wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -os "*$($($SystemInfo.os.Substring(0,$SystemInfo.os.Length-1)).Substring(1))*"
        $PesterSystem.os.count | Should -BeGreaterThan 0
    }


    It "Searches for JumpCloud system by remoteIP wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -remoteIP "$($SystemInfo.remoteIP.Substring(0,$SystemInfo.remoteIP.Length-1))*"
        $PesterSystem.remoteIP.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by remoteIP wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -remoteIP "*$($SystemInfo.remoteIP.Substring(1))"
        $PesterSystem.remoteIP.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by remoteIP wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -remoteIP "*$($($SystemInfo.remoteIP.Substring(0,$SystemInfo.remoteIP.Length-1)).Substring(1))*"
        $PesterSystem.remoteIP.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by serialNumber wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -serialNumber "$($SystemInfo.serialNumber.Substring(0,$SystemInfo.serialNumber.Length-1))*"
        $PesterSystem.serialNumber.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by serialNumber wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -serialNumber "*$($SystemInfo.serialNumber.Substring(1))"
        $PesterSystem.serialNumber.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by serialNumber wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -serialNumber "*$($($SystemInfo.serialNumber.Substring(0,$SystemInfo.serialNumber.Length-1)).Substring(1))*"
        $PesterSystem.serialNumber.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by agentVersion wildcard end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -agentVersion "$($SystemInfo.agentVersion.Substring(0,$SystemInfo.agentVersion.Length-1))*"
        $PesterSystem.agentVersion.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by agentVersion wildcard beginning" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -agentVersion "*$($SystemInfo.agentVersion.Substring(1))"
        $PesterSystem.agentVersion.count | Should -BeGreaterThan 0
    }

    It "Searches for JumpCloud system by agentVersion wildcard beginning and end" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
        $PesterSystem = Get-JCSystem -agentVersion "*$($($SystemInfo.agentVersion.Substring(0,$SystemInfo.agentVersion.Length-1)).Substring(1))*"
        $PesterSystem.agentVersion.count | Should -BeGreaterThan 0
    }



    ## Cannot use wildcards on system timezone

    It "Searches for JumpCloud system by systemTimezone" {

        $SystemInfo = Get-JCSystem -SystemID $PesterParams.SystemID
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
        $Sys = Get-JCSystem -systemID $PesterParams.SystemID

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
        $NewestSystemlastContact = ([DateTime](Get-JCSystem -active $false -returnProperties lastContact | Where-Object lastContact -ne $null | Select-Object -Last 1 -ExpandProperty lastContact)).ToUniversalTime()
        $NewestSystemlastContactVerify = ([DateTime](Get-JCSystem -filterDateProperty lastContact -dateFilter after -date $NewestSystemlastContact.addSeconds(-1) | Select-Object -Last 1 -ExpandProperty lastContact)).ToUniversalTime()
        $NewestSystemlastContact | Should -Be $NewestSystemlastContactVerify
    }
    It "Searches for a JumpCloud system using filterDateProperty lastContact and before" {
        $OldestSystemlastContact = ([DateTime](Get-JCSystem -active $false -returnProperties lastContact | Where-Object lastContact -ne $null | Select-Object -First 1 -ExpandProperty lastContact)).ToUniversalTime()
        $OldestSystemlastContactVerify = ([DateTime](Get-JCSystem -filterDateProperty lastContact -dateFilter before -date $OldestSystemlastContact.addSeconds(1) | Select-Object -First 1 -ExpandProperty lastContact)).ToUniversalTime()
        $OldestSystemlastContact | Should -Be $OldestSystemlastContactVerify
    }
}
