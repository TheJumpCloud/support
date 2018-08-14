Function Import-JCUsersFromCSV ()
{
    [CmdletBinding(DefaultParameterSetName = 'GUI')]
    param
    (
        [Parameter(Mandatory,
            position = 0,
            ParameterSetName = 'GUI')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.csv$' )]

        [Parameter(Mandatory,
            position = 0,
            ParameterSetName = 'force')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.csv$' )]

        [string]$CSVFilePath,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force


    )

    begin
    {
        Write-Verbose "$($PSCmdlet.ParameterSetName)"

        if ($PSCmdlet.ParameterSetName -eq 'GUI')
        {

            Write-Verbose 'Verifying JCAPI Key'
            if ($JCAPIKEY.length -ne 40) {Connect-JConline}

            $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  / 
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /  
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/   
                       /_/                                                      
                                                  User Import
"@

            Clear-Host
            Write-Host $Banner -ForegroundColor Green
            Write-Host ""

            $NewUsers = Import-Csv -Path $CSVFilePath
            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($NewUsers.count) Usernames"

            $ExistingUsernameCheck = Get-Hash_UserName_ID

            foreach ($User in $NewUsers)
            {
                if ($ExistingUsernameCheck.ContainsKey($User.Username))
                {
                    Write-Warning "A user with username: $($User.Username) already exists this user will not be created." 
                }
                else
                {
                    Write-Verbose "$($User.Username) does not exist"
                }
            }


            $UsernameDup = $NewUsers | Group-Object Username

            ForEach ($U in $UsernameDup )
            {
                if ($U.count -gt 1)
                {

                    Write-Warning "Duplicate username for username $($U.name) in import file. Usernames must be unique. To resolve eliminate the duplicate username and then retry import." 
                }
            }


            Write-Host -BackgroundColor Green -ForegroundColor Black "Username check complete"
            Write-Host ""

            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($NewUsers.count) Emails Addresses"

            $ExistingEmailCheck = Get-Hash_Email_ID

            foreach ($User in $NewUsers)
            {
                if ($ExistingEmailCheck.ContainsKey($User.email))
                {
                    Write-Warning "A user with email address: $($User.email) already exists this user will not be created." 
                }
                else
                {
                    Write-Verbose "$($User.email) does not exist"
                }
            }

            $EmailDup = $NewUsers | Group-Object Email

            ForEach ($U in $EmailDup)
            {
                if ($U.count -gt 1)
                {

                    Write-Warning "Duplicate email for email $($U.name) in import file. Emails must be unique. To resolve eliminate the duplicate emails." 
                }
            }

            Write-Host -BackgroundColor Green -ForegroundColor Black "Email check complete"
            Write-Host ""

            $SystemCount = $NewUsers.SystemID | Where-Object Length -gt 1 | Select-Object -unique

            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($SystemCount.count) Systems"
            $SystemCheck = Get-Hash_SystemID_HostName

            foreach ($User in $NewUsers)
            {
                if (($User.SystemID).length -gt 1)
                {

                    if ($SystemCheck.ContainsKey($User.SystemID))
                    {
                        Write-Verbose "$($User.SystemID) exists"
                    }
                    else
                    {
                        Write-Warning "A system with SystemID: $($User.SystemID) does not exist and will not be bound to user $($User.Username)" 
                    }
                }
                else {Write-Verbose "No system"}
            }

            $Permissions = $NewUsers.Administrator | Where-Object Length -gt 1 | Select-Object -unique

            foreach ($Value in $Permissions)
            {

                if ( ($Value -notlike "*true" -and $Value -notlike "*false") )
                {

                    Write-Warning "Administrator must be a boolean value and set to either '`$True/True' or '`$False/False' please correct value: $Value " 

                
                }

            }


            Write-Host -BackgroundColor Green -ForegroundColor Black "System check complete"
            Write-Host ""
            #Group Check

            $GroupArrayList = New-Object System.Collections.ArrayList

            ForEach ($User in $NewUsers)
            {

                $Groups = $User | Get-Member -Name Group* | Select-Object Name

                foreach ($Group in $Groups)
                {
                    $CheckGroup = [pscustomobject]@{
                        Type  = 'GroupName'
                        Value = $User.($Group.Name)
                    }

                    if ($CheckGroup.Value.Length -gt 1)
                    {

                        $GroupArrayList.Add($CheckGroup) | Out-Null

                    }

                    else {}

                }

            }

            $UniqueGroups = $GroupArrayList | Select-Object Value -Unique

            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($UniqueGroups.count) Groups"
            $GroupCheck = Get-Hash_UserGroupName_ID

            foreach ($GroupTest in $UniqueGroups)
            {
                if ($GroupCheck.ContainsKey($GroupTest.Value))
                {
                    Write-Verbose "$($GroupTest.Value) exists"
                }
                else
                {
                    Write-Host ""
                    Write-Host "The JumpCloud Group:" -NoNewLine
                    Write-Host " $($GroupTest.Value)" -ForegroundColor Yellow -NoNewLine
                    Write-Host " does not exist. Users will not be added to this Group."
                }
            }

            Write-Host -BackgroundColor Green -ForegroundColor Black "Group check complete"
            Write-Host ""

            $ResultsArrayList = New-Object System.Collections.ArrayList

            $NumberOfNewUsers = $NewUsers.email.count

            $title = "Import Summary:"
            $menuwidth = 30
            [int]$pad = ($menuwidth / 2) + ($title.length / 2)

            $menu = @"

    Number Of Users To Import = $NumberOfNewUsers

    Would you like to import these users?

"@

            Write-Host $title -ForegroundColor Red
            Write-Host $menu -ForegroundColor Yellow


            while ($Confirm -ne 'Y' -and $Confirm -ne 'N')
            {
                $Confirm = Read-Host "Press Y to confirm or N to quit"
            }

            if ($Confirm -eq 'Y')
            {

                Write-Host ''
                Write-Host "Hang tight! Creating your users. " -NoNewline
                Write-Host "DO NOT shutdown the console." -ForegroundColor Red
                Write-Host ''
                Write-Host "Feel free to watch your user count increase in the JumpCloud admin console!"
                Write-Host ''
                Write-Host "It takes ~ 1 minute per 100 users."

            }

            elseif ($Confirm -eq 'N')
            {
                break
            }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            $NewUsers = Import-Csv -Path $CSVFilePath
            $ResultsArrayList = New-Object System.Collections.ArrayList
        }

    } #begin block end

    process
    {
        foreach ($UserAdd in $NewUsers)
        {
            $NewUser = $Null
            $Status = $Null
            $UserGroupArrayList = $Null
            $SystemAddStatus = $Null

            $CustomAttributes = $UserAdd | Get-Member -Name *Attribute* | Where-Object {$_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null"} | Select-Object Name

            Write-Verbose $CustomAttributes.name.count

            if ($CustomAttributes.name.count -gt 1)
            {
                try
                {   
                    $NumberOfCustomAttributes = ($CustomAttributes.name.count) / 2
                    $NewUser = $UserAdd | New-JCUser -NumberOfCustomAttributes $NumberOfCustomAttributes

                    if ($NewUser)
                    {

                        $Status = 'User Created'
                    }

                    elseif (-not $NewUser)
                    {
                        $Status = 'User Not Created'
                    }
                   

                    try #User is created
                    {
                        if ($UserAdd.SystemID)
                        {

                            if ($UserAdd.Administrator)
                            {

                                if ($UserAdd.Administrator -like "*True")
                                {

                                    Write-Verbose "Admin set to true"

                                    try
                                    {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id -Administrator $true
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch
                                    {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                }

                                elseif ($UserAdd.Administrator -like "*False")
                                {

                                    Write-Verbose "Admin set to false"

                                    try
                                    {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id -Administrator $false
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch
                                    {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                    
                                }
                                
                            }

                            else
                            {
                                
                                Write-Verbose "No admin set"

                                try
                                {
                                    $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id
                                    Write-Verbose  "$($SystemAdd.Status)"
                                    $SystemAddStatus = $SystemAdd.Status
                                }
                                catch
                                {
                                    $SystemAddStatus = $_.ErrorDetails
                                }

                            }
                        }
                        $CustomGroupArrayList = New-Object System.Collections.ArrayList

                        $CustomGroups = $UserAdd | Get-Member -Name *Group* | Select-Object Name

                        foreach ($Group in $CustomGroups)
                        {
                            $GetGroup = [pscustomobject]@{
                                Type  = 'GroupName'
                                Value = $UserAdd.($Group.Name)
                            }

                            $CustomGroupArrayList.Add($GetGroup) | Out-Null

                        }

                        $UserGroupArrayList = New-Object System.Collections.ArrayList

                        foreach ($Group in $CustomGroupArrayList)
                        {
                            try
                            {

                                $GroupAdd = Add-JCUserGroupMember -ByID -UserID $NewUser._id -GroupName $Group.value

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $GroupAdd.Status
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }

                            catch
                            {

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $_.ErrorDetails
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }
                        }
                    }
                    catch
                    {

                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'  = $NewUser.username
                        'Status'    = $Status
                        'UserID'    = $NewUser._id
                        'GroupsAdd' = $UserGroupArrayList
                        'SystemID'  = $UserAdd.SystemID
                        'SystemAdd' = $SystemAddStatus

                    }

                    

                }

                catch
                {

                    $Status = $_.ErrorDetails

                    $FormattedResults = [PSCustomObject]@{

                        'Username'  = $NewUser.username
                        'Status'    = $Status
                        'UserID'    = $NewUser._id
                        'GroupsAdd' = $UserGroupArrayList
                        'SystemID'  = $UserAdd.SystemID
                        'SystemAdd' = $SystemAddStatus

                    }

                    
                }

                $ResultsArrayList.Add($FormattedResults) | Out-Null
                $SystemAddStatus = $null
                

            }

            else
            {
                try
                {
                    $NewUser = $UserAdd | New-JCUser
                    $Status = 'User Created'

                    try #User is created
                    {
                        if ($UserAdd.SystemID)
                        {

                            if ($UserAdd.Administrator)
                            {

                                Write-Verbose "Admin set"

                                if ($UserAdd.Administrator -like "*True")
                                {

                                    Write-Verbose "Admin set to true"

                                    try
                                    {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id -Administrator $true
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch
                                    {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                }

                                elseif ($UserAdd.Administrator -like "*False")
                                {

                                    Write-Verbose "Admin set to false"

                                    try
                                    {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id -Administrator $false
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch
                                    {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                    
                                }
                                    
                                
                            }

                            else
                            {
                                
                                Write-Verbose "No admin set"

                                try
                                {
                                    $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id
                                    Write-Verbose  "$($SystemAdd.Status)"
                                    $SystemAddStatus = $SystemAdd.Status
                                }
                                catch
                                {
                                    $SystemAddStatus = $_.ErrorDetails
                                }

                            }
                        


                        }

                        $CustomGroupArrayList = New-Object System.Collections.ArrayList

                        $CustomGroups = $UserAdd | Get-Member -Name *Group* | Select-Object Name

                        foreach ($Group in $CustomGroups)
                        {
                            $GetGroup = [pscustomobject]@{
                                Type  = 'GroupName'
                                Value = $UserAdd.($Group.Name)
                            }

                            $CustomGroupArrayList.Add($GetGroup) | Out-Null

                        }

                        $UserGroupArrayList = New-Object System.Collections.ArrayList

                        foreach ($Group in $CustomGroupArrayList)
                        {
                            try
                            {

                                $GroupAdd = Add-JCUserGroupMember -ByID -UserID $NewUser._id -GroupName $Group.value

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $GroupAdd.Status
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }

                            catch
                            {

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $_.ErrorDetails
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }
                        }
                    }
                    catch
                    {

                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'  = $NewUser.username
                        'Status'    = $Status
                        'UserID'    = $NewUser._id
                        'GroupsAdd' = $UserGroupArrayList
                        'SystemID'  = $UserAdd.SystemID
                        'SystemAdd' = $SystemAddStatus

                    }

                    


                }

                catch
                {

                    $Status = $_.ErrorDetails

                    $FormattedResults = [PSCustomObject]@{

                        'Username'  = $NewUser.username
                        'Status'    = $Status
                        'UserID'    = $NewUser._id
                        'GroupsAdd' = $UserGroupArrayList
                        'SystemID'  = $UserAdd.SystemID
                        'SystemAdd' = $SystemAddStatus

                    }

                    
                }

                $ResultsArrayList.Add($FormattedResults) | Out-Null
                $SystemAddStatus = $null
            
            }
        }
    }

    end
    {
        return $ResultsArrayList
    }
}