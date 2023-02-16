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