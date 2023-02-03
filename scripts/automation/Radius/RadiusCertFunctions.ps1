# Begin Functions

function Show-RadiusMainMenu {
    param (
        [string]$Title = 'JumpCloud Radius Cert Deployment'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "$([char]0x1b)[96mEdit the variables in Config.ps1 before continuing this script"

    Write-Host "1: Press '1' to generate your Root Certificate."
    Write-Host "2: Press '2' to generate your User Certificate(s)."
    Write-Host "3: Press '3' to distribute your User Certificate(s)."
    Write-Host "4: Press '4' to monitor your User Certification Distribution."
    Write-Host "Q: Press 'Q' to quit."
}

function get-GroupMembership {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [system.string]
        $groupID
    )
    begin {
        $skip = 0
        $limit = 100
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID
        }
        $paginate = $true
        $list = @()
    }
    process {
        while ($paginate) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/usergroups/$JCUSERGROUP/membership?limit=$limit&skip=$skip" -Method GET -Headers $headers
            $list += $response
            $skip += $limit
            if ($response.count -lt $limit) {
                $paginate = $false
            }
        }
    }
    end {
        return $list
    }
}

function get-webjcuser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [system.string]
        $userID
    )
    begin {
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID
        }
    }
    process {
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/systemusers/$userID" -Method GET -Headers $headers
    }
    end {
        # return ${id, username, email }
        $userObj = [PSCustomObject]@{
            username = $response.username
            id       = $response._id
            email    = $response.email
        }
        return $userObj
    }
}

function Generate-UserCert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("EmailSAN", "EmailDn", "UsernameCN")]
        [system.String]
        $CertType,
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $rootCAKey,
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $rootCA,
        [Parameter(Mandatory = $true,
            HelpMessage = "User Object Containing, id, username, email")]
        [System.Object]
        $user
    )
    begin {
        if (-Not (Test-Path -Path $rootCAKey)) {
            Throw "RootCAKey could not be found in project direcotry, have you run Generate-Cert.ps1?"
            exit 1
        }
        if (-Not (Test-Path -Path $rootCA)) {
            Throw "RootCA could not be found in project direcotry, have you run Generate-Cert.ps1?"
            exit 1
        }
    }
    process {
        # Set Extension Path
        $opensslBinary = '/usr/local/Cellar/openssl@3/3.0.7/bin/openssl'
        $ExtensionPath = "$psscriptroot/Extensions/extensions-$($CertType).cnf"
        # User Certificate Signing Request:
        $userCSR = "$psscriptroot/UserCerts/$($user.username)-cert-req.csr"
        # Set key, crt, pfx variables:
        $userKey = "$psscriptroot/UserCerts/$($user.username)-$($CertType)-client-signed.key"
        $userCert = "$psscriptroot/UserCerts/$($user.username)-$($CertType)-client-signed-cert.crt"
        $userPfx = "$psscriptroot/UserCerts/$($user.username)-client-signed.pfx"

        switch ($CertType) {
            'EmailSAN' {
                # replace extension subjectAltName
                $extContent = Get-Content -Path $ExtensionPath -Raw
                $extContent -replace ("subjectAltName.*", "subjectAltName = email:$($user.email)") | Set-Content -Path $ExtensionPath -NoNewline -Force
                # Get CSR & Key
                Write-Host "[status] Get CSR & Key"
                Invoke-Expression "$opensslBinary req -newkey rsa:2048 -nodes -keyout $userKey -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)`" -out $userCSR"
                # take signing request, make cert # specify extensions requets
                Write-Host "[status] take signing request, make cert # specify extensions requets"
                Invoke-Expression "$opensslBinary x509 -req -extfile $ExtensionPath -days $JCUSERCERTVALIDITY -in $userCSR -CA $rootCA -CAkey $rootCAKey -passin pass:$($JCORGID) -CAcreateserial -out $userCert -extensions v3_req"
                # validate the cert we cant see it once it goes to pfx
                Write-Host "[status] validate the cert we cant see it once it goes to pfx"
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # legacy needed if we take a cert like this then pass it out
                Write-Host "[status] legacy needed if we take a cert like this then pass it out"
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCUSERCERTPASS) -legacy"
            }
            'EmailDn' {
                # Create Client cert with email in the subject distinguished name
                Invoke-Expression "$opensslBinary genrsa -out $userKey 2048 -noout"
                # Generate User CSR
                Invoke-Expression "$opensslBinary req -nodes -new -key $rootCAKey -passin pass:$($JCORGID) -out $($userCSR) -subj /C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($subj.CommonName)"
                Invoke-Expression "$opensslBinary req -new -key $userKey -out $userCsr -config $ExtensionPath -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=/emailAddress=$($user.email)`""
                # Gennerate User Cert
                Invoke-Expression "$opensslBinary x509 -req -in $userCsr -CA $rootCA -CAkey $rootCAKey -days $JCUSERCERTVALIDITY -passin pass:$($JCORGID) -CAcreateserial -out $userCert -extfile $ExtensionPath"
                # Combine key and cert to create pfx file
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCUSERCERTPASS) -legacy"
                # Output
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # invoke-expression "$opensslBinary pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCUSERCERTPASS)"
            }
            'UsernameCN' {
                # Create Client cert with email in the subject distinguished name
                Invoke-Expression "$opensslBinary genrsa -out $userKey 2048"
                # Generate User CSR
                Invoke-Expression "$opensslBinary req -nodes -new -key $rootCAKey -passin pass:$($JCORGID) -out $($userCSR) -subj /C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($subj.CommonName)"
                Invoke-Expression "$opensslBinary req -new -key $userKey -out $userCSR -config $ExtensionPath -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($user.username)`""
                # Gennerate User Cert
                Invoke-Expression "$opensslBinary x509 -req -in $userCSR -CA $rootCA -CAkey $rootCAKey -days $JCUSERCERTVALIDITY -CAcreateserial -passin pass:$($JCORGID) -out $userCert -extfile $ExtensionPath"
                # Combine key and cert to create pfx file
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -inkey $userKey -passout pass:$($JCUSERCERTPASS) -legacy"
                # Output
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # invoke-expression "$opensslBinary pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCUSERCERTPASS)"
            }
        }

    }
    end {
        # Clean Up User Certs Directory remove non .crt files
        # $userCertFiles = Get-ChildItem -Path "$PSScriptRoot/UserCerts"
        # $userCertFiles | Where-Object { $_.Name -notmatch ".pfx" } | ForEach-Object {
        #     Remove-Item -path $_.fullname
        # }

    }
}

function New-JCCommandFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][System.IO.FileInfo]$certFilePath,
        [Parameter(Mandatory = $true)][String]$FileName,
        [Parameter(Mandatory = $true)][String]$FileDestination
    )
    begin {
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID
        }
        $body = @{
            content     = [convert]::ToBase64String((Get-Content -Path $certFilePath -AsByteStream))
            name        = $FileName
            destination = $FileDestination
        }

    }
    process {
        $CommandFile = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/files' -Method POST -Headers $headers -Body $body
    }
    end {
        return $CommandFile._id
    }
}

function Show-CertDeploymentMenu {
    param (
        [string]$Title = 'Radius Cert Deployment Status'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    Write-Host "1: Press '1' to view overview results."
    Write-Host "2: Press '2' to view detailed results."
    Write-Host "3: Press '3' to invoke commands"
    Write-Host "E: Press 'E' to exit."
}
function Invoke-CommandRun {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $commandID
    )
    begin {
        if ($commandID.length -ne 24) {
            throw "Supplied CommandID is not of the correct length"
        }
    }
    process {
        $headers = @{
            'x-api-key'    = $Env:JCApiKey
            'x-org-id'     = $Env:JCOrgId
            "content-type" = "application/json"
        }
        $body = @{
            _id = $commandID
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/runCommand' -Method POST -Headers $headers -ContentType 'application/json' -Body $body
    }
    end {
        if (!$response.queueIds) {
            Throw "Command with ID: $commandID could not be triggered"
        }

    }

}

function Clear-JCQueuedCommand {
    param (
        [System.String]
        $workflowId
    )
    process {
        $headers = @{
            'x-api-key' = $Env:JCApiKey
            'x-org-id'  = $Env:JCOrgId
        }
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/commandqueue/$workflowId" -Method DELETE -Headers $headers
    }
    end {
        return $response
    }
}

function Get-JCQueuedCommands {
    param (
        [string]$workflow
    )
    begin {
        $headers = @{
            "x-api-key" = $Env:JCApiKey
            "x-org-id"  = $Env:JCOrgId

        }
        $limit = [int]100
        $skip = [int]0
        $resultsArray = @()
    }
    process {
        if ($workflow) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommands?filter=workflow:eq:$workflow&skip=$skip&limit=$limit" -Method GET -Headers $headers
            $resultsArray += $response.results
        } else {
            while (($resultsArray.results).Count -ge $skip) {
                $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommand/workflows?limit=$limit&skip=$skip" -Method GET -Headers $headers
                $skip += $limit
                $resultsArray += $response.results
            }
        }
    }
    end {
        return $resultsArray
    }
}

Function Invoke-CommandsRetry {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.string]
        $jsonFile
    )
    begin {
        $RetryCommands = @()
        $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json -Depth 6
        $queuedCommands = Get-JCQueuedCommands
        $finishedCommands = Get-JCCommandResult | Where-Object name -Like "RadiusCert-Install*"
    }
    process {
        # Prompt to rerun commands that have failed or expired
        Foreach ($command in $commandsObject.commandAssociations) {
            if ($command.commandId -in $queuedCommands.command) {
                Write-Host "[status] $($command.commandName) is currently $([char]0x1b)[93mPENDING"
                continue
            } else {
                $failedCommands = $finishedCommands | Where-Object exitCode -NE 0
                if (($command.commandId -in $failedCommands.workflowId) -or ($command.commandPreviouslyRun -eq $false) -or ($command.commandId -notin $QueuedCommands.command -and $command.commandId -notin $finishedCommands.workflowId)) {
                    try {
                        if (!(Get-JcSdkCommandAssociation -CommandId $command.commandId -Targets system)) {
                            Write-Host "[status] $([char]0x1b)[91mNo system associations were found for $($command.commandName)"
                        } else {
                            Invoke-CommandRun -commandID $command.commandId
                            Write-Host "[status] $([char]0x1b)[92mInvoking $($command.commandName)"
                            # set command to queued
                            $command.commandQueued = $true
                            $RetryCommands += $command.commandId
                        }
                    } catch {
                        Write-Error "$($command.commandId) could not be invoked"
                    }
                }
            }
        }
    }
    end {
        # write out/ update jsonFile
        $commandsObject | ConvertTo-Json -Depth 6 | Out-File $jsonFile
        return $RetryCommands
    }
}

Function Get-CommandObjectTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]$retryCommands,
        [Parameter()]
        [string]$jsonFile,
        [Parameter(ParameterSetName = 'Overview')]
        [switch]$Overview,
        [Parameter(ParameterSetName = 'Detailed')]
        [switch]$Detailed
    )
    process {
        switch ($PSCmdlet.ParameterSetName) {
            Overview {
                # Import the users.json file and get the commandAssociations
                $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json -Depth 6

                # Clean up command results
                $commandResults = Get-JCCommandResult | Where-Object name -Like "RadiusCert-Install*"
                if ($commandResults) {
                    $groupedCommandResults = $commandResults | Group-Object name, system | Sort-Object -Property responseTime -Descending
                    $mostRecentCommandResults = $groupedCommandResults | ForEach-Object { $_.Group | Select-Object -First 1 | Select-Object _id }
                    $commandResults | ForEach-Object {
                        if ($_._id -in $mostRecentCommandResults._id) {
                            return
                        } else {
                            Remove-JCCommandResult -CommandResultID $_._id -force | Out-Null
                        }
                    }
                }

                # Find all queued commands for organization
                $QueuedCommands = Get-JCQueuedCommands

                $CommandObjectTable = @()

                # Iterate through all the associated commands
                foreach ($command in $commandsObject.commandAssociations) {
                    # Check to see if the current command is pending/queued
                    $queuedCommandInfo = $QueuedCommands | Where-Object command -EQ $command.commandId
                    if ($queuedCommandInfo) {
                        # If the command is queued, get the specific details of the queued workflow
                        $pendingCommands = Get-JCQueuedCommands -workflow $queuedCommandInfo.id
                    } else {
                        # If the command is not queued, set the pending commands to null
                        $pendingCommands = @()
                    }
                    # Check command results for finished instances
                    $finishedCommands = Get-JCCommandResult -CommandID $command.commandID

                    # Create command table
                    $CommandTable = @{
                        commandId   = $command.commandId
                        commandName = $command.commandName
                        pending     = $pendingCommands.count
                        completed   = $finishedCommands.count
                    }
                    # Add command table to object array
                    $CommandObjectTable += $CommandTable
                }
                # Display object array
                Write-Host "`n[Radius Cert Deployment Status - Overview]"
                $CommandObjectTable | ForEach-Object { [PSCustomObject]$_ } | Sort-Object pending -Descending | Format-Table commandId, commandName, pending, completed
            }
            Detailed {
                # Import the users.json file and get the commandAssociations
                $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json -Depth 6
                # Gather hash of system ids and displayNames
                $SystemHash = Get-JCSystem -returnProperties displayName
                # Find all the queued commands for organization
                $QueuedCommands = Get-JCQueuedCommands

                $CommandObjectTable = @()

                # Clean up command results
                $commandResults = Get-JCCommandResult | Where-Object name -Like "RadiusCert-Install*"
                if ($commandResults) {
                    $groupedCommandResults = $commandResults | Group-Object name, system | Sort-Object -Property responseTime -Descending
                    $mostRecentCommandResults = $groupedCommandResults | ForEach-Object { $_.Group | Select-Object -First 1 | Select-Object _id }
                    $commandResults | ForEach-Object {
                        if ($_._id -in $mostRecentCommandResults._id) {
                            return
                        } else {
                            Remove-JCCommandResult -CommandResultID $_._id -force | Out-Null
                        }
                    }
                }

                # Iterate through all the associated commands
                foreach ($command in $commandsObject.commandAssociations) {
                    # Check to see if the current command is pending/queued
                    if ($command.commandId -in $QueuedCommands.command) {
                        # Get the queued command info for all workflows
                        $queuedCommandInfo = $QueuedCommands | Where-Object command -EQ $command.commandId
                        # Get the individual workflow information
                        $pendingCommands = Get-JCQueuedCommands -workflow $queuedCommandInfo.id
                        # Set the command properties in json
                        $command.commandPreviouslyRun = $true
                        $command.commandQueued = $true
                        # Create command table and add to object array
                        $pendingCommands | ForEach-Object {
                            $CommandTable = @{
                                commandName       = $command.commandName
                                systemDisplayName = $SystemHash | Where-Object _id -EQ $_.system | Select-Object -ExpandProperty displayName
                                status            = "$([char]0x1b)[93mPENDING"
                            }
                            $CommandObjectTable += $CommandTable
                        }
                    }

                    # Get finished command results for current command
                    $finishedCommands = Get-JCCommandResult -CommandID $command.commandID | Sort-Object system, responsetime -Descending | Select-Object -Unique
                    if ($finishedCommands) {
                        # If there are finished command results, iterate through each and add to command object array
                        $finishedCommands | ForEach-Object {
                            if (($finishedCommands.exitCode -eq 0)) {
                                $character = "$([char]0x1b)[92mOK"
                                # Remove successful systems from command associations
                                Set-JcSdkCommandAssociation -CommandId:("$($command.commandId)") -Op 'remove' -Type:('system') -Id:("$($_.systemId)") -ErrorAction SilentlyContinue | Out-Null
                            } else {
                                $character = "$([char]0x1b)[91mFAILED"
                            }
                            $CommandTable = @{
                                commandName       = $command.commandName
                                systemDisplayName = $_.system
                                status            = $character
                            }
                            $CommandObjectTable += $CommandTable
                        }
                    }

                    if ($CommandObjectTable.commandName -notcontains $command.commandName) {
                        if (!(Get-JcSdkCommandAssociation -CommandId $command.commandId -Targets system)) {
                            $CommandTable = @{
                                commandName       = $command.commandName
                                systemDisplayName = $null
                                status            = "$([char]0x1b)[91mNo system associations found"
                            }
                            $CommandObjectTable += $CommandTable
                        } elseif (($command.commandPreviouslyRun -eq $false -and $command.commandQueued -eq $false) -or ($command.commandId -notin $QueuedCommands.command -and $command.commandId -notin $finishedCommands.workflowId)) {
                            foreach ($system in $command.systems) {
                                $CommandTable = @{
                                    commandName       = $command.commandName
                                    systemDisplayName = $SystemHash | Where-Object _id -EQ $system.systemId | Select-Object -ExpandProperty displayName
                                    status            = "$([char]0x1b)[91mNOT SCHEDULED"
                                }
                                $CommandObjectTable += $CommandTable
                            }
                        }
                    }
                }
                # Display object array
                Write-Host "`n[Radius Cert Deployment Status - Detailed]"
                $CommandObjectTable | ForEach-Object { [PSCustomObject]$_ } | Sort-Object -Property commandName, systemDisplayName, status | Format-Table commandName, systemDisplayName, status
            }
        }
    }
    end {
        # Update the json
        $commandsObject | ConvertTo-Json -Depth 6 | Out-File $jsonFile
    }
}
# End Functions