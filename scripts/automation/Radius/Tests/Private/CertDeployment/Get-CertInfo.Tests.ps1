Describe "Date Parsing is Culture Invariant" -Tag "Acceptance" {

    BeforeAll {
        # Load all functions from private folders
        $Private = @( Get-ChildItem -Path "$JCRScriptRoot/Functions/Private/*.ps1" -Recurse)
        Foreach ($Import in $Private) {
            Try {
                . $Import.FullName
            } Catch {
                Write-Error -Message "Failed to import function $($Import.FullName): $_"
            }
        }
        Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "new" -force
    }
    Context "Date Parsing" {

        BeforeAll {
            $originalCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
            $originalUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
        }
        AfterAll {
            [System.Threading.Thread]::CurrentThread.CurrentCulture = $originalCulture
            [System.Threading.Thread]::CurrentThread.CurrentUICulture = $originalUICulture
        }

        It "Parses date string in pt-BR culture" {
            # Set culture to Brazilian Portuguese
            [System.Threading.Thread]::CurrentThread.CurrentCulture = 'pt-BR'
            [System.Threading.Thread]::CurrentThread.CurrentUICulture = 'pt-BR'

            $user = $global:JCRRadiusMembers.username | select -First 1
            # if the user does not have a valid cert, generate one with Start-GenerateUserCerts
            $userCertExpectedPath = "$($global:JCRConfig.radiusDirectory.value)/UserCerts/$($user)-$($global:JCRConfig.certType.value)-client-signed-cert.crt"
            if (-not (Test-Path -Path $userCertExpectedPath)) {
                Start-GenerateUserCerts -username $user -forceReplaceCert -type ByUsername
            }
            { Get-CertInfo -UserCerts -username $user } | Should -Not -Throw
        }
    }


}