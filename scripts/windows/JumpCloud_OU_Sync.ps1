function Sync-Jumpcloudsmartgroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateLength(40, 40)]
        [string]$JumpCloudApiKey,
        [Parameter(Mandatory=$False)]
        [string]$ExcludeOnAttribute
    )

    begin {

    #connect to jc api
    Connect-JCOnline -JumpCloudApiKey $JumpCloudApiKey

    $grouparray = Get-JCUser -returnProperties location,department | where-object {$_.location} | Sort-Object -Property 'location','department' -Unique

    for ($i = 0; $i -lt $grouparray.Count; $i++) {
        $grouparray[$i] | Add-Member NoteProperty -Name required_group -value (($grouparray[$i].location).replace(' ', '_') + '.' + $grouparray[$i].department) -Force
    }
    }

    process {
    #jumpcloud group creation
    #return required group names
    foreach ($group in $grouparray){
        $groupSplit = $group.required_group.split(".")
        if (!(Get-JCGroup -Type User -Name ($group).required_group).name) {
            if (([string]::IsNullOrWhiteSpace($groupSplit[0]) -eq $false) || ([string]::IsNullOrWhiteSpace($groupSplit[1]) -eq $false)){
                write-host ('Creating JumpCloud user group: ' + $group.required_group)
                New-JCUserGroup -GroupName $group.required_group
            }
            else{
                write-host ('Invalid group name')
            }
        }
        else {
            Write-Host 'JumpCloud user group already exists: '$group.required_group
        }
        if (Get-JCGroup -Type User -Name $group.required_group) {
            Write-Host "Modifying Membership of User Group: " $group.required_group

            # user adds
            $groupSplit = $group.required_group.split(".")
            $usrCollection = Get-JCUser -department $groupSplit[1] | where-object {$_.location -eq ($groupSplit[0]).Replace('_', ' ')} | Select-Object $_.id
            foreach ($usrID in $usrCollection){
                # add user
                if (($usrID.department -eq $groupSplit[1]) && ($usrID.location-ne $groupSplit[0])){
                    Add-JCUserGroupMember -GroupName $group.required_group -Id $usrID._id
                }
            }

            # user dels
            $dels = Get-JCUserGroupMember -GroupName $group.required_group
            foreach ($usrID in $dels){
                $testCondition = Get-JCUser -id $usrID.UserID
                if ($testCondition.department -ne $groupSplit[1]){
                    write-host "mismatched attribute, removing user:" $usrID.UserID
                    write-host $testCondition.department "should be" $groupSplit[1]
                    Remove-JCUserGroupMember -GroupName $group.required_group -UserID $usrID.UserID
                }
                elseif ($testCondition.location -ne $groupSplit[0].Replace('_', ' ')){
                    write-host "mismatched attribute, removing user: " $usrID.UserID
                    write-host $testCondition.location "should be" $groupSplit[0].Replace('_', ' ')
                    Remove-JCUserGroupMember -GroupName $group.required_group -UserID $usrID.UserID
                }
            }
        }
    }
    }

    end {
        return $grouparray.required_group
    }
}

function Build-JCGroupsInAD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateLength(40, 40)]
        [string]$JumpCloudApiKey,
        [Parameter(Mandatory=$False)]
        [string]$UsersSearchBase
    )

    begin {
    #connect to jc api
    Connect-JCOnline -JumpCloudApiKey $JumpCloudApiKey

    $grouparray = Get-JCUser -returnProperties location,department | where-object {$_.location} | Sort-Object -Property 'location','department' -Unique

    for ($i = 0; $i -lt $grouparray.Count; $i++) {
        $grouparray[$i] | Add-Member NoteProperty -Name required_group -value (($grouparray[$i].location).replace(' ', '_') + '.' + $grouparray[$i].department) -Force
    }
    }

    process {
    #Create Matching AD Groups
    foreach ($group in $grouparray) {
        if (!(Get-ADGroup -ldapfilter "(name=$group.required_group)" -SearchBase $UsersSearchBase)) {
            write-host ('Creating JumpCloud user group: ' + $group.required_group)
            #New-AdGroup
        }else{
            Write-Host 'JumpCloud user group already exists: '$group.required_group
        }
    }
    }

    end {

    }
}

function Sync-JCAdGroupAndOU {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateLength(40, 40)]
        [string]$JumpCloudApiKey,
        [Parameter(Mandatory=$true)]
        [string]$SearchBase
    )

    begin {
    #connect to jc api
    Connect-JCOnline -JumpCloudApiKey $JumpCloudApiKey

    $grouparray = Get-JCUser -returnProperties location,department | where-object {$_.location} | Sort-Object -Property 'location','department' -Unique

    for ($i = 0; $i -lt $grouparray.Count; $i++) {
        $grouparray[$i] | Add-Member NoteProperty -Name required_group -value (($grouparray[$i].location).replace(' ', '_') + '.' + $grouparray[$i].department) -Force
    }
    }

    process {
        foreach ($group in $grouparray) {
            $UsersSearchBase = "CN=Users," + $SearchBase
            $LocationGroup = $group.required_group
            $locationsplit = $LocationGroup.split(".")
            $location = $locationsplit[0].Trim().Replace('_', ' ')
            $department = ($locationsplit[1]).Trim()
            $syncgroup = "CN=$LocationGroup,$UsersSearchBase"
            $Users = Get-ADGroupMember -Identity $syncgroup
            $TargetOU =  "OU=$department,OU=$location,OU=Grove," + $SearchBase
            $JumpCloudGroup = "CN=JumpCloud," + $SearchBase

            $Users | ForEach-Object {
                $UserDN = $_.distinguishedName
                Write-Host " Moving " $_.Name " to $tg"
                Move-ADObject  -Identity $UserDN  -TargetPath $TargetOU
                Add-ADGroupMember -Identity $JumpCloudGroup -Members $Users
                }
        }
    }

    end {

    }
}

#Example function calls
#Sync-Jumpcloudsmartgroup -JumpCloudApiKey '$APIKEY'
#Build-JCGroupsInAD -JumpCloudApiKey 'APIKEY' -SearchBase 'CN=Users,DC=sajumpcloud,DC=com'
#Sync-JCAdGroupAndOU -JumpCloudApiKey 'APIKEY' -SearchBase 'CN=Users,DC=sajumpcloud,DC=com'