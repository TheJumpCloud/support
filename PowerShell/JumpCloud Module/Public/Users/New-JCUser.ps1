Function New-JCUser ()
{

    [CmdletBinding(DefaultParameterSetName = 'NoAttributes')]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The first name of the user')][System.String]$firstname,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The last name of the user')][System.String]$lastname,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The username for the user. This must be a unique value. This value is not modifiable after user creation.')][System.String]$username,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The email address for the user. This must be a unique value.')][System.String]$email,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The password for the user')][System.String]$password,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A true or false value for enabling password_never_expires')][ValidateSet($true, $false)][System.String]$password_never_expires,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A true or false value for allowing pubic key authentication')][ValidateSet($true, $false)][System.String]$allow_public_key,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A true or false value if you want to enable the user to be an administrator on any and all systems the user is bound to.')][ValidateSet($true, $false)][System.String]$sudo,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A true or false value for enabling managed uid')][ValidateSet($true, $false)][System.String]$enable_managed_uid,
        [Parameter(HelpMessage = 'The unix_uid for the new user. Note this value must be an number.')][ValidateRange(0, 4294967295)][int]$unix_uid,
        [Parameter(HelpMessage = 'The unix_guid for the new user. Note this value must be an number.')][ValidateRange(0, 4294967295)][int]$unix_guid,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A true or false value if you want to enable passwordless_sudo')][ValidateSet($true, $false)][System.String]$passwordless_sudo,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A true or false value to enable the user as an LDAP binding user')][ValidateSet($true, $false)][System.String]$ldap_binding_user,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A true or false value for enabling MFA at the user portal')][ValidateSet($true, $false)][System.String]$enable_user_portal_multifactor,
        [Parameter(ParameterSetName = 'Attributes', HelpMessage = 'If you intend to create users with Custom Attributes you must declare how many Custom Attributes you intend to add. Based on the NumberOfCustomAttributes value two Dynamic Parameters will be created for each Custom Attribute: Attribute_name and Attribute_value with an associated number. See an example for adding a user with two Custom Attributes in EXAMPLE 3')][int]$NumberOfCustomAttributes,
        # New attributes as of 1.8.0 release
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home location. The LDAP displayName of this property is initials.')][System.String]$middlename,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s preferredName. The LDAP displayName of this property is displayName.')][Alias('preferredName')][System.String]$displayname,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home number. The LDAP displayName of this property is title.')][System.String]$jobTitle,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s employeeIdentifier. The LDAP displayName of this property is employeeNumber. Note this field must be unique per user.')][System.String]$employeeIdentifier,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s department. The LDAP displayName of this property is departmentNumber.')][System.String]$department,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s costCenter. The LDAP displayName of this property is businessCategory.')][System.String]$costCenter,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s company. The LDAP displayName of this property is company.')][System.String]$company,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s employeeType. The LDAP displayName of this property is employeeType.')][System.String]$employeeType,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s description. The LDAP displayName of this property is description. This field is limited to 1024 characters.')][ValidateLength(0, 1024)][System.String]$description,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home location. The LDAP displayName of this property is physicalDeliveryOfficeName.')][System.String]$location,
        #Objects
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s streetAddress on their work address object. This property is nested within the LDAP property with the displayName postalAddress.')][System.String]$work_streetAddress,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s poBox on their work address object. The LDAP displayName of this property is postOfficeBox.')][System.String]$work_poBox,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s city on their work address object. The LDAP displayName of this property is l.')][Alias('work_city')][System.String]$work_locality,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s state on their work address object. This property is nested within the LDAP property with the displayName postalAddress.')][Alias('work_state')][System.String]$work_region,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s postalCode on their work address object. The LDAP displayName of this property is postalCode.')][System.String]$work_postalCode,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s country on the work address object. This property is nested within the LDAP property with the displayName postalAddress.')][System.String]$work_country,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s streetAddress on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')][System.String]$home_streetAddress,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s poBox on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')][System.String]$home_poBox,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s city on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')][Alias('home_city')][System.String]$home_locality,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s state on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')][Alias('home_state')][System.String]$home_region,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s postalCode on their home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')][System.String]$home_postalCode,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s country on the home address object. This property is nested within the LDAP property with the displayName homePostalAddress.')][System.String]$home_country,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s mobile number. The LDAP displayName of this property is mobile.')][System.String]$mobile_number,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s home number. The LDAP displayName of this property is homePhone.')][System.String]$home_number,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work number. The LDAP displayName of this property is telephoneNumber.')][System.String]$work_number,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work mobile number. The LDAP displayName of this property is pager.')][System.String]$work_mobile_number,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the user''s work fax number. The LDAP displayName of this property is facsimileTelephoneNumber.')][System.String]$work_fax_number,
        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'A true or false value for putting the account into a suspended state')][ValidateSet($true, $false)][System.String]$suspended
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
            If ($param.Value -in ('true', 'false'))
            {
                $body.add($param.Key, [System.Convert]::ToBoolean($param.Value))
            }
            Else
            {
                $body.add($param.Key, $param.Value)
            }
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
        if ($enable_user_portal_multifactor)
        {
            if ([System.Convert]::ToBoolean($enable_user_portal_multifactor) -eq $True)
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