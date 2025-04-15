Function Set-JCUser () {

    [CmdletBinding(DefaultParameterSetName = 'Username')]
    param
    (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Username',
            Position = 0, HelpMessage = 'The Username of the JumpCloud user you wish to modify')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'RemoveCustomAttribute', HelpMessage = 'The Custom Attribute of the JumpCloud user you wish to modify')]
        [string]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID', HelpMessage = 'The _id of the User which you want to modify.
To find a JumpCloud UserID run the command:
PS C:\> Get-JCUser | Select username, _id
The UserID will be the 24 character string populated for the _id field.
UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCUser function before calling Add-JCUserGroupMember. This is shown in EXAMPLES 3, 4, and 5.
')]

        [Alias('_id', 'id')]
        [string]$UserID,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The email address for the user. This must be a unique value.')]
        [string]
        $email,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The first name of the user')]
        [string]
        $firstname,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The last name of the user')]
        [string]
        $lastname,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The password for the user')]
        [string]
        $password,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value for enabling password_never_expires')]
        [bool]
        $password_never_expires,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value for allowing pubic key authentication')]
        [bool]
        $allow_public_key,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value if you want to enable the user to be an administrator on any and all systems the user is bound to.')]
        [bool]
        $sudo,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value for enabling managed uid')]
        [bool]
        $enable_managed_uid,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The unix_uid for the user. Note this value must be an number.')]
        [int]
        [ValidateRange(0, 4294967295)]
        $unix_uid,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The unix_guid for the user. Note this value must be a number.')]
        [int]
        [ValidateRange(0, 4294967295)]
        $unix_guid,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'unlock or lock a users JumpCloud account')]
        [bool]
        $account_locked,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value if you want to enable passwordless_sudo')]
        [bool]
        $passwordless_sudo,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value for enabling externally_managed')]
        [bool]
        $externally_managed,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to enable the user as an LDAP binding user')]
        [bool]
        $ldap_binding_user,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value for enabling MFA at the user portal')]
        [bool]
        $enable_user_portal_multifactor,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'If you intend to update a user with existing Custom Attributes or add new Custom Attributes you must declare how many Custom Attributes you intend to update or add. If an Custom Attribute exists with a name that matches the new attribute then the existing attribute will be updated. Based on the NumberOfCustomAttributes value two Dynamic Parameters will be created for each Custom Attribute: Attribute_name and Attribute_value with an associated number. See an example for working with Custom Attribute in EXAMPLE 4')]
        [int]
        $NumberOfCustomAttributes,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RemoveCustomAttribute', HelpMessage = 'The name of the existing Custom Attributes you wish to remove. See an EXAMPLE for working with the -RemoveCustomAttribute Parameter in EXAMPLE 5')]
        [string[]]
        [Alias('RemoveAttribute')]
        $RemoveCustomAttribute,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID', HelpMessage = 'Use the -ByID parameter when the UserID is being passed over the pipeline to the Set-JCUser function. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which will increase the function speed and performance. You cannot use this with the ''RemoveCustomAttribute'' Parameter')]
        [switch]
        $ByID,

        # New attributes as of 1.8.0 release
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home location. The LDAP displayName of this property is initials.')]
        [string]
        $middlename,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s preferredName. The LDAP displayName of this property is displayName.')]
        [string]
        [Alias('preferredName')]
        $displayname,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s job title. The LDAP displayName of this property is title.')]
        [string]
        $jobTitle,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s employeeIdentifier. The LDAP displayName of this property is employeeNumber. Note this field must be unique per user.')]
        [string]
        $employeeIdentifier,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s department. The LDAP displayName of this property is departmentNumber.')]
        [string]
        $department,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s costCenter. The LDAP displayName of this property is businessCategory.')]
        [string]
        $costCenter,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s company. The LDAP displayName of this property is company.')]
        [string]
        $company,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s employeeType. The LDAP displayName of this property is employeeType.')]
        [string]
        $employeeType,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s description. The LDAP displayName of this property is description. This field is limited to 1024 characters.')]
        [string]
        [ValidateLength(0, 1024)]
        $description,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home location. The LDAP displayName of this property is physicalDeliveryOfficeName.')]
        [string]
        $location,

        #Objects

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s streetAddress on their work address object. This property is nested within the LDAP property with the displayName postalAddress.')]
        [string]
        $work_streetAddress,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s poBox on their work address object. The LDAP displayName of this property is postOfficeBox.')]
        [string]
        $work_poBox,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s city on their work address object. The LDAP displayName of this property is l.')]
        [string]
        [Alias('work_city')]
        $work_locality,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s state on their work address object. This property is nested within the LDAP property with the displayName postalAddress.')]
        [string]
        [Alias('work_state')]
        $work_region,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s postalCode on their work address object. The LDAP displayName of this property is postalCode.')]
        [string]
        $work_postalCode,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s country on the work address object. This property is nested within the LDAP property with the displayName postalAddress.')]
        [string]
        $work_country,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s streetAddress on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]
        $home_streetAddress,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s poBox on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]
        $home_poBox,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s city on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]
        [Alias('home_city')]
        $home_locality,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s state on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]
        [Alias('home_state')]
        $home_region,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s postalCode on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]
        $home_postalCode,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s country on the home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]
        $home_country,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s mobile number. The LDAP displayName of this property is mobile.')]
        [string]
        $mobile_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home number. The LDAP displayName of this property is homePhone.')]
        [string]
        $home_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work number. The LDAP displayName of this property is telephoneNumber.')]
        [string]
        $work_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work mobile number. The LDAP displayName of this property is pager.')]
        [string]
        $work_mobile_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work fax number. The LDAP displayName of this property is facsimileTelephoneNumber.')]
        [string]
        $work_fax_number,

        # New attributes as of 1.12.0 release

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The distinguished name of the AD domain (ADB Externally managed users only)')]
        [string]
        $external_dn,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The externally managed user source type (ADB Externally managed users only)')]
        [string]
        $external_source_type,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A string value for putting the account into an activated or suspended state')]
        [ValidateSet('ACTIVATED', 'SUSPENDED')]
        [string]
        $state,

        [Parameter(DontShow, ValueFromPipelineByPropertyName = $False, HelpMessage = 'A boolean $true/$false value for putting the account into a suspended state')]
        [nullable[bool]]
        $suspended,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The manager username, ID or primary email of the JumpCloud manager user; must be a valid user')]
        $manager,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The managedAppleId for the user')]
        [string]
        $managedAppleId,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The alternateEmail for the user')]
        [string]
        $alternateEmail,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The recoveryEmail for the user')]
        [string]$recoveryEmail

    )

    DynamicParam {
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        If ((Get-PSCallStack).Command -like '*MarkdownHelp') {
            $enable_user_portal_multifactor = $true
            $NumberOfCustomAttributes = 2
        }
        If ($enable_user_portal_multifactor -eq $True) {
            # Set the dynamic parameters' name
            $ParamName = 'EnrollmentDays'
            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.HelpMessage = 'Number of days to allow for MFA enrollment.'
            # Generate and set the ValidateSet
            $ValidateRangeAttribute = New-Object System.Management.Automation.ValidateRangeAttribute(1, 365)
            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateRangeAttribute)
            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)
            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName, [Int32], $AttributeCollection)
            $dict.Add($ParamName, $RuntimeParameter)

        }

        If ($NumberOfCustomAttributes) {

            [int]$NewParams = 0
            [int]$ParamNumber = 1

            while ($NewParams -ne $NumberOfCustomAttributes) {

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


        }

        return $dict
    }

    begin {
        Write-Debug "Parameter set $($PSCmdlet.ParameterSetName)"

        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        $UpdatedUserArray = @()

        if ($PSCmdlet.ParameterSetName -ne 'ByID') {
            $UserHash = Get-DynamicHash -Object User -returnProperties username
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }
        $ObjectParams = @{ }
        $ObjectParams.Add("work_streetAddress", "addresses")
        $ObjectParams.Add("work_poBox", "addresses")
        $ObjectParams.Add("work_locality", "addresses")
        $ObjectParams.Add("work_region", "addresses")
        $ObjectParams.Add("work_postalCode", "addresses")
        $ObjectParams.Add("work_country", "addresses")
        $ObjectParams.Add("home_poBox", "addresses")
        $ObjectParams.Add("home_locality", "addresses")
        $ObjectParams.Add("home_region", "addresses")
        $ObjectParams.Add("home_postalCode", "addresses")
        $ObjectParams.Add("home_country", "addresses")
        $ObjectParams.Add("home_streetAddress", "addresses")
        $ObjectParams.Add("mobile_number", "phoneNumbers")
        $ObjectParams.Add("home_number", "phoneNumbers")
        $ObjectParams.Add("work_number", "phoneNumbers")
        $ObjectParams.Add("work_mobile_number", "phoneNumbers")
        $ObjectParams.Add("work_fax_number", "phoneNumbers")

        if ($PSCmdlet.ParameterSetName -eq 'ByID') {
            $URL_ID = $UserID
        }

        # Convert recoveryEmail to an object
        if ($recoveryEmail) {
            $recoveryEmailAddress = @{
                'address' = $recoveryEmail
            }
            $PSBoundParameters['recoveryEmail'] = $recoveryEmailAddress
        }
    }


    process {
        $body = @{ }

        if ($PSCmdlet.ParameterSetName -ne 'ByID') {
            if ($UserHash.Values.username -contains ($Username)) {
                $URL_ID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
                Write-Debug $URL_ID
            }

            else {
                Throw "$Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."
            }

        }

        $UpdateParms = $PSBoundParameters.GetEnumerator() | Select-Object Key
        $UpdateObjectParams = @{ }

        foreach ($param in $UpdateParms) {

            if ($ObjectParams.ContainsKey($param.key)) {
                $UpdateObjectParams.Add($param.key, $ObjectParams.($param.key))
            }

        }

        if ($UpdateObjectParams.Count -gt 0) {
            $objectCheck = $UpdateObjectParams.Values | Select-Object -Unique

            $UserObjectCheck = Get-JCUser -userid $URL_ID

            if ($objectCheck.contains("phoneNumbers")) {
                $phoneNumbers = @()

                $UpdatedNumbers = @{ }

                foreach ($param in $PSBoundParameters.GetEnumerator()) {

                    if ($param.Key -like '*_number') {
                        $Number = @{ }
                        $Number.Add("type", ($($param.Key -replace "_number", "")))
                        $Number.Add("number", $param.Value)
                        $UpdatedNumbers.Add(($($param.Key -replace "_number", "")), $param.Value)
                        $phoneNumbers += $Number
                        continue
                    }

                }

                foreach ($ExitingNumber in $UserObjectCheck.phoneNumbers) {
                    if ($UpdatedNumbers.ContainsKey($ExitingNumber.type)) {
                        Continue
                    } else {
                        $Number = @{ }
                        if ($ExitingNumber.number) {
                            $Number.Add("type", $ExitingNumber.type )
                            $Number.Add("number", $ExitingNumber.number)
                            $phoneNumbers += $Number

                        }

                    }
                }

                $body.Add('phoneNumbers', $phoneNumbers)
            }

            if ($objectCheck.contains("addresses")) {
                $Addresses = @()

                $WorkAddressParams = @{ }
                $WorkAddressParams.Add("type", "work")

                $HomeAddressParams = @{ }
                $HomeAddressParams.Add("type", "home")

                foreach ($param in $PSBoundParameters.GetEnumerator()) {
                    if ($param.Key -like '*_number') {
                        continue
                    }

                    if ($param.Key -like 'work_*') {
                        $WorkAddressParams.Add(($($param.Key -split "_", 2)[1]), $param.Value)
                        continue
                    }

                    if ($param.Key -like 'home_*') {
                        $HomeAddressParams.Add(($($param.Key -split "_", 2)[1]), $param.Value)
                        continue
                    }

                }


                $ExistingWorkParams = $UserObjectCheck.addresses | Where-Object Type -EQ "Work"

                $ExistingWorkHash = @{ }
                $ExistingWorkHash.Add("country", $ExistingWorkParams.country)
                $ExistingWorkHash.Add("locality", $ExistingWorkParams.locality)
                $ExistingWorkHash.Add("poBox", $ExistingWorkParams.poBox)
                $ExistingWorkHash.Add("postalCode", $ExistingWorkParams.postalCode)
                $ExistingWorkHash.Add("region", $ExistingWorkParams.region)
                $ExistingWorkHash.Add("streetAddress", $ExistingWorkParams.streetAddress)


                foreach ($WorkParam in $ExistingWorkHash.GetEnumerator()) {

                    if ($WorkAddressParams.ContainsKey($WorkParam.key)) {
                        Continue
                    }

                    else {
                        if ($WorkParam.value) {
                            $WorkAddressParams.Add($WorkParam.key, $WorkParam.value)
                        }

                    }
                }


                $Addresses += $WorkAddressParams



                $ExistingHomeParams = $UserObjectCheck.addresses | Where-Object Type -EQ "Home"

                $ExistingHomeHash = @{ }
                $ExistingHomeHash.Add("country", $ExistingHomeParams.country)
                $ExistingHomeHash.Add("locality", $ExistingHomeParams.locality)
                $ExistingHomeHash.Add("poBox", $ExistingHomeParams.poBox)
                $ExistingHomeHash.Add("postalCode", $ExistingHomeParams.postalCode)
                $ExistingHomeHash.Add("region", $ExistingHomeParams.region)
                $ExistingHomeHash.Add("streetAddress", $ExistingHomeParams.streetAddress)

                foreach ($HomeParam in $ExistingHomeHash.GetEnumerator()) {

                    if ($HomeAddressParams.ContainsKey($HomeParam.key)) {
                        Continue
                    }

                    else {
                        if ($HomeParam.value) {
                            $HomeAddressParams.Add($HomeParam.key, $HomeParam.value)
                        }
                    }
                }

                $Addresses += $HomeAddressParams


                $body.Add('addresses', $Addresses)
            }

        }
        if ($PSCmdlet.ParameterSetName -eq 'Username' -and !$NumberOfCustomAttributes) {
            if ($UserHash.Values.username -contains ($Username)) {
                $URL_ID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
                Write-Debug $URL_ID

                $URL = "$JCUrlBasePath/api/Systemusers/$URL_ID"
                Write-Debug $URL

                foreach ($param in $PSBoundParameters.GetEnumerator()) {

                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) {
                        continue
                    }

                    if ($param.key -in ('Username', 'EnrollmentDays')) {
                        continue
                    }

                    if ($param.Key -like '*_number') {
                        continue
                    }

                    if ($param.Key -like 'work_*') {
                        continue
                    }

                    if ($param.Key -like 'home_*') {
                        continue
                    }

                    # Get the manager using manager username instead of userId
                    if ("manager" -eq $param.Key) {
                        if ([System.String]::isNullOrEmpty($param.value)) {
                            $managerValue = $null
                        } else {
                            # First check if manager returns valid user with id
                            # Regex match a userid
                            $regexPattern = [Regex]'^[a-z0-9]{24}$'
                            if (((Select-String -InputObject $param.Value -Pattern $regexPattern).Matches.value)::IsNullOrEmpty) {
                                # if we have a 24 characterid, try to match the id using the search endpoint
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'id' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'id'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue; this is a validated user id
                                $managerValue = $managerResults.id
                                # if no value was returned, then assume the case this is actually a username and search
                                if (!$managerValue) {
                                    $managerSearch = @{
                                        filter = @{
                                            'and' = @(
                                                @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                            )
                                        }
                                        fields = 'username'
                                    }
                                    $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                    # Set managerValue from the matched username
                                    $managerValue = $managerResults.id
                                }
                            }
                            # Use class mailaddress to check if $param.value is email
                            try {
                                $null = [mailaddress]$EmailAddress
                                # Search for manager using email
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'email' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'email'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue; this is a validated user id
                                $managerValue = $managerResults.id
                                # if no value was returned, then assume the case this is actually a username and search
                                if (!$managerValue) {
                                    $managerSearch = @{
                                        filter = @{
                                            'and' = @(
                                                @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                            )
                                        }
                                        fields = 'username'
                                    }
                                    $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                    # Set managerValue from the matched username
                                    $managerValue = $managerResults.id
                                }
                            } catch {
                                # search the username in the search endpoint
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'username'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue from the matched username
                                $managerValue = $managerResults.id
                            }
                            if ($managerValue) {
                                $body.add($param.Key, $managerValue)
                            } else {
                                $body.add($param.Key, $param.Value)
                            }
                            continue
                        }
                    }
                    $body.add($param.Key, $param.Value)
                }

                if ($enable_user_portal_multifactor -eq $True) {
                    if ($PSBoundParameters['EnrollmentDays']) {
                        $exclusionUntil = (Get-Date).AddDays($PSBoundParameters['EnrollmentDays'])
                    } else {
                        $exclusionUntil = (Get-Date).AddDays(7)
                    }

                    $mfa = @{ }
                    $mfa.Add("exclusion", $true)
                    $mfa.Add("exclusionUntil", [string]$exclusionUntil)
                    $body.Add('mfa', $mfa)
                }

                if ((($suspended -eq $true) -And ($state -eq "ACTIVATED")) -Or (($suspended -eq $false) -And ($state -eq "SUSPENDED"))) {
                    throw "Cannot save conflicting state and suspended fields. (state=$state suspended=$suspended)"
                } elseif ($suspended -eq $true) {
                    $body['state'] = 'SUSPENDED'
                } else {
                    switch ($state) {
                        SUSPENDED {
                            $body['suspended'] = $true
                        }
                        ACTIVATED {
                            $body['suspended'] = $false
                        }
                    }
                }

                $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                $UpdatedUserArray += $NewUserInfo
            }

            else {
                Throw "$Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."
            }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'Username' -and ($NumberOfCustomAttributes)) {
            if ($UserHash.Values.username -contains ($Username)) {
                $URL_ID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
                Write-Debug $URL_ID

                $URL = "$JCUrlBasePath/api/Systemusers/$URL_ID"
                Write-Debug $URL

                $CurrentAttributes = Get-JCUser -userid $URL_ID | Select-Object -ExpandProperty attributes | Select-Object value, name
                Write-Debug "There are $($CurrentAttributes.count) existing attributes"

                $CustomAttributeArrayList = New-Object System.Collections.ArrayList

                foreach ($param in $PSBoundParameters.GetEnumerator()) {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) {
                        continue
                    }

                    if ($param.key -in ('Username', 'EnrollmentDays')) {
                        continue
                    }

                    if ($param.key -eq 'NumberOfCustomAttributes') {
                        continue
                    }

                    if ($param.Key -like '*_number') {
                        continue
                    }

                    if ($param.Key -like 'work_*') {
                        continue
                    }

                    if ($param.Key -like 'home_*') {
                        continue
                    }

                    # Get the manager using manager username instead of userId
                    if ("manager" -eq $param.Key) {
                        if ([System.String]::isNullOrEmpty($param.value)) {
                            $managerValue = $null
                        } else {
                            # First check if manager returns valid user with id
                            # Regex match a userid
                            $regexPattern = [Regex]'^[a-z0-9]{24}$'
                            if (((Select-String -InputObject $param.Value -Pattern $regexPattern).Matches.value)::IsNullOrEmpty) {
                                # if we have a 24 characterid, try to match the id using the search endpoint
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'id' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'id'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue; this is a validated user id
                                $managerValue = $managerResults.id
                                # if no value was returned, then assume the case this is actually a username and search
                                if (!$managerValue) {
                                    $managerSearch = @{
                                        filter = @{
                                            'and' = @(
                                                @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                            )
                                        }
                                        fields = 'username'
                                    }
                                    $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                    # Set managerValue from the matched username
                                    $managerValue = $managerResults.id
                                }
                            }
                            # Use class mailaddress to check if $param.value is email
                            try {
                                $null = [mailaddress]$EmailAddress
                                # Search for manager using email
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'email' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'email'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue; this is a validated user id
                                $managerValue = $managerResults.id
                                # if no value was returned, then assume the case this is actually a username and search
                                if (!$managerValue) {
                                    $managerSearch = @{
                                        filter = @{
                                            'and' = @(
                                                @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                            )
                                        }
                                        fields = 'username'
                                    }
                                    $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                    # Set managerValue from the matched username
                                    $managerValue = $managerResults.id
                                }
                            } catch {
                                # search the username in the search endpoint
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'username'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue from the matched username
                                $managerValue = $managerResults.id
                            }
                            if ($managerValue) {
                                $body.add($param.Key, $managerValue)
                            } else {
                                $body.add($param.Key, $param.Value)
                            }
                            continue
                        }
                    }

                    if ($param.Key -like 'Attribute*') {
                        $CustomAttribute = [pscustomobject]@{

                            CustomAttribute = ($Param.key).Split('_')[0]
                            Type            = ($Param.key).Split('_')[1]
                            Value           = $Param.value
                        }

                        $CustomAttributeArrayList.Add($CustomAttribute) | Out-Null

                        $UniqueAttributes = $CustomAttributeArrayList | Select-Object CustomAttribute -Unique

                        $NewAttributes = New-Object System.Collections.ArrayList

                        foreach ($A in $UniqueAttributes ) {
                            $Props = $CustomAttributeArrayList | Where-Object CustomAttribute -EQ $A.CustomAttribute

                            $obj = New-Object PSObject

                            foreach ($Prop in $Props) {
                                $obj | Add-Member -MemberType NoteProperty -Name $Prop.type -Value $Prop.value
                            }

                            $NewAttributes.Add($obj) | Out-Null

                        }

                        continue
                    }


                    $body.add($param.Key, $param.Value)

                }


                $NewAttributesHash = @{ }

                foreach ($NewA in $NewAttributes) {
                    $NewAttributesHash.Add($NewA.name, $NewA.value)

                }

                $CurrentAttributesHash = @{ }

                foreach ($CurrentA in $CurrentAttributes) {
                    $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
                }



                foreach ($A in $NewAttributesHash.GetEnumerator()) {
                    if (($CurrentAttributesHash).Contains($A.Key)) {
                        $CurrentAttributesHash.set_Item($($A.key), $($A.value))
                    } else {
                        $CurrentAttributesHash.Add($($A.key), $($A.value))
                    }
                }

                $UpdatedAttributeArrayList = New-Object System.Collections.ArrayList


                foreach ($NewA in $CurrentAttributesHash.GetEnumerator()) {
                    $temp = New-Object PSObject
                    $temp | Add-Member -MemberType NoteProperty -Name name -Value $NewA.key
                    $temp | Add-Member -MemberType NoteProperty -Name value -Value $NewA.value
                    $UpdatedAttributeArrayList.Add($temp) | Out-Null
                }

                $body.add('attributes', $UpdatedAttributeArrayList)

                if ($enable_user_portal_multifactor -eq $True) {
                    if ($PSBoundParameters['EnrollmentDays']) {
                        $exclusionUntil = (Get-Date).AddDays($PSBoundParameters['EnrollmentDays'])
                    } else {
                        $exclusionUntil = (Get-Date).AddDays(7)
                    }

                    $mfa = @{ }
                    $mfa.Add("exclusion", $true)
                    $mfa.Add("exclusionUntil", [string]$exclusionUntil)
                    $body.Add('mfa', $mfa)
                }

                if ((($suspended -eq $true) -And ($state -eq "ACTIVATED")) -Or (($suspended -eq $false) -And ($state -eq "SUSPENDED"))) {
                    throw "Cannot save conflicting state and suspended fields. (state=$state suspended=$suspended)"
                } elseif ($suspended -eq $true) {
                    $body['state'] = 'SUSPENDED'
                } else {
                    switch ($state) {
                        SUSPENDED {
                            $body['suspended'] = $true
                        }
                        ACTIVATED {
                            $body['suspended'] = $false
                        }
                    }
                }

                $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                $UpdatedUserArray += $NewUserInfo


            }

            else {
                Throw "$Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."
            }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'RemoveCustomAttribute') {
            if ($UserHash.Values.username -contains ($Username)) {
                $URL_ID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
                Write-Debug $URL_ID

                $URL = "$JCUrlBasePath/api/Systemusers/$URL_ID"
                Write-Debug $URL

                $CurrentAttributes = Get-JCUser -userid $URL_ID | Select-Object -ExpandProperty attributes | Select-Object value, name
                Write-Debug "There are $($CurrentAttributes.count) existing attributes"

                foreach ($param in $PSBoundParameters.GetEnumerator()) {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) {
                        continue
                    }

                    if ($param.key -in ('Username', 'EnrollmentDays')) {
                        continue
                    }

                    if ($param.key -eq 'RemoveCustomAttribute') {
                        continue
                    }

                    if ($param.Key -like '*_number') {
                        continue
                    }

                    if ($param.Key -like 'work_*') {
                        continue
                    }

                    if ($param.Key -like 'home_*') {
                        continue
                    }

                    # Get the manager using manager username instead of userId
                    if ("manager" -eq $param.Key) {
                        if ([System.String]::isNullOrEmpty($param.value)) {
                            $managerValue = $null
                        } else {
                            # First check if manager returns valid user with id
                            # Regex match a userid
                            $regexPattern = [Regex]'^[a-z0-9]{24}$'
                            if (((Select-String -InputObject $param.Value -Pattern $regexPattern).Matches.value)::IsNullOrEmpty) {
                                # if we have a 24 characterid, try to match the id using the search endpoint
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'id' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'id'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue; this is a validated user id
                                $managerValue = $managerResults.id
                                # if no value was returned, then assume the case this is actually a username and search
                                if (!$managerValue) {
                                    $managerSearch = @{
                                        filter = @{
                                            'and' = @(
                                                @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                            )
                                        }
                                        fields = 'username'
                                    }
                                    $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                    # Set managerValue from the matched username
                                    $managerValue = $managerResults.id
                                }
                            }
                            # Use class mailaddress to check if $param.value is email
                            try {
                                $null = [mailaddress]$EmailAddress
                                Write-Debug "This is true"
                                # Search for manager using email
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'email' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'email'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue; this is a validated user id
                                $managerValue = $managerResults.id
                                # if no value was returned, then assume the case this is actually a username and search
                                if (!$managerValue) {
                                    $managerSearch = @{
                                        filter = @{
                                            'and' = @(
                                                @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                            )
                                        }
                                        fields = 'username'
                                    }
                                    $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                    # Set managerValue from the matched username
                                    $managerValue = $managerResults.id
                                }
                            } catch {
                                # search the username in the search endpoint
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'username'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue from the matched username
                                $managerValue = $managerResults.id
                            }
                            if ($managerValue) {
                                $body.add($param.Key, $managerValue)
                            } else {
                                $body.add($param.Key, $param.Value)
                            }
                            continue
                        }
                    }

                    $body.add($param.Key, $param.Value)

                }

                $CurrentAttributesHash = @{ }

                foreach ($CurrentA in $CurrentAttributes) {
                    $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
                }

                foreach ($Remove in $RemoveCustomAttribute) {
                    if ($CurrentAttributesHash.ContainsKey($Remove)) {
                        Write-Debug "$Remove is getting removed from custom attributes"
                        $CurrentAttributesHash.Remove($Remove)
                    }
                }

                $UpdatedAttributeArrayList = New-Object System.Collections.ArrayList


                foreach ($NewA in $CurrentAttributesHash.GetEnumerator()) {
                    $temp = New-Object PSObject
                    $temp | Add-Member -MemberType NoteProperty -Name name -Value $NewA.key
                    $temp | Add-Member -MemberType NoteProperty -Name value -Value $NewA.value
                    $UpdatedAttributeArrayList.Add($temp) | Out-Null
                }

                $body.add('attributes', $UpdatedAttributeArrayList)

                if ($enable_user_portal_multifactor -eq $True) {
                    if ($PSBoundParameters['EnrollmentDays']) {
                        $exclusionUntil = (Get-Date).AddDays($PSBoundParameters['EnrollmentDays'])
                    } else {
                        $exclusionUntil = (Get-Date).AddDays(7)
                    }

                    $mfa = @{ }
                    $mfa.Add("exclusion", $true)
                    $mfa.Add("exclusionUntil", [string]$exclusionUntil)
                    $body.Add('mfa', $mfa)
                }

                if ((($suspended -eq $true) -And ($state -eq "ACTIVATED")) -Or (($suspended -eq $false) -And ($state -eq "SUSPENDED"))) {
                    throw "Cannot save conflicting state and suspended fields. (state=$state suspended=$suspended)"
                } elseif ($suspended -eq $true) {
                    $body['state'] = 'SUSPENDED'
                } else {
                    switch ($state) {
                        SUSPENDED {
                            $body['suspended'] = $true
                        }
                        ACTIVATED {
                            $body['suspended'] = $false
                        }
                    }
                }

                $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                $UpdatedUserArray += $NewUserInfo


            }

            else {
                Throw "$Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."
            }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID' -and (!$NumberOfCustomAttributes)) {
            Write-Debug $UserID

            $URL = "$JCUrlBasePath/api/Systemusers/$UserID"

            Write-Debug $URL



            foreach ($param in $PSBoundParameters.GetEnumerator()) {
                if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) {
                    continue
                }

                if ($param.key -in ('EnrollmentDays')) {
                    continue
                }

                if ($param.Key -like '*_number') {
                    continue
                }

                if ($param.Key -like 'work_*') {
                    continue
                }

                if ($param.Key -like 'home_*') {
                    continue
                }

                # Get the manager using manager username instead of userId
                if ("manager" -eq $param.Key) {
                    if ([System.String]::isNullOrEmpty($param.value)) {
                        $managerValue = $null
                    } else {
                        # First check if manager returns valid user with id
                        # Regex match a userid
                        $regexPattern = [Regex]'^[a-z0-9]{24}$'
                        if (((Select-String -InputObject $param.Value -Pattern $regexPattern).Matches.value)::IsNullOrEmpty) {
                            # if we have a 24 characterid, try to match the id using the search endpoint
                            $managerSearch = @{
                                filter = @{
                                    'and' = @(
                                        @{'id' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                    )
                                }
                                fields = 'id'
                            }
                            $managerResults = Search-JcSdkUser -Body:($managerSearch)
                            # Set managerValue; this is a validated user id
                            $managerValue = $managerResults.id
                            # if no value was returned, then assume the case this is actually a username and search
                            if (!$managerValue) {
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'username'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue from the matched username
                                $managerValue = $managerResults.id
                            }
                        }
                        # Use class mailaddress to check if $param.value is email
                        try {
                            $null = [mailaddress]$EmailAddress
                            Write-Debug "This is true"
                            # Search for manager using email
                            $managerSearch = @{
                                filter = @{
                                    'and' = @(
                                        @{'email' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                    )
                                }
                                fields = 'email'
                            }
                            $managerResults = Search-JcSdkUser -Body:($managerSearch)
                            # Set managerValue; this is a validated user id
                            $managerValue = $managerResults.id
                            # if no value was returned, then assume the case this is actually a username and search
                            if (!$managerValue) {
                                $managerSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                        )
                                    }
                                    fields = 'username'
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue from the matched username
                                $managerValue = $managerResults.id
                            }
                        } catch {
                            # search the username in the search endpoint
                            $managerSearch = @{
                                filter = @{
                                    'and' = @(
                                        @{'username' = @{'$regex' = "(?i)(`^$($param.Value)`$)" } }
                                    )
                                }
                                fields = 'username'
                            }
                            $managerResults = Search-JcSdkUser -Body:($managerSearch)
                            # Set managerValue from the matched username
                            $managerValue = $managerResults.id
                        }
                        if ($managerValue) {
                            $body.add($param.Key, $managerValue)
                        } else {
                            $body.add($param.Key, $param.Value)
                        }
                        continue
                    }
                }

                if ($param.key -eq 'UserID') {
                    continue
                }

                if ($param.key -eq 'ByID') {
                    continue
                }

                $body.add($param.Key, $param.Value)

            }

            if ($enable_user_portal_multifactor -eq $True) {
                if ($PSBoundParameters['EnrollmentDays']) {
                    $exclusionUntil = (Get-Date).AddDays($PSBoundParameters['EnrollmentDays'])
                } else {
                    $exclusionUntil = (Get-Date).AddDays(7)
                }

                $mfa = @{ }
                $mfa.Add("exclusion", $true)
                $mfa.Add("exclusionUntil", [string]$exclusionUntil)
                $body.Add('mfa', $mfa)
            }

            if ((($suspended -eq $true) -And ($state -eq "ACTIVATED")) -Or (($suspended -eq $false) -And ($state -eq "SUSPENDED"))) {
                throw "Cannot save conflicting state and suspended fields. (state=$state suspended=$suspended)"
            } elseif ($suspended -eq $true) {
                $body['state'] = 'SUSPENDED'
            } else {
                switch ($state) {
                    SUSPENDED {
                        $body['suspended'] = $true
                    }
                    ACTIVATED {
                        $body['suspended'] = $false
                    }
                }
            }

            $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

            Write-Debug $jsonbody

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

            $UpdatedUserArray += $NewUserInfo


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID' -and ($NumberOfCustomAttributes)) {
            Write-Debug $UserID

            $URL = "$JCUrlBasePath/api/Systemusers/$UserID"

            $CurrentAttributes = Get-JCUser -userid $UserID | Select-Object -ExpandProperty attributes | Select-Object value, name
            Write-Debug "There are $($CurrentAttributes.count) existing attributes"

            $CustomAttributeArrayList = New-Object System.Collections.ArrayList

            foreach ($param in $PSBoundParameters.GetEnumerator()) {
                if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) {
                    continue
                }

                if ($param.key -in ('Username', 'EnrollmentDays')) {
                    continue
                }

                if ($param.key -eq 'ByID') {
                    continue
                }

                if ($param.key -eq 'UserID') {
                    continue
                }

                if ($param.key -eq 'NumberOfCustomAttributes') {
                    continue
                }

                if ($param.Key -like '*_number') {
                    continue
                }

                if ($param.Key -like 'work_*') {
                    continue
                }

                if ($param.Key -like 'home_*') {
                    continue
                }

                if ($param.Key -like 'Attribute*') {
                    $CustomAttribute = [pscustomobject]@{

                        CustomAttribute = ($Param.key).Split('_')[0]
                        Type            = ($Param.key).Split('_')[1]
                        Value           = $Param.value
                    }

                    $CustomAttributeArrayList.Add($CustomAttribute) | Out-Null

                    $UniqueAttributes = $CustomAttributeArrayList | Select-Object CustomAttribute -Unique

                    $NewAttributes = New-Object System.Collections.ArrayList

                    foreach ($A in $UniqueAttributes ) {
                        $Props = $CustomAttributeArrayList | Where-Object CustomAttribute -EQ $A.CustomAttribute

                        $obj = New-Object PSObject

                        foreach ($Prop in $Props) {
                            $obj | Add-Member -MemberType NoteProperty -Name $Prop.type -Value $Prop.value
                        }

                        $NewAttributes.Add($obj) | Out-Null

                    }

                    continue
                }


                $body.add($param.Key, $param.Value)

            }


            $NewAttributesHash = @{ }

            foreach ($NewA in $NewAttributes) {
                $NewAttributesHash.Add($NewA.name, $NewA.value)

            }

            $CurrentAttributesHash = @{ }

            foreach ($CurrentA in $CurrentAttributes) {
                $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
            }



            foreach ($A in $NewAttributesHash.GetEnumerator()) {
                if (($CurrentAttributesHash).Contains($A.Key)) {
                    $CurrentAttributesHash.set_Item($($A.key), $($A.value))
                } else {
                    $CurrentAttributesHash.Add($($A.key), $($A.value))
                }
            }

            $UpdatedAttributeArrayList = New-Object System.Collections.ArrayList


            foreach ($NewA in $CurrentAttributesHash.GetEnumerator()) {
                $temp = New-Object PSObject
                $temp | Add-Member -MemberType NoteProperty -Name name -Value $NewA.key
                $temp | Add-Member -MemberType NoteProperty -Name value -Value $NewA.value
                $UpdatedAttributeArrayList.Add($temp) | Out-Null
            }

            $body.add('attributes', $UpdatedAttributeArrayList)

            if ($enable_user_portal_multifactor -eq $True) {
                if ($PSBoundParameters['EnrollmentDays']) {
                    $exclusionUntil = (Get-Date).AddDays($PSBoundParameters['EnrollmentDays'])
                } else {
                    $exclusionUntil = (Get-Date).AddDays(7)
                }

                $mfa = @{ }
                $mfa.Add("exclusion", $true)
                $mfa.Add("exclusionUntil", [string]$exclusionUntil)
                $body.Add('mfa', $mfa)
            }

            if ((($suspended -eq $true) -And ($state -eq "ACTIVATED")) -Or (($suspended -eq $false) -And ($state -eq "SUSPENDED"))) {
                throw "Cannot save conflicting state and suspended fields. (state=$state suspended=$suspended)"
            } elseif ($suspended -eq $true) {
                $body['state'] = 'SUSPENDED'
            } else {
                switch ($state) {
                    SUSPENDED {
                        $body['suspended'] = $true
                    }
                    ACTIVATED {
                        $body['suspended'] = $false
                    }
                }
            }

            $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

            Write-Debug $jsonbody

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        }
    }
    end {
        return $UpdatedUserArray
    }
}