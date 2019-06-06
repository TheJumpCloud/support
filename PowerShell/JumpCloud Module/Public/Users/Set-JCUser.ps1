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
        $password_never_expires,

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
        [ValidateRange(0, 4294967295)]
        $unix_uid,

        [Parameter()]
        [int]
        [ValidateRange(0, 4294967295)]
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
        $ByID,

        # New attributes as of 1.8.0 release
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $middlename,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        [Alias('preferredName')]
        $displayname,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $jobTitle,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $employeeIdentifier,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $department,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $costCenter,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $company,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $employeeType,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        [ValidateLength(0, 1024)]
        $description,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $location,

        #Objects

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $work_streetAddress,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $work_poBox,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        [Alias('work_city')]
        $work_locality,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        [Alias('work_state')]
        $work_region,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $work_postalCode,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $work_country,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $home_streetAddress,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $home_poBox,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        [Alias('home_city')]
        $home_locality,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        [Alias('home_state')]
        $home_region,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $home_postalCode,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $home_country,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $mobile_number,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $home_number,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $work_number,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $work_mobile_number,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $work_fax_number,

        # New attributes as of 1.12.0 release

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $external_dn,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]
        $external_source_type


    )

    DynamicParam
    {
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            $enable_user_portal_multifactor = $true
            $NumberOfCustomAttributes = 2
        }
        If ($enable_user_portal_multifactor -eq $True)
        {
            # Set the dynamic parameters' name
            $ParamName = 'EnrollmentDays'
            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            # Generate and set the ValidateSet
            $ValidateRangeAttribute = New-Object System.Management.Automation.ValidateRangeAttribute('1', '365')
            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateRangeAttribute)
            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)
            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName, [Int32], $AttributeCollection)
            $dict.Add($ParamName, $RuntimeParameter)

        }

        If ($NumberOfCustomAttributes)
        {

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


        }

        return $dict
    }

    begin

    {
        Write-Debug "Parameter set $($PSCmdlet.ParameterSetName)"

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

        $UpdatedUserArray = @()

        if ($PSCmdlet.ParameterSetName -ne 'ByID')

        {
            $UserHash = Get-Hash_UserName_ID
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

        if ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            $URL_ID = $UserID
        }

    }


    process
    {
        $body = @{ }

        if ($PSCmdlet.ParameterSetName -ne 'ByID')
        {
            if ($UserHash.ContainsKey($Username))

            {
                $URL_ID = $UserHash.Get_Item($Username)
                Write-Debug $URL_ID
            }

            else
            {
                Throw "$Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."
            }

        }

        $UpdateParms = $PSBoundParameters.GetEnumerator() | Select-Object Key
        $UpdateObjectParams = @{ }

        foreach ($param in $UpdateParms)
        {

            if ($ObjectParams.ContainsKey($param.key))
            {
                $UpdateObjectParams.Add($param.key, $ObjectParams.($param.key))
            }

        }

        if ($UpdateObjectParams.Count -gt 0)
        {
            $objectCheck = $UpdateObjectParams.Values | Select-Object -Unique

            $UserObjectCheck = Get-JCUser -userid $URL_ID

            if ($objectCheck.contains("phoneNumbers"))
            {
                $phoneNumbers = @()

                $UpdatedNumbers = @{ }

                foreach ($param in $PSBoundParameters.GetEnumerator())
                {

                    if ($param.Key -like '*_number')
                    {
                        $Number = @{ }
                        $Number.Add("type", ($($param.Key -replace "_number", "")))
                        $Number.Add("number", $param.Value)
                        $UpdatedNumbers.Add(($($param.Key -replace "_number", "")), $param.Value)
                        $phoneNumbers += $Number
                        continue
                    }

                }

                foreach ($ExitingNumber in $UserObjectCheck.phoneNumbers)
                {
                    if ($UpdatedNumbers.ContainsKey($ExitingNumber.type))
                    {
                        Continue
                    }
                    else
                    {
                        $Number = @{ }
                        if ($ExitingNumber.number)
                        {
                            $Number.Add("type", $ExitingNumber.type )
                            $Number.Add("number", $ExitingNumber.number)
                            $phoneNumbers += $Number

                        }

                    }
                }

                $body.Add('phoneNumbers', $phoneNumbers)
            }

            if ($objectCheck.contains("addresses"))
            {
                $Addresses = @()

                $WorkAddressParams = @{ }
                $WorkAddressParams.Add("type", "work")

                $HomeAddressParams = @{ }
                $HomeAddressParams.Add("type", "home")

                foreach ($param in $PSBoundParameters.GetEnumerator())
                {
                    if ($param.Key -like '*_number')
                    { continue }

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

                }


                $ExistingWorkParams = $UserObjectCheck.addresses | Where-Object Type -EQ "Work"

                $ExistingWorkHash = @{ }
                $ExistingWorkHash.Add("country", $ExistingWorkParams.country)
                $ExistingWorkHash.Add("locality", $ExistingWorkParams.locality)
                $ExistingWorkHash.Add("poBox", $ExistingWorkParams.poBox)
                $ExistingWorkHash.Add("postalCode", $ExistingWorkParams.postalCode)
                $ExistingWorkHash.Add("region", $ExistingWorkParams.region)
                $ExistingWorkHash.Add("streetAddress", $ExistingWorkParams.streetAddress)


                foreach ($WorkParam in $ExistingWorkHash.GetEnumerator())
                {

                    if ($WorkAddressParams.ContainsKey($WorkParam.key))
                    {
                        Continue
                    }

                    else
                    {
                        if ($WorkParam.value)
                        {
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

                foreach ($HomeParam in $ExistingHomeHash.GetEnumerator())
                {

                    if ($HomeAddressParams.ContainsKey($HomeParam.key))
                    {
                        Continue
                    }

                    else
                    {
                        if ($HomeParam.value)
                        {
                            $HomeAddressParams.Add($HomeParam.key, $HomeParam.value)
                        }
                    }
                }

                $Addresses += $HomeAddressParams


                $body.Add('addresses', $Addresses)
            }

        }

        if ($PSCmdlet.ParameterSetName -eq 'Username' -and !$NumberOfCustomAttributes)
        {
            if ($UserHash.ContainsKey($Username))

            {
                $URL_ID = $UserHash.Get_Item($Username)
                Write-Debug $URL_ID

                $URL = "$JCUrlBasePath/api/Systemusers/$URL_ID"
                Write-Debug $URL

                foreach ($param in $PSBoundParameters.GetEnumerator())
                {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                    if ($param.key -in ('Username', 'EnrollmentDays')) { continue }

                    if ($param.Key -like '*_number') { continue }

                    if ($param.Key -like 'work_*') { continue }

                    if ($param.Key -like 'home_*') { continue }

                    $body.add($param.Key, $param.Value)

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

                $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                $UpdatedUserArray += $NewUserInfo
            }

            else { Throw "$Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users." }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'Username' -and ($NumberOfCustomAttributes))
        {
            if ($UserHash.ContainsKey($Username))

            {
                $URL_ID = $UserHash.Get_Item($Username)
                Write-Debug $URL_ID

                $URL = "$JCUrlBasePath/api/Systemusers/$URL_ID"
                Write-Debug $URL

                $CurrentAttributes = Get-JCUser -UserID $URL_ID | Select-Object -ExpandProperty attributes | Select-Object value, name
                Write-Debug "There are $($CurrentAttributes.count) existing attributes"

                $CustomAttributeArrayList = New-Object System.Collections.ArrayList


                foreach ($param in $PSBoundParameters.GetEnumerator())
                {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                    if ($param.key -in ('Username', 'EnrollmentDays')) { continue }

                    if ($param.key -eq 'NumberOfCustomAttributes') { continue }

                    if ($param.Key -like '*_number') { continue }

                    if ($param.Key -like 'work_*') { continue }

                    if ($param.Key -like 'home_*') { continue }

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


                $NewAttributesHash = @{ }

                foreach ($NewA in $NewAttributes)
                {
                    $NewAttributesHash.Add($NewA.name, $NewA.value)

                }

                $CurrentAttributesHash = @{ }

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

                $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                $UpdatedUserArray += $NewUserInfo


            }

            else { Throw "$Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users." }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'RemoveAttribute')
        {
            if ($UserHash.ContainsKey($Username))

            {
                $URL_ID = $UserHash.Get_Item($Username)
                Write-Debug $URL_ID

                $URL = "$JCUrlBasePath/api/Systemusers/$URL_ID"
                Write-Debug $URL

                $CurrentAttributes = Get-JCUser -UserID $URL_ID | Select-Object -ExpandProperty attributes | Select-Object value, name
                Write-Debug "There are $($CurrentAttributes.count) existing attributes"

                foreach ($param in $PSBoundParameters.GetEnumerator())
                {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                    if ($param.key -in ('Username', 'EnrollmentDays')) { continue }

                    if ($param.key -eq 'RemoveAttribute') { continue }

                    if ($param.Key -like '*_number') { continue }

                    if ($param.Key -like 'work_*') { continue }

                    if ($param.Key -like 'home_*') { continue }

                    $body.add($param.Key, $param.Value)

                }

                $CurrentAttributesHash = @{ }

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

                $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

                Write-Debug $jsonbody

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                $UpdatedUserArray += $NewUserInfo


            }

            else { Throw "$Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users." }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID' -and (!$NumberOfCustomAttributes))
        {
            Write-Debug $UserID

            $URL = "$JCUrlBasePath/api/Systemusers/$UserID"

            Write-Debug $URL



            foreach ($param in $PSBoundParameters.GetEnumerator())
            {
                if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                if ($param.key -in ('EnrollmentDays')) { continue }

                if ($param.Key -like '*_number') { continue }

                if ($param.Key -like 'work_*') { continue }

                if ($param.Key -like 'home_*') { continue }

                if ($param.key -eq 'UserID') { continue }

                if ($param.key -eq 'ByID') { continue }

                $body.add($param.Key, $param.Value)

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

            $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

            Write-Debug $jsonbody

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

            $UpdatedUserArray += $NewUserInfo


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID' -and ($NumberOfCustomAttributes))
        {
            Write-Debug $UserID

            $URL = "$JCUrlBasePath/api/Systemusers/$UserID"

            $CurrentAttributes = Get-JCUser -UserID $UserID | Select-Object -ExpandProperty attributes | Select-Object value, name
            Write-Debug "There are $($CurrentAttributes.count) existing attributes"

            $CustomAttributeArrayList = New-Object System.Collections.ArrayList

            foreach ($param in $PSBoundParameters.GetEnumerator())
            {
                if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                if ($param.key -in ('Username', 'EnrollmentDays')) { continue }

                if ($param.key -eq 'ByID') { continue }

                if ($param.key -eq 'UserID') { continue }

                if ($param.key -eq 'NumberOfCustomAttributes') { continue }

                if ($param.Key -like '*_number') { continue }

                if ($param.Key -like 'work_*') { continue }

                if ($param.Key -like 'home_*') { continue }

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


            $NewAttributesHash = @{ }

            foreach ($NewA in $NewAttributes)
            {
                $NewAttributesHash.Add($NewA.name, $NewA.value)

            }

            $CurrentAttributesHash = @{ }

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

            $jsonbody = $body | ConvertTo-Json -Compress -Depth 4

            Write-Debug $jsonbody

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

            $UpdatedUserArray += $NewUserInfo


        }

    }
    end
    {
        return $UpdatedUserArray

    }

}