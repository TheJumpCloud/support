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

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.6.0'

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

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.6.0'

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

                $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.6.0'

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

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.6.0'

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

            $NewUserInfo = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.6.0'

            $UpdatedUserArray += $NewUserInfo


        }

    }

    end
    {
        return $UpdatedUserArray

    }

}