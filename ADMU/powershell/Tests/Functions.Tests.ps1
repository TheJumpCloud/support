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
            Write-Log -Message:('System is NOT joined to a domain.') -Level:('Info') | Out-Null
            Test-Path 'c:\windows\temp\jcAdmu.log' | Should Be $true
            #delete log file
            remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force

        }

        It 'Write-Log - ERROR: Log entry exists' {
        
            Write-Log -Message:('Test Log Entry.') -Level:('Error')
            $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
            $Log.Contains('ERROR: Test Log Entry.') | Out-Nu | Should Be $true
            remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
        }

        It 'Write-Log - WARNING: Log entry exists' {
        
            Write-Log -Message:('Test Log Entry.') -Level:('Warning')
            $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
            $Log.Contains('WARNING: Test Log Entry.') | Should Be $true
            remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
        }

        It 'Write-Log - INFO: Log entry exists' {
        
            Write-Log -Message:('Test Log Entry.') -Level:('Info')
            $Log = Get-Content 'c:\windows\temp\jcAdmu.log'
            $Log.Contains('INFO: Test Log Entry.') | Should Be $true
            remove-item -Path 'C:\windows\Temp\jcAdmu.log' -Force
        }
    }#context

}#describe
 
