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
        Expand-Archive -LiteralPath "$Path" -DestinationPath $zipArchive.PSParentPath -Force
        $zipArchiveName = $zipArchive.Name.split('_')[0]
        $zipArchiveTimestamp = $zipArchive.Name.split('_')[1].Replace('.zip', '')
        $workingDir = Join-Path -Path $zipArchive.PSParentPath -ChildPath $zipArchiveName
        $Types = If ($PSBoundParameters.Type -eq 'All') {

            $Command = Get-Command $MyInvocation.MyCommand
            $Command.Parameters.Type.Attributes.ValidValues | Where-Object { $_ -ne 'All' }
        }
        Else {
            $PSBoundParameters.Type
        }
        # Identify objects to restore
        $restoreFiles = @()
        $restoreAssociations = @()
        foreach ($item in $Types) {
            $itemPath = Join-Path -Path $workingDir -ChildPath $item
            If (Test-Path -Path: "$itemPath.json") {
                $restoreFiles += Get-Item "$itemPath.json"
            }
            If (Test-Path -Path: "$itemPath-Associations.json") {
                $restoreAssociations += Get-Item "$itemPath-Associations.json"
            }
        }
        Write-Host "restoring backup from $zipArchiveTimestamp"
        Write-Host "there are $($restoreFiles.Count) files in the backup direcotry"
        Write-Host "Working Dir: $workingDir"

        # New Hashtable to track Newly added objects for the orig associations when we restore associations
        $trackList = @{}
        foreach ($file in $restoreFiles){
            # For associations we need to track the ID added and map it back to the orig ID.
            write-host "Restoring: $file"
            $params = (Get-Command New-JCSdk$($file.BaseName)).Parameters.Keys
            $functionName = "Get-JcSdk$($file.BaseName)"
            $existingIds = (& $functionName -Fields id).id
            $data = Get-content $file | ConvertFrom-Json
            $itemProperties = $data | Get-Member -MemberType Properties
            foreach ($item in $data) {
                if ( $item.id -notin $existingIds ) 
                {
                    # Do not import user if Externally Managed user
                    if ( -not $item.ExternallyManaged )
                    {
                        $attributeObjects = @{}
                        $itemProperties | foreach-object {
                            # TODO: Figure out how to pass nested objects like Phone, Address, Attributes to attributeObjects hashtable
                            # validate values in restore object are valid for the object type
                            # ex. we won't pass an ID into New-JcSdkSystem User
                            if ((-not [System.String]::isnullorempty($($_.value))) -And ($_.Name -in $params)) {
                                if ($_.Name -eq "email") {
                                    # Temp fix to test importing users from a backup file, generate unique id for email
                                    write-host "Email: $_.value"
                                    $tempEmail = "$(New-Guid)$($_.value)"
                                    write-host "Setting temp Email for testing: $tempEmail"
                                    $attributeObjects.Add($_.Name, $tempEmail)
                                }
                                elseif ( ($_.Name -eq "Addresses") -or ($_.Name -eq "PhoneNumbers") -or ($_.Name -eq "Attributes") ) {
                                    $formattedList = @()
                                    if ($_.value) {
                                        foreach ($addressItem in $_.value) {
                                            # write-host $addressItem
                                            $hash = @{}
                                            foreach ($subitem in $addressItem.PSObject.Properties) {
                                                $hash.Add($subitem.Name, "$($subitem.Value)")
                                            }
                                            $formattedList += $hash
                                        }
                                    }
                                    # $formattedList
                                    $attributeObjects.Add($_.Name, $formattedList)
                                }
                                else {
                                    # Add attributes to attributeObjects hash table
                                    $attributeObjects.Add($_.Name, $_.value)
                                }
                            }
                        }
                    }

                    # Invoke command to create new resource
                    $functionName = "New-JcSdk$($file.BaseName)"
                    # "########################################"
                    # write-host @attributeObjects
                    # "########################################"
                    $newItem = & $functionName @attributeObjects
                    # try {
                    #     # Restore the item with the splatted @attributeObjects hashtable of valid params
                    #     $newItem = & $functionName @attributeObjects -ErrorAction Continue
                    # }
                    # catch {
                    #     # TODO: Better errors here
                    #     write-host "Error Restoring: $($item.id)"
                    # }
                    # For debugging write out the ids and add items to trackList for associations later on
                    if ($newItem){
                        write-host "Old ID: $($item.id)"
                        write-host "New ID: $($newItem.Id)"
                        $trackList.Add("$($item.id)", "$($newItem.Id)")
                    }
                }
            }
        }

        # Save the added items and their mapped IDs to: RestoreMap.json
        # $trackList | ConvertTo-Json | Out-File -FilePath:("$($workingDir)/RestoreMap.json") -Force
        # for reference how the ids map back to eachother
        foreach ($item in $trackList.keys){
            write-host "OldID: $item maps to NewID: $($tracklist[$item])"
        }

        # For each assoicaiton list:
        # $associationFiles = Get-ChildItem $workingDir -filter *-Associations.json
        foreach ($file in $restoreAssociations) {
            $associations = Convertfrom-Json -InputObject (Get-Content $file -raw)
            # for each association
            foreach ($item in $associations) {
                # If the NewID maps back to a valid OldID, for both the source and target, create the Association
                if ($($tracklist[$($item.id)]) -And $($tracklist[$($item.targetId)])) {
                    New-JCAssociation -Type $($item.type) -Id $($tracklist[$($item.id)]) -TargetId $($tracklist[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
                }
            }
        }
        # TODO: for testing:
        # remove-jcusergroup PesterTest_UserGroup -Force; remove-jcusergroup ybelgqoz -Force; remove-jcsystemgroup PesterTest_SystemGroup -Force; $users = Get-JCUser | Where-Object { $_.email -Match "@pestertest" }; $users | Remove-JCUser -force; $users = Get-JCUser | Where-Object { $_.email -Match "@deleteme" }; $users | Remove-JCUser -force; $users = Get-JCUser | Where-Object { $_.email -Match "@fhpomlyu" }; $users | Remove-JCUser -force;


    }
    End
    {
        # Clean up global variables
        $GlobalVars = @('JCHttpRequest', 'JCHttpRequestContent', 'JCHttpResponse', 'JCHttpResponseContent')
        $GlobalVars | ForEach-Object {
            If ((Get-Variable -Scope:('Global')).Where( { $_.Name -eq $_ })) { Remove-Variable -Name:($_) -Scope:('Global') }
        }
        Return $Results

    }
}