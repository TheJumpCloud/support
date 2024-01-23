function Set-UserJsonData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]
        $userArray
    )
    # If the json is a single item, explicitly make it a list so we can add to it
    If ($userArray.count -eq 1) {
        $array = New-Object System.Collections.ArrayList
        $array.add($userArray)
        $userArray = $array
    }
    $userArray | ConvertTo-Json -Depth 6 | Set-Content -Path "$JCScriptRoot/users.json"

}