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
        $Title = "regType Selector"
        $Message = "Please select the desired registry type:"
        $DWORD = New-Object System.Management.Automation.Host.ChoiceDescription "&DWORD", "DWORD"
        $EXPAND_SZ = New-Object System.Management.Automation.Host.ChoiceDescription "&EXPAND_SZ", "expandString"
        $MULTI_SZ = New-Object System.Management.Automation.Host.ChoiceDescription "&MULTI_SZ", "multiString"
        $QWORD = New-Object System.Management.Automation.Host.ChoiceDescription "&QWORD", "QWORD"
        $SZ = New-Object System.Management.Automation.Host.ChoiceDescription "&SZ", "String"
        $Options = [System.Management.Automation.Host.ChoiceDescription[]]($DWORD, $EXPAND_SZ, $MULTI_SZ, $QWORD, $SZ)
    }
    process {
        if (-Not $customData) {
            $customData = (Read-Host "Please enter the registry data value")
        }
        if (-Not $customRegType) {
            $choice = $host.ui.PromptForChoice($title, $message, $options, 0)
            $customRegTypeValue = $validRegTypes[$choice].value
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
