Describe -Tag:('deployment') -Name "MacOS Deployment Tests" {

    BeforeAll {
        $user = @{
            username = "test.user"
        }
        $certHash = @{
            serial = '149B8C3C37EAC184E73EA01F0846FA5D85B4EA54'
        }
        $NETWORKSSID = 'test'
        $certIdentifier = 'e'
        $JCUSERCERTPASS = 'potato'
        $macScript = Get-Content -Path "$psscriptroot/../../scripts/installCert.sh" -Raw
        $macScript = $macScript.Replace('$($user.userName)', $($user.userName))
        $macScript = $macScript.Replace('$($certHash.serial)', $($certHash.serial))
        $macScript = $macScript.Replace('$($NETWORKSSID)', $($NETWORKSSID))
        $macScript = $macScript.Replace('$($macCertSearch)', $($macCertSearch))
        $macScript = $macScript.Replace('$($certIdentifier)', $($certIdentifier))
        $macScript = $macScript.Replace('$($JCUSERCERTPASS)', $($JCUSERCERTPASS))
        $macScript | Out-File -Path "$psscriptroot/tempMacInstaller.sh"
    }
    It 'tests that macScript was rewritten' {
        $macScript | Should -Match "test.user"
        $macScript | Should -Match "149B8C3C37EAC184E73EA01F0846FA5D85B4EA54"
    }

    It 'should exit 4 when running as the wrong user' {
        function foo {
            $global:LASTEXITCODE = 0 # Note the global prefix.
            # Invoke-Expression "dotnet build xyz" # xyz is meaningless, to force nonzero exit code.
            Invoke-Expression "/bin/bash $psscriptroot/../../scripts/bash.sh"
            Write-Host $LASTEXITCODE
        }
        foo
        $LASTEXITCODE  | Should -be 4
        foo
        # { sh "$psscriptroot/../../scripts/bash.sh" } | should -Throw
    }
    It 'should exit 4 when running as the wrong user with the temp script' {
        function foo {
            $global:LASTEXITCODE = 0 # Note the global prefix.
            # Invoke-Expression "dotnet build xyz" # xyz is meaningless, to force nonzero exit code.
            Invoke-Expression "/bin/bash $psscriptroot/tempMacInstaller.sh"
            Write-Host $LASTEXITCODE
        }
        foo
        $LASTEXITCODE  | Should -be 4
        foo
        # { sh "$psscriptroot/../../scripts/bash.sh" } | should -Throw
    }
}