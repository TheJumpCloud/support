Describe 'Functions' {

    Context 'VerifyAccount Function'{

       It 'VerifyAccount - Real domain account bob.lazar@JCADB2.local' {
           VerifyAccount -username bob.lazar -domain JCADB2.local | Should Be $true
       }

       It 'VerifyAccount - Wrong account bobby.lazar@JCADB2.local' {
           #VerifyAccount -username bobby.lazar -domain JCADB2.local | Should Be $false
       }

       It 'VerifyAccount - Real account with wrong domain bob.lazar@JCADB2.localw' {
           #VerifyAccount -username bob.lazar -domain JCADB2.localw | Should Be $false
       }

    }

    Context 'Write-Log Function'{
	
        It 'Write-Log - ' {
		    if ((Test-Path 'C:\Windows\Temp\jcAdmu.log') -eq $true){
                    remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
            }
                Write-Log -Message:('Log is created - test.') -Level:('Info')
                $log='C:\windows\Temp\jcAdmu.log'
                $log | Should exist
        }

        It 'Write-Log - Log is created' {
		    if ((Test-Path 'C:\Windows\Temp\jcAdmu.log') -eq $true){
                    remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
            }
                Write-Log -Message:('Log is created - test.') -Level:('Info')
                $log='C:\windows\Temp\jcAdmu.log'

                $log | Should exist
        }

        It 'Write-Log - ERROR: Log entry exists' {
		    if ((Test-Path 'C:\Windows\Temp\jcAdmu.log') -eq $true){
                   remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
            }
              # Write-Log -Message:('Test Error Log Entry.') -Level:('Error') -ErrorAction 
               #$Log = Get-Content 'c:\windows\temp\jcAdmu.log'
               #$Log.Contains('ERROR: Test Error Log Entry.') | Should Be $true
               #    if ($error.Count -eq 1) {
               #    $error.Clear()
               #    }
        }

        It 'Write-Log - WARNING: Log entry exists' {
		    if ((Test-Path 'C:\Windows\Temp\jcAdmu.log') -eq $true){
                   remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
            }
               Write-Log -Message:('Test Warning Log Entry.') -Level:('Warn')
               $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
               $Log.Contains('WARNING: Test Warning Log Entry.') | Should Be $true
        }

        It 'Write-Log - INFO: Log entry exists' {
            if ((Test-Path 'C:\Windows\Temp\jcAdmu.log') -eq $true){
                    remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
            }
                Write-Log -Message:('Test Info Log Entry.') -Level:('Info')
                $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
                $Log.Contains('INFO: Test Info Log Entry.') | Should Be $true
                remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
        }

    }

    Context 'Remove-ItemIfExists Function'{

        It 'Remove-ItemIfExists - Does Exist c:\windows\temp\test\' {
            if(Test-Path 'c:\windows\Temp\test\') {Remove-Item 'c:\windows\Temp\test' -Recurse -Force}
            New-Item -ItemType directory -path 'c:\windows\Temp\test\'
            New-Item 'c:\windows\Temp\test\test.txt'
            Remove-ItemIfExists -Path 'c:\windows\Temp\test\' -Recurse
            Test-Path 'c:\windows\Temp\test\' | Should Be $false
        }

        It 'Remove-ItemIfExists - Fails c:\windows\temp\test\' {
            if ((Test-Path 'C:\Windows\Temp\jcAdmu.log') -eq $true){remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force}
            Mock Remove-ItemIfExists {Write-Log -Message ('Removal Of Temp Files & Folders Failed') -Level Warn}
            Remove-ItemIfExists -Path 'c:\windows\Temp\test\'
            $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
            $Log.Contains('Removal Of Temp Files & Folders Failed') | Should Be $true
        }

    }

    Context 'DownloadLink'{

        # It 'DownloadLink - ' {
        #     if(Test-Path 'c:\windows\Temp\test\') {Remove-Item 'c:\windows\Temp\test' -Recurse -Force}
        #     New-Item -ItemType directory -path 'c:\windows\Temp\test\'
        #     #DownloadLink -Link:('http://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x86.exe') -Path:('c:\windows\Temp\Test\vcredist_x86.exe')
        #     test-path ('c:\windows\Temp\test\vcredist_x86.exe')  | Should be $true
        # }

    }

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

    }

    Context 'Uninstall_Program'{

         It 'Install & Uninstall - x32 filezilla' {
             $app = 'C:\Windows\Temp\FileZilla_3.45.1_win32.exe'
             $arg = '/S'
             Start-Process $app $arg
             start-sleep -Seconds 5
             Uninstall_Program -programName 'FileZilla Client 3.45.1'
             start-sleep -Seconds 5
             Check_Program_Installed -programName 'FileZilla' | Should Be $false
         }

    }

    Context 'Check_Program_Installed Function'{

        It 'Check_Program_Installed x64 - Google Chrome' {
            Check_Program_Installed -programName 'Google Chrome' | Should Be $true
        }

        It 'Check_Program_Installed x32 - TeamViewer 14' {
            Check_Program_Installed -programName 'TeamViewer 14' | Should Be $true
        }

        It 'Check_Program_Installed - Program Name Does Not Exist' {
            Check_Program_Installed -programName 'Google Chrome1' | Should Be $false
        }

    }

    Context 'Start-NewProcess Function'{

        It 'Start-NewProcess - Notepad' {
            Start-NewProcess -pfile:('c:\windows\system32\notepad.exe') -Timeout 1000
            (Get-Process -Name 'notepad') -ne $null | Should Be $true
            Stop-Process -Name "notepad"  
        }

        It 'Start-NewProcess & end after 2s timeout - Notepad ' {
            if ((Test-Path 'C:\Windows\Temp\jcAdmu.log') -eq $true){
                    remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
            }
            Start-NewProcess -pfile:('c:\windows\system32\notepad.exe') -Timeout 1000
            Start-Sleep -s 2
            Stop-Process -Name "notepad"
            $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
               $Log.Contains('Windows ADK Setup did not complete after 5mins') | Should Be $true
               remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
        }

    }

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

    }

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

    }

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

    }

    Context 'DownloadAndInstallAgent Function'{

        It 'DownloadAndInstallAgent - Verify Download JCAgent prereq Visual C++ 2013 x64' {
            Test-path 'C:\Windows\Temp\JCADMU\vc_redist.x64.exe' | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Download JCAgent prereq Visual C++ 2013 x86' {
            Test-path 'C:\Windows\Temp\JCADMU\vc_redist.x86.exe' | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Download JCAgent' {
            Test-path 'C:\Windows\Temp\JCADMU\JumpCloudInstaller.exe' | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Install JCAgent prereq Visual C++ 2013 x64' {
            (Check_Program_Installed("Microsoft Visual C\+\+ 2013 x64")) | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Install JCAgent prereq Visual C++ 2013 x86' {
            (Check_Program_Installed("Microsoft Visual C\+\+ 2013 x86")) | Should Be $true
        }

        It 'DownloadAndInstallAgent - Verify Install JCAgent' {
        Start-Sleep -Seconds 10
            (Check_Program_Installed("JumpCloud")) | Should Be $true
        }

    }

    Context 'GetNetBiosName Function'{

        It 'GetNetBiosName - JCADB2' {
            GetNetBiosName | Should Be 'JCADB2'
        }

    }

    Context 'ConvertSID Function'{

        It 'ConvertSID - Built In Administrator SID' {
            ConvertSID -Sid 'S-1-5-21-1382148263-173757150-4289105529-500' | Should Be '10PRO18091\Administrator'
        }

    }
}

