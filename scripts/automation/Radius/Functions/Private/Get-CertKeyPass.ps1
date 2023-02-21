function Get-CertKeyPass {
    $foundKeyPem = Resolve-Path -Path "$JCScriptRoot/Cert/*key.pem"
    Write-Host "Found key: $($foundKeyPem)"

    if ($foundKeyPem -match "ca-key") {
        # Check if the key is encrypted
        $checkKey = openssl rsa -in $foundKeyPem -check -passin pass: 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "The key is not encrypted"
        } else {
            #Check for a file with key.pem in the name
            if ($foundKeyPem) {
                # Create a loop to ask for the password
                do {
                    Write-Output "The key is encrypted"
                    $keypassword = Read-Host "Please enter the password import cert key"
                    $checkKey = openssl rsa -in $foundKeyPem -check -passin pass:$($keypassword) 2>&1
                    $checkKey
                    if ($checkKey -match "RSA key ok") {
                        # Save password to ENV variable
                        Write-Host "Saving password to env"
                        Set-Item -Path "env:Import_key_password" -Value $keypassword

                    }
                } until ($checkKey -match "RSA key ok")
            }
        }
    }

}

