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
            $systemTable = @{
                systemId    = $system.resource_object_id
                displayName = $system.hostname
                osFamily    = $system.device_os
            }
            $systemAssociations += $systemTable
        }

    }
    end {
        return $systemAssociations
    }
}