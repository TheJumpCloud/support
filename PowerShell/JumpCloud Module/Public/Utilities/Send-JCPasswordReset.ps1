Function Send-JCPasswordReset {
    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    param (

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByUsername', Position = 0, HelpMessage = 'The Username of the JumpCloud user you wish to send the email.')]
        [String]$username,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', Position = 0, HelpMessage = 'The _id of the User which you want to send the email. To find a JumpCloud UserID run the command: PS C:\> Get-JCUser | Select username, _id
The UserID will be the 24 character string populated for the _id field.')]
        [Alias('_id', 'id')]
        [System.String]$UserID
    )

    begin {

        Write-Verbose 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JConline
        }

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }


        Write-Verbose 'Initilizing resultsArray'
        $resultsArrayList = New-Object System.Collections.ArrayList

        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"

        if ($PSCmdlet.ParameterSetName -ne 'ByID') {
            $UserHash = Get-DynamicHash -Object User -returnProperties username
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }


    }

    process {

        switch ($PSCmdlet.ParameterSetName) {
            ByUsername {

                try {

                    $UserID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($username) }).Name

                    $Body = [ordered]@{

                        isSelectAll = $false
                        models      = @(
                            @{
                                _id = "$UserID"
                            }
                        )

                    }

                    $jsonbody = $Body | ConvertTo-Json -Depth 4 -Compress


                    $URL = "$JCUrlBasePath/api/systemusers/reactivate"

                    try {

                        $SendInvite = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                        $InviteStatus = 'Sent'

                    } catch {

                        $InviteStatus = "Error $($_.ErrorDetails)"

                    }

                    $Confirmation = [pscustomobject]@{

                        'Username'   = $username
                        'ResetEmail' = $InviteStatus

                    }

                    $resultsArrayList.Add($Confirmation) | Out-Null



                } catch {

                    Write-Error "$($_.ErrorDetails)"

                }


            }
            ByID {

                $Body = [ordered]@{

                    isSelectAll = $false
                    models      = @(
                        @{
                            _id = "$UserID"
                        }
                    )

                }

                $jsonbody = $Body | ConvertTo-Json -Depth 4 -Compress


                $URL = "$JCUrlBasePath/api/systemusers/reactivate"

                try {

                    $SendInvite = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                    $InviteStatus = 'Sent'

                } catch {

                    $InviteStatus = "Error $($_.ErrorDetails)"

                }

                $Confirmation = [pscustomobject]@{

                    'UserID'     = $UserID
                    'ResetEmail' = $InviteStatus

                }

                $resultsArrayList.Add($Confirmation) | Out-Null





            }
        }
    }

    end {

        Return $resultsArrayList

    }
}
