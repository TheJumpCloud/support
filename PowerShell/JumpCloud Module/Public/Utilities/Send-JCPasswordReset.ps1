Function Send-JCPasswordReset
{
    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    param (

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByUsername',
            Position = 0)]
        [String]$username,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]
        [Alias('_id', 'id')]
        $UserID


    )

    begin
    {

        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }


        Write-Verbose 'Initilizing resultsArray'
        $resultsArrayList = New-Object System.Collections.ArrayList

        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"

        if ($PSCmdlet.ParameterSetName -ne 'ByID')

        {
            $UserHash = Get-Hash_UserName_ID
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }


    }

    process
    {

        switch ($PSCmdlet.ParameterSetName)
        {
            ByUsername
            {

                try
                {

                    $UserID = $UserHash.$username

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

                    try
                    {

                        $SendInvite = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                        $InviteStatus = 'Sent'

                    }
                    catch
                    {

                        $InviteStatus = "Error $($_.ErrorDetails)"

                    }

                    $Confirmation = [pscustomobject]@{

                        'Username'   = $username
                        'ResetEmail' = $InviteStatus

                    }

                    $resultsArrayList.Add($Confirmation) | Out-Null



                }
                catch
                {

                    Write-Error "$($_.ErrorDetails)"

                }


            }
            ByID
            {

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

                try
                {

                    $SendInvite = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                    $InviteStatus = 'Sent'

                }
                catch
                {

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

    end
    {

        Return $resultsArrayList

    }
}
