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
        Expand-Archive -LiteralPath "$Path" -DestinationPath $zipArchive.Directory -Force
        $zipArchiveName = $zipArchive.Name.split('_')[0]
        $zipArchiveTimestamp = $zipArchive.Name.split('_')[1].Replace('.zip', '')
        $workingDir = Join-Path -Path $zipArchive.Directory -ChildPath $zipArchiveName
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
                            if ($property -eq "email")
                            {
                                # Temp fix to test importing users from a backup file, generate unique id for email
                                # write-host "Email: $($item.($property))"
                                $tempEmail = "$(New-Guid)$($item.($property))"
                                # write-host "Setting temp Email for testing: $tempEmail"
                                $attributeObjects.Add($property, $tempEmail)
                            }
                            elseif ( ($property -eq "Addresses") -or ($property -eq "PhoneNumbers") -or ($property -eq "Attributes") )
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

        $jobs = foreach ($file in $restoreAssociations)
        {
            Start-Job -ScriptBlock:( {
                    Param ($file, $flattenedMap)
                $file = get-item $file
                $associations = Convertfrom-Json -InputObject (Get-Content $file -raw)
                # for each association
                foreach ($item in $associations)
                {
                    # If the NewID maps back to a valid OldID, for both the source and target, create the Association
                    if ($($flattenedMap[$($item.id)]) -And $($flattenedMap[$($item.targetId)]))
                    {
                        New-JCAssociation -Type $($item.type) -Id $($flattenedMap[$($item.id)]) -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
                    }
                }
            }) -ArgumentList:($file, $flattenedMap)
        }
        $JobStatus = Wait-Job -Id:($Jobs.Id)
        $JobStatus | Receive-Job


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
# Restore-JcSdkOrganization -Path /Users/jworkman/Dec15Backup/JumpCloud_20201216T1019123092.zip -Type All