Describe -Tag:('JCDeployment') "Invoke-JCDeployment 1.7.0" {
    BeforeEach {
        $RandomString1 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
        $commandDef = @{
            name        = "pester-JCCMDDeployment_$RandomString1"
            trigger     = 'JCCMDDeployment'
            commandType = 'linux'
            command     = 'test'
            launchType  = 'trigger'
            timeout     = 120
        }
        $cmd = New-JCCommand @commandDef
        Write-Host "commandName: $($cmd.name)"

    }
    It "Invokes a JumpCloud command deployment with 2 systems" {

        $Invoke2 = Invoke-JCDeployment -CommandID $cmd.id -CSVFilePath $PesterParams_JCDeployment_2_CSV
        $Invoke2.SystemID.count | Should -Be "2"
    }

    It "Invokes a JumpCloud command deployment with 10 systems" {
        $Invoke10 = Invoke-JCDeployment -CommandID $cmd.id -CSVFilePath $PesterParams_JCDeployment_10_CSV
        $Invoke10.SystemID.count | Should -Be "10"
    }
    AfterEach {
        Write-Host "removing commandName: $($cmd.name)"
        Remove-JCCommand -CommandID $cmd._id -force
    }
}
