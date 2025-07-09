function Get-UserJsonData {
    [OutputType([System.Collections.ArrayList])]
    [CmdletBinding()]
    param (

    )
    begin {
        if (Test-Path -Path "$JCRScriptRoot/users.json" -PathType Leaf) {
            $content = (Get-Content -Raw -Path "$JCRScriptRoot/users.json")
            if ([string]::isNullOrEmpty($content)) {
                $userArray = New-Object System.Collections.ArrayList
            } else {
                $userArray = $content | ConvertFrom-Json -Depth 6

            }
        } else {
            $userArray = New-Object System.Collections.ArrayList
        }
    }
    process {
        # If the json is a single item, explicitly make it a list so we can add to it
        If ($userArray.count -eq 1) {
            $array = New-Object System.Collections.ArrayList
            $array.add($userArray) | Out-Null
            $userArray = $array
        }
    }
    end {
        return [System.Collections.ArrayList]$userArray
    }
}