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