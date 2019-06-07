Function Add-JCCommandTarget
{
    <#
.SYNOPSIS

Associates a JumpCloud system or a JumpCloud system group with a JumpCloud command

.DESCRIPTION

The Add-JCCommandTarget function allows you to add JumpCloud systems or JumpCloud system groups to the target list of a specific JumpCloud command. Group associations can be made by system group name or system group ID system associations can only be made using the SystemID. When JumpCloud commands are run they target all the systems on their target list.

.EXAMPLE
Add-JCCommandTarget -CommandID 5b99777710a3690ssisr3a1w -SystemID 5l0o2fu426041i79st3c35

Adds the JumpCloud system with System ID '5l0o2fu426041i79st3c35' to the target list for the JumpCloud command with command ID '5b99777710a3690ssisr3a1w'

.EXAMPLE
Add-JCCommandTarget -CommandID 5b99777710a3690ssisr3a1w -GroupName WindowsMachines

Adds the JumpCloud system group 'WindowsMachines' and the systems within this group to the target list for the JumpCloud command with command ID '5b99777710a3690ssisr3a1w'

.EXAMPLE
Add-JCCommandTarget -CommandID 5b99777710a3690ssisr3a1w -GroupID 5j03458a232z115210z66913

Adds the JumpCloud system group with the GroupID '5j03458a232z115210z66913' and the systems within this group to the target list for the JumpCloud command with command ID '5b99777710a3690ssisr3a1w'

#>
    [CmdletBinding(DefaultParameterSetName = 'SystemID')]
    param (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SystemID',
            Position = 0,
            HelpMessage = 'The id value of the JumpCloud command. Use the command "Get-JCCommand | Select-Object _id, name" to find the "_id" value for all the JumpCloud commands in your tenant.'
        ) ]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GroupName',
            Position = 0,
            HelpMessage = 'The id value of the JumpCloud command. Use the command "Get-JCCommand | Select-Object _id, name" to find the "_id" value for all the JumpCloud commands in your tenant.'
        ) ]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GroupID',
            Position = 0,
            HelpMessage = 'The id value of the JumpCloud command. Use the command "Get-JCCommand | Select-Object _id, name" to find the "_id" value for all the JumpCloud commands in your tenant.'
        ) ]

        [Alias('_id', 'id')]
        [String]$CommandID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SystemID',
            Position = 1,
            HelpMessage = 'The _id of a JumpCloud system. To find the _id of all JumpCloud systems within your tenant run "Get-JCSystem | select _id, hostname"'
        ) ]
        $SystemID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GroupName',
            Position = 1,
            HelpMessage = 'The name of the JumpCloud system group. If the name includes a space enter the name within quotes. Example: -GroupName "The Space"'
        ) ]
        [Alias('name')]
        $GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GroupID',
            Position = 1,
            HelpMessage = 'The id value of a JumpCloud system group.'
        ) ]
        $GroupID

    )

    begin
    {

        Write-Verbose "Paramter set: $($PSCmdlet.ParameterSetName)"

        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }


        if ($PSCmdlet.ParameterSetName -eq 'GroupName')
        {

            Write-Verbose 'Populating SystemGroupNameHash'
            $SystemGroupNameHash = Get-Hash_SystemGroupName_ID

        }



        if ($PSCmdlet.ParameterSetName -eq 'SystemID')
        {

            Write-Verbose 'Populating CommandID_Type hash'
            $CommandID_TypeHash = Get-Hash_CommandID_Type

            Write-Verbose 'Populating SystemID_OS hash'
            $SystemID_OSHash = Get-Hash_SystemID_OS
        }

        Write-Verbose 'Populating CommandNameHash'
        $CommandNameHash = Get-Hash_CommandID_Name

        Write-Verbose 'Initilizing RawResults and resultsArrayList'
        $resultsArray = @()


    }

    process
    {


        switch ($PSCmdlet.ParameterSetName)
        {

            SystemID
            {

                $SystemOS_Raw = $SystemID_OSHash.($SystemID)

                $CommandType = $CommandID_TypeHash.($CommandID)

                switch ($SystemOS_Raw)
                {
                    "Mac OS X" {  $SystemType = 'mac'}
                    Windows {  $SystemType = 'windows'}
                    Default {  $SystemType = 'linux' }
                }

                if ($SystemType -eq $CommandType)
                {

                    $OS_conflict = $false
                }
                else
                {
                    $OS_conflict = $true
                    $Status = 'OS_Conflict'
                }

                $body = @{

                    type = "system"
                    op   = "add"
                    id   = $SystemID

                }

            } # end SystemID switch

            GroupName
            {

                $GroupID = $SystemGroupNameHash.($GroupName)

                $body = @{

                    type = "system_group"
                    op   = "add"
                    id   = $GroupID

                }

            } # end GroupName switch

            GroupID
            {

                $body = @{

                    type = "system_group"
                    op   = "add"
                    id   = $GroupID

                }
            } # end GroupID switch
        } # end switch


        $jsonbody = $body | ConvertTo-Json
        $URL = "$JCUrlBasePath/api/v2/commands/$($CommandID)/associations"


        if ($OS_conflict -ne $true)
        {

            try
            {

                $APIresults = Invoke-RestMethod -Method Post -Uri  $URL  -Header $hdrs -Body $jsonbody -UserAgent:(Get-JCUserAgent)
                $Status = 'Added'

            }
            catch
            {

                $Status = $_.ErrorDetails

            }

        }

        $CommandName = $CommandNameHash.($CommandID)

        $FormattedResults = [PSCustomObject]@{

            'CommandID'   = $CommandID
            'CommandName' = $CommandName
            'Type'        = $body.type
            'id'          = $body.id
            'Status'      = $Status
        }

        $resultsArray += $FormattedResults



    } # end process

    end
    {

        Return $resultsArray
    }
}