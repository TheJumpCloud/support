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
        $userObj = [PSCustomObject]@{
            # If the localUserAccount field is set, use that for username, otherwise use JC username
            hasLocalUsername = $(if ([string]::IsNullOrEmpty($response.systemUsername)) {
                    $false
                } else {
                    $true
                })
            username         = $response.username
            localUsername    = $response.systemUsername

            id               = $response._id
            email            = $response.email
        }
    }
    end {
        return $userObj
    }
}