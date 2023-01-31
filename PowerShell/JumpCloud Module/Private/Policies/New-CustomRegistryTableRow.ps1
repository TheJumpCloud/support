function New-CustomRegistryTableRow {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $customData,
        [Parameter()]
        [System.String]
        $customRegType,
        [Parameter()]
        [System.String]
        $customLocation,
        [Parameter()]
        [System.String]
        $customValueName
    )
    begin {
        $validRegTypes = @('DWORD', 'EXPAND_SZ', 'MULTI_SZ', 'SZ', 'QWORD')

    }
    process {
        if (-Not $customData) {
            $customData = (Read-Host "Please enter the registry data value")
        }
        if (-Not $customRegType) {
            Do {
                $customRegType = (Read-Host "Please enter the reg type (DWORD, EXPAND_SZ, MULTI_SZ, SZ, QWORD) value")
            } While ($customRegType -notin $validRegTypes)
        }
        if (-Not $customLocation) {
            $customLocation = (Read-Host "Please enter the reg key location value")
        }
        if (-Not $customValueName) {
            $customValueName = (Read-Host "Please enter the reg key name value")
        }

    }
    end {
        $tableRow = [PSCustomObject]@{
            customData      = $customData
            customRegType   = $customRegType
            customLocation  = $customLocation
            customValueName = $customValueName
        }
        return $tableRow
    }
}
