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
        switch ($GroupType) {
            'System' {
                $existingMembers = Get-JcSdkSystemGroupMembership -GroupId $ID
                $addMembers = $systems.id | Where { $existingMembers.Id -notcontains $_ }
                $removeMembers = $existingMembers.Id | Where { $systems.id -notcontains $_ }

                $addMembers | ForEach-Object { Set-JcSdkUserGroupMember -GroupId $ID -Op add -Id $_ }
                $removeMembers | ForEach-Object { Set-JcSdkUserGroupMember -GroupId $ID -Op remove -Id $_ }
            }
            'User' {
                $existingMembers = Get-JcSdkuserGroupMembership -GroupId $ID
                $addMembers = $users._id | Where { $existingMembers.Id -notcontains $_ }
                $removeMembers = $existingMembers.Id | Where { $users._id -notcontains $_ }

                $addMembers | ForEach-Object { Set-JcSdkUserGroupMember -GroupId $ID -Op add -Id $_ }
                $removeMembers | ForEach-Object { Set-JcSdkUserGroupMember -GroupId $ID -Op remove -Id $_ }
            }
            Default {
            }
        }
    }
}


