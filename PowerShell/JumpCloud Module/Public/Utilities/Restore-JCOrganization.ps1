<#
.Synopsis
The function exports objects from your JumpCloud organization to local json files
.Description
The function exports objects from your JumpCloud organization to local json files
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}

.Notes

.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V1/docs/exports/Restore-JcSdkOrganization.md
#>
Function Restore-JcSdkOrganization
{
    [CmdletBinding(DefaultParameterSetName = 'Restore', PositionalBinding = $false)]
    Param(
        [Parameter(ParameterSetName = 'Restore', Mandatory)]
        [System.String]
        # Specify input .zip
        ${Path},

        [Parameter()]
        [ValidateSet('All', 'SystemGroup', 'UserGroup', 'SystemUser')]
        [System.String[]]
        # Specify the type of JumpCloud objects you want to backup.
        ${Type}

        # [Parameter(DontShow)]
        # [JumpCloud.SDK.V1.Category('Runtime')]
        # [System.Management.Automation.SwitchParameter]
        # # Wait for .NET debugger to attach
        # ${Break},

        # [Parameter(DontShow)]
        # [ValidateNotNull()]
        # [JumpCloud.SDK.V1.Category('Runtime')]
        # [JumpCloud.SDK.V1.Runtime.SendAsyncStep[]]
        # # SendAsync Pipeline Steps to be appended to the front of the pipeline
        # ${HttpPipelineAppend},

        # [Parameter(DontShow)]
        # [ValidateNotNull()]
        # [JumpCloud.SDK.V1.Category('Runtime')]
        # [JumpCloud.SDK.V1.Runtime.SendAsyncStep[]]
        # # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        # ${HttpPipelinePrepend},

        # [Parameter(DontShow)]
        # [JumpCloud.SDK.V1.Category('Runtime')]
        # [System.Uri]
        # # The URI for the proxy server to use
        # ${Proxy},

        # [Parameter(DontShow)]
        # [ValidateNotNull()]
        # [JumpCloud.SDK.V1.Category('Runtime')]
        # [System.Management.Automation.PSCredential]
        # # Credentials for a proxy server to use for the remote call
        # ${ProxyCredential},

        # [Parameter(DontShow)]
        # [JumpCloud.SDK.V1.Category('Runtime')]
        # [System.Management.Automation.SwitchParameter]
        # # Use the default credentials for the proxy
        # ${ProxyUseDefaultCredentials}
    )
    Begin
    {
        $Results = @()
        $PSBoundParameters.Add('HttpPipelineAppend', {
                param($req, $callback, $next)
                # call the next step in the Pipeline
                $ResponseTask = $next.SendAsync($req, $callback)
                $global:JCHttpRequest = $req
                $global:JCHttpRequestContent = If (-not [System.String]::IsNullOrEmpty($req.Content)) { $req.Content.ReadAsStringAsync() }
                $global:JCHttpResponse = $ResponseTask
                # $global:JCHttpResponseContent = If (-not [System.String]::IsNullOrEmpty($ResponseTask.Result.Content)) { $ResponseTask.Result.Content.ReadAsStringAsync() }
                Return $ResponseTask
            }
        )
    }
    Process
    {
        $zipArchive = Get-Item $Path
        Expand-Archive -Path "$Path" -DestinationPath $zipArchive.Directory -Force
        $zipArchiveName = $zipArchive.Name.split('_')[0]
        $zipArchiveTimestamp = $zipArchive.Name.split('_')[1].Replace('.zip', '')
        $workingDir = Get-Item $zipArchive.BaseName #-ChildPath $zipArchiveName
        $Types = If ($PSBoundParameters.Type -eq 'All')
        {
            $Command = Get-Command $MyInvocation.MyCommand
            $Command.Parameters.Type.Attributes.ValidValues | Where-Object { $_ -ne 'All' }
        }
        Else 
        {
            $PSBoundParameters.Type
        }
        # Identify objects to restore
        $restoreFiles = @()
        $restoreAssociations = @()
        foreach ($item in $Types)
        {
            $itemPath = Join-Path -Path $workingDir -ChildPath $item
            If (Test-Path -Path: "$itemPath.json")
            {
                $restoreFiles += Get-Item "$itemPath.json"
            }
            If (Test-Path -Path: "$itemPath-Associations.json")
            {
                $restoreAssociations += Get-Item "$itemPath-Associations.json"
            }
        }
        # Write-Host "restoring backup from $zipArchiveTimestamp"
        # Write-Host "there are $($restoreFiles.Count) files in the backup direcotry"
        # Write-Host "Working Dir: $workingDir"

        $jobs = foreach ($file in $restoreFiles)
        {
            Start-Job -ScriptBlock:( {
                Param ($file)
                # Track new objects for the orig associations when restore associations
                $trackList = @{}
                # Get the file from the system again.
                $file = get-item $file
                # write-host "Restoring: $file with basename $($file.BaseName)"
                $params = (Get-Command New-JCSdk$($file.BaseName)).Parameters.Keys
                $functionName = "Get-JcSdk$($file.BaseName)"
                $existingIds = (& $functionName -Fields id).id
                $data = Get-content $file | ConvertFrom-Json
                $itemProperties = $data | Get-Member -MemberType Properties
                foreach ($item in $data)
                {
                    $properties = $itemProperties | Where-Object { ( $params -contains $_.Name ) -and ( -not [string]::IsNullOrEmpty($item.($_.Name)) ) }
                    # Do not import user already exists or user is externally managed
                    if ( ($item.id -notin $existingIds) -and (-not $item.ExternallyManaged) )
                    {
                        $attributeObjects = @{}
                        foreach ( $property in $properties.Name )
                        {
                            # if ($property -eq "email")
                            # {
                            #     # Temp fix to test importing users from a backup file, generate unique id for email
                            #     # write-host "Email: $($item.($property))"
                            #     $tempEmail = "$(New-Guid)$($item.($property))"
                            #     # write-host "Setting temp Email for testing: $tempEmail"
                            #     $attributeObjects.Add($property, $tempEmail)
                            # }
                            if ( ($property -eq "Addresses") -or ($property -eq "PhoneNumbers") -or ($property -eq "Attributes") )
                            {
                                $formattedList = @()
                                if ($item.($property))
                                {
                                    foreach ($nestedItem in $item.($property))
                                    {
                                        # write-host $nestedItem
                                        $hash = @{}
                                        foreach ($subitem in $nestedItem.PSObject.Properties)
                                        {
                                            $hash.Add($subitem.Name, "$($subitem.Value)")
                                        }
                                        $formattedList += $hash
                                    }
                                }
                                # $formattedList
                                $attributeObjects.Add($property, $formattedList)
                            }
                            else
                            {
                                # Add attributes to attributeObjects hash table
                                $attributeObjects.Add($property, $item.($property))
                            }
                        }
                        # Invoke command to create new resource
                        $functionName = "New-JcSdk$($file.BaseName)"
                        # write-host @attributeObjects
                        $newItem = & $functionName @attributeObjects
                        # For debugging write out the ids and add items to trackList for associations later on
                        if ($newItem)
                        {
                            # write-host "Old ID: $($item.id)"
                            # write-host "New ID: $($newItem.Id)"
                            $trackList.Add("$($item.id)", "$($newItem.Id)")
                        }
                    }
                }
            return $trackList
            }) -ArgumentList:($file)
        }
        $JobStatus = Wait-Job -Id:($Jobs.Id)
        $results += $JobStatus | Receive-Job

        # flatten results to single table
        $flattenedMap = @{}
        foreach ($hash in $results) {
            foreach ($key in $hash.Keys) {
                # write-host "OldID: $key maps to NewID: $($hash[$key])"
                $flattenedMap.Add($key, $($hash[$key]))
            }
        }
        write-host "$($flattenedMap.count) Items were restored"

        # $jobs = foreach ($file in $restoreAssociations)
        # {
        #     Start-Job -ScriptBlock:( {
        #         Param ($file, $flattenedMap)
        #         $file = get-item $file
        #         write-host "checking $file"
        #         $functionName = "Get-JcSdk$($file.BaseName)".replace("-Associations", "")
        #         $existingIds = (& $functionName -Fields id).id
        #         $associations = Convertfrom-Json -InputObject (Get-Content $file -raw)
        #         # for each association
        #         # TODO: quickly loop through and find possible target types, get existingTargetIds
        #         $targetTypes = $associations.Paths.ToType | Get-Unique
        #             $JcTypesMap = @{
        #                 application = 'Application'
        #                 command = 'Command'
        #                 g_suite = 'GSuite'
        #                 ldap_server = 'LdapServer'
        #                 office_365 = 'Office365'
        #                 policy = 'Policy'
        #                 radius_server = 'RadiusServer'
        #                 system = 'System'
        #                 system_group = 'SystemGroup'
        #                 user = 'SystemUser'
        #                 user_group = 'UserGroup'
        #             }
        #         $existingTargetIds = @()
        #         foreach ($item in $targetTypes)
        #         {
        #             $functionName = "Get-JcSdk$($JcTypesMap[$item])"
        #             $existingTargetIds += (& $functionName -Fields id).id
        #         }
        #         foreach ($item in $associations)
        #         {
        #             if ($($flattenedMap[$($item.id)]) -And $($flattenedMap[$($item.targetId)]) -And ($($item.associationType) -eq "direct"))
        #             {
        #                 # If the NewID maps back to a valid OldID, for both the source and target, create the Association
        #                 # Write-Host "Association Restore Type: New Source & Target"
        #                 New-JCAssociation -Type $($item.type) -Id $($flattenedMap[$($item.id)]) -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
        #             }
        #             if (($($flattenedMap[$($item.id)])) -And ($item.targetId -in $existingTargetIds) -And ($($item.associationType) -eq "direct"))
        #             {
        #                 # NewID Maps to Old ID for source, associated w/ existingTargetID
        #                 # Write-Host "Association Restore Type: New Source, Existing Target"
        #                 New-JCAssociation -Type $($item.type) -Id $($flattenedMap[$($item.id)]) -TargetId $item.targetId -TargetType $($item.Paths.ToType) -Force
        #             }
        #             if (($item.id -in $existingIds) -And $($flattenedMap[$($item.targetId)]) -And ($($item.associationType) -eq "direct"))
        #             {
        #                 # Source Old ID exists and Target NewID maps to Old ID
        #                 # Write-Host "Association Restore Type: Existing Source, New Target"
        #                 New-JCAssociation -Type $($item.type) -Id $item.id -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
        #             }
        #             if (($item.id -in $existingIds) -And ($item.targetId -in $existingTargetIds) -And ($($item.associationType) -eq "direct"))
        #             {
        #                 # Source & Target exist, update association
        #                 if ($item.targetId -notin (Get-JCAssociation -Id $item.id -Type $item.type -TargetType $($item.Paths.ToType)).targetId)
        #                 {
        #                     write-Host "Assocation Restored!"
        #                     New-JCAssociation -Type $($item.type) -Id $item.id -TargetId $item.targetId -TargetType $($item.Paths.ToType) -Force
        #                 }

        #             }
        #         }
        #     }) -ArgumentList:($file, $flattenedMap)
        # }
        # $JobStatus = Wait-Job -Id:($Jobs.Id)
        # $JobStatus | Receive-Job
        # $finalCount = 0
        # foreach ($item in $associationsResults) {
        #     write-host "value $item"
        #     $finalCount += $item
        # }
        # write-host "$($finalCount) Associations were restored"

        # TODO: for testing:
        # remove-jcusergroup PesterTest_UserGroup -Force; remove-jcusergroup ybelgqoz -Force; remove-jcsystemgroup PesterTest_SystemGroup -Force; $users = Get-JCUser | Where-Object { $_.email -Match "@pestertest" }; $users | Remove-JCUser -force; $users = Get-JCUser | Where-Object { $_.email -Match "@deleteme" }; $users | Remove-JCUser -force; $users = Get-JCUser | Where-Object { $_.email -Match "@fhpomlyu" }; $users | Remove-JCUser -force;


    }
    End
    {
        # Clean up global variables
        # $GlobalVars = @('JCHttpRequest', 'JCHttpRequestContent', 'JCHttpResponse', 'JCHttpResponseContent')
        # $GlobalVars | ForEach-Object
        # {
        #     If ((Get-Variable -Scope:('Global')).Where( { $_.Name -eq $_ })) { Remove-Variable -Name:($_) -Scope:('Global') }
        # }
        # Return $Results
    }
}