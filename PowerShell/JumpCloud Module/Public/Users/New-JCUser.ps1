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
        $password_never_expires,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $allow_public_key,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $sudo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
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

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $passwordless_sudo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]
        $ldap_binding_user,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [String]
        [ValidateSet('True', 'False', '$True', '$False')]
        $enable_user_portal_multifactor,

        [Parameter(ParameterSetName = 'Attributes')]
        [int]
        $NumberOfCustomAttributes,

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
        $work_fax_number



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