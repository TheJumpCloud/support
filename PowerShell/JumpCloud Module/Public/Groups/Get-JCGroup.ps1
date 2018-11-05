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
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [string], $attrColl)
            $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $dict.Add('Name', $param)
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
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($param.IsSet)
        {
               
            if ($Type -eq 'System')
            {
                    
                Write-Verbose 'Populating SystemGroupHash'
                $SystemGroupHash = Get-Hash_SystemGroupName_ID
                    
            }
            elseif ($Type -eq 'User')
            {

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
                $limitURL = "$JCUrlBasePath/api/v2/groups?sort=type,name&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent $JCUserAgent

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
            if ($Type -eq 'System')
            {

                $GID = $SystemGroupHash.Get_Item($param.Value)
                $GURL = "$JCUrlBasePath/api/v2/systemgroups/$GID"
                $result = Invoke-RestMethod -Method GET -Uri $GURL -Headers $hdrs -UserAgent $JCUserAgent
                $resultsArray += $result    
            }
            elseif ($Type -eq 'User')
            {

                $GID = $UserGroupHash.Get_Item($param.Value)
                $GURL = "$JCUrlBasePath/api/v2/usergroups/$GID"
                $result = Invoke-RestMethod -Method GET -Uri $GURL -Headers $hdrs -UserAgent $JCUserAgent
                    
                $formattedResult = [PSCustomObject]@{

                    name        = $result.name
                    ldapGroups  = $result.attributes.ldapGroups
                    posixGroups = $result.attributes.posixGroups
                    id          = $result.id
                    type        = $result.type

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