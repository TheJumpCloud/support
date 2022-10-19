function Update-JCSmartGroupMembership {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateSet('System', 'User')]
        [System.String]
        ${GroupType},
        [Parameter(Mandatory)]
        [System.String]
        $ID
    )
    begin {
        $SmartGroupDetails = Get-JCSmartGroup -GroupType $GroupType -ID $ID

        # Build Attribute string:
        $string = ''
        $And = $SmartGroupDetails.Attributes.And.PSobject.Properties.Name
        $or = $SmartGroupDetails.Attributes.Or.PSobject.Properties.Name
        $ret = @($and) + @($or)
        foreach ($item in $ret) {
            $string += \'"$item"\'
        }
        $ret = $ret.replace(" ", "")
        #TODO: Turn the attributes into a list and pass to next function
        $systems = Get-DynamicHash -Object $GroupType -returnProperties $ret
        # TODO:, figure out how to call this once if we are updating all groups
    }
    process {
        # For the group specified, go fetch system group membership
        switch ($GroupType) {
            'System' {
                $existingMembers = Get-JcSdkSystemGroupMembership -GroupId $ID
                "existing users"
                $existingMembers
            }
            'User' {

            }
            Default {
            }
        }
        # Look at the dynamicHash, do we need to update memebership?
        # update membership
    }
}