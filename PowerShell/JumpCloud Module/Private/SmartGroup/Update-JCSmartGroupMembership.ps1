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
        $SmartGroupDetails = Get-JCSmartGroup -GroupType $GroupType -ByID $ID

        # Build Attribute string:
        $filterBuilder = @()
        $ands = $SmartGroupDetails.Attributes.And.PSobject.Properties.Name

        foreach ($And in $ands) {
            $filterBuilder += "$($and):" + $SmartGroupDetails.Attributes.And."$and"
        }
        # $string = ''
        # $And = $SmartGroupDetails.Attributes.And.PSobject.Properties.Name
        # $or = $SmartGroupDetails.Attributes.Or.PSobject.Properties.Name
        # $ret = @($and) + @($or)
        # foreach ($item in $ret) {
        #     $string += "'$item'"
        # }
        # $ret = $ret.replace(" ", "")
        #TODO: Turn the attributes into a list and pass to next function
        # $filter @{
        #     "osFamily:$eq:darwin"
        # }
        $Search = @{
            filter = @{
                and = $filterBuilder
            }
        }
        $systems = Search-JcSdkSystem -Body:($Search)
        $systems.count
        # TODO:, figure out how to call this once if we are updating all groups
    }
    process {
        # For the group specified, go fetch system group membership
        #TODO: update the groups
        switch ($GroupType) {
            'System' {
                $existingMembers = Get-JcSdkSystemGroupMembership -GroupId $ID
                foreach ($system in $systems) {
                    # If Existing Member not in group, add
                    if ($system.id -notin $existingMembers.Id) {
                        Set-JcSdkSystemGroupMember -GroupId $ID -Op add -Id $system.id
                    }
                }
                #TODO: remove system members if they do not match criteria
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