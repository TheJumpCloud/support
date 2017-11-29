# Published
Function Connect-JCOnline ()
{
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory = $True, HelpMessage = "Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.") ]
        [ValidateScript( {
                If (($_).Length -ne 40)
                {
                    Throw "Please enter your API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console."
                }

                Else {$true}
            })]


        [string]$JumpCloudAPIKey
    )

    begin
    {

        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JumpCloudAPIKey
        }

        $URL = "https://console.jumpcloud.com/api"
        Write-debug $URL
    }

    process
    {

        try
        {
            Invoke-RestMethod -Method GET -Uri $URL -Header $hdrs | Out-Null
        }
        catch
        {
            Write-Host "Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with 'API Settings' accessible from the drop down in the top right hand corner of the screen"
            $script:JCAPIKEY = $null
            break
        }
    }

    end
    {
        $global:JCAPIKEY = $JumpCloudAPIKey
        Write-Host -BackgroundColor Green -ForegroundColor Black "Successfully connected to JumpCloud"
    }

}
Function New-JCImportTemplate()
{
    [CmdletBinding()]

    param
    (
    )

    begin
    {
        $Banner = @"
           __
          / /  __  __   ____ ___     ____
     __  / /  / / / /  / __  __ \   / __ \
    / /_/ /  / /_/ /  / / / / / /  / /_/ /
    \____/   \____/  /_/ /_/ /_/  /  ___/
                                 /_/
   ______   __                      __
  / ____/  / /  ____   __  __  ____/ /
 / /      / /  / __ \ / / / / / __  /
/ /___   / /  / /_/ // /_/ / / /_/ /
\____/  /_/   \____/ \____/  \____/

"@

        $date = Get-Date -Format MM-dd-yyyy
        $fileName = 'JCUserImport_' + $date + '.csv'
        Write-Debug $fileName

        $Heading1 = 'The CSV file:'
        $Heading2 = 'Will be created within the directory:'
        
        Clear-host

        Write-Host $Banner -ForegroundColor Green
        Write-Host $Heading1 -NoNewline
        Write-Host " $fileName" -ForegroundColor Yellow
        Write-Host $Heading2 -NoNewline
        Write-Host " $home" -ForegroundColor Yellow
        Write-Host ""


        while ($ConfirmFile -ne 'Y' -and $ConfirmFile -ne 'N')
        {
            $ConfirmFile = Read-Host  "Enter Y to confirm or N to change $fileName output location" #Confirm .csv file location creation
        }

        if ($ConfirmFile -eq 'Y')
        {

            $ExportLocation = $home
        }

        elseif ($ConfirmFile -eq 'N')
        {
            $ExportLocation = Read-Host "Enter the full path to the folder you wish to create $fileName in"

            while (-not(Test-Path -Path $ExportLocation -PathType Container))
            {
                Write-Host -BackgroundColor Yellow -ForegroundColor Red "The location $ExportLocation does not exist. Try another"
                $ExportLocation = Read-Host "Enter the full path to the folder you wish to create $fileName in"

            }
            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "The .csv file $fileName will be created within the $ExportLocation directory"
            Pause

        }

    }

    process
    {
        $CSV = [ordered]@{
            FirstName = $null
            LastName  = $null
            Username  = $null
            Email     = $null
            Password  = $null
        }

        Write-Host ""
        Write-Host 'Do you want to bind your new users to existing JumpCloud systems during import?'

        while ($ConfirmSystem -ne 'Y' -and $ConfirmSystem -ne 'N')
        {
            $ConfirmSystem = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($ConfirmSystem -eq 'Y')
        {

            $CSV.add('SystemID', $null)

            $ExistingSystems = Get-JCSystem | Select-Object HostName, DisplayName, @{Name = 'SystemID'; Expression = {$_._id}}, lastContact

            $SystemsName = 'JCSystems_' + $date + '.csv'

            $ExistingSystems | Export-Csv -path "$ExportLocation/$SystemsName" -NoTypeInformation

            Write-Host 'Creating file '  -NoNewline
            Write-Host $SystemsName -ForegroundColor Yellow -NoNewline
            Write-Host ' with all existing systems in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow

        }

        elseif ($ConfirmAttributes -eq 'N') {}

        Write-Host ""
        Write-Host 'Do you want to add the new users to JumpCloud user groups during import?'

        while ($ConfirmGroups -ne 'Y' -and $ConfirmGroups -ne 'N')
        {
            $ConfirmGroups = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($ConfirmGroups -eq 'Y')
        {
            [int]$GroupNumber = Read-Host  "What is the maximum number of groups you want to add a single user to during import? ENTER A NUMBER"
            [int]$NewGroup = 0
            [int]$GroupID = 1
            $GroupsArray = @()

            while ($NewGroup -ne $GroupNumber)
            {
                $GroupsArray += "Group$GroupID"
                $NewGroup++
                $GroupID++
            }

            foreach ($Group in $GroupsArray)
            {
                $CSV.add($Group, $null)
            }

        }

        elseif ($ConfirmGroups -eq 'N') {}


        Write-Host ""
        Write-Host 'Do you want to add any custom attributes to your users during import?'

        while ($ConfirmAttributes -ne 'Y' -and $ConfirmAttributes -ne 'N')
        {
            $ConfirmAttributes = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($ConfirmAttributes -eq 'Y')
        {
            [int]$AttributeNumber = Read-Host  "What is the maximum number of custom attributes you want to add to a single user during import? ENTER A NUMBER"
            [int]$NewAttribute = 0
            [int]$AttributeID = 1
            $NewAttributeArrayList = New-Object System.Collections.ArrayList

            while ($NewAttribute -ne $AttributeNumber)
            {
                $temp = New-Object PSObject
                $temp | Add-Member -MemberType NoteProperty -Name AttributeName  -Value "Attribute$AttributeID`_name"
                $temp | Add-Member -MemberType NoteProperty -Name AttributeValue  -Value "Attribute$AttributeID`_value"
                $NewAttributeArrayList.Add($temp) | Out-Null
                $NewAttribute ++
                $AttributeID ++
            }


            foreach ($Attribute in $NewAttributeArrayList)
            {
                $CSV.add($Attribute.AttributeName, $null)
                $CSV.add($Attribute.AttributeValue, $null)
            }

        }

        elseif ($ConfirmAttributes -eq 'N') {}

        $CSVheader = New-Object psobject -Property $Csv
    }


    end
    {
        $ExportPath = Test-Path ("$ExportLocation/$FileName")
        if (!$ExportPath )
        {
            Write-Host ""
            $CSVheader  | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
            Write-Host 'Creating file'  -NoNewline
            Write-Host " $fileName" -ForegroundColor Yellow -NoNewline
            Write-Host ' in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow
        }
        else
        {
            Write-Host ""
            Write-Warning "The file $fileName already exists do you want to overwrite it?" -WarningAction Inquire
            Write-Host ""
            $CSVheader  | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
            Write-Host 'Creating file '  -NoNewline
            Write-Host $FileName -ForegroundColor Yellow -NoNewline
            Write-Host ' in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "Do you want to open the file" -NoNewLine
        Write-Host " $FileName`?" -ForegroundColor Yellow

        while ($Open -ne 'Y' -and $Open -ne 'N')
        {
            $Open = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($Open -eq 'Y')
        {
            Invoke-Item -path "$ExportLocation/$FileName"

        }
        if ($Open -eq 'N') {}
    }

}
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

        [string]$CSVFilePath

    )

    begin
    {

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        $Banner = @"
           __
          / /  __  __   ____ ___     ____
     __  / /  / / / /  / __  __ \   / __ \
    / /_/ /  / /_/ /  / / / / / /  / /_/ /
    \____/   \____/  /_/ /_/ /_/  /  ___/
                                 /_/
   ______   __                      __
  / ____/  / /  ____   __  __  ____/ /
 / /      / /  / __ \ / / / / / __  /
/ /___   / /  / /_/ // /_/ / / /_/ /
\____/  /_/   \____/ \____/  \____/

"@

        Clear-Host
        Write-Host $Banner -ForegroundColor Green
        Write-Host ""

        $NewUsers = Import-Csv -Path $CSVFilePath
        Write-Host ""
        Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($NewUsers.count) Usernames"

        $UsernameCheck = Get-Hash_UserName_ID

        foreach ($User in $NewUsers)
        {
            if ($UsernameCheck.ContainsKey($User.Username))
            {
                Write-Warning "A user with username: $($User.Username) already exisits this user will not be created would you like to continue?" -WarningAction Inquire
            }
            else
            {
                Write-Debug "$($User.Username) does not exist"
            }
        }

        Write-Host -BackgroundColor Green -ForegroundColor Black "Username check complete"
        Write-Host ""

        Write-Host ""
        Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($NewUsers.count) Emails Addresses"

        $EmailCheck = Get-Hash_Email_ID

        foreach ($User in $NewUsers)
        {
            if ($EmailCheck.ContainsKey($User.email))
            {
                Write-Warning "A user with email address: $($User.email) already exisits this user will not be created would you like to continue?" -WarningAction Inquire
            }
            else
            {
                Write-Debug "$($User.email) does not exist"
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
                    Write-Debug "$($User.SystemID) exists"
                }
                else
                {
                    Write-Warning "A system with SystemID: $($User.SystemID) does not exist and will not be bound to user $($User.Username)" -WarningAction Inquire
                }
            }
            else {Write-Debug "No system"}
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
                Write-Debug "$($GroupTest.Value) exists"
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

        $NumberOfNewUsers = $NewUsers.count

        $title = "Import Summary:"
        $menuwidth = 30
        #calculate how much to pad left to center the title
        [int]$pad = ($menuwidth / 2) + ($title.length / 2)

        #define a here string for the menu options
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

    process
    {
        foreach ($UserAdd in $NewUsers)
        {

            $CustomAttributes = $UserAdd | Get-Member -Name *Attribute* | Where-Object {$_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null"} | Select-Object Name

            Write-Debug $CustomAttributes.name.count

            if ($CustomAttributes.name.count -gt 1)
            {
                try
                {   
                    $NumberOfCustomAttributes = ($CustomAttributes.name.count) / 2
                    $NewUser = $UserAdd | New-JCUser -NumberOfCustomAttributes $NumberOfCustomAttributes
                    $Status = 'User Created'

                    try #User is created
                    {
                        if ($UserAdd.SystemID)
                        {
                            try
                            {
                                $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id
                                $SystemAddStatus = $SystemAdd.Status
                            }
                            catch
                            {
                                $SystemAddStatus = $_.ErrorDetails
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
                            try
                            {
                                $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id
                                $SystemAddStatus = $SystemAdd.Status
                            }
                            catch
                            {
                                $SystemAddStatus = $_.ErrorDetails
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
            }
        }
    }

    end
    {
        return $ResultsArrayList
    }
}
Function Get-JCCommandResult ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String[]]$CommandResultID,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID
    )


    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and resultsArrayByID'
        $resultsArray = @()
    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll')

        {

            Write-Debug 'Setting skip to zero'
            [int]$skip = 0 #Do not change!

            while (($resultsArray).Count -ge $skip)
            {
                $limitURL = "https://console.jumpcloud.com/api/commandresults?sort=type,_id&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs

                $skip += $limit
                Write-Debug "Setting skip to $skip"

                $resultsArray += $results.results
                $count = ($resultsArray).Count
                Write-Debug "Results count equals $count"
            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {

            foreach ($uid in $CommandResultID)

            {

                $URL = "https://console.jumpcloud.com/api/commandresults/$uid"
                Write-Debug $URL

                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

                $FormattedResults = [PSCustomObject]@{

                    name               = $CommandResults.name
                    command            = $CommandResults.command
                    system             = $CommandResults.system
                    organization       = $CommandResults.organization
                    workflowId         = $CommandResults.workflowId
                    workflowInstanceId = $CommandResults.workflowInstanceId
                    output             = $CommandResults.response.data.output
                    exitCode           = $CommandResults.response.data.exitCode
                    user               = $CommandResults.user
                    sudo               = $CommandResults.sudo
                    requestTime        = $CommandResults.requestTime
                    responseTime       = $CommandResults.responseTime
                    _id                = $CommandResults._id
                    error              = $CommandResults.response.error

                }


                $resultsArray += $FormattedResults

            }
        }

    }

    end

    {
        return $resultsArray
    }
}
Function Remove-JCCommandResult ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(
            ParameterSetName = 'warn',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]

        [Parameter(
            ParameterSetName = 'force',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]

        [Alias('_id', 'id')]
        [String[]] $CommandResultID,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing deleteArray'
        $deleteArray = @()
    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn')

        {
            $URI = "https://console.jumpcloud.com/api/commandresults/$CommandResultID"

            $result = Get-JCcommandresult -ByID $CommandResultID | Select-Object -ExpandProperty Name #may need to modify this

            Write-Warning "Are you sure you wish to delete object: $result ?" -WarningAction Inquire

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs

            $deleteArray += $delete
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            $URI = "https://console.jumpcloud.com/api/commandresults/$CommandResultID"

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs

            $deleteArray += $delete
        }
    }

    end
    {

        return $deleteArray

    }


}
Function Get-JCCommand ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String[]]$CommandID,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID
    )


    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and resultsArrayByID'
        $resultsArray = @()
    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll')

        {

            Write-Debug 'Setting skip to zero'
            [int]$skip = 0 #Do not change!

            while (($resultsArray).Count -ge $skip)
            {
                $limitURL = "https://console.jumpcloud.com/api/commands?sort=type,_id&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs

                $skip += $limit
                Write-Debug "Setting skip to $skip"

                $resultsArray += $results.results
                $count = ($resultsArray).Count
                Write-Debug "Results count equals $count"
            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            foreach ($uid in $CommandID)
            {
                $URL = "https://console.jumpcloud.com/api/commands/$uid"
                Write-Debug $URL
                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs
                $resultsArray += $CommandResults

            }
        }

    }

    end

    {
        return $resultsArray
    }
}
Function Invoke-JCCommand ()
{
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [String]$trigger
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Accept'    = 'application/json'
            'X-API-KEY' = $JCAPIKEY

        }

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

    }

    process

    {

        foreach ($uid in $trigger)

        {

            $URL = "https://console.jumpcloud.com/api/command/trigger/$uid"
            Write-Debug $URL

            $CommandResults = Invoke-RestMethod -Method POST -Uri $URL -Headers $hdrs

            $resultsArray += $CommandResults

        }


    }

    end

    {
        return $resultsArray
    }
}
Function Get-JCGroup ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]


    param
    (
        [Parameter(
            ParameterSetName = 'Type',
            Position = 0)]
        [ValidateSet('User', 'System')]
        [string]
        $Type
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and resultsArrayByType'
        $resultsArray = @()
        $resultsArrayByType = @()
    }


    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll')

        {

            Write-Debug 'Setting skip to zero'
            [int]$skip = 0 #Do not change!

            while ($resultsArray.Count -ge $skip)
            {
                $limitURL = "https://console.jumpcloud.com/api/v2/groups?sort=type,name&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs

                $skip += $limit
                Write-Debug "Setting skip to $skip"

                $resultsArray += $results
                $count = ($resultsArray.results).Count
                Write-Debug "Results count equals $count"
            }

        }


        elseif ($PSCmdlet.ParameterSetName -eq 'Type')
        {

            if ($type -eq 'User')
            {
                $resultsArrayByType = Get-JCGroup | Where-Object type -EQ 'user_group'

            }
            elseif ($type -eq 'System')
            {
                $resultsArrayByType = Get-JCGroup | Where-Object type -EQ 'system_group'

            }
        }

    }
    end
    {
        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll') {return $resultsArray}

        elseif ($PSCmdlet.ParameterSetName -eq 'Type') {return $resultsArrayByType}
    }
}
function Add-JCSystemGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]

        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]

        [Alias('_id', 'id')]
        [string]$SystemID,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [string]$GroupID
    )
    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_SystemGroupName_ID

            Write-Debug 'Populating SystemHostNameHash'
            $SystemHostNameHash = Get-Hash_SystemID_HostName
        }
    }
    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($GroupNameHash.containsKey($GroupName)) {}

            else { Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud user groups."}

            $GroupID = $GroupNameHash.Get_Item($GroupName)
            $HostName = $SystemHostNameHash.Get_Item($SystemID)

            $body = @{

                type = "system"
                op   = "add"
                id   = $SystemID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/systemgroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Header $hdrs
                $Status = 'Added'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'Groupname' = $GroupName
                'System'    = $HostName
                'SystemID'  = $SystemID
                'Status'    = $Status

            }

            $resultsArray += $FormattedResults


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            if (!$GroupID)
            {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-Hash_SystemGroupName_ID
                $GroupID = $GroupNameHash.Get_Item($GroupName)
            }

            $body = @{

                type = "system"
                op   = "add"
                id   = $SystemID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/systemgroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Header $hdrs
                $Status = 'Added'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'Group'    = $GroupID
                'SystemID' = $SystemID
                'Status'   = $Status
            }

            $resultsArray += $FormattedResults
        }
    }

    end

    {
        return $resultsArray
    }

}
Function Add-JCUserGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]

        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1)]
        [String]$Username,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [string]$GroupID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [Alias('_id', 'id')]
        [string]$UserID

    )
    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_UserGroupName_ID

            Write-Debug 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($GroupNameHash.containsKey($GroupName)) {}

            else { Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."}

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

            $GroupID = $GroupNameHash.Get_Item($GroupName)
            $UserID = $UserNameHash.Get_Item($Username)

            $body = @{

                type = "user"
                op   = "add"
                id   = $UserID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Header $hdrs
                $Status = 'Added'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'GroupName' = $GroupName
                'Username'  = $Username
                'UserID'    = $UserID
                'Status'    = $Status

            }

            $resultsArray += $FormattedResults


        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            if (!$GroupID)
            {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-Hash_UserGroupName_ID
                $GroupID = $GroupNameHash.Get_Item($GroupName)
            }

            $body = @{

                type = "user"
                op   = "add"
                id   = $UserID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Header $hdrs
                $Status = 'Added'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'Group'  = $GroupID
                'UserID' = $UserID
                'Status' = $Status
            }

            $resultsArray += $FormattedResults
        }
    }

    end

    {
        return $resultsArray
    }

}

Function Get-JCSystemGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup',
            Position = 0)]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [Alias('_id', 'id')]
        [String]$ByID
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and results ArraryByID'
        $rawResults = @()
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_SystemGroupName_ID
            Write-Debug 'Populating SystemIDHash'
            $SystemIDHash = Get-Hash_SystemID_HostName
        }

    }


    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')

        {
            foreach ($Group in $GroupName)

            {
                if ($GroupNameHash.containsKey($Group))

                {
                    $Group_ID = $GroupNameHash.Get_Item($Group)
                    Write-Debug "$Group_ID"

                    [int]$skip = 0 #Do not change!
                    Write-Debug "Setting skip to $skip"

                    while ($resultsArray.Count -ge $skip)
                    {
                        $limitURL = "https://console.jumpcloud.com/api/v2/Systemgroups/$Group_ID/members?limit=$limit&skip=$skip"
                        Write-Debug $limitURL
                        $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs
                        $skip += $limit
                        $rawResults += $results
                    }

                    foreach ($uid in $rawResults)
                    {
                        $Systemname = $SystemIDHash.Get_Item($uid.to.id)

                        $FomattedResult = [pscustomobject]@{

                            'GroupName' = $GroupName
                            'System'    = $Systemname
                            'SystemID'  = $uid.to.id
                        }

                        $resultsArray += $FomattedResult
                    }

                    $rawResults = $null

                }

                else { Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud System groups."}

            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            [int]$skip = 0 #Do not change!

            while ($resultsArray.Count -ge $skip)
            {

                $limitURL = "https://console.jumpcloud.com/api/v2/Systemgroups/$ByID/members?limit=$limit&skip=$skip"
                Write-Debug $limitURL
                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs
                $skip += $limit
                $resultsArray += $results
            }

        }
    }
    end
    {
        return $resultsArray
    }
}

Function Get-JCUserGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup',
            Position = 0)]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [String]$ByID
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and results ArraryByID'
        $rawResults = @()
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_UserGroupName_ID
            Write-Debug 'Populating UserIDHash'
            $UserIDHash = Get-Hash_ID_Username
        }

    }


    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')

        {
            foreach ($Group in $GroupName)

            {
                if ($GroupNameHash.containsKey($Group))

                {
                    $Group_ID = $GroupNameHash.Get_Item($Group)
                    Write-Debug "$Group_ID"

                    [int]$skip = 0 #Do not change!
                    Write-Debug "Setting skip to $skip"

                    while ($rawResults.Count -ge $skip)
                    {
                        $limitURL = "https://console.jumpcloud.com/api/v2/usergroups/$Group_ID/members?limit=$limit&skip=$skip"
                        Write-Debug $limitURL
                        $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs
                        $skip += $limit
                        $rawResults += $results
                    }

                    foreach ($uid in $rawResults)
                    {
                        $Username = $UserIDHash.Get_Item($uid.to.id)

                        $FomattedResult = [pscustomobject]@{

                            'GroupName' = $GroupName
                            'Username'  = $Username
                            'UserID'    = $uid.to.id
                        }

                        $resultsArray += $FomattedResult
                    }

                    $rawResults = $null

                }

                else { Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."}

            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            [int]$skip = 0 #Do not change!

            while ($resultsArray.Count -ge $skip)
            {

                $limitURL = "https://console.jumpcloud.com/api/v2/usergroups/$ByID/members?limit=$limit&skip=$skip"
                Write-Debug $limitURL
                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs
                $skip += $limit
                $resultsArray += $results
            }

        }
    }
    end
    {
        return $resultsArray
    }
}

Function New-JCSystemGroup ()
{
    [CmdletBinding()]
    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $GroupName
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        $URI = 'https://console.jumpcloud.com/api/v2/systemgroups'
        $NewGroupsArrary = @()

    }

    process
    {

        foreach ($Group in $GroupName)
        {
            $body = @{
                'name' = $Group
            }

            $jsonbody = ConvertTo-Json $body

            try
            {
                $NewGroup = Invoke-RestMethod -Method POST -Uri $URI  -Body $jsonbody -Header $hdrs
                $Status = 'Created'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }
            $FormattedResults = [PSCustomObject]@{

                'Name'   = $Group
                'id'     = $NewGroup.id
                'Result' = $Status
            }

            $NewGroupsArrary += $FormattedResults
        }
    }

    end
    {
        return $NewGroupsArrary
    }
}

Function New-JCUserGroup ()
{
    [CmdletBinding()]
    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $GroupName
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        $URI = 'https://console.jumpcloud.com/api/v2/usergroups'
        $NewGroupsArrary = @()

    }

    process
    {

        foreach ($Group in $GroupName)
        {
            $body = @{
                'name' = $Group
            }

            $jsonbody = ConvertTo-Json $body

            try
            {
                $NewGroup = Invoke-RestMethod -Method POST -Uri $URI  -Body $jsonbody -Header $hdrs
                $Status = 'Created'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }
            $FormattedResults = [PSCustomObject]@{

                'Name'   = $Group
                'id'     = $NewGroup.id
                'Result' = $Status
            }

            $NewGroupsArrary += $FormattedResults
        }
    }

    end
    {
        return $NewGroupsArrary
    }
}

Function Remove-JCSystemGroup ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'warn',
            Position = 0)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'force',
            Position = 0)]

        [Alias('name')]
        [String]$GroupName,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing rawResults and results resultsArray'
        $resultsArray = @()


        Write-Debug 'Populating GroupNameHash'
        $GroupNameHash = Get-Hash_SystemGroupName_ID


    }


    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn')

        {
            ForEach ($Gname in $GroupName)

            {
                if ($GroupNameHash.containsKey($Gname))

                {
                    $GID = $GroupNameHash.Get_Item($Gname)

                    Write-Warning "Are you sure you want to delete group: $Gname ?" -WarningAction Inquire

                    $URI = "https://console.jumpcloud.com/api/v2/systemgroups/$GID"

                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs

                    $Status = 'Deleted'

                    $FormattedResults = [PSCustomObject]@{

                        'Name'   = $Gname
                        'Result' = $Status

                    }

                    $resultsArray += $FormattedResults
                }

                else
                {
                    Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'force')
        {
            ForEach ($Gname in $GroupName)
            {

                $GID = $GroupNameHash.Get_Item($Gname)

                try
                {
                    $URI = "https://console.jumpcloud.com/api/v2/systemgroups/$GID"
                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs
                    $Status = 'Deleted'
                }
                catch
                {
                    $Status = $_.ErrorDetails
                }

                $FormattedResults = [PSCustomObject]@{

                    'Name'   = $Gname
                    'Result' = $Status

                }

                $resultsArray += $FormattedResults
            }

        }
    }
    end
    {
        return $resultsArray
    }
}

Function Remove-JCSystemGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]

        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]

        [Alias('id', '_id')]
        [string]$SystemID,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [string]$GroupID
    )
    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_SystemGroupName_ID
            Write-Debug 'Populating SystemHostNameHash'
            $SystemHostNameHash = Get-Hash_SystemID_HostName
        }
    }
    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($GroupNameHash.containsKey($GroupName)) {}

            else { Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud user groups."}

            $GroupID = $GroupNameHash.Get_Item($GroupName)
            $HostName = $SystemHostNameHash.Get_Item($SystemID)

            $body = @{

                type = "system"
                op   = "remove"
                id   = $SystemID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/systemgroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupRemove = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Header $hdrs
                $Status = 'Removed'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'Groupname' = $GroupName
                'System'    = $HostName
                'SystemID'  = $SystemID
                'Status'    = $Status

            }

            $resultsArray += $FormattedResults


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            if (!$GroupID)
            {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-Hash_SystemGroupName_ID
                $GroupID = $GroupNameHash.Get_Item($GroupName)
            }

            $body = @{

                type = "system"
                op   = "remove"
                id   = $SystemID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/systemgroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupRemove = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Header $hdrs
                $Status = 'Removed'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'Group'    = $GroupID
                'SystemID' = $SystemID
                'Status'   = $Status
            }

            $resultsArray += $FormattedResults
        }
    }

    end

    {
        return $resultsArray
    }

}

Function Remove-JCUserGroup ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'warn',
            Position = 0)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'force',
            Position = 0)]

        [Alias('name')]
        [String]$GroupName,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing rawResults and results resultsArray'
        $resultsArray = @()


        Write-Debug 'Populating GroupNameHash'
        $GroupNameHash = Get-Hash_UserGroupName_ID


    }


    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn')

        {
            ForEach ($Gname in $GroupName)

            {
                if ($GroupNameHash.containsKey($Gname))

                {
                    $GID = $GroupNameHash.Get_Item($Gname)

                    Write-Warning "Are you sure you want to delete group: $Gname ?" -WarningAction Inquire

                    $URI = "https://console.jumpcloud.com/api/v2/usergroups/$GID"

                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs

                    $Status = 'Deleted'

                    $FormattedResults = [PSCustomObject]@{

                        'Name'   = $Gname
                        'Result' = $Status

                    }

                    $resultsArray += $FormattedResults
                }

                else
                {
                    Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'force')
        {
            ForEach ($Gname in $GroupName)
            {

                $GID = $GroupNameHash.Get_Item($Gname)

                try
                {
                    $URI = "https://console.jumpcloud.com/api/v2/usergroups/$GID"
                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs
                    $Status = 'Deleted'
                }
                catch
                {
                    $Status = $_.ErrorDetails
                }

                $FormattedResults = [PSCustomObject]@{

                    'Name'   = $Gname
                    'Result' = $Status

                }

                $resultsArray += $FormattedResults
            }

        }
    }
    end
    {
        return $resultsArray
    }
}

Function Remove-JCUserGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]

        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1)]
        [String]$Username,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [string]$GroupID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [Alias('_id', 'id')]
        [string]$UserID

    )
    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_UserGroupName_ID
            Write-Debug 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($GroupNameHash.containsKey($GroupName)) {}

            else { Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."}

            Write-Debug 'Populating UserNameHash'

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

            $GroupID = $GroupNameHash.Get_Item($GroupName)
            $UserID = $UserNameHash.Get_Item($Username)

            $body = @{

                type = "user"
                op   = "remove"
                id   = $UserID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Header $hdrs
                $Status = 'Removed'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'GroupName' = $GroupName
                'Username'  = $Username
                'UserID'    = $UserID
                'Status'    = $Status

            }

            $resultsArray += $FormattedResults


        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            if (!$GroupID)
            {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-Hash_UserGroupName_ID
                $GroupID = $GroupNameHash.Get_Item($GroupName)
            }

            $body = @{

                type = "user"
                op   = "remove"
                id   = $UserID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Header $hdrs
                $Status = 'Removed'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'GroupID' = $GroupID
                'UserID'  = $UserID
                'Status'  = $Status
            }

            $resultsArray += $FormattedResults
        }
    }

    end

    {
        return $resultsArray
    }

}
Function Get-JCSystem ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]

        [Alias('_id', 'id')]
        [String]$SystemID,


        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID

    )


    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and resultsArrayByID'
        $resultsArray = @()
        #$resultsArrayByID = @()
    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll')

        {

            Write-Debug 'Setting skip to zero'
            [int]$skip = 0 #Do not change!

            while (($resultsArray.results).Count -ge $skip)

            {
                $limitURL = "https://console.jumpcloud.com/api/Systems?sort=type,_id&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs

                $skip += $limit
                Write-Debug "Setting skip to $skip"

                $resultsArray += $results.results
                $count = ($resultsArray).Count
                Write-Debug "Results count equals $count"
            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {

            foreach ($uid in $SystemID)

            {

                $URL = "https://console.jumpcloud.com/api/Systems/$uid"
                Write-Debug $URL
                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs
                $resultsArray += $CommandResults

            }
        }

    }

    end

    {
        return $resultsArray
    }
}
Function Get-JCSystemUser ()
{
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        Position=0)]
        [Alias('_id','id')]
        [String]$SystemID
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept' = 'application/json'
            'X-API-KEY' = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArrayList and resultsArray'
        $resultsArrayList = New-Object System.Collections.ArrayList
        $resultsArray = @()

        Write-Debug 'Populating UserIDHash'
        $UserIDHash = Get-Hash_ID_Username

        Write-Debug 'Populating SystemIDHash'
        $SystemIDHash = Get-Hash_SystemID_HostName

    }

    process
    {
        Write-Debug 'Setting skip to zero'
        [int]$skip = 0 #Do not change!

        while (($resultsArray.results).Count -ge $skip)
        {
            $URI = "https://console.jumpcloud.com/api/v2/systems/$SystemID/users?sort=type,_id&limit=$limit&skip=$skip"

            Write-Debug $URI

            $APIresults = Invoke-RestMethod -Method GET -Uri $URI -Body $jsonbody -Header $hdrs

            $skip += $limit
            Write-Debug "Setting skip to $skip"

            $resultsArray += $APIresults

            $count = ($resultsArray).Count
            Write-Debug "Results count equals $count"
        }


        $Hostname = $SystemIDHash.Get_Item($SystemID)

        foreach ($result in $resultsArray)
        {
            $UserID = $result.id
            $Username = $UserIDHash.Get_Item($UserID)
            $Groups = $result.compiledAttributes.ldapGroups.name

            if (($result.paths.to).Count -eq $null)
            {
                $DirectBind = $true
            }
            elseif ((($result.paths.to).Count % 3 -eq 0))
            {
                $DirectBind = $false
            }
            else
            {
                $DirectBind = $true
            }

            $SystemUser = [pscustomobject]@{
                'HostName' = $Hostname
                'SystemID' = $SystemID
                'Username' = $Username
                'DirectBind' = $DirectBind
                'BindGroups' = @($Groups)
            }

            $resultsArrayList.Add($SystemUser) | Out-Null
        }

    }

    end
    {
        return $resultsArrayList
    }
}
Function Remove-JCSystemUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Force',
            Position = 0)]

        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Force',
            Position = 1)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]

        [string]
        [alias("_id")]
        $SystemID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]
        [string]
        $UserID,

        [Parameter(
            ParameterSetName = 'Force')]
        [Switch]
        $force

    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing SystemUpdateArray'
        $SystemUpdateArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName' -or $PSCmdlet.ParameterSetName -eq 'Force')
        {
            Write-Debug $PSCmdlet.ParameterSetName
            Write-Debug 'Populating HostNameHash'
            $HostNameHash = Get-Hash_SystemID_HostName
            Write-Debug 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

        Write-Debug $PSCmdlet.ParameterSetName
    }

    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($HostNameHash.containsKey($SystemID)) {}

            else { Throw "SystemID does not exist. Run 'Get-JCsystem | Select-Object Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."}

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

            $UserID = $UserNameHash.Get_Item($Username)
            $HostName = $HostNameHash.Get_Item($SystemID)

            $body = @{

                op         = "remove"
                type       = "user"
                id         = $UserID
                attributes = $null

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Debug $URL

            Write-Warning "Are you sure you want to remove user: $Username from system: $HostName id: $SystemID ?" -WarningAction Inquire

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Header $hdrs
                $Status = 'Removed'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'   = $HostName
                'SystemID' = $SystemID
                'Username' = $Username
                'Status'   = $Status
            }


            $SystemUpdateArray += $FormattedResults

        }

        if ($PSCmdlet.ParameterSetName -eq 'Force')
        {
            $UserID = $UserNameHash.Get_Item($Username)
            $HostName = $HostNameHash.Get_Item($SystemID)

            $body = @{

                op         = "remove"
                type       = "user"
                id         = $UserID
                attributes = $null

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Debug $URL

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Header $hdrs
                $Status = 'Removed'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'   = $HostName
                'SystemID' = $SystemID
                'Username' = $Username
                'Status'   = $Status
            }


            $SystemUpdateArray += $FormattedResults

        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')
        {
            $body = @{

                op         = "remove"
                type       = "user"
                id         = $UserID
                attributes = $null

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Debug $URL

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Header $hdrs
                $Status = 'Removed'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'SystemID' = $SystemID
                'UserID'   = $UserID
                'Status'   = $Status
            }

            $SystemUpdateArray += $FormattedResults
        }
    }

    end

    {
        return $SystemUpdateArray
    }

}
Function Add-JCSystemUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]
        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]
        [string]
        $UserID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]

        [string]
        [alias("_id")]
        $SystemID

    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Debug 'Initilizing SystemUpdateArray'
        $SystemUpdateArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Debug $PSCmdlet.ParameterSetName

            Write-Debug 'Populating HostNameHash'
            $HostNameHash = Get-Hash_SystemID_HostName
            Write-Debug 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

        Write-Debug $PSCmdlet.ParameterSetName
    }

    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($HostNameHash.containsKey($SystemID)) {}

            else { Throw "SystemID does not exist. Run 'Get-JCsystem | Select-Object Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."}

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

            $UserID = $UserNameHash.Get_Item($Username)
            $HostName = $HostNameHash.Get_Item($SystemID)

            $body = @{

                op         = "add"
                type       = "user"
                id         = $UserID
                attributes = $null

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Debug $URL


            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Header $hdrs
                $Status = 'Added'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'   = $HostName
                'SystemID' = $SystemID
                'Username' = $Username
                'Status'   = $Status
            }


            $SystemUpdateArray += $FormattedResults

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')
        {
            $body = @{

                op         = "add"
                type       = "user"
                id         = $UserID
                attributes = $null

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Debug $URL

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Header $hdrs
                $Status = 'Added'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'SystemID' = $SystemID
                'UserID'   = $UserID
                'Status'   = $Status
            }   

            $SystemUpdateArray += $FormattedResults
        }
    }

    end

    {
        return $SystemUpdateArray
    }

}
Function Remove-JCSystem ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(
            ParameterSetName = 'warn',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]

        [Parameter(
            ParameterSetName = 'force',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]
        [Alias('_id', 'id')]
        [String] $SystemID,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        $deletedArray = @()
        $HostNameHash = Get-Hash_SystemID_HostName

    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn')

        {
            $Hostname = $HostnameHash.Get_Item($SystemID)
            Write-Warning "Are you sure you wish to delete system: $Hostname ?" -WarningAction Inquire

            try
            {

                $URI = "https://console.jumpcloud.com/api/systems/$SystemID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }


            $FormattedResults = [PSCustomObject]@{
                'HostName' = $Hostname
                'SystemID' = $SystemID
                'Results'  = $Status
            }

            $deletedArray += $FormattedResults

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            try
            {

                $URI = "https://console.jumpcloud.com/api/systems/$SystemID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }


            $FormattedResults = [PSCustomObject]@{
                'HostName' = $Hostname
                'SystemID' = $SystemID
                'Results'  = $Status
            }

            $deletedArray += $FormattedResults

        }
    }

    end
    {

        return $deletedArray

    }


}
Function Set-JCSystem ()
{
    [CmdletBinding()]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string]
        [Alias('_id', 'id')]
        $SystemID,

        [Parameter()]
        [string]
        $displayName,

        [Parameter()]
        [bool]
        $allowSshPasswordAuthentication,

        [Parameter()]
        [bool]
        $allowSshRootLogin,

        [Parameter()]
        [bool]
        $allowMultiFactorAuthentication,

        [Parameter()]
        [bool]
        $allowPublicKeyAuthentication
    )

    begin

    {

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        $UpdatedSystems = @()
    }

    process
    {
        $body = @{}

        foreach ($param in $PSBoundParameters.GetEnumerator())
        {

            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

            if ($param.key -eq 'SystemID', 'JCAPIKey') { continue }

            $body.add($param.Key, $param.Value)

        }

        $jsonbody = $body | ConvertTo-Json

        Write-Debug $jsonbody

        $URL = "https://console.jumpcloud.com/api/systems/$SystemID"

        Write-Debug $URL

        $System = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Header $hdrs

        $UpdatedSystems += $System
    }

    end
    {
        return $UpdatedSystems

    }

}

Function Get-JCUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Username',
            Position = 0)]
        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'UserID')]
        [Alias('_id', 'id')]
        [String]$UserID,

        [Parameter(ParameterSetName = 'UserID')]
        [switch]
        $ByID

    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'Username')

        {
            $UserHash = Get-Hash_UserName_ID
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }
    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll')

        {

            [int]$skip = 0 #Do not change!
            Write-Debug "Setting skip to $skip"

            while (($resultsArray).Count -ge $skip)

            {
                $limitURL = "https://console.jumpcloud.com/api/Systemusers?sort=type,_id&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs

                $skip += $limit
                Write-Debug "Setting skip to $skip"

                $resultsArray += $results.results

                $count = ($resultsArray).Count
                Write-Debug "Results count equals $count"
            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'UserID')

        {
            foreach ($uid in $UserID)

            {
                $URL = "https://console.jumpcloud.com/api/Systemusers/$uid"
                Write-Debug $URL
                $results = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs
                $resultsArray += $results
            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'Username')

        {

            foreach ($uid in $Username)

            {
                if ($UserHash.ContainsKey($uid))

                {
                    $URL_ID = $UserHash.Get_Item($uid)
                    Write-Debug $URL_ID

                    $URL = "https://console.jumpcloud.com/api/Systemusers/$URL_ID"
                    Write-Debug $URL

                    $results = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs
                    $resultsArray += $results
                }

                else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

            }
        }

    }

    end

    {
        return $resultsArray
    }
}

Function New-JCUser ()
{

    [CmdletBinding(DefaultParameterSetName = 'NoAttributes')]
    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $firstname,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $lastname,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        [ValidateLength(0, 20)]
        $username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        $email,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $password,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $allow_public_key,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $sudo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $enable_managed_uid,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [int]
        [ValidateRange(0, 65535)]
        $unix_uid,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [int]
        [ValidateRange(0, 65535)]
        $unix_guid,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $passwordless_sudo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $ldap_binding_user,

        [Parameter(ValueFromPipelineByPropertyName = $True)] ##Test this to see if this can be modified.
        [bool]
        $enable_user_portal_multifactor,

        [Parameter(ParameterSetName = 'Attributes')] ##Test this to see if this can be modified.
        [int]
        $NumberOfCustomAttributes
    )


    DynamicParam
    {

        If ($PSCmdlet.ParameterSetName -eq 'Attributes')
        {
            $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            [int]$NewParams = 0
            [int]$ParamNumber = 1

            while ($NewParams -ne $NumberOfCustomAttributes)
            {

                $attr = New-Object System.Management.Automation.ParameterAttribute
                $attr.HelpMessage = "Enter an attribute name"
                $attr.Mandatory = $true
                $attr.ValueFromPipelineByPropertyName = $true
                $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl.Add($attr)
                $param = New-Object System.Management.Automation.RuntimeDefinedParameter("Attribute$ParamNumber`_name", [string], $attrColl)
                $dict.Add("Attribute$ParamNumber`_name", $param)

                $attr1 = New-Object System.Management.Automation.ParameterAttribute
                $attr1.HelpMessage = "Enter an attribute value"
                $attr1.Mandatory = $true
                $attr1.ValueFromPipelineByPropertyName = $true
                $attrColl1 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl1.Add($attr1)
                $param1 = New-Object System.Management.Automation.RuntimeDefinedParameter("Attribute$ParamNumber`_value", [string], $attrColl1)
                $dict.Add("Attribute$ParamNumber`_value", $param1)

                $NewParams++
                $ParamNumber++
            }

            return $dict
        }
    }

    begin
    {

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        $URL = "https://console.jumpcloud.com/api/systemusers"

        $NewUserArrary = @()
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'NoAttributes')
        {
            $body = @{}

            foreach ($param in $PSBoundParameters.GetEnumerator())
            {
                if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                if ($param.key -eq '_id', 'JCAPIKey') { continue }

                if ($param.key -eq 'username')
                {
                    Write-Debug 'Setting username to all lowercase'
                    $body.Add($param.Key, ($param.Value).toLower())
                    continue
                }

                $body.add($param.Key, $param.Value)

            }

            $jsonbody = $body | ConvertTo-Json

            Write-Debug $jsonbody

            $NewUserInfo = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Header $hdrs

            $NewUserArrary += $NewUserInfo
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'Attributes')
        {
            $body = @{}

            $CustomAttributeArrayList = New-Object System.Collections.ArrayList

            foreach ($param in $PSBoundParameters.GetEnumerator())
            {
                if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                if ($param.key -eq '_id', 'JCAPIKey', 'NumberOfCustomAttributes') { continue }

                if ($param.key -eq 'username')
                {
                    Write-Debug 'Setting username to all lowercase'
                    $body.Add($param.Key, ($param.Value).toLower())
                    continue
                }

                if ($param.Key -like 'Attribute*')
                {
                    $CustomAttribute = [pscustomobject]@{

                        CustomAttribute = ($Param.key).Split('_')[0]
                        Type            = ($Param.key).Split('_')[1]
                        Value           = $Param.value
                    }

                    $CustomAttributeArrayList.Add($CustomAttribute) | Out-Null

                    $UniqueAttributes = $CustomAttributeArrayList | Select-Object CustomAttribute -Unique

                    $NewAttributes = New-Object System.Collections.ArrayList

                    foreach ($A in $UniqueAttributes )
                    {
                        $Props = $CustomAttributeArrayList | Where-Object CustomAttribute -EQ $A.CustomAttribute

                        $obj = New-Object PSObject

                        foreach ($Prop in $Props)
                        {
                            $obj | Add-Member -MemberType NoteProperty -Name $Prop.type -Value $Prop.value
                        }

                        $NewAttributes.Add($obj) | Out-Null
                    }
                    continue
                }

                $body.add($param.Key, $param.Value)

            }

            $body.add('attributes', $NewAttributes)

            $jsonbody = $body | ConvertTo-Json

            Write-Debug $jsonbody

            $NewUserInfo = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Header $hdrs

            $NewUserArrary += $NewUserInfo
        }
    }

    end
    {

        return $NewUserArrary ##Can we remove return?
    }


}

function Remove-JCUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'warn',
            ValueFromPipelineByPropertyName,
            Position = 0)]

        [Parameter(
            ParameterSetName = 'force',
            ValueFromPipelineByPropertyName,
            Position = 0)]

        [String] $Username,

        [Parameter(
            ParameterSetName = 'warn',
            ValueFromPipelineByPropertyName)]

        [Parameter(
            ParameterSetName = 'force',
            ValueFromPipelineByPropertyName)]

        [Alias('_id')]
        [String] $UserID,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force,

        [Parameter()]
        [Switch]
        $ByID
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        $deletedArray = @()
            
        if (!$ByID)

        {
            $UserHash = Get-Hash_UserName_ID
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }

    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn' -and !$ByID)
        {
            if ($UserHash.ContainsKey($Username))
            {
                $UserID = $UserHash.Get_Item($Username)

                try
                {
                    $URI = "https://console.jumpcloud.com/api/systemusers/$UserID"
                    Write-Warning "Are you sure you wish to delete user: $Username ?" -WarningAction Inquire
                    $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                    $Status = 'Deleted'
                }
                catch
                {
                    $Status = $_.ErrorDetails
                }

                $FormattedResults = [PSCustomObject]@{
                    'Username' = $Username 
                    'Results'  = $Status
                }

                $deletedArray += $FormattedResults
            }
            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}
        }

        if ($PSCmdlet.ParameterSetName -eq 'force' -and !$ByID)
        {
            $UserID = $UserHash.Get_Item($Username)

            try
            {
                $URI = "https://console.jumpcloud.com/api/systemusers/$UserID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'Username' = $Username 
                'Results'  = $Status
            }

            $deletedArray += $FormattedResults

        }
            
            
            
        if ($PSCmdlet.ParameterSetName -eq 'warn' -and $ByID)

        {
            try
            {
                $URI = "https://console.jumpcloud.com/api/systemusers/$UserID"
                Write-Warning "Are you sure you wish to delete user: $Username ?" -WarningAction Inquire
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'UserID'  = $UserID
                'Results' = $Status
            }


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force' -and $ByID)
        {

            try
            {
                $URI = "https://console.jumpcloud.com/api/systemusers/$UserID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'UserID'  = $UserID 
                'Results' = $Status
            }

            $deletedArray += $FormattedResults

        }
    }

    end
    {

        return $deletedArray

    }


}
Function Set-JCUser ()
{

    [CmdletBinding(DefaultParameterSetName = 'Username')]
    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Username',
            Position = 0)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'RemoveAttribute')]

        [string]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]

        [Alias('_id', 'id')]
        [string]$UserID,

        [Parameter()]
        [string]
        $email,

        [Parameter()]
        [string]
        $firstname,

        [Parameter()]
        [string]
        $lastname,

        [Parameter()]
        [string]
        $password,

        [Parameter()]
        [bool]
        $allow_public_key,

        [Parameter()]
        [bool]
        $sudo,

        [Parameter()]
        [bool]
        $enable_managed_uid,

        [Parameter()]
        [int]
        [ValidateRange(0, 65535)]
        $unix_uid,

        [Parameter()]
        [int]
        [ValidateRange(0, 65535)]
        $unix_guid,

        [Parameter()]
        [bool]
        $account_locked,

        [Parameter()]
        [bool]
        $passwordless_sudo,

        [Parameter()]
        [bool]
        $externally_managed,

        [Parameter()]
        [bool]
        $ldap_binding_user,

        [Parameter()]
        [bool]
        $enable_user_portal_multifactor,

        [Parameter()]
        [int]
        $NumberOfCustomAttributes,

        [Parameter(ParameterSetName = 'RemoveAttribute')]
        [string[]]
        $RemoveAttribute,

        [Parameter(ParameterSetName = 'ByID')]
        [switch]
        $ByID

    )

    DynamicParam
    {

        If ($NumberOfCustomAttributes)
        {
            $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            [int]$NewParams = 0
            [int]$ParamNumber = 1

            while ($NewParams -ne $NumberOfCustomAttributes)
            {

                $attr = New-Object System.Management.Automation.ParameterAttribute
                $attr.HelpMessage = "Enter an attribute name"
                $attr.Mandatory = $true
                $attr.ValueFromPipelineByPropertyName = $true
                $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl.Add($attr)
                $param = New-Object System.Management.Automation.RuntimeDefinedParameter("Attribute$ParamNumber`_name", [string], $attrColl)
                $dict.Add("Attribute$ParamNumber`_name", $param)

                $attr1 = New-Object System.Management.Automation.ParameterAttribute
                $attr1.HelpMessage = "Enter an attribute value"
                $attr1.Mandatory = $true
                $attr1.ValueFromPipelineByPropertyName = $true
                $attrColl1 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl1.Add($attr1)
                $param1 = New-Object System.Management.Automation.RuntimeDefinedParameter("Attribute$ParamNumber`_value", [string], $attrColl1)
                $dict.Add("Attribute$ParamNumber`_value", $param1)

                $NewParams++
                $ParamNumber++
            }

            return $dict
        }
    }

    begin

    {
        Write-Debug "Parameter set $($PSCmdlet.ParameterSetName)"

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        $UpdatedUserArray = @()

        if ($PSCmdlet.ParameterSetName -ne 'ByID')

        {
            $UserHash = Get-Hash_UserName_ID
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'Username' -and !$NumberOfCustomAttributes)
        {
            if ($UserHash.ContainsKey($Username))

            {
                $URL_ID = $UserHash.Get_Item($Username)
                Write-Debug $URL_ID

                $URL = "https://console.jumpcloud.com/api/Systemusers/$URL_ID"
                Write-Debug $URL

                $body = @{}

                foreach ($param in $PSBoundParameters.GetEnumerator())
                {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                    if ($param.key -eq 'Username') { continue }

                    $body.add($param.Key, $param.Value)

                }

                $jsonbody = $body | ConvertTo-Json

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Header $hdrs

                $UpdatedUserArray += $NewUserInfo


            }

            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'Username' -and ($NumberOfCustomAttributes))
        {
            if ($UserHash.ContainsKey($Username))

            {
                $URL_ID = $UserHash.Get_Item($Username)
                Write-Debug $URL_ID

                $URL = "https://console.jumpcloud.com/api/Systemusers/$URL_ID"
                Write-Debug $URL

                $CurrentAttributes = Get-JCUser -UserID $URL_ID | Select-Object -ExpandProperty attributes | Select-Object value, name
                Write-Debug "There are $($CurrentAttributes.count) existing attributes"

                $body = @{}

                $CustomAttributeArrayList = New-Object System.Collections.ArrayList


                foreach ($param in $PSBoundParameters.GetEnumerator())
                {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                    if ($param.key -eq 'Username') { continue }

                    if ($param.key -eq 'NumberOfCustomAttributes') { continue }

                    if ($param.Key -like 'Attribute*')
                    {
                        $CustomAttribute = [pscustomobject]@{

                            CustomAttribute = ($Param.key).Split('_')[0]
                            Type            = ($Param.key).Split('_')[1]
                            Value           = $Param.value
                        }

                        $CustomAttributeArrayList.Add($CustomAttribute) | Out-Null

                        $UniqueAttributes = $CustomAttributeArrayList | Select-Object CustomAttribute -Unique

                        $NewAttributes = New-Object System.Collections.ArrayList

                        foreach ($A in $UniqueAttributes )
                        {
                            $Props = $CustomAttributeArrayList | Where-Object CustomAttribute -EQ $A.CustomAttribute

                            $obj = New-Object PSObject

                            foreach ($Prop in $Props)
                            {
                                $obj | Add-Member -MemberType NoteProperty -Name $Prop.type -Value $Prop.value
                            }

                            $NewAttributes.Add($obj) | Out-Null

                        }

                        continue
                    }


                    $body.add($param.Key, $param.Value)

                }


                $NewAttributesHash = @{}

                foreach ($NewA in $NewAttributes)
                {
                    $NewAttributesHash.Add($NewA.name, $NewA.value)

                }

                $CurrentAttributesHash = @{}

                foreach ($CurrentA in $CurrentAttributes)
                {
                    $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
                }



                foreach ($A in $NewAttributesHash.GetEnumerator())
                {
                    if (($CurrentAttributesHash).Contains($A.Key))
                    {
                        $CurrentAttributesHash.set_Item($($A.key), $($A.value))
                    }
                    else
                    {
                        $CurrentAttributesHash.Add($($A.key), $($A.value))
                    }
                }

                $UpdatedAttributeArrayList = New-Object System.Collections.ArrayList


                foreach ($NewA in $CurrentAttributesHash.GetEnumerator())
                {
                    $temp = New-Object PSObject
                    $temp | Add-Member -MemberType NoteProperty -Name name -Value $NewA.key
                    $temp | Add-Member -MemberType NoteProperty -Name value -Value $NewA.value
                    $UpdatedAttributeArrayList.Add($temp) | Out-Null
                }

                $body.add('attributes', $UpdatedAttributeArrayList)

                $jsonbody = $body | ConvertTo-Json

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Header $hdrs

                $UpdatedUserArray += $NewUserInfo


            }

            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'RemoveAttribute')
        {
            if ($UserHash.ContainsKey($Username))

            {
                $URL_ID = $UserHash.Get_Item($Username)
                Write-Debug $URL_ID

                $URL = "https://console.jumpcloud.com/api/Systemusers/$URL_ID"
                Write-Debug $URL
                    
                $CurrentAttributes = Get-JCUser -UserID $URL_ID | Select-Object -ExpandProperty attributes | Select-Object value, name
                Write-Debug "There are $($CurrentAttributes.count) existing attributes"

                $body = @{}

                foreach ($param in $PSBoundParameters.GetEnumerator())
                {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                    if ($param.key -eq 'Username') { continue }

                    if ($param.key -eq 'RemoveAttribute') { continue}

                    $body.add($param.Key, $param.Value)

                }

                $CurrentAttributesHash = @{}

                foreach ($CurrentA in $CurrentAttributes)
                {
                    $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
                }

                foreach ($Remove in $RemoveAttribute)
                {
                    if ($CurrentAttributesHash.ContainsKey($Remove))
                    {
                        Write-Debug "$Remove is here"
                        $CurrentAttributesHash.Remove($Remove)
                    }
                }



                $UpdatedAttributeArrayList = New-Object System.Collections.ArrayList


                foreach ($NewA in $CurrentAttributesHash.GetEnumerator())
                {
                    $temp = New-Object PSObject
                    $temp | Add-Member -MemberType NoteProperty -Name name -Value $NewA.key
                    $temp | Add-Member -MemberType NoteProperty -Name value -Value $NewA.value
                    $UpdatedAttributeArrayList.Add($temp) | Out-Null
                }

                $body.add('attributes', $UpdatedAttributeArrayList)                    

                $jsonbody = $body | ConvertTo-Json

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Header $hdrs

                $UpdatedUserArray += $NewUserInfo


            }

            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID' -and (!$NumberOfCustomAttributes))
        {
            Write-Debug $UserID

            $URL = "https://console.jumpcloud.com/api/Systemusers/$UserID"

            Write-Debug $URL

            $body = @{}

            foreach ($param in $PSBoundParameters.GetEnumerator())
            {
                if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                if ($param.key -eq 'UserID') { continue }

                if ($param.key -eq 'ByID') { continue }

                $body.add($param.Key, $param.Value)

            }

            $jsonbody = $body | ConvertTo-Json

            Write-Debug $jsonbody

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Header $hdrs

            $UpdatedUserArray += $NewUserInfo


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID' -and ($NumberOfCustomAttributes))
        {
            Write-Debug $UserID

            $URL = "https://console.jumpcloud.com/api/Systemusers/$UserID"

            $CurrentAttributes = Get-JCUser -UserID $UserID | Select-Object -ExpandProperty attributes | Select-Object value, name
            Write-Debug "There are $($CurrentAttributes.count) existing attributes"

            $body = @{}

            $CustomAttributeArrayList = New-Object System.Collections.ArrayList


            foreach ($param in $PSBoundParameters.GetEnumerator())
            {
                if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                if ($param.key -eq 'Username') { continue }

                if ($param.key -eq 'ByID') { continue }

                if ($param.key -eq 'UserID') { continue }

                if ($param.key -eq 'NumberOfCustomAttributes') { continue }

                if ($param.Key -like 'Attribute*')
                {
                    $CustomAttribute = [pscustomobject]@{

                        CustomAttribute = ($Param.key).Split('_')[0]
                        Type            = ($Param.key).Split('_')[1]
                        Value           = $Param.value
                    }

                    $CustomAttributeArrayList.Add($CustomAttribute) | Out-Null

                    $UniqueAttributes = $CustomAttributeArrayList | Select-Object CustomAttribute -Unique

                    $NewAttributes = New-Object System.Collections.ArrayList

                    foreach ($A in $UniqueAttributes )
                    {
                        $Props = $CustomAttributeArrayList | Where-Object CustomAttribute -EQ $A.CustomAttribute

                        $obj = New-Object PSObject

                        foreach ($Prop in $Props)
                        {
                            $obj | Add-Member -MemberType NoteProperty -Name $Prop.type -Value $Prop.value
                        }

                        $NewAttributes.Add($obj) | Out-Null

                    }

                    continue
                }


                $body.add($param.Key, $param.Value)

            }


            $NewAttributesHash = @{}

            foreach ($NewA in $NewAttributes)
            {
                $NewAttributesHash.Add($NewA.name, $NewA.value)

            }

            $CurrentAttributesHash = @{}

            foreach ($CurrentA in $CurrentAttributes)
            {
                $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
            }



            foreach ($A in $NewAttributesHash.GetEnumerator())
            {
                if (($CurrentAttributesHash).Contains($A.Key))
                {
                    $CurrentAttributesHash.set_Item($($A.key), $($A.value))
                }
                else
                {
                    $CurrentAttributesHash.Add($($A.key), $($A.value))
                }
            }

            $UpdatedAttributeArrayList = New-Object System.Collections.ArrayList


            foreach ($NewA in $CurrentAttributesHash.GetEnumerator())
            {
                $temp = New-Object PSObject
                $temp | Add-Member -MemberType NoteProperty -Name name -Value $NewA.key
                $temp | Add-Member -MemberType NoteProperty -Name value -Value $NewA.value
                $UpdatedAttributeArrayList.Add($temp) | Out-Null
            }

            $body.add('attributes', $UpdatedAttributeArrayList)

            $jsonbody = $body | ConvertTo-Json

            Write-Debug $jsonbody

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Header $hdrs

            $UpdatedUserArray += $NewUserInfo


        }

    }

    end
    {
        return $UpdatedUserArray

    }

}

# Helper functions - Not published

Function Get-Hash_Email_ID ()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser

    foreach ($User in $Users)
    {
        $UsersHash.Add($User.Email, $User._id)

    }
    return $UsersHash
}
Function Get-Hash_ID_Username ()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser

    foreach ($User in $Users)
    {
        $UsersHash.Add($User._id, $User.username)

    }
    return $UsersHash
}
Function Get-Hash_SystemGroupName_ID ()
{

    $UserSystemHash = New-Object System.Collections.Hashtable

    $UserSystems = Get-JCGroup -Type System

    foreach ($System in $UserSystems)
    {
        $UserSystemHash.Add($System.name, $System.id)
    }
    return $UserSystemHash
}
Function Get-Hash_SystemID_HostName ()
{

    $SystemsHash = New-Object System.Collections.Hashtable

    $Systems = Get-JCsystem

    foreach ($System in $Systems)
    {
        $SystemsHash.Add($System._id, $System.HostName)

    }
    return $SystemsHash
}
Function Get-Hash_UserGroupName_ID ()
{

    $UserGroupHash = New-Object System.Collections.Hashtable

    $UserGroups = Get-JCGroup -Type User

    foreach ($Group in $UserGroups)
    {
        $UserGroupHash.Add($Group.name, $Group.id)
    }

    return $UserGroupHash
}
Function Get-Hash_UserName_ID ()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser

    foreach ($User in $Users)
    {
        $UsersHash.Add($User.username, $User._id)

    }
    return $UsersHash
}

Export-ModuleMember -Function Connect-JCOnline, Get-JCCommandResult, Remove-JCCommandResult, Invoke-JCCommand, Get-JCCommand, Remove-JCUserGroupMember, Remove-JCUserGroup, Remove-JCSystemGroupMember, Remove-JCSystemGroup, New-JCUserGroup, New-JCSystemGroup, Add-JCSystemGroupMember, Get-JCSystemGroupMember, Get-JCGroup, Add-JCUserGroupMember, Get-JCUserGroupMember, Set-JCSystem, Get-JCSystemUser, Remove-JCSystem, Get-JCSystem, Remove-JCSystemUser, Add-JCSystemUser, Get-JCUser, New-JCUser, Remove-JCUser, Set-JCUser, Import-JCUsersFromCSV, New-JCImportTemplate
