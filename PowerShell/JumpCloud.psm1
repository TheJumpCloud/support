# Published
Function Connect-JCOnline ()
{
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]

    param
    (
        [Parameter(
            ParameterSetName ='force',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position=0)]
        
        [Parameter(Mandatory = $True,
            ParameterSetName ='Interactive',
            Position=0,
            HelpMessage = "Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.") ]
            [ValidateScript( {
                If (($_).Length -ne 40)
                {
                    Throw "Please enter your API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console."
                }

                Else {$true}
            })]


        [string]$JumpCloudAPIKey,

        [Parameter(
        ParameterSetName ='force')]
        [Switch]
        $force
    )

    begin
    {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $GitHubModuleInfoURL = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md'

        $ReleaseNotesURL = 'https://git.io/jc-pwsh-releasenotes'

        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JumpCloudAPIKey
        }

        $ConnectionTestURL = "https://console.jumpcloud.com/api"

    }

    process
    {

        try
        {
            Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'  | Out-Null
        }
        catch
        {
            Write-Output "Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with 'API Settings' accessible from the drop down in the top right hand corner of the screen"
            $global:JCAPIKEY = $null
            break
        }
    }

    end
    {
        $global:JCAPIKEY = $JumpCloudAPIKey

        if ($PSCmdlet.ParameterSetName -eq 'Interactive') {

            Write-Host -BackgroundColor Green -ForegroundColor Black "Successfully connected to JumpCloud"

            $GitHubModuleInfo = Invoke-WebRequest -uri  $GitHubModuleInfoURL -UseBasicParsing | Select-Object RawContent

            $CurrentBanner = ((((($GitHubModuleInfo -split "</a>Banner Current</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]

            $OldBanner =  ((((($GitHubModuleInfo -split "</a>Banner Old</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]

            $LatestVersion = ((((($GitHubModuleInfo -split "</a>Latest Version</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]
    
    
            $InstalledModuleVersion = Get-InstalledModule -Name JumpCloud | Select-Object -ExpandProperty Version
    
            if ($InstalledModuleVersion -eq $LatestVersion) {
    
                Write-Host -BackgroundColor Green -ForegroundColor Black "$CurrentBanner Module version: $InstalledModuleVersion" 
                
            }
    
            elseif ($InstalledModuleVersion -ne $LatestVersion) {
    
                Write-Host "$OldBanner" 
                Write-Host -BackgroundColor Yellow -ForegroundColor Black  "Installed Version: $InstalledModuleVersion " -NoNewline
                Write-Host -BackgroundColor Green -ForegroundColor Black  " Latest Version: $LatestVersion "

                Write-Host  "`nWould you like to upgrade to version: $LatestVersion ?"
                
                $Accept = Read-Host  "`nEnter 'Y' if you wish to update to version $LatestVersion or 'N' to continue using version: $InstalledModuleVersion"


                if ($Accept -eq 'N') {

                    return #Exit the function
                }

                While ($Accept -notcontains 'Y'){

                    write-warning " Typo? $Accept != 'Y'"

                    $Accept = Read-Host "`nEnter 'Y' if you wish to update to the latest version or 'N' to continue using version: $InstalledModuleVersion `n"

                    if ($Accept -eq 'N') {

                        return # Exist the function
                    }

                }


                if ($PSVersionTable.PSVersion.Major -eq '5') {

                    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){

                        Write-Warning "You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command."
            
                        Return
            
                    }

                    Uninstall-Module -Name JumpCloud -RequiredVersion $InstalledModuleVersion

                    Install-Module -Name JumpCloud -Scope CurrentUser
                }

                elseif ($PSVersionTable.PSVersion.Major -ge 6) {

                    if ($PSVersionTable.Platform -eq 'Unix') {

                        Uninstall-Module -Name JumpCloud -RequiredVersion $InstalledModuleVersion

                        Install-Module -Name JumpCloud -Scope CurrentUser
                                
                    }

                    elseif ($PSVersionTable.Platform -like "*Win*") {

                        If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){

                            Write-Warning "You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command."
                
                            Return
                
                        }

                        Uninstall-Module -Name JumpCloud -RequiredVersion $InstalledModuleVersion

                        Install-Module -Name JumpCloud -Scope CurrentUser
                                
                    }

                }

                    
                $UpdatedModuleVersion = Get-InstalledModule -Name JumpCloud | Select-Object -ExpandProperty Version

                if ($UpdatedModuleVersion -eq $LatestVersion) {

                    Clear-Host
                
                    $ReleaseNotesRaw =  Invoke-WebRequest -uri $ReleaseNotesURL -UseBasicParsing #for backwards compatibility

                    $ReleaseNotes = ((((($ReleaseNotesRaw.RawContent -split "</a>$LatestVersion</h2>")[1]) -split "<pre><code>")[1]) -split "</code>")[0]

                    Write-Host "Module updated to version: $LatestVersion`n"

                    Write-Host "Release Notes: `n"

                    Write-Host $ReleaseNotes

                    Write-Host "`nTo see the full release notes navigate to: `n" 
                    Write-Host "$ReleaseNotesURL`n"

                    Pause
    
                }
                
            }



        } #End if

        
    }#End endblock

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
       $Heading2 ='Will be created within the directory:'
        
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

        if ($ConfirmFile -eq 'Y'){

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
            LastName = $null
            Username = $null
            Email = $null
            Password = $null
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
                        $CSV.add('Administrator', $null)

                        $ExistingSystems = Get-JCSystem | Select-Object HostName, DisplayName, @{Name='SystemID';Expression={$_._id}}, lastContact

                        $SystemsName = 'JCSystems_' + $date + '.csv'

                        $ExistingSystems | Export-Csv -path "$ExportLocation/$SystemsName" -NoTypeInformation

                        Write-Host 'Creating file '  -NoNewline
                        Write-Host $SystemsName -ForegroundColor Yellow -NoNewline
                        Write-Host ' with all existing systems in the location' -NoNewline
                        Write-Host " $ExportLocation" -ForegroundColor Yellow

                    }

                    elseif ($ConfirmAttributes-eq 'N') {}

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

                elseif ($ConfirmAttributes-eq 'N') {}

                $CSVheader =  New-Object psobject -Property $Csv
    }


    end
    {
        $ExportPath = Test-Path ("$ExportLocation/$FileName")
        if (!$ExportPath ) {
            Write-Host ""
            $CSVheader  | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
            Write-Host 'Creating file'  -NoNewline
            Write-Host " $fileName" -ForegroundColor Yellow -NoNewline
            Write-Host ' in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow
        }
        else {
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
        if ($Open -eq 'N'){}
    }

}
Function Import-JCUsersFromCSV ()
{
    [CmdletBinding(DefaultParameterSetName='GUI')]
     param
    (
        [Parameter(Mandatory,
        position=0,
        ParameterSetName='GUI')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.csv$' )]

        [Parameter(Mandatory,
        position=0,
        ParameterSetName='force')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.csv$' )]

        [string]$CSVFilePath,

        [Parameter(
        ParameterSetName ='force')]
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

        $ExistingUsernameCheck = Get-Hash_UserName_ID

        foreach ($User in $NewUsers)
        {
           if ($ExistingUsernameCheck.ContainsKey($User.Username))
           {
               Write-Warning "A user with username: $($User.Username) already exisits this user will not be created would you like to continue?" -WarningAction Inquire
           }
           else {
               Write-Verbose "$($User.Username) does not exist"
           }
        }


        $UsernameDup = $NewUsers | Group-Object Username

        ForEach ($U in $UsernameDup ) {
            if ($U.count -gt 1) {

                Write-Warning "Duplicate username for username $($U.name) in import file. Usernames must be unique. To resolve elminiate the duplicate username and then retry import" -WarningAction Inquire
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
               Write-Warning "A user with email address: $($User.email) already exisits this user will not be created would you like to continue?" -WarningAction Inquire
           }
           else {
               Write-Verbose "$($User.email) does not exist"
           }
        }

        $EmailDup = $NewUsers | Group-Object Email

        ForEach ($U in $EmailDup) {
            if ($U.count -gt 1) {

                Write-Warning "Duplicate email for email $($U.name) in import file. Emails must be unique. To resolve elminiate the duplicate emails and then retry import" -WarningAction Inquire
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
                else {
                        Write-Warning "A system with SystemID: $($User.SystemID) does not exist and will not be bound to user $($User.Username)" -WarningAction Inquire
                }
            }
            else {Write-Verbose "No system"}
        }

        $Permissions = $NewUsers.Administrator | Where-Object Length -gt 1 | Select-Object -unique

        foreach ($Value in $Permissions) {

            if ( ($Value -notlike "*true" -and $Value -notlike "*false") ) {

                Write-Warning "Administrator must be a boolean value and set to either '`$True/True' or '`$False/False' please correct value: $Value " -WarningAction Inquire

                
            }

        }


        Write-Host -BackgroundColor Green -ForegroundColor Black "System check complete"
        Write-Host ""
        #Group Check

        $GroupArrayList = New-Object System.Collections.ArrayList

        ForEach ($User in $NewUsers) {

            $Groups = $User | Get-Member -Name Group* | Select-Object Name

            foreach ($Group in $Groups)
            {
                $CheckGroup = [pscustomobject]@{
                Type =  'GroupName'
                Value =  $User.($Group.Name)
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
        [int]$pad = ($menuwidth/2)+($title.length/2)

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

        if ($Confirm -eq 'Y'){

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

    elseif ($PSCmdlet.ParameterSetName -eq 'force') {

        $NewUsers = Import-Csv -Path $CSVFilePath
        $ResultsArrayList = New-Object System.Collections.ArrayList
    }

    } #begin block end

    process
    {
        foreach ($UserAdd in $NewUsers)
        {

            $CustomAttributes = $UserAdd | Get-Member -Name *Attribute* | Where-Object {$_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null"} | Select-Object Name

            Write-Verbose $CustomAttributes.name.count

            if ($CustomAttributes.name.count -gt 1)
            {
                try
                {   
                    $NumberOfCustomAttributes = ($CustomAttributes.name.count)/2
                    $NewUser = $UserAdd | New-JCUser -NumberOfCustomAttributes $NumberOfCustomAttributes
                    $Status = 'User Created'

                    try #User is created
                    {
                        if ($UserAdd.SystemID) {

                            if ($UserAdd.Administrator) {

                                if ($UserAdd.Administrator -like "*True") {

                                    Write-Verbose "Admin set to true"

                                    try {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id -Administrator $true
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                }

                                elseif ($UserAdd.Administrator -like "*False") {

                                    Write-Verbose "Admin set to false"

                                    try {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id -Administrator $false
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                    
                                }
                                
                            }

                            else {
                                
                                Write-Verbose "No admin set"

                                try {
                                    $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id
                                    Write-Verbose  "$($SystemAdd.Status)"
                                    $SystemAddStatus = $SystemAdd.Status
                                }
                                catch {
                                    $SystemAddStatus = $_.ErrorDetails
                                }

                            }
                        }
                        $CustomGroupArrayList = New-Object System.Collections.ArrayList

                        $CustomGroups = $UserAdd | Get-Member -Name *Group* | Select-Object Name

                        foreach ($Group in $CustomGroups)
                        {
                            $GetGroup = [pscustomobject]@{
                            Type =  'GroupName'
                            Value =  $UserAdd.($Group.Name)
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

                                    'Group' = $Group.value
                                    'Status' = $GroupAdd.Status
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }

                            catch
                            {

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group' = $Group.value
                                    'Status' = $_.ErrorDetails
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }
                        }
                    }
                    catch
                    {

                    }

                    $FormattedResults =[PSCustomObject]@{

                    'Username' = $NewUser.username
                    'Status' = $Status
                    'UserID' = $NewUser._id
                    'GroupsAdd' = $UserGroupArrayList
                    'SystemID' = $UserAdd.SystemID
                    'SystemAdd' = $SystemAddStatus

                    }

                    

                }

                catch
                {

                    $Status = $_.ErrorDetails

                    $FormattedResults =[PSCustomObject]@{

                    'Username' = $NewUser.username
                    'Status' = $Status
                    'UserID' = $NewUser._id
                    'GroupsAdd' = $UserGroupArrayList
                    'SystemID' = $UserAdd.SystemID
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
                        if ($UserAdd.SystemID) {

                            if ($UserAdd.Administrator) {

                                Write-Verbose "Admin set"

                                if ($UserAdd.Administrator -like "*True") {

                                    Write-Verbose "Admin set to true"

                                    try {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id -Administrator $true
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                }

                                elseif ($UserAdd.Administrator -like "*False") {

                                    Write-Verbose "Admin set to false"

                                    try {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id -Administrator $false
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                    
                                }
                                    
                                
                            }

                            else {
                                
                                Write-Verbose "No admin set"

                                try {
                                    $SystemAdd = Add-JCSystemUser -SystemID $UserAdd.SystemID -UserID $NewUser._id
                                    Write-Verbose  "$($SystemAdd.Status)"
                                    $SystemAddStatus = $SystemAdd.Status
                                }
                                catch {
                                    $SystemAddStatus = $_.ErrorDetails
                                }

                            }
                        


                        }

                        $CustomGroupArrayList = New-Object System.Collections.ArrayList

                        $CustomGroups = $UserAdd | Get-Member -Name *Group* | Select-Object Name

                        foreach ($Group in $CustomGroups)
                        {
                            $GetGroup = [pscustomobject]@{
                            Type =  'GroupName'
                            Value =  $UserAdd.($Group.Name)
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

                                    'Group' = $Group.value
                                    'Status' = $GroupAdd.Status
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }

                            catch
                            {

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group' = $Group.value
                                    'Status' = $_.ErrorDetails
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }
                        }
                    }
                    catch
                    {

                    }

                    $FormattedResults =[PSCustomObject]@{

                    'Username' = $NewUser.username
                    'Status' = $Status
                    'UserID' = $NewUser._id
                    'GroupsAdd' = $UserGroupArrayList
                    'SystemID' = $UserAdd.SystemID
                    'SystemAdd' = $SystemAddStatus

                    }

                    


                }

                catch
                {

                    $Status = $_.ErrorDetails

                    $FormattedResults =[PSCustomObject]@{

                    'Username' = $NewUser.username
                    'Status' = $Status
                    'UserID' = $NewUser._id
                    'GroupsAdd' = $UserGroupArrayList
                    'SystemID' = $UserAdd.SystemID
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

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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

                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

            $deleteArray += $delete
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            $URI = "https://console.jumpcloud.com/api/commandresults/$CommandResultID"

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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
                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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

            $CommandResults = Invoke-RestMethod -Method POST -Uri $URL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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
        ParameterSetName ='Type',
        Position=0)]
        [ValidateSet('User','System')]
        [string]
        $Type
    )

    DynamicParam
    {

        If ($Type)
        {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter the group name"
            $attr.Mandatory = $false
            $attr.ValueFromPipelineByPropertyName = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('Name',[string],$attrColl)
            $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $dict.Add('Name',$param)
            return $dict
        }

    }    

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

            Write-Debug 'Initilizing resultsArray'
            $resultsArray = @()

            if ($param.IsSet) {
               
                if ($Type -eq 'System') {
                    
                    Write-Verbose 'Populating SystemGroupHash'
                    $SystemGroupHash = Get-Hash_SystemGroupName_ID
                    
                }
                elseif ($Type  -eq 'User') {

                    Write-Verbose 'Populating UserGroupHash'
                    $UserGroupHash = Get-Hash_UserGroupName_ID
                    
                }

            }

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

                    $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

                    $skip += $limit
                    Write-Debug "Setting skip to $skip"

                    $resultsArray += $results
                    $count = ($resultsArray.results).Count
                    Write-Debug "Results count equals $count"
                }

            }


            elseif (($PSCmdlet.ParameterSetName -eq 'Type') -and !($param.IsSet))
            {

                if ($type -eq 'User')
                {
                    $resultsArray = Get-JCGroup | Where-Object type -EQ 'user_group'

                }
                elseif ($type -eq 'System')
                {
                    $resultsArray = Get-JCGroup | Where-Object type -EQ 'system_group'

                }
            }

            elseif (($PSCmdlet.ParameterSetName -eq 'Type') -and ($param.IsSet))
            {
                if ($Type -eq 'System') {

                    $GID = $SystemGroupHash.Get_Item($param.Value)
                    $GURL = "https://console.jumpcloud.com/api/v2/systemgroups/$GID"
                    $result = Invoke-RestMethod -Method GET -Uri $GURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                    $resultsArray += $result    
                }
                elseif ($Type -eq 'User') {

                    $GID = $UserGroupHash.Get_Item($param.Value)
                    $GURL = "https://console.jumpcloud.com/api/v2/usergroups/$GID"
                    $result = Invoke-RestMethod -Method GET -Uri $GURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                    
                    $formattedResult = [PSCustomObject]@{

                        name = $result.name
                        ldapGroups = $result.attributes.ldapGroups
                        posixGroups = $result.attributes.posixGroups
                        id = $result.id
                        type = $result.type

                    }

                    $resultsArray += $formattedResult    
                    
                    
                }

            }

        }
    end
        {
           return $resultsArray

        }
}
Function Add-JCSystemGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByName',
        Position=0)]

        [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID',
        Position=0)]

        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByName')]

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID')]

        [Alias('_id','id')]
        [string]$SystemID,

        [Parameter(
        ParameterSetName ='ByID')]
        [Switch]
        $ByID,

        [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID')]
        [string]$GroupID
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
                if ($GroupNameHash.containsKey($GroupName)){}

                else { Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud user groups."}

                $GroupID = $GroupNameHash.Get_Item($GroupName)
                $HostName = $SystemHostNameHash.Get_Item($SystemID)

                $body =  @{

                    type = "system"
                    op = "add"
                    id = $SystemID

                }

                $jsonbody = $body | ConvertTo-Json
                Write-Debug $jsonbody


                $GroupsURL =  "https://console.jumpcloud.com/api/v2/systemgroups/$GroupID/members"
                Write-Debug $GroupsURL

                    try {
                        $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                        $Status = 'Added'
                    }
                    catch {
                        $Status = $_.ErrorDetails
                    }

                $FormattedResults =[PSCustomObject]@{

                    'Groupname' =  $GroupName
                    'System' = $HostName
                    'SystemID' = $SystemID
                    'Status' = $Status

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
    
                $body =  @{

                    type = "system"
                    op = "add"
                    id = $SystemID

                }

                $jsonbody = $body | ConvertTo-Json
                Write-Debug $jsonbody


                $GroupsURL =  "https://console.jumpcloud.com/api/v2/systemgroups/$GroupID/members"
                Write-Debug $GroupsURL

                try {
                    $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                    $Status = 'Added'
                }
                catch {
                    $Status = $_.ErrorDetails
                }

                $FormattedResults =[PSCustomObject]@{

                    'Group' =  $GroupID
                    'SystemID' = $SystemID
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
Function Add-JCUserGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName ='ByName')]

    param
    (
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByName',
        Position=0)]

        [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID',
        Position=0)]

        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByName',
        Position=1)]
        [String]$Username,

        [Parameter(
        ParameterSetName ='ByID')]
        [Switch]
        $ByID,

        [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID')]
        [string]$GroupID,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID')]
        [Alias('_id','id')]
        [string]$UserID

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

            Write-Debug 'Initilizing resultsArray'
            $resultsArray = @()

            if ($PSCmdlet.ParameterSetName -eq 'ByName')
            {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-Hash_UserGroupName_ID

                 Write-Debug 'Populating UserNameHash'
                $UserNameHash =  Get-Hash_UserName_ID
            }

        }

    process

        {

            if ($PSCmdlet.ParameterSetName -eq 'ByName')
            {
                if ($GroupNameHash.containsKey($GroupName)){}

                else { Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."}

                if ($UserNameHash.containsKey($Username)){}

                else { Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."}

                $GroupID = $GroupNameHash.Get_Item($GroupName)
                $UserID = $UserNameHash.Get_Item($Username)

                $body =  @{

                    type = "user"
                    op = "add"
                    id = $UserID

                }

                $jsonbody = $body | ConvertTo-Json
                Write-Debug $jsonbody


                $GroupsURL =  "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
                Write-Debug $GroupsURL

                try
                    {
                        $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                        $Status = 'Added'
                    }
                catch
                    {
                        $Status = $_.ErrorDetails
                    }

                $FormattedResults =[PSCustomObject]@{

                    'GroupName' =  $GroupName
                    'Username' = $Username
                    'UserID' = $UserID
                    'Status' = $Status

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

                $body =  @{

                    type = "user"
                    op = "add"
                    id = $UserID

                }

                $jsonbody = $body | ConvertTo-Json
                Write-Debug $jsonbody


                $GroupsURL =  "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
                Write-Debug $GroupsURL

                try {
                    $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                    $Status = 'Added'
                }
                catch {
                    $Status = $_.ErrorDetails
                }

                $FormattedResults =[PSCustomObject]@{

                    'Group' =  $GroupID
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
                        $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                        $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $NewGroup = Invoke-RestMethod -Method POST -Uri $URI  -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $NewGroup = Invoke-RestMethod -Method POST -Uri $URI  -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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

                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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
                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
        ParameterSetName ='ByName',
        Position=0)]

        [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID',
        Position=0)]

        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByName')]

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID')]

        [Alias('id','_id')]
        [string]$SystemID,

        [Parameter(
        ParameterSetName ='ByID')]
        [Switch]
        $ByID,

        [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID')]
        [string]$GroupID
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
                if ($GroupNameHash.containsKey($GroupName)){}

                else { Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud user groups."}

                $GroupID = $GroupNameHash.Get_Item($GroupName)
                $HostName = $SystemHostNameHash.Get_Item($SystemID)

                $body =  @{

                    type = "system"
                    op = "remove"
                    id = $SystemID

                }

                $jsonbody = $body | ConvertTo-Json
                Write-Debug $jsonbody


                $GroupsURL =  "https://console.jumpcloud.com/api/v2/systemgroups/$GroupID/members"
                Write-Debug $GroupsURL

                    try {
                        $GroupRemove = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                        $Status = 'Removed'
                    }
                    catch {
                        $Status = $_.ErrorDetails
                    }

                $FormattedResults =[PSCustomObject]@{

                    'Groupname' =  $GroupName
                    'System' = $HostName
                    'SystemID' = $SystemID
                    'Status' = $Status

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
                
                $body =  @{

                    type = "system"
                    op = "remove"
                    id = $SystemID

                }

                $jsonbody = $body | ConvertTo-Json
                Write-Debug $jsonbody


                $GroupsURL =  "https://console.jumpcloud.com/api/v2/systemgroups/$GroupID/members"
                Write-Debug $GroupsURL

                try {
                    $GroupRemove = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                    $Status = 'Removed'
                }
                catch {
                    $Status = $_.ErrorDetails
                }

                $FormattedResults =[PSCustomObject]@{

                    'Group' =  $GroupID
                    'SystemID' = $SystemID
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

                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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
                    $DeletedGroup = Invoke-RestMethod -Method DELETE -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
    [CmdletBinding(DefaultParameterSetName ='ByName')]

    param
    (
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByName',
        Position=0)]

        [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID',
        Position=0)]

        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByName',
        Position=1)]
        [String]$Username,

        [Parameter(
        ParameterSetName ='ByID')]
        [Switch]
        $ByID,

        [Parameter(
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID')]
        [string]$GroupID,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='ByID')]
        [Alias('_id','id')]
        [string]$UserID

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

            Write-Debug 'Initilizing resultsArray'
            $resultsArray = @()

            if ($PSCmdlet.ParameterSetName -eq 'ByName')
            {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-Hash_UserGroupName_ID
                Write-Debug 'Populating UserNameHash'
                $UserNameHash =  Get-Hash_UserName_ID
            }

        }

    process

        {

            if ($PSCmdlet.ParameterSetName -eq 'ByName')
            {
                if ($GroupNameHash.containsKey($GroupName)){}

                else { Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."}

                Write-Debug 'Populating UserNameHash'

                if ($UserNameHash.containsKey($Username)){}

                else { Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."}

                $GroupID = $GroupNameHash.Get_Item($GroupName)
                $UserID = $UserNameHash.Get_Item($Username)

                $body =  @{

                    type = "user"
                    op = "remove"
                    id = $UserID

                }

                $jsonbody = $body | ConvertTo-Json
                Write-Debug $jsonbody


                $GroupsURL =  "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
                Write-Debug $GroupsURL

                try
                    {
                        $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                        $Status = 'Removed'
                    }
                catch
                    {
                        $Status = $_.ErrorDetails
                    }

                $FormattedResults =[PSCustomObject]@{

                    'GroupName' =  $GroupName
                    'Username' = $Username
                    'UserID' = $UserID
                    'Status' = $Status

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

                $body =  @{

                    type = "user"
                    op = "remove"
                    id = $UserID

                }

                $jsonbody = $body | ConvertTo-Json
                Write-Debug $jsonbody


                $GroupsURL =  "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
                Write-Debug $GroupsURL

                try {
                    $GroupRemove = $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                    $Status = 'Removed'
                }
                catch {
                    $Status = $_.ErrorDetails
                }

                $FormattedResults =[PSCustomObject]@{

                    'GroupID' =  $GroupID
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

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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
                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                $resultsArray += $CommandResults

            }
        }

    }

    end

    {
        return $resultsArray
    }
}
function Get-JCSystemUser ()
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
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept' = 'application/json'
            'X-API-KEY' = $JCAPIKEY

        }

        [int]$limit = '100'
        Write-Verbose "Setting limit to $limit"

        Write-Verbose 'Initilizing resultsArrayList and resultsArray'
        $resultsArrayList = New-Object System.Collections.ArrayList
        $resultsArray = @()

        Write-Verbose 'Populating UserIDHash'
        $UserIDHash = Get-Hash_ID_Username

        Write-Verbose 'Populating SystemIDHash'
        $SystemIDHash = Get-Hash_SystemID_HostName

        Write-Verbose 'Populating DisplayNameHash'
        $DisplayNameHash = Get-Hash_SystemID_DisplayName

        Write-Verbose 'Populating SudoHash'
        $SudoHash = Get-Hash_ID_Sudo

    }

    process
    {
        Write-Verbose 'Setting skip to zero'
        [int]$skip = 0 #Do not change!

        while (($resultsArray.results).Count -ge $skip)
        {
            $URI = "https://console.jumpcloud.com/api/v2/systems/$SystemID/users?sort=type,_id&limit=$limit&skip=$skip"

            Write-Verbose $URI

            $APIresults = Invoke-RestMethod -Method GET -Uri $URI -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

            $skip += $limit
            Write-Verbose "Setting skip to $skip"

            $resultsArray += $APIresults

            $count = ($resultsArray).Count
            Write-Verbose "Results count equals $count"
        }


        $Hostname = $SystemIDHash.Get_Item($SystemID)
        $DisplayName = $DisplayNameHash.Get_Item($SystemID)

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

            if ($result.compiledAttributes.sudo.enabled -eq $true){

                $Admin = $true
            }
            else {

                $Sudo = $SudoHash.Get_Item($UserID)

                if ($Sudo -eq $true) {

                    $Admin = $true
                    
                }

                else {
                    $Admin = $false 
                }

            }

            $SystemUser = [pscustomobject]@{
                'DisplayName' = $DisplayName
                'HostName' = $Hostname
                'SystemID' = $SystemID
                'Username' = $Username
                'Administrator' = $Admin
                'DirectBind' = $DirectBind
                'BindGroups' = @($Groups)
            }

            $resultsArrayList.Add($SystemUser) | Out-Null

        }

        $resultsArray = $null

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
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
        $SystemID,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 2)]

        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]
        [bool]
        $Administrator = $false

    )

    begin

    {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Verbose 'Initilizing SystemUpdateArray'
        $SystemUpdateArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Verbose $PSCmdlet.ParameterSetName

            Write-Verbose 'Populating HostNameHash'
            $HostNameHash = Get-Hash_SystemID_HostName

            Write-Verbose 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

        Write-Verbose 'Populating SudoHash'
        $SudoHash = Get-Hash_ID_Sudo

        Write-Verbose $PSCmdlet.ParameterSetName
    }

    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($HostNameHash.containsKey($SystemID)) {}

            else { Throw "SystemID does not exist. Run 'Get-JCsystem | select Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."}

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."}

            $UserID = $UserNameHash.Get_Item($Username)

            $HostName = $HostNameHash.Get_Item($SystemID)

            $GlobalAdmin = $SudoHash.Get_Item($UserID)

            if ($GlobalAdmin -eq $true)
            {
                $Administrator = $true           
            }

            if ($Administrator -eq $true)
            {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $true
                            withoutPassword = $false
                    
                        }
                    }
                }

            }

            else
            {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = $null
    
                }

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL


            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                $Status = 'Added'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'        = $HostName
                'SystemID'      = $SystemID
                'Username'      = $Username
                'Status'        = $Status
                'Administrator' = $Administrator
            }


            $SystemUpdateArray += $FormattedResults

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')
        {

            $GlobalAdmin = $SudoHash.Get_Item($UserID)

            if ($GlobalAdmin -eq $true)
            {
                $Administrator = $true        
            }

            if ($Administrator -eq $true)
            {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $true
                            withoutPassword = $false
                    
                        }
                    }
                }

            }

            else
            {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = $null
    
                }

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                'Administrator' = $Administrator
            }   

            $SystemUpdateArray += $FormattedResults
        }
    }

    end

    {
        return $SystemUpdateArray
    }

}
Function Set-JCSystemUser ()
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
        $SystemID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 2)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]

        [bool]
        $Administrator

    )

    begin

    {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        Write-Verbose 'Initilizing SystemUpdateArray'
        $SystemUpdateArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Verbose $PSCmdlet.ParameterSetName

            Write-Verbose 'Populating HostNameHash'
            $HostNameHash = Get-Hash_SystemID_HostName
            Write-Verbose 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

        Write-Verbose $PSCmdlet.ParameterSetName
    }

    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($HostNameHash.containsKey($SystemID)) {}

            else { Throw "SystemID does not exist. Run 'Get-JCsystem | select Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."}

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."}

            $UserID = $UserNameHash.Get_Item($Username)
            $HostName = $HostNameHash.Get_Item($SystemID)

            if ($Administrator -eq $true)
            {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $true
                            withoutPassword = $false
                    
                        }
                    }
    
                }
                    
            }

            elseif ($Administrator -eq $false)
            {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $false
                            withoutPassword = $false
                    
                        }
                    }
    
                }
                    
                    
            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"

            Write-Verbose $URL


            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                $Status = 'Updated'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'        = $HostName
                'SystemID'      = $SystemID
                'Username'      = $Username
                'Status'        = $Status
                'Administrator' = $Administrator
            }


            $SystemUpdateArray += $FormattedResults

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')
        {
            if ($Administrator -eq $true)
            {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $true
                            withoutPassword = $false
                    
                        }
                    }
    
                }
                    
            }

            elseif ($Administrator -eq $false)
            {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $false
                            withoutPassword = $false
                    
                        }
                    }
    
                }
                    
                    
            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                $Status = 'Updated'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'SystemID'      = $SystemID
                'UserID'        = $UserID
                'Status'        = $Status
                'Administrator' = $Administrator
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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

        $System = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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
        ParameterSetName ='Username',
        Position=0)]
        [String]$Username,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='FirstName'
        )]
        [String]$FirstName,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='LastName'
        )]
        [String]$LastName,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='Email'
        )]
        [String]$Email,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName ='UserID')]
        [Alias('_id','id')]
        [String]$UserID


    )

    begin

        {
            Write-Verbose 'Verifying JCAPI Key'
            if ($JCAPIKEY.length -ne 40) {Connect-JConline}

            Write-Verbose 'Populating API headers'
            $hdrs = @{

                'Content-Type' = 'application/json'
                'Accept' = 'application/json'
                'X-API-KEY' = $JCAPIKEY

            }

            [int]$limit = '1000'
            Write-Verbose "Setting limit to $limit"

            Write-Verbose 'Initilizing resultsArray'
            $resultsArray = @()

        }

    process

        {

            switch ($PSCmdlet.ParameterSetName) {

                ReturnAll { 

                    [int]$skip = 0 #Do not change!
                    Write-Verbose "Setting skip to $skip"
    
                    while (($resultsArray).Count -ge $skip)
    
                    {
                        $limitURL = "https://console.jumpcloud.com/api/Systemusers?sort=type,_id&limit=$limit&skip=$skip"
                        Write-Verbose $limitURL
    
                        $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
    
                        $skip += $limit
                        Write-Verbose "Setting skip to $skip"
    
                        $resultsArray += $results.results
    
                        $count = ($resultsArray).Count
                        Write-Verbose "Results count equals $count"
                    }

                }

                UserID {

                    $URL = "https://console.jumpcloud.com/api/Systemusers/$UserID"
                    Write-Verbose $URL
                    $results = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                    $resultsArray += $results

                } 

                Username {

                    [int]$skip = 0 #Do not change!
                    Write-Verbose "Setting skip to $skip"
    
                    while (($resultsArray).Count -ge $skip)
    
                    {
                        $UserNameSearch = "https://console.jumpcloud.com/api/systemusers?skip=$skip&limit=$limit&sort=lastname&search%5Bfields%5D%5B%5D=username&search%5BsearchTerm%5D=$Username"
                        Write-Verbose $UserNameSearch
    
                        $results = Invoke-RestMethod -Method GET -Uri $UserNameSearch -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
    
                        $skip += $limit
                        Write-Verbose "Setting skip to $skip"
    
                        $resultsArray += $results.results
    
                        $count = ($resultsArray).Count
                        Write-Verbose "Results count equals $count"
                    }

                }


                Firstname {

                    [int]$skip = 0 #Do not change!
                    Write-Verbose "Setting skip to $skip"
                
                    while (($resultsArray).Count -ge $skip)
                
                    {
                        $FirstnameSearch = "https://console.jumpcloud.com/api/systemusers?skip=$skip&limit=$limit&sort=lastname&search%5Bfields%5D%5B%5D=firstname&search%5BsearchTerm%5D=$Firstname"

                        Write-Verbose $FirstnameSearch
                
                        $results = Invoke-RestMethod -Method GET -Uri $FirstnameSearch -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                
                        $skip += $limit
                        Write-Verbose "Setting skip to $skip"
                
                        $resultsArray += $results.results
                
                        $count = ($resultsArray).Count
                        Write-Verbose "Results count equals $count"
                    }
                
                }

                LastName {

                    [int]$skip = 0 #Do not change!
                    Write-Verbose "Setting skip to $skip"
                
                    while (($resultsArray).Count -ge $skip)
                
                    {
                        $LastNameSearch = "https://console.jumpcloud.com/api/systemusers?skip=$skip&limit=$limit&sort=lastname&search%5Bfields%5D%5B%5D=lastname&search%5BsearchTerm%5D=$LastName"
                        Write-Verbose $LastNameSearch
                
                        $results = Invoke-RestMethod -Method GET -Uri $LastNameSearch -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                
                        $skip += $limit
                        Write-Verbose "Setting skip to $skip"
                
                        $resultsArray += $results.results
                
                        $count = ($resultsArray).Count
                        Write-Verbose "Results count equals $count"
                    }
                
                }

                Email {

                    [int]$skip = 0 #Do not change!
                    Write-Verbose "Setting skip to $skip"
                
                    while (($resultsArray).Count -ge $skip)
                
                    {
                        $EmailSearch = "https://console.jumpcloud.com/api/systemusers?skip=$skip&limit=$limit&sort=lastname&search%5Bfields%5D%5B%5D=email&search%5BsearchTerm%5D=$Email"
                        Write-Verbose $EmailSearch
                
                        $results = Invoke-RestMethod -Method GET -Uri $EmailSearch -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
                
                        $skip += $limit
                        Write-Verbose "Setting skip to $skip"
                
                        $resultsArray += $results.results
                
                        $count = ($resultsArray).Count
                        Write-Verbose "Results count equals $count"
                    }
                
                }

                Default {}
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

            $NewUserInfo = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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

            $NewUserInfo = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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
                    $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.2.0'
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

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

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

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

            $UpdatedUserArray += $NewUserInfo


        }

    }

    end
    {
        return $UpdatedUserArray

    }

}

Function Remove-JCCommand () #Ready for pester
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(
        ParameterSetName = 'warn',
        Mandatory,
        ValueFromPipelineByPropertyName,
        Position=0
        )]

        [Parameter(
        ParameterSetName = 'force',
        Mandatory,
        ValueFromPipelineByPropertyName,
        Position=0
        )]
        [Alias('_id','id')]
        [String] $CommandID,

        [Parameter(
        ParameterSetName ='force')]
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
            'Accept' = 'application/json'
            'X-API-KEY' = $JCAPIKEY

            }

            $deletedArray= @()
            $CommandNameHash = Get-Hash_ID_CommandName

        }
    process

        {
            if ($PSCmdlet.ParameterSetName -eq 'warn')

            {
                $CommandName = $CommandNameHash.Get_Item($CommandID)
                Write-Warning "Are you sure you want to remove command: $CommandName ?" -WarningAction Inquire

                try
                {

                    $URI = "https://console.jumpcloud.com/api/commands/$CommandID"
                    $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                    $Status = 'Deleted'
                }
                catch
                {
                    $Status = $_.ErrorDetails
                }


                $FormattedResults = [PSCustomObject]@{
                        'Name' = $CommandName 
                        'CommandID' = $CommandID
                        'Results' = $Status
                }

                $deletedArray += $FormattedResults

            }

            elseif ($PSCmdlet.ParameterSetName -eq 'force') {

            try
                {
                    $CommandName = $CommandNameHash.Get_Item($CommandID)

                    $URI = "https://console.jumpcloud.com/api/commands/$CommandID"
                    $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                    $Status = 'Deleted'
                }
                catch
                {
                    $Status = $_.ErrorDetails
                }


                $FormattedResults = [PSCustomObject]@{
                    'Name' = $CommandName 
                    'CommandID' = $CommandID
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

Function New-JCCommand {
    [CmdletBinding()]

    param (
        
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName=$True)]
        [string]
        $name,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName=$True)]
        [string]
        [ValidateSet('windows','mac','linux')]
        $commandType,

        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName=$True)]
        [string]
        $command,

        [Parameter(
        ValueFromPipelineByPropertyName=$True)]
        [string]
        [ValidateSet('trigger','manual','repeated','one-time')]
        $launchType = 'manual', 
        
        [Parameter(
        ValueFromPipelineByPropertyName=$True)]
        [string]
        $timeout = '120'

    )
    
    DynamicParam {

        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        If ($commandType -eq "windows") {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter shell type"
            $attr.ValueFromPipelineByPropertyName = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $attrColl.Add((New-Object System.Management.Automation.ValidateSetAttribute('powershell','cmd')))
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('shell',[string],$attrColl)
            $dict.Add('shell',$param)
                    
        }

        If ($commandType -ne "windows") {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter run as user"
            $attr.ValueFromPipelineByPropertyName = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('user',[string],$attrColl)
            $dict.Add('user',$param)
                    
        }

        If ($launchType -eq "trigger") {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter a trigger name. Triggers must be unique"
            $attr.ValueFromPipelineByPropertyName = $true
            $attr.Mandatory = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('trigger',[string],$attrColl)
            $dict.Add('trigger',$param)
              
        }

        If ($launchType -eq "repeated") {

            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter the schedule in crontab notation"
            $attr.ValueFromPipelineByPropertyName = $true
            $attr.Mandatory = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('schedule',[string],$attrColl)
            $dict.Add('schedule',$param)

            $attr1 = New-Object System.Management.Automation.ParameterAttribute
            $attr1.HelpMessage = "Enter the scheduleRepeatType"
            $attr1.Mandatory = $true
            $attr1.ValueFromPipelineByPropertyName = $true
            $attrColl1 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl1.Add($attr1)
            $param1 = New-Object System.Management.Automation.RuntimeDefinedParameter("scheduleRepeatType",[string],$attrColl1)
            $dict.Add("scheduleRepeatType",$param1)
                   
        }

        If ($launchType -eq "one-time") {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter the schedule in crontab notation"
            $attr.ValueFromPipelineByPropertyName = $true
            $attr.Mandatory = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('schedule',[string],$attrColl)
            $dict.Add('schedule',$param)

            $attr1 = New-Object System.Management.Automation.ParameterAttribute
            $attr1.HelpMessage = "Enter the scheduleRepeatType"
            $attr1.Mandatory = $true
            $attr1.ValueFromPipelineByPropertyName = $true
            $attrColl1 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl1.Add($attr1)
            $param1 = New-Object System.Management.Automation.RuntimeDefinedParameter("scheduleRepeatType",[string],$attrColl1)
            $dict.Add("scheduleRepeatType",$param1)
        }

        return $dict 
        
    }

    begin {

        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept' = 'application/json'
            'X-API-KEY' = $JCAPIKEY
        }

        $URL = "https://console.jumpcloud.com/api/commands/"

        Write-Verbose 'Initilizing NewCommandsArray'
        $NewCommandsArray = @()

    }
    
    process {

        Write-Verbose "commandType is $CommandType"

        switch ($commandType) {
            mac {

                if ($PSBoundParameters["user"] -eq $null)
                {
                    $PSBoundParameters["user"] = "000000000000000000000000"
                }

                $body = @{

                    name = $name
                    command = $command
                    commandType = "mac"
                    launchType = $launchType
                    timeout = $timeout
                    user = $PSBoundParameters["user"]
                }
              
            }

            windows{

                if ($PSBoundParameters["shell"] -eq $null)
                {
                    $PSBoundParameters["shell"] = "powershell"`
                }

                $body = @{

                    command = $command
                    commandType = "windows"
                    launchType = $launchType
                    name = $name
                    timeout = $timeout
                    shell = $PSBoundParameters["shell"]
                }
               
            }

            linux{

                if ($PSBoundParameters["user"] -eq $null)
                {
                    $PSBoundParameters["user"] = "000000000000000000000000"
                }

                $body = @{

                    command = $command
                    commandType = "linux"
                    launchType = $launchType
                    name = $name
                    timeout = $timeout
                    user = $PSBoundParameters["user"]
                }
               
            }

            Default {
                Write-Host 'No Command Type'
                break
            }
        }


        if ($PSBoundParameters['launchType'] -eq 'trigger'){

            $body.Add('trigger',$PSBoundParameters['trigger'])

        }

        if (($PSBoundParameters['launchType'] -eq 'one-time') -or ($PSBoundParameters['launchType'] -eq 'repeated') ) {

            Write-Debug $PSBoundParameters['launchType']

        }

        $jsonbody = $body | ConvertTo-Json

        $NewCommand = Invoke-RestMethod -Uri $URL -Method POST -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.2.0'

        $NewCommandsArray += $NewCommand

    }
    
    end {

        Return $NewCommandsArray

    }
}

Function Import-JCCommand {
    [CmdletBinding(DefaultParameterSetName ='URL')]
    param (

        [Parameter(
        ParameterSetName = 'URL',
        Mandatory,
        Position=0,
        ValueFromPipelineByPropertyName=$True)]
        [string]
        [ValidateScript({
            If (Invoke-Webrequest $_ -UseBasicParsing) {
                $True
                }
                else {
                Throw "You are either offline or $_ is not a URL. Enter a URL"
                }
        })]
        $URL

    )
    
    begin { 

       
        $NewCommandsArray = @() #Output new commands
        
    }
    
    process 
    {

        if ($PSCmdlet.ParameterSetName -eq 'URL') {

            $NewCommand = New-JCCommandFromURL -GitHubURL $URL
            
            $NewCommandsArray += $NewCommand
        }

    } #End process
        
    end {

        Return $NewCommandsArray
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

Function Get-Hash_ID_Sudo()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser

        foreach ($User in $Users)
        {
            $UsersHash.Add($User._id, $User.sudo)

        }
    return $UsersHash
}

Function Get-Hash_SystemID_DisplayName ()
{

    $SystemsHash =  New-Object System.Collections.Hashtable

    $Systems = Get-JCsystem

        foreach ($System in $Systems)
        {
            $SystemsHash.Add($System._id, $System.DisplayName)

        }
    return $SystemsHash
}

Function Get-Hash_ID_CommandName()
{

    $CommandHash = New-Object System.Collections.Hashtable

    $Commands = Get-JCCommand

        foreach ($Command in $Commands)
        {
            $CommandHash.Add($Command._id, $Command.name)

        }
    return $CommandHash
}

Function New-JCCommandFromURL {
    [CmdletBinding()]
    param (

    [Parameter(
    Mandatory,
    ValueFromPipelineByPropertyName=$True)]
    [string]
    [alias("URL")]
    $GitHubURL
        
    )
    
    begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    }
    
    process {

        $Command = Invoke-WebRequest -Uri $GitHubURL -UseBasicParsing | Select-Object RawContent

        $CodeRaw = (($Command -split '<code>')[1] -split '</code>')[0] # Contain XML escape characters

        $Code = (((((($CodeRaw -replace "&amp;","&") -replace "&lt;", "<") -replace "&gt;", ">") -replace "&quot;",'"') -Replace "&apos;","'") -replace "`n","")  # Replace XML character references

        $Name = (((((($Command -split 'Name</h4>')[1]) -replace "`n","") -split '</p>')[0]) -replace '<p>', '')

        $commandType = (((($Command -split 'commandType</h4>')[1] -replace "`n", "") -split '</p>')[0] -replace "<p>", "") 

        $NewCommandParams = @{

            name = $Name
            commandType = $commandType
            command = $code 
        }

        Write-Verbose $NewCommandParams
    
        try{

            $NewCommand = New-JCCommand @NewCommandParams

        }


        catch{

            $NewCommand = $_.ErrorDetails

        }
    }
    
    end {

        Return $NewCommand

    }
}

Export-ModuleMember -Function Connect-JCOnline, Get-JCCommandResult, Remove-JCCommandResult, Invoke-JCCommand, Get-JCCommand, Remove-JCUserGroupMember, Remove-JCUserGroup, Remove-JCSystemGroupMember, Remove-JCSystemGroup, New-JCUserGroup, New-JCSystemGroup, Add-JCSystemGroupMember, Get-JCSystemGroupMember, Get-JCGroup, Add-JCUserGroupMember, Get-JCUserGroupMember, Set-JCSystem, Get-JCSystemUser, Remove-JCSystem, Get-JCSystem, Remove-JCSystemUser, Add-JCSystemUser, Set-JCSystemUser, Get-JCUser, New-JCUser, Remove-JCUser, Set-JCUser, Import-JCUsersFromCSV, New-JCImportTemplate, Remove-JCCommand, New-JCCommand, Import-JCCommand
