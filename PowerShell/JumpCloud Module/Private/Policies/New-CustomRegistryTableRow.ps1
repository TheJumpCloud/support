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
        $validRegTypes = @(
            [pscustomobject]@{
                row   = 0;
                name  = 'DWORD';
                value = 'DWORD'
            },
            [pscustomobject]@{
                row   = 1;
                name  = 'EXPAND_SZ';
                value = 'expandString'
            },
            [pscustomobject]@{
                row   = 2;
                name  = 'MULTI_SZ';
                value = 'multiString'
            },
            [pscustomobject]@{
                row   = 3;
                name  = 'QWORD';
                value = 'QWORD';
            },
            [pscustomobject]@{
                row   = 4;
                name  = 'SZ';
                value = 'String'
            }
        )
    }
    process {
        if (-Not $customData) {
            $customData = (Read-Host "Please enter the registry data value")
        }
        if (-Not $customRegType) {
            $validRegTypes | Format-Table -Property Row, Name | Out-Host
            Do {
                $customRegType = (Read-Host "Please enter a row number for a coresponding registry type (0 - 4)")
                $customRegTypeValue = $validRegTypes[$customRegType].value
            } While ($validRegTypes.Row -notcontains $customRegType)
        }
        if (-Not $customLocation) {
            $customLocation = (Read-Host "Please enter the registry key location value")
        }
        if (-Not $customValueName) {
            $customValueName = (Read-Host "Please enter the registry key name value")
        }

    }
    end {
        $tableRow = [PSCustomObject]@{
            customData      = $customData
            customRegType   = $customRegTypeValue
            customLocation  = $customLocation
            customValueName = $customValueName
        }
        return $tableRow
    }
}
