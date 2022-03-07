Function New-JCUser ()
{

    [CmdletBinding(DefaultParameterSetName = 'NoAttributes')]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The first name of the user')]
        [string]$firstname,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The last name of the user')]
        [string]$lastname,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The username for the user. This must be a unique value. This value is not modifiable after user creation.')]
        [string]$username,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The email address for the user. This must be a unique value.')]
        [string]$email,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The password for the user')]
        [string]$password,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A boolean $true/$false value for enabling password_never_expires')]
        [bool]$password_never_expires,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A boolean $true/$false value for allowing pubic key authentication')]
        [bool]$allow_public_key,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A boolean $true/$false value if you want to enable the user to be an administrator on any and all systems the user is bound to.')]
        [bool]$sudo,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A boolean $true/$false value for enabling managed uid')]
        [bool]$enable_managed_uid,

        [Parameter(HelpMessage = 'The unix_uid for the new user. Note this value must be an number.')]
        [ValidateRange(0, 4294967295)]
        [int]$unix_uid,

        [Parameter(HelpMessage = 'The unix_guid for the new user. Note this value must be an number.')]
        [ValidateRange(0, 4294967295)]
        [int]$unix_guid,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A boolean $true/$false value if you want to enable passwordless_sudo')]
        [bool]$passwordless_sudo,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A boolean $true/$false value to enable the user as an LDAP binding user')]
        [bool]$ldap_binding_user,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A boolean $true/$false value for enabling MFA at the user portal')]
        [ValidateSet('True', 'False', '$True', '$False')]
        [String]$enable_user_portal_multifactor,

        [Parameter(ParameterSetName = 'Attributes', HelpMessage = 'If you intend to create users with Custom Attributes you must declare how many Custom Attributes you intend to add. Based on the NumberOfCustomAttributes value two Dynamic Parameters will be created for each Custom Attribute: Attribute_name and Attribute_value with an associated number. See an example for adding a user with two Custom Attributes in EXAMPLE 3')]
        [int]$NumberOfCustomAttributes,

        # New attributes as of 1.8.0 release
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home location. The LDAP displayName of this property is initials.')]
        [string]$middlename,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s preferredName. The LDAP displayName of this property is displayName.')]
        [Alias('preferredName')]
        [string]$displayname,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home number. The LDAP displayName of this property is title.')]
        [string]$jobTitle,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s employeeIdentifier. The LDAP displayName of this property is employeeNumber. Note this field must be unique per user.')]
        [string]$employeeIdentifier,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s department. The LDAP displayName of this property is departmentNumber.')]
        [string]$department,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s costCenter. The LDAP displayName of this property is businessCategory.')]
        [string]$costCenter,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s company. The LDAP displayName of this property is company.')]
        [string]$company,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s employeeType. The LDAP displayName of this property is employeeType.')]
        [string]$employeeType,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s description. The LDAP displayName of this property is description. This field is limited to 1024 characters.')]
        [ValidateLength(0, 1024)]
        [string]$description,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home location. The LDAP displayName of this property is physicalDeliveryOfficeName.')]
        [string]$location,

        #Objects

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s streetAddress on their work address object. This property is nested within the LDAP property with the displayName postalAddress.')]
        [string]$work_streetAddress,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s poBox on their work address object. The LDAP displayName of this property is postOfficeBox.')]
        [string]$work_poBox,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s city on their work address object. The LDAP displayName of this property is l.')]
        [Alias('work_city')]
        [string]$work_locality,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s state on their work address object. This property is nested within the LDAP property with the displayName postalAddress.')]
        [Alias('work_state')]
        [string]$work_region,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s postalCode on their work address object. The LDAP displayName of this property is postalCode.')]
        [string]$work_postalCode,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s country on the work address object. This property is nested within the LDAP property with the displayName postalAddress.')]
        [string]$work_country,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s streetAddress on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]$home_streetAddress,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s poBox on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]$home_poBox,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s city on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [Alias('home_city')]
        [string]$home_locality,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s state on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [Alias('home_state')]
        [string]$home_region,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s postalCode on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]$home_postalCode,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s country on the home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')]
        [string]$home_country,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s mobile number. The LDAP displayName of this property is mobile.')]
        [string]$mobile_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home number. The LDAP displayName of this property is homePhone.')]
        [string]$home_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work number. The LDAP displayName of this property is telephoneNumber.')]
        [string]$work_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work mobile number. The LDAP displayName of this property is pager.')]
        [string]$work_mobile_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work fax number. The LDAP displayName of this property is facsimileTelephoneNumber.')]
        [string]$work_fax_number,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A boolean $true/$false value for putting the account into a suspended state')]
        [bool]$suspended,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The manager username or ID of the JumpCloud manager user; must be a valid user')]
        [string]$manager,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The managedAppleId for the user')]
        [string]$managedAppleId,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The alternateEmail for the user')]
        [string]$alternateEmail

    )
    DynamicParam
    {
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            $enable_user_portal_multifactor = $true
            $NumberOfCustomAttributes = 2
        }
        If ($enable_user_portal_multifactor)
        {
            New-DynamicParameter -Name:('enrollmentDays') -Type:([Int]) -ValueFromPipelineByPropertyName -HelpMessage:('A dynamic parameter that can be set only if -enable_user_portal_multifactor is set to true. This will specify the enrollment period for users for enrolling into MFA via the users console. The default is 7 days if this value is not specified.') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        }
        If ($NumberOfCustomAttributes)
        {
            [int]$NewParams = 0
            [int]$ParamNumber = 1
            While ($NewParams -ne $NumberOfCustomAttributes)
            {
                New-DynamicParameter -Name:("Attribute$ParamNumber`_name") -Type:([System.String]) -Mandatory -HelpMessage:('Enter an attribute name') -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
                New-DynamicParameter -Name:("Attribute$ParamNumber`_value") -Type:([System.String]) -Mandatory -HelpMessage:('Enter an attribute value') -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
                $NewParams++
                $ParamNumber++
            }
        }
        Return $RuntimeParameterDictionary
    }
    begin
    {

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JConline }

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        $URL = "$JCUrlBasePath/api/systemusers"

        $NewUserArray = @()
    }

    process
    {
        if ($enable_user_portal_multifactor)
        {
            switch ($enable_user_portal_multifactor)
            {
                'True' { [bool]$enable_user_portal_multifactor = $true }
                '$True' { [bool]$enable_user_portal_multifactor = $true }
                'False' { [bool]$enable_user_portal_multifactor = $false }
                '$False' { [bool]$enable_user_portal_multifactor = $false }
            }
        }

        $body = @{ }

        $WorkAddressParams = @{ }
        $WorkAddressParams.Add("type", "work")

        $HomeAddressParams = @{ }
        $HomeAddressParams.Add("type", "home")

        $phoneNumbers = @()
        $Addresses = @()

        $CustomAttributeArrayList = New-Object System.Collections.ArrayList

        foreach ($param in $PSBoundParameters.GetEnumerator())
        {
            # Write-Host $param
            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

            if ($param.key -in ('_id', 'JCAPIKey', 'NumberOfCustomAttributes', 'EnrollmentDays')) { continue }

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

            if ($param.Key -like '*_number')
            {
                $Number = @{ }
                $Number.Add("type", ($($param.Key -replace "_number", "")))
                $Number.Add("number", $param.Value)
                $phoneNumbers += $Number
                continue
            }

            if ($param.Key -like 'work_*')
            {
                $WorkAddressParams.Add(($($param.Key -split "_", 2)[1]), $param.Value)
                continue
            }

            if ($param.Key -like 'home_*')
            {
                $HomeAddressParams.Add(($($param.Key -split "_", 2)[1]), $param.Value)
                continue
            }

            if ($param.Key -eq 'enable_user_portal_multifactor')
            {

                switch ($param.Value)
                {
                    'True' { [bool]$enable_user_portal_multifactor = $true }
                    '$True' { [bool]$enable_user_portal_multifactor = $true }
                    'False' { [bool]$enable_user_portal_multifactor = $false }
                    '$False' { [bool]$enable_user_portal_multifactor = $false }
                }

                $body.add($param.Key, $enable_user_portal_multifactor)
                continue
            }
            # Get the manager using manager username instead of userId
            if ("manager" -eq $param.Key)
            {
                if ([System.String]::isNullOrEmpty($param.Value)) {
                    # If manager field is null, skip
                    continue
                }
                else {
                    # First check if manager returns valid user with id
                        # Regex match a userid
                        $regexPattern = [Regex]'^[a-z0-9]{24}$'
                        if (((Select-String -InputObject $param.Value -Pattern $regexPattern).Matches.value)::IsNullOrEmpty){
                            # if we have a 24 characterid, try to match the id using the search endpoint
                            $managerSearch = @{
                                filter = @{
                                    or = @(
                                        '_id:$eq:' + $param.Value
                                    )
                                }
                            }
                            $managerResults = Search-JcSdkUser -Body:($managerSearch)
                            # Set managerValue; this is a validated user id
                            $managerValue = $managerResults.id
                            # if no value was returned, then assume the case this is actuallty a username and search
                            if (!$managerValue){
                                $managerSearch = @{
                                    filter = @{
                                        or = @(
                                            'username:$eq:' + $param.Value
                                        )
                                    }
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue from the matched username
                                $managerValue = $managerResults.id
                            }
                        }
                        else {
                            # search the username in the search endpoint
                            $managerSearch = @{
                                filter = @{
                                    or = @(
                                        'username:$eq:' + $param.Value
                                    )
                                }
                            }
                            $managerResults = Search-JcSdkUser -Body:($managerSearch)
                            # Set managerValue from the matched username
                            $managerValue = $managerResults.id
                        }
                    if ($managerValue) {
                        $body.add($param.Key, $managerValue)
                    }
                    else {
                        $body.add($param.Key, $param.Value)
                    }
                    continue
                }
            }

            $body.add($param.Key, $param.Value)

        }

        if ($WorkAddressParams.Count -gt 1)
        {
            $Addresses += $WorkAddressParams
        }

        if ($HomeAddressParams.Count -gt 1)
        {
            $Addresses += $HomeAddressParams
        }

        if ($Addresses)
        {
            $body.Add('addresses', $Addresses)
        }

        if ($phoneNumbers)
        {
            $body.Add('phoneNumbers', $phoneNumbers)
        }

        if ($enable_user_portal_multifactor -eq $True)
        {
            if ($PSBoundParameters['EnrollmentDays'])
            {
                $exclusionUntil = (Get-Date).AddDays($PSBoundParameters['EnrollmentDays'])
            }
            else
            {
                $exclusionUntil = (Get-Date).AddDays(7)
            }

            $mfa = @{ }
            $mfa.Add("exclusion", $true)
            $mfa.Add("exclusionUntil", [string]$exclusionUntil)
            $body.Add('mfa', $mfa)
        }

        If ($NewAttributes) { $body.add('attributes', $NewAttributes) }

        $jsonbody = $body | ConvertTo-Json

        Write-Debug $jsonbody

        $NewUserInfo = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        $NewUserArray += $NewUserInfo

    }
    end
    {
        return $NewUserArray
    }
}