function New-SystemTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $userID
    )
    begin {
        # Create new lists:
        $systemAssociations = @()
    }
    process {
        # Get User to System Associations:
        $AssociationTable = $Global:JCRAssociations[$userID]
        # $SystemUserAssociations += (Get-JCAssociation -Type user -Id $userID -TargetType system | Select-Object @{N = 'SystemID'; E = { $_.targetId } })
        foreach ($system in $AssociationTable.systemAssociations) {
            # $systemInfo = $GLOBAL:SystemHash[$system.resource_object_id]
            $systemTable = [ordered]@{
                systemId = $system.systemId
                hostname = $system.hostname
                osFamily = if (($system.osFamily -eq "darwin") -or ($system.osFamily -eq "macOS")) {
                    "macOS"
                } elseif ($system.osFamily -eq "windows") {
                    "windows"
                }
            }
            $systemAssociations += $systemTable
        }

    }
    end {
        return $systemAssociations
    }
}