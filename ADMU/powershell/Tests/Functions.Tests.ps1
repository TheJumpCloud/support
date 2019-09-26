. 'C:\Users\Administrator\Downloads\support-ADMU_1.2.0 (1)\support-ADMU_1.2.0\ADMU\powershell\Functions.ps1'
Describe 'Functions' {

    Context 'VerifyAccount Function'{
        It 'VerifyAccount - Real Domain Account bob.lazar@JCADB2.local' {
            VerifyAccount -username bob.lazar -domain JCADB2.local | Should Be $true
        }

        It 'VerifyAccount - False Account' {
            VerifyAccount -username bob.lazar -domain JCADB2.localw | Should Be $false
        }
    }#context

    Context 'Write-Log Function'{
        It 'Write-Log - Log exists' {
            Write-Log -Message:('System is NOT joined to a domain.') -Level:('Info')
            Test-Path 'c:\windows\temp\jcAdmu.log' | Should Be $true
            #delete log file
            remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force

        }

        It 'Write-Log - ERROR: Log entry exists' {
        
            Write-Log -Message:('Test Error Log Entry.') -Level:('Error')
            $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
            $Log.Contains('ERROR: Test Error Log Entry.') | Should Be $true
            remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
        }

        It 'Write-Log - WARNING: Log entry exists' {
        
            Write-Log -Message:('Test Warning Log Entry.') -Level:('Warn')
            $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
            $Log.Contains('WARNING: Test Warning Log Entry.') | Should Be $true
            remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
        }

        It 'Write-Log - INFO: Log entry exists' {
        
            Write-Log -Message:('Test Info Log Entry.') -Level:('Info')
            $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
            $Log.Contains('INFO: Test Info Log Entry.') | Should Be $true
            remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
        }
    }#context

    Context 'Remove-ItemIfExists Function'{
        It 'Remove-ItemIfExists - c:\windows\temp\test\' {
            if(Test-Path 'c:\windows\Temp\test\') {Remove-Item 'c:\windows\Temp\test' -Recurse -Force}
            New-Item -ItemType directory -path 'c:\windows\Temp\test\'
            New-Item 'c:\windows\Temp\test\test.txt'
            Remove-ItemIfExists -Path 'c:\windows\Temp\test\' -Recurse 
            Test-Path 'c:\windows\Temp\test\' | Should Be $false
        }
    }#context

    Context 'Add-LocalUser Function'{
        It 'Add-LocalUser - testuser to Users ' {
            net user testuser /delete | Out-Null
            net user testuser Temp123! /add
            Remove-LocalGroupMember -Group "Users" -Member "testuser"
            $WmiComputerSystem = Get-WmiObject -Class:('Win32_ComputerSystem')
            $localComputerName = $WmiComputerSystem.Name
            Add-LocalUser -computer:($localComputerName) -group:('Users') -localusername:('testuser')
            (Get-LocalGroupMember -Group 'Users' -Member 'testuser') -ne $null | Should Be $true
        }

    }#context

    Context 'Check_Program_Installed Function'{
        It 'Check_Program_Installed - Google Chrome' {
            Check_Program_Installed -programName 'Google Chrome' | Should Be $true
        }

        It 'Check_Program_Installed - Program Name Does Not Exist' {
            Check_Program_Installed -programName 'Google Chrome1' | Should Be $false
        }

    }#context

    Context 'Start-NewProcess Function'{
        It 'Start-NewProcess - Notepad' {
            Start-NewProcess -pfile:('c:\windows\system32\notepad.exe') -Timeout 2
            (Get-Process -Name 'notepad') -ne $null | Should Be $true
             Stop-Process -Name "notepad"
        }

    }#context

    Context 'Test-IsNotEmpty Function'{
        It 'Test-IsNotEmpty - $null' {
            Test-IsNotEmpty -field $null | Should Be $true
        }

        It 'Test-IsNotEmpty - empty' {
            Test-IsNotEmpty -field '' | Should Be $true
        }

        It 'Test-IsNotEmpty - test string' {
            Test-IsNotEmpty -field 'test' | Should Be $false
        }

    }#context

    Context 'Test-Is40chars Function'{
        It 'Test-Is40chars - $null' {
            Test-Is40chars -field $null | Should Be $false
        }

        It 'Test-Is40chars - 39 Chars' {
            Test-Is40chars -field '111111111111111111111111111111111111111' | Should Be $false
        }

        It 'Test-Is40chars - 40 Chars' {
            Test-Is40chars -field '1111111111111111111111111111111111111111' | Should Be $true
        }

    }#context

    Context 'Test-HasNoSpaces Function'{
        It 'Test-HasNoSpaces - $null' {
            Test-HasNoSpaces -field $null | Should Be $true
        }

        It 'Test-HasNoSpaces - no spaces' {
            Test-HasNoSpaces -field 'testwithnospaces' | Should Be $true
        }

        It 'Test-HasNoSpaces - spaces' {
            Test-HasNoSpaces -field 'test with spaces' | Should Be $false
        }

    }#context

    $jcAdmuTempPath = 'C:\Windows\Temp\JCADMU\'
    $msvc2013x64File = 'vc_redist.x64.exe'
    $msvc2013x86File = 'vc_redist.x86.exe'
    $msvc2013x86Link = 'http://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x86.exe'
    $msvc2013x64Link = 'http://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x64.exe'
    $msvc2013x86Install = "$jcAdmuTempPath$msvc2013x86File /install /quiet /norestart"
    $msvc2013x64Install = "$jcAdmuTempPath$msvc2013x64File /install /quiet /norestart"
    #uninstall jcagent
    #uninstall c++ 2013 x64
    #uninstall c++ 2013 x86

    Context 'DownloadAndInstallAgent Function'{
        It 'DownloadAndInstallAgent - Verify Download JCAgent prereq Visual C++ 2013 x64' {
            Test-path 'C:\Windows\Temp\JCADMU\vc_redist.x64.exe' | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Download JCAgent prereq Visual C++ 2013 x86' {
            Test-path 'C:\Windows\Temp\JCADMU\vc_redist.x86.exe' | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Download JCAgent' {
            Test-path 'C:\Windows\Temp\JCADMU\JumpCloud-agent.exe' | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Install JCAgent prereq Visual C++ 2013 x64' {
            (Check_Program_Installed("Microsoft Visual C\+\+ 2013 x64")) | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Install JCAgent prereq Visual C++ 2013 x86' {
            (Check_Program_Installed("Microsoft Visual C\+\+ 2013 x86")) | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Install JCAgent' {
            (Check_Program_Installed("JumpCloud")) | Should Be $true
        }
    }#context

    Context 'GetNetBiosName Function'{
        It 'GetNetBiosName - JCADB2' {
            GetNetBiosName | Should Be 'JCADB2'
        }

    }#context

    Context 'ConvertSID Function'{
        It 'ConvertSID - Built In Administrator SID' {
            ConvertSID -Sid 'S-1-5-21-1382148263-173757150-4289105529-500' | Should Be '10PRO18091\Administrator'
        }

    }#context

}#describe
