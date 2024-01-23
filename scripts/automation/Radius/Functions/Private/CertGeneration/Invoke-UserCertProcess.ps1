Function Invoke-UserCertProcess {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'The user object from users.json', ParameterSetName = 'radiusMember')]
        [System.object]
        $radiusMember,
        [Parameter(ParameterSetName = 'selectedUserObject')]
        [System.String]
        $selectedUserObject,
        [Parameter(HelpMessage = 'The type of certificate to generate, either: "EmailSAN", "EmailDN" or "UsernameCN"', Mandatory)]
        [ValidateSet('EmailSAN', 'EmailDN', 'UsernameCN')]
        [System.String]
        $JCR_CERT_TYPE,
        # force replace existing certificate
        [Parameter(HelpMessage = 'When specified, existing certificates will be replaced')]
        [switch]
        $forceReplaceCert,
        # prompt replace existing certificate
        [Parameter(HelpMessage = 'When specified, this parameter will prompt for user imput and ask if existing certificates should be replaced' )]
        [switch]
        $prompt
    )
    begin {
        switch ($PSCmdlet.ParameterSetName) {
            'radiusMember' {
                try {
                    $MatchedUser = $GLOBAL:JCRUsers[$radiusMember.userID]
                } catch {
                    Write-Warning "could not identify user by userobject: $radiusMember"
                }
            }
            'userObject' {
                $MatchedUser = $GLOBAL:JCRUsers[$selectedUserObject.userid]
            }
        }

        # get the user from user.json
        $userObject, $userIndex = Get-UserFromTable -userID $MatchedUser.id
        # Test if the file exists:
        switch (Test-Path "$JCScriptRoot/UserCerts/$($matchedUser.username)-client-signed.pfx") {
            $true {
                switch ($forceReplaceCert) {
                    $true {
                        $writeCert = $true
                        $cert_action = "Overwritten"
                    }
                    $false {
                        $writeCert = $false
                        $cert_action = "Skip Generation"

                    }
                }
                if ($prompt) {
                    $writeCert = Get-ResponsePrompt -message "A certifcate already exists for user: $($matchedUser.username) do you want to re-generate this certificate?"
                    switch ($writeCert) {
                        $true {
                            $cert_action = "Overwritten"

                        }
                        $false {
                            $cert_action = "Skip Generation"
                        }
                    }

                }
            }
            $false {
                $writeCert = $true
                $cert_action = "New Cert Generated"
            }
            Default {
                $writeCert = $false
                $cert_action = "Unknown Action"
            }
        }

    }
    process {
        # if writeCert, generate the cert
        if ($writeCert) {
            Generate-UserCert -CertType $JCR_CERT_TYPE -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" *> /dev/null
            # validate that the cert was written correctly:
            #TODO: validate and return as variable
        }

        # generate the cert depending if -force or if new
        if ($userIndex -ge 0) {
            # update the new certificate info & set commandAssociation to $null
            # TODO: commandAssociation not being set to null
            $certInfo = Get-CertInfo -UserCerts -username $MatchedUser.username
            # Add the cert info tracking to the object
            $certInfo | Add-Member -Name 'deployed' -Type NoteProperty -Value $false
            $certInfo | Add-Member -Name 'deploymentDate' -Type NoteProperty -Value $null
            Set-UserTable -index $userIndex -certInfoObject $certInfo -commandAssociationsObject $null
        } else {
            # Create a new table entry
            New-UserTable -id $MatchedUser.id -username $MatchedUser.username -localUsername $MatchedUser.systemUsername
        }

    }
    end {
        #TODO: eventually add message if we fail to generate a command
        $resultTable = [ordered]@{
            'Username'       = $MatchedUser.username;
            'Cert Action'    = $cert_action;
            'Generated Date' = $certInfo.generated;
        }

        return $resultTable
    }
}