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
        ${Path}

        # [Parameter()]
        # [ValidateSet("All", "Applications", "Command", "Directory", "LdapServer", "Policy", "RadiusServer", "SoftwareApp", "System", "SystemGroup", "SystemUser", "UserGroup", "Settings")]
        # [System.String[]]
        # ${Type},
        # Add validate path
        # [-All] [-Applications] [-Commands] [-Directories] [-LdapServers] [-Policies] [-RadiusServers] [-SoftwareApps] [-System] [-SystemGroup] [-SystemUser] [-UserGroup] [-Settings]

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
        # expand the archive and take note of the timestamp
        # TODO: fix temp path for all OS
        $zipArchive = Get-Item $Path
        Expand-Archive -LiteralPath "$Path" -DestinationPath $env:TMPDIR -Force
        $zipArchiveName = $zipArchive.Name.split('_')[0]
        $zipArchiveTimestamp = $zipArchive.Name.split('_')[1].Replace('.zip', '')
        $workingDir = "$env:TMPDIR$($zipArchiveName)"
        $workingFiles = Get-ChildItem $workingDir
        Write-Host "restoring backup from $zipArchiveTimestamp"
        Write-Host "there are $($workingFiles.Count) files in the backup direcotry"
        Write-Host "Working Dir: $workingDir"
        # if the path does not exist, create it

        # TODO: Define the restore files we can create (All but system):
        # WorkingFiles, where name not like "-Associations"
        # $Types = ('SystemUser', 'UserGroup', 'LdapServer', 'RadiusServer', 'Application', 'System', 'SystemGroup', 'Policy', 'Command', 'SoftwareApp', 'Directory')
        foreach ($file in $workingFiles){
            if ($file -notMatch "-associations"){
                write-host "$($file.Name)"
                # For associations we need to track the ID added and map it back to the orig ID.
                $trackList = @{}
                if ($file -Match "SystemUser"){
                    write-host "Restoring: $file"
                    # New-JcSdkSystemUser:
                    # Email                           EnableUserPortalMultifactor     PasswordNeverExpires
                    # Username                        ExternalDn                      PasswordlessSudo
                    # AccountLocked                   ExternalPasswordExpirationDate  PhoneNumbers
                    # Activated                       ExternalSourceType              PublicKey
                    # Addresses                       ExternallyManaged               Relationships
                    # AllowPublicKey                  Firstname                       SambaServiceUser
                    # Attributes                      JobTitle                        Sudo
                    # Company                         Lastname                        Suspended
                    # CostCenter                      LdapBindingUser                 UnixGuid
                    # Department                      Location                        UnixUid
                    # Description                     MfaConfigured                   Body
                    # Displayname                     MfaExclusion                    PassThru
                    # EmployeeIdentifier              MfaExclusionUntil               WhatIf
                    # EmployeeType                    Middlename                      Confirm
                    # EnableManagedUid                Password
                    $data = Get-Content $file | ConvertFrom-Json
                    foreach ($item in $data) {
                        $attributeObjects = @{}
                        $item.PSObject.Properties | foreach-object {
                            # $name = $_.Name
                            # $value = $_.value
                            # Get attributes with values
                            if (-not [System.String]::isnullorempty($($_.value))){
                                # Add attributes to attributeObjects hash table
                                $attributeObjects.Add($_.Name, $_.value)
                            }
                        }
                        # build the command to invoke new user
                        $commandString = "New-JcSdkSystemUser "
                        foreach ($attribute in $attributeObjects.Keys) {
                            # TODO: dynamically fix nested attributes
                            # if ($attribute -eq "PhoneNumbers"){
                            #     write-host "$attribute"
                            #     # $cake = $attribute
                            #     $attributeObjects["$attribute"]

                            # }
                            $commandString += "-$($attribute) $($attributeObjects[$attribute]), "
                        }
                        write-host "$commandString"
                        # TODO: invoke command for new user, map old $item.ID to newly added user ID and add to $tracklist.
                    }
                }
            }
        }

        # if (-not (Test-Path $Path)){
        #     New-Item -Path "$Path" -Name "$($Path.BaseName)" -ItemType "directory"
        # }
        # if ($Type -eq "All"){
        #     $Types = ('SystemUser', 'UserGroup', 'LdapServer', 'RadiusServer', 'Application', 'System', 'SystemGroup', 'Policy', 'Command', 'SoftwareApp', 'Directory')
        # }
        # else {
        #     $Types = $Type
        # }
        # # $Types = ('SystemUser', 'UserGroup', 'LdapServer')#, 'LdapServer', 'RadiusServer', 'Application', 'System', 'SystemGroup', 'Policy', 'Command', 'SoftwareApp', 'Directory')
        # # Map to define how jcassoc & jcsdk types relate
        # $map = @{
        #     Application  = 'application';
        #     Command      = 'command';
        #     # aaa          = 'g_suite';
        #     LdapServer   = 'ldap_server';
        #     # bbb          = 'office_365';
        #     Policy       = 'policy';
        #     RadiusServer = 'radius_server';
        #     System       = 'system';
        #     SystemGroup  = 'system_group';
        #     SystemUser   = 'user';
        #     UserGroup    = 'user_group';
        # }

        # $Jobs = $Types | ForEach-Object {
        #     $JumpCloudType = $_
        #     Start-Job -ScriptBlock:( {
        #             param ($Path, $JumpCloudType);
        #             $CommandTemplate = "Get-JcSdk{0}"
        #             $Result = Invoke-Expression -Command:($CommandTemplate -f $JumpCloudType)
        #             Write-Debug ('HttpRequest: ' + $JCHttpRequest);
        #             Write-Debug ('HttpRequestContent: ' + $JCHttpRequestContent.Result);
        #             Write-Debug ('HttpResponse: ' + $JCHttpResponse.Result);
        #             # Write-Debug ('HttpResponseContent: ' + $JCHttpResponseContent.Result);

        #             # Write output to file
        #             $Result `
        #             | Select-Object @{Name = 'JcSdkType'; Expression = { $JumpCloudType } }, * `
        #             | ConvertTo-Json -Depth:(100) `
        #             | Out-File -FilePath:("$($Path)/$($JumpCloudType).json") -Force
        #         }) -ArgumentList:($Path, $JumpCloudType)
        # }
        # $JobStatus = Wait-Job -Id:($Jobs.Id)
        # $JobStatus | Receive-Job



        # # Get the backup files we created earlier
        # $files = Get-ChildItem $Path | Where-Object { $_.BaseName -in $Types }
        # $JobsAssoc = $files | ForEach-Object {
        #     $file = $_
        #     Start-Job -ScriptBlock:( {
        #         param ($Path, $Types, $map, $file);
        #         $assoc = @()
        #         # Get content from the file
        #         $jsonContent = Get-Content $file | ConvertFrom-Json
        #         foreach ($item in $jsonContent){
        #             $result = Get-JCAssociation -type $map["$($item.JcSdkType)"] -id $($item.id)
        #             if ($result) {
        #                 $assoc += $result
        #             }
        #         }
        #         # Write out the results
        #         if (-not [System.String]::IsNullOrEmpty($assoc)){
        #             $assoc | ConvertTo-Json -Depth: 100 | Out-File -FilePath:("$file-associations.json") -Force
        #         }
        #     }) -ArgumentList:($Path, $Types, $map, $file)
        # }
        # $JobStatus = Wait-Job -Id:($JobsAssoc.Id)
        # $JobStatus | Receive-Job
        # $time = get-date -UFormat %m-%d-%Y-%T
        # $compress = @{
        #     path = $Path
        #     CompressionLevel = "Fastest"
        #     Destination = "$Path-$time.zip"
        # }
        # Compress-Archive @compress

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