function Update-JCSmartGroupMembership {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [System.Object]
        $Attribute,
        [Parameter(Mandatory)]
        [System.String]
        $ID
    )
    begin {
        $SmartGroupDetails = Get-JCSmartGroup -ID $ID
        $returnProperties = $SmartGroupDetails.Attributes
        #TODO: Turn the attributes into a list and pass to next function
        $systems = Get-DynamicHash -Object $SmartGroupDetails.Type -returnProperties $returnProperties
        # TODO:, figure out how to call this once if we are updating all groups
    }
    process {
        # For the group specified, go fetch system group membership
        # Look at the dynamicHash, do we need to update memebership?
        # update membership
    }
}