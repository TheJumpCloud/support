function Get-CertKeyPass {
    #TODO: params required to test if a CA password is correct
    $foundKeyPem = Resolve-Path -Path "$JCScriptRoot/Cert/*key.pem"
    Write-Host "Found key: $($foundKeyPem)"

    if ($foundKeyPem -match "ca_key") {
        # Check if the key is encrypted
        $checkKey = openssl rsa -in $foundKeyPem -check -passin pass: 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "The key is not encrypted"
        } else {
            #Check for a file with key.pem in the name
            if ($foundKeyPem) {
                # Create a loop to ask for the password
                do {
                    Write-Debug "The key is encrypted"
                    $secureCertKeyPass = Read-Host -Prompt "Enter a password for the certificate key" -AsSecureString
                    $certKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                    $checkKey = openssl rsa -in $foundKeyPem -check -passin pass:$($certKeyPass) 2>&1
                    if ($checkKey -match "RSA key ok") {
                        # Save password to ENV variable
                        Write-Host "Saving password as Environment Variable"
                        $env:certKeyPassword = $certKeyPass


                    }
                } until ($checkKey -match "RSA key ok")
            }
        }
    }

}

