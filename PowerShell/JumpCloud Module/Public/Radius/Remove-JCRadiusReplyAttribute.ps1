function Remove-JCRadiusReplyAttribute
{
    [CmdletBinding()]
    param (
        [Parameter( Mandatory, position = 0, ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup')]
        [Alias('name')]
        [String]$GroupName,

        [Parameter( ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup')]
        [String[]]
        $AttributeName,

        [Parameter( ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup')]
        [switch]
        $All
    )

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


        if ($All)
        {
            $Body = @{
                attributes = @{}
                "name"     = "$LdapGroupName"
            }

            $URL = "$JCUrlBasePath/api/v2/usergroups/$Group_ID"

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


            $jsonbody = $Body | ConvertTo-Json -Depth 5 -Compress

            Write-Debug $jsonbody
            Write-Verbose $jsonbody

            $AttributeRemove = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))

            $ResultsArray += $AttributeRemove

            Break

        }

        $CurrentAttributes = Get-JCGroup -Type User -Name $GroupName | Select-Object @{Name = "RadiusAttributes"; Expression = {$_.attributes.radius.reply}} | Select-Object -ExpandProperty RadiusAttributes

        $CurrentAttributesHash = @{}

        foreach ($CurrentA in $CurrentAttributes)
        {
            $CurrentAttributesHash.Add($CurrentA.name, $CurrentA.value)
        }

        if ($AttributeName)
        {
            foreach ($Attribute in $AttributeName)
            {
                if ($CurrentAttributesHash.ContainsKey($Attribute))
                {
                    Write-Debug "$Attribute is here"
                    $CurrentAttributesHash.Remove($Attribute)
                }
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

            $URL = "$JCUrlBasePath/api/v2/usergroups/$Group_ID"

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


            $jsonbody = $Body | ConvertTo-Json -Depth 5 -Compress

            Write-Debug $jsonbody
            Write-Verbose $jsonbody

            $AttributeRemove = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))

            $FormattedResults = $AttributeRemove.attributes.radius.reply

            $ResultsArray += $FormattedResults
        }
    }

    end
    {
        Return $ResultsArray
    }

}
