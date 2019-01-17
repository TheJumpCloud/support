Function Add-JCRadiusReplyAttribute ()
{

    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]
    param
    (

        [Parameter( Mandatory, position = 0, ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup')]
        [Alias('name')]
        [String]$GroupName,

        [Parameter( ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup')]
        [String]$VLAN,

        [Parameter(, ValueFromPipelineByPropertyName)] 
        [int]
        $NumberOfAttributes

    )


    DynamicParam
    {

        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        [int]$NewParams = 0
        [int]$ParamNumber = 1

        while ($NewParams -ne $NumberOfAttributes)
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

        if ($VLAN)
        {
            $VLANattr = New-Object System.Management.Automation.ParameterAttribute
            $VLANattr.Mandatory = $false
            $VLANattr.ValueFromPipelineByPropertyName = $true
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($(0..31))

            $VLANattrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $VLANattrColl.Add($VLANattr)
            $VLANattrColl.Add($ValidateSetAttribute)

            $VLANparam = New-Object System.Management.Automation.RuntimeDefinedParameter("VLANTag", [string], $VLANattrColl)
            $dict.Add("VLANTag", $VLANparam)
        }

        return $dict
        
    }

    begin
    {

        Write-Verbose 'Verifying JCAPI Key'
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

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')
        {
            Write-Verbose 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_UserGroupName_ID

        }

        $ResultsArray = @()
    }

    process
    {

        if ($GroupNameHash.containsKey($GroupName))

        {
            $Group_ID = $GroupNameHash.Get_Item($GroupName)
            Write-Verbose "$Group_ID"

            $GroupInfo = Get-JCGroup -Type User -Name $GroupName

            $LdapGroupName = $GroupInfo.attributes.ldapGroups.name
            Write-Verbose "$LdapGroupName"

            $ExistingAttributes = $GroupInfo | Select-Object -ExpandProperty attributes
        }
        else { Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."}
        
        $replyAttributes = New-Object System.Collections.ArrayList

        $CurrentAttributes = Get-JCGroup -Type User -Name $GroupName | Select-Object @{Name = "RadiusAttributes"; Expression = {$_.attributes.radius.reply}} | Select-Object -ExpandProperty RadiusAttributes

        $RadiusCustomAttributesArrayList = New-Object System.Collections.ArrayList

        foreach ($param in $PSBoundParameters.GetEnumerator())
        {
            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

            if ($param.key -eq 'Name', 'GroupName', 'JCAPIKey', 'NumberOfAttributes', 'VLAN', 'VLANTag') { continue }

            if ($param.Key -like 'Attribute*')
            {
                $CustomAttribute = [pscustomobject]@{

                    CustomAttribute = ($Param.key).Split('_')[0]
                    Type            = ($Param.key).Split('_')[1]
                    Value           = $Param.value
                }

                $RadiusCustomAttributesArrayList.Add($CustomAttribute) | Out-Null

                $UniqueAttributes = $RadiusCustomAttributesArrayList | Select-Object CustomAttribute -Unique

                $NewAttributes = New-Object System.Collections.ArrayList

                foreach ($A in $UniqueAttributes )
                {
                    $Props = $RadiusCustomAttributesArrayList | Where-Object CustomAttribute -EQ $A.CustomAttribute

                    $obj = New-Object PSObject

                    foreach ($Prop in $Props)
                    {
                        $obj | Add-Member -MemberType NoteProperty -Name $Prop.type -Value $Prop.value
                    }

                    $NewAttributes.Add($obj) | Out-Null

                }
                continue
            }

        }

        $NewAttributesHash = @{}

        foreach ($NewA in $NewAttributes)
        {
            $NewAttributesHash.Add($NewA.name, $NewA.value)

        }

        if ($VLAN)
        {
            if ($PSBoundParameters['VLANTag'])
            {
                $VLANTag = $PSBoundParameters['VLANTag']
                $TunnelType = New-Object PSObject
                $TunnelType | Add-Member -MemberType NoteProperty -Name "name" -Value "Tunnel-Type:$VLANTag"
                $TunnelType | Add-Member -MemberType NoteProperty -Name "value" -Value "VLAN"
    
                $NewAttributesHash.Add($TunnelType.name, $TunnelType.value)
    
                $TunnelMediumType = New-Object PSObject
    
                $TunnelMediumType | Add-Member -MemberType NoteProperty -Name "name" -Value "Tunnel-Medium-Type:$VLANTag"
                $TunnelMediumType | Add-Member -MemberType NoteProperty -Name "value" -Value "IEEE-802"
    
                $NewAttributesHash.Add($TunnelMediumType.name, $TunnelMediumType.value)
    
                $TunnelPrivateGroupID = New-Object PSObject
    
                $TunnelPrivateGroupID | Add-Member -MemberType NoteProperty -Name "name" -Value "Tunnel-Private-Group-Id:$VLANTag"
                $TunnelPrivateGroupID | Add-Member -MemberType NoteProperty -Name "value" -Value "$($VLAN)"
    
                $NewAttributesHash.Add($TunnelPrivateGroupID.name, $TunnelPrivateGroupID.value)
            }

            else
            {
                $TunnelType = New-Object PSObject
                $TunnelType | Add-Member -MemberType NoteProperty -Name "name" -Value "Tunnel-Type"
                $TunnelType | Add-Member -MemberType NoteProperty -Name "value" -Value "VLAN"
    
                $NewAttributesHash.Add($TunnelType.name, $TunnelType.value)
    
                $TunnelMediumType = New-Object PSObject
    
                $TunnelMediumType | Add-Member -MemberType NoteProperty -Name "name" -Value "Tunnel-Medium-Type"
                $TunnelMediumType | Add-Member -MemberType NoteProperty -Name "value" -Value "IEEE-802"
    
                $NewAttributesHash.Add($TunnelMediumType.name, $TunnelMediumType.value)
    
                $TunnelPrivateGroupID = New-Object PSObject
    
                $TunnelPrivateGroupID | Add-Member -MemberType NoteProperty -Name "name" -Value "Tunnel-Private-Group-Id"
                $TunnelPrivateGroupID | Add-Member -MemberType NoteProperty -Name "value" -Value "$($VLAN)"
    
                $NewAttributesHash.Add($TunnelPrivateGroupID.name, $TunnelPrivateGroupID.value)
                
            }

        }

        $CurrentAttributesHash = @{}

        $VLANAttrHash = @{
            "Tunnel-Type"             = "Tunnel-Type"
            "Tunnel-Medium-Type"      = "Tunnel-Medium-Type"
            "Tunnel-Private-Group-Id" = "Tunnel-Private-Group-Id"
        }

        foreach ($CurrentA in $CurrentAttributes)
        {
            if ($VLAN)
            {
                $TagSplit = ($CurrentA.name -split ":")[0]

                if (($VLANAttrHash).ContainsKey($TagSplit)) {Continue}

                else
                {
                    $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
                }
            }

            else
            {
                $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
            }

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

        $replyAttributes = $UpdatedAttributeArrayList



        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')
        {

            $Body = @{
                attributes = @{
                    radius = @{
                        'reply' = $replyAttributes
                    }
                }
                "name"     = "$LdapGroupName"
            }

            if ($ExistingAttributes.posixGroups)
            {
                $posixGroups = New-Object PSObject
                $posixGroups | Add-Member -MemberType NoteProperty -Name name -Value $ExistingAttributes.posixGroups.name
                $posixGroups | Add-Member -MemberType NoteProperty -Name id -Value $ExistingAttributes.posixGroups.id

                $Body.attributes.Add("posixGroups", @($posixGroups))
            }

            if ($ExistingAttributes.ldapGroups) 
            {
                $ldapGroups = New-Object PSObject
                $ldapGroups | Add-Member -MemberType NoteProperty -Name name -Value $ExistingAttributes.ldapGroups.name
                $Body.attributes.Add("ldapGroups", @($ldapGroups))
            }

            if ($GroupInfo.attributes.sambaEnabled -eq $True) 
            {
                $Body.attributes.Add("sambaEnabled", $True)
            }


            $URL = "$JCUrlBasePath/api/v2/usergroups/$Group_ID"

            $jsonbody = $Body | ConvertTo-Json -Depth 5 -Compress

            Write-Verbose $Body
            Write-Debug $jsonbody
            Write-Verbose $jsonbody

            $AttributeAdd = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent $JCUserAgent

            $FormattedResults = $AttributeAdd.attributes.radius.reply

            $ResultsArray += $FormattedResults

        }

    }

    end
    {
        return $ResultsArray
    }

}