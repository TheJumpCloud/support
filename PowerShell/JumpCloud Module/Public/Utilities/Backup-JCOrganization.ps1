<#
.Synopsis
Backup your JumpCloud organization to local json files

.Description
This function exports objects and associations from your JumpCloud organization to local json files.
Association takes a significant amount of time to gather.
The -Format:('csv') is slower than standard json output.

.Example
Backup all available JumpCloud objects and their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp')

.Example
Backup all available JumpCloud objects and their associations to CSV (default json)
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Format:('csv')

.Example
Backup UserGroups and Users with their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','User') -Association

.Example
Backup UserGroups and Users without their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','User')

.Example
Backup all available JumpCloud objects with their associations and return metadata
PS C:\> $BackupJcOrganizationResults = Backup-JCOrganization -Path:('C:\Temp') -PassThru
PS C:\> $BackupJcOrganizationResults.Keys
PS C:\> $BackupJcOrganizationResults.User

.Link
https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Backup-JCOrganization.md
#>

Function Backup-JCOrganization
{
    [CmdletBinding(DefaultParameterSetName = 'All', PositionalBinding = $false)]
    Param(
        [Parameter(Mandatory)]
        [System.String]
        # File directory for backup output
        ${Path},

        [Parameter(ParameterSetName = 'All')]
        [System.Management.Automation.SwitchParameter]
        # Backup all available types and associations
        ${All},

        [Parameter(ParameterSetName = 'Type')]
        [ValidateSet('ActiveDirectory', 'AppleMdm', 'Application', 'AuthenticationPolicy', 'Command', 'Directory', 'Group', 'GSuite', 'IPList', 'LdapServer', 'Office365', 'Organization', 'Policy', 'RadiusServer', 'SoftwareApp', 'System', 'SystemGroup', 'User', 'UserGroup')]
        [System.String[]]
        # JumpCloud objects that you want to backup
        ${Type},

        [Parameter(ParameterSetName = 'Type')]
        [System.Management.Automation.SwitchParameter]
        # Use to backup relationship data between diffrent types
        ${Association},

        [Parameter()]
        [ValidateSet('json', 'csv')]
        [System.String]
        # The format of the output files
        ${Format} = 'json',

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        # Return object metadata to pipeline
        ${PassThru}
    )
    Begin
    {
        If ([System.String]::IsNullOrEmpty($env:JCApiKey) -or [System.String]::IsNullOrEmpty($env:JCOrgId)) { Connect-JCOnline }
        $TimerTotal = [Diagnostics.Stopwatch]::StartNew()
        $Date = Get-Date -Format:("yyyyMMddTHHmmssffff")
        $ChildPath = "JumpCloud_$($Date)"
        $Path = Resolve-Path -Path:($Path)
        $TempPath = Join-Path -Path:($Path) -ChildPath:($ChildPath)
        $ArchivePath = Join-Path -Path:($Path) -ChildPath:("$($ChildPath).zip")
        $OutputHash = [ordered]@{}
        # If the backup directory does not exist, create it
        If (-not (Test-Path $TempPath))
        {
            $BackupLocation = New-Item -Path:($TempPath) -Name:$($TempPath.BaseName) -ItemType:('directory')
            $OutputHash.Add('BackupLocation', $BackupLocation)
        }
        # When -All is provided use all type options and Association
        $Types = If ($PSCmdlet.ParameterSetName -eq 'All')
        {
            $Association = $true
            (Get-Command $MyInvocation.MyCommand).Parameters.Type.Attributes.ValidValues
        }
        Else
        {
            $Type
        }
        # Map to define how JCAssociation & JcSdk types relate
        $JcTypesMap = @{
            ActiveDirectory      = [PSCustomObject]@{Name = 'active_directory'; AssociationTargets = @('user', 'user_group'); };
            AppleMdm             = [PSCustomObject]@{Name = 'apple_mdm'; AssociationTargets = @(); };
            Application          = [PSCustomObject]@{Name = 'application'; AssociationTargets = @('user', 'user_group'); };
            AuthenticationPolicy = [PSCustomObject]@{Name = 'authentication_policy'; AssociationTargets = @(); };
            Command              = [PSCustomObject]@{Name = 'command'; AssociationTargets = @('system', 'system_group'); };
            Directory            = [PSCustomObject]@{Name = 'directory'; AssociationTargets = @(); };
            Group                = [PSCustomObject]@{Name = 'group'; AssociationTargets = @(); };
            GSuite               = [PSCustomObject]@{Name = 'g_suite'; AssociationTargets = @( 'user', 'user_group'); };
            IPList               = [PSCustomObject]@{Name = 'ip_list'; AssociationTargets = @(); };
            LdapServer           = [PSCustomObject]@{Name = 'ldap_server'; AssociationTargets = @('user', 'user_group'); };
            Office365            = [PSCustomObject]@{Name = 'office_365'; AssociationTargets = @('user', 'user_group'); };
            Organization         = [PSCustomObject]@{Name = 'organization'; AssociationTargets = @(); };
            Policy               = [PSCustomObject]@{Name = 'policy'; AssociationTargets = @( 'system', 'system_group'); };
            RadiusServer         = [PSCustomObject]@{Name = 'radius_server'; AssociationTargets = @('user', 'user_group'); };
            SoftwareApp          = [PSCustomObject]@{Name = 'software_app'; AssociationTargets = @( 'system', 'system_group'); };
            System               = [PSCustomObject]@{Name = 'system'; AssociationTargets = @( 'command', 'policy', 'system_group', 'user', 'user_group'); };
            SystemGroup          = [PSCustomObject]@{Name = 'system_group'; AssociationTargets = @( 'command', 'policy', 'system', 'user', 'user_group'); };
            User                 = [PSCustomObject]@{Name = 'user'; AssociationTargets = @('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system', 'system_group', 'user_group'); };
            UserGroup            = [PSCustomObject]@{Name = 'user_group'; AssociationTargets = @('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system', 'system_group', 'user'); };
        }
    }
    Process
    {
        $TimerObject = [Diagnostics.Stopwatch]::StartNew()
        # Foreach type start a new job and retrieve object records
        $ObjectJobs = @()
        ForEach ($JumpCloudType In $Types)
        {
            $SourceTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Key -eq $JumpCloudType }
            $ObjectBaseName = "{0}" -f $SourceTypeMap.Key
            $ObjectFileName = "{0}.{1}" -f $ObjectBaseName, $Format
            $ObjectFullName = "{0}/{1}" -f $TempPath, $ObjectFileName
            $ObjectJobs += Start-Job -ScriptBlock:( { Param ($SourceTypeMap, $ObjectBaseName, $ObjectFileName, $ObjectFullName, $Format, $Debug);
                    # Logic to handle directories
                    $Command = If ($SourceTypeMap.Key -eq 'GSuite')
                    {
                        "(Get-JcSdkDirectory | Where-Object { `$_.Type -eq '$($SourceTypeMap.Value.Name)' }) | ForEach-Object { Get-JcSdk$($SourceTypeMap.Key) -Id:(`$_.Id)}"
                    }
                    ElseIf ($SourceTypeMap.Key -eq 'Office365')
                    {
                        "(Get-JcSdkDirectory | Where-Object { `$_.Type -eq '$($SourceTypeMap.Value.Name)' }) | ForEach-Object { Get-JcSdk$($SourceTypeMap.Key) -$($SourceTypeMap.Key)Id:(`$_.Id)}"
                    }
                    ElseIf ($SourceTypeMap.Key -eq 'Organization')
                    {
                        "Get-JcSdk{0} -Id:('{1}')" -f $SourceTypeMap.Key, $env:JCOrgId
                    }
                    Else
                    {
                        "Get-JcSdk{0}" -f $SourceTypeMap.Key
                    }
                    If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                    $Result = Invoke-Expression -Command:($Command)
                    If (-not [System.String]::IsNullOrEmpty($Result))
                    {
                        # Write output to file
                        If ($Format -eq 'json')
                        {
                            $Result | ConvertTo-Json -Depth:(100) | Out-File -FilePath:($ObjectFullName) -Force
                        }
                        ElseIf ($Format -eq 'csv')
                        {
                            # Convert object properties of objects to compressed json strings
                            $Result | ForEach-Object {
                                $NewRecord = [PSCustomObject]@{}
                                $_.PSObject.Properties | ForEach-Object {
                                    If ($_.TypeNameOfValue -like '*.Models.*' -or $_.TypeNameOfValue -like '*Object*' -or $_.TypeNameOfValue -like '*String`[`]*')
                                    {
                                        Add-Member -InputObject:($NewRecord) -MemberType:('NoteProperty') -Name:($_.Name) -Value:($_.Value | ConvertTo-Json -Depth:(100) -Compress)
                                    }
                                    Else
                                    {
                                        Add-Member -InputObject:($NewRecord) -MemberType:('NoteProperty') -Name:($_.Name) -Value:($_.Value)
                                    }
                                }
                                Return $NewRecord
                            } | Export-Csv -NoTypeInformation -Path:($ObjectFullName) -Force
                        }
                        Else
                        {
                            Write-Error ("Unknown format: $Format")
                        }
                        # TODO: Potential use for restore function
                        #| ForEach-Object { $_ | Select-Object *, @{Name = 'JcSdkModel'; Expression = { $_.GetType().FullName } } } `
                        # Build hash to return data
                        Return @{$ObjectBaseName = $Result }
                    }
                }) -ArgumentList:($SourceTypeMap, $ObjectBaseName, $ObjectFileName, $ObjectFullName, $Format, $PSBoundParameters.Debug)
        }
        $ObjectJobStatus = Wait-Job -Id:($ObjectJobs.Id)
        $ObjectJobResults = $ObjectJobStatus | Receive-Job
        # Add the results of objects to outputhash results
        $ObjectJobResults | ForEach-Object {
            $_.GetEnumerator() | ForEach-Object {
                $OutputHash.Add($_.Key, $_.Value)
            }
        }
        $TimerObject.Stop()
        # Foreach type start a new job and retrieve object association records
        If ($Association)
        {
            $AssociationJobs = @()
            $TimerAssociations = [Diagnostics.Stopwatch]::StartNew()
            # Get the backup files we created earlier
            $BackupFiles = Get-ChildItem -Path:($TempPath) | Where-Object { $_.BaseName -in $Types }
            ForEach ($BackupFile In $BackupFiles)
            {
                # Type mapping lookup
                $SourceTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Key -eq $BackupFile.BaseName }
                # TODO: Figure out how to make this work with x-ms-enum.
                # $ValidTargetTypes = (Get-Command Get-JcSdk$($SourceTypeMap.Key)Association).Parameters.Targets.Attributes.ValidValues
                # $ValidTargetTypes = ((Get-Command Get-JcSdk$($SourceTypeMap.Key)Association).Parameters.Targets.ParameterType.DeclaredFields | Where-Object { $_.IsPublic }).Name
                # Get list of valid target types from Get-JCAssociation
                $ValidTargetTypes = $SourceTypeMap.Value.AssociationTargets
                # Lookup file names in $JcTypesMap
                ForEach ($ValidTargetType In $ValidTargetTypes)
                {
                    $TargetTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Value.Name -eq $ValidTargetType }
                    # If the valid target type matches a file name look up the associations for the SourceType and TargetType
                    If ($TargetTypeMap.Key -in $BackupFiles.BaseName)
                    {
                        $AssociationBaseName = "Association-{0}To{1}" -f $SourceTypeMap.Key, $TargetTypeMap.Key
                        $AssociationFileName = "{0}.{1}" -f $AssociationBaseName, $Format
                        $AssociationFullName = "{0}/{1}" -f $TempPath, $AssociationFileName
                        $AssociationJobs += Start-Job -ScriptBlock:( { Param ($SourceTypeMap, $TargetTypeMap, $BackupFile, $AssociationBaseName, $AssociationFileName, $AssociationFullName, $Format, $Settings, $Debug);
                                $AssociationResults = @()
                                # Get content from the file
                                $BackupRecords = If ($Format -eq 'json')
                                {
                                    Get-Content -Path:($BackupFile.FullName) | ConvertFrom-Json
                                }
                                ElseIf ($Format -eq 'csv')
                                {
                                    Import-Csv -Path:($BackupFile.FullName)
                                }
                                Else
                                {
                                    Write-Error ("Unknown format: $Format")
                                }
                                ForEach ($BackupRecord In $BackupRecords)
                                {
                                    # Build Command based upon source and target combinations
                                    # *Group commands take "GroupId" as a parameter vs "{Type}Id"
                                    # User associations is called Get-JcSdkUserAssociation and Get-JcSdkUserMember
                                    If (($SourceTypeMap.Value.Name -eq 'system' -and $TargetTypeMap.Value.Name -eq 'system_group') -or ($SourceTypeMap.Value.Name -eq 'user' -and $TargetTypeMap.Value.Name -eq 'user_group'))
                                    {
                                        $Command = 'Get-JcSdk{0}Member -{1}Id:("{2}")' -f $SourceTypeMap.Key, $SourceTypeMap.Key.Replace('UserGroup', 'Group').Replace('SystemGroup', 'Group'), $BackupRecord.id
                                        If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                        $AssociationResult = Invoke-Expression -Command:($Command)
                                        If (-not [System.String]::IsNullOrEmpty($AssociationResult))
                                        {
                                            # The direct association/"Get-JcSdk*Member" endpoints return null for FromId. So manually populate them here.
                                            $AssociationResult.Paths | ForEach-Object {
                                                $_ | ForEach-Object {
                                                    If ([System.String]::IsNullOrEmpty($_.FromId))
                                                    {
                                                        $_.FromId = $BackupRecord.id
                                                    }
                                                    # The direct association/"Get-JcSdk*Member" endpoints return null for FromType. So manually populate them here.
                                                    If ([System.String]::IsNullOrEmpty($_.FromType))
                                                    {
                                                        $_.FromType = $SourceTypeMap.Value.Name
                                                    }
                                                }
                                            }
                                            $AssociationResults += $AssociationResult
                                        }
                                    }
                                    ElseIf (($SourceTypeMap.Value.Name -eq 'system_group' -and $TargetTypeMap.Value.Name -eq 'system') -or ($SourceTypeMap.Value.Name -eq 'user_group' -and $TargetTypeMap.Value.Name -eq 'user'))
                                    {
                                        $Command = 'Get-JcSdk{0}Membership -{1}Id:("{2}")' -f $SourceTypeMap.Key, $SourceTypeMap.Key.Replace('UserGroup', 'Group').Replace('SystemGroup', 'Group'), $BackupRecord.id
                                        If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                        $AssociationResult = Invoke-Expression -Command:($Command)
                                        If (-not [System.String]::IsNullOrEmpty($AssociationResult))
                                        {
                                            # The direct association/"Get-JcSdk*Membership" endpoints return null for FromId. So manually populate them here.
                                            $AssociationResult.Paths | ForEach-Object {
                                                $_ | ForEach-Object {
                                                    If ([System.String]::IsNullOrEmpty($_.FromId))
                                                    {
                                                        $_.FromId = $BackupRecord.id
                                                    }
                                                    # The direct association/"Get-JcSdk*Membership" endpoints return null for FromType. So manually populate them here.
                                                    If ([System.String]::IsNullOrEmpty($_.FromType))
                                                    {
                                                        $_.FromType = $SourceTypeMap.Value.Name
                                                    }
                                                }
                                            }
                                            $AssociationResults += $AssociationResult
                                        }
                                    }
                                    ElseIf (($SourceTypeMap.Value.Name -eq 'command' -and $TargetTypeMap.Value.Name -eq 'system' -and $Settings.ROLE -eq 'Read Only') -or ($SourceTypeMap.Value.Name -eq 'command' -and $TargetTypeMap.Value.Name -eq 'system_group' -and $Settings.ROLE -eq 'Read Only'))
                                    {
                                        # Note on SA-2014 read only cases, this is temporary and should be addressed in the API but this is proving difficult, these cases are only necessary since the association endpoints on systems->commands/softwareapps is disabled for readonly users
                                        $Command = 'Get-JcSdk{0}Traverse{2} -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id, (Get-Culture).TextInfo.ToTitleCase($TargetTypeMap.Value.Name)
                                        If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                        $AssociationResult = Invoke-Expression -Command:($Command)
                                        If (-not [System.String]::IsNullOrEmpty($AssociationResult))
                                        {
                                            # The direct association/"Get-JcSdk*Membership" endpoints return null for FromId. So manually populate them here.
                                            $AssociationResult.Paths | ForEach-Object {
                                                $_ | ForEach-Object {
                                                    If ([System.String]::IsNullOrEmpty($_.FromId))
                                                    {
                                                        $_.FromId = $BackupRecord.id
                                                    }
                                                    # The direct association/"Get-JcSdk*Membership" endpoints return null for FromType. So manually populate them here.
                                                    If ([System.String]::IsNullOrEmpty($_.FromType))
                                                    {
                                                        $_.FromType = $SourceTypeMap.Value.Name
                                                    }
                                                }
                                            }
                                            $AssociationResults += $AssociationResult
                                        }
                                    }
                                    ElseIf (($SourceTypeMap.Value.Name -eq 'system' -and $TargetTypeMap.Value.Name -eq 'command' -and $Global:JCSettings.ROLE -eq 'Read Only') -or ($SourceTypeMap.Value.Name -eq 'system_group' -and $TargetTypeMap.Value.Name -eq 'command' -and $Global:JCSettings.ROLE -eq 'Read Only'))
                                    {
                                        $Command = 'Get-JcSdk{0}Traverse{2} -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id, (Get-Culture).TextInfo.ToTitleCase($TargetTypeMap.Value.Name)
                                        If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                        $AssociationResult = Invoke-Expression -Command:($Command)
                                        If (-not [System.String]::IsNullOrEmpty($AssociationResult))
                                        {
                                            # The direct association/"Get-JcSdk*Membership" endpoints return null for FromId. So manually populate them here.
                                            $AssociationResult.Paths | ForEach-Object {
                                                $_ | ForEach-Object {
                                                    If ([System.String]::IsNullOrEmpty($_.FromId))
                                                    {
                                                        $_.FromId = $BackupRecord.id
                                                    }
                                                    # The direct association/"Get-JcSdk*Membership" endpoints return null for FromType. So manually populate them here.
                                                    If ([System.String]::IsNullOrEmpty($_.FromType))
                                                    {
                                                        $_.FromType = $SourceTypeMap.Value.Name
                                                    }
                                                }
                                            }
                                            $AssociationResults += $AssociationResult
                                        }
                                    }
                                    ElseIf (($SourceTypeMap.Value.Name -eq 'SoftwareApp' -and $TargetTypeMap.Value.Name -eq 'system' -and $Global:JCSettings.ROLE -eq 'Read Only') -or ($SourceTypeMap.Value.Name -eq 'SoftwareApp' -and $TargetTypeMap.Value.Name -eq 'system_group' -and $Global:JCSettings.ROLE -eq 'Read Only'))
                                    {
                                        $Command = 'Get-JcSdk{0}Traverse{2} -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id, (Get-Culture).TextInfo.ToTitleCase($TargetTypeMap.Value.Name)
                                        If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                        $AssociationResult = Invoke-Expression -Command:($Command)
                                        If (-not [System.String]::IsNullOrEmpty($AssociationResult))
                                        {
                                            # The direct association/"Get-JcSdk*Membership" endpoints return null for FromId. So manually populate them here.
                                            $AssociationResult.Paths | ForEach-Object {
                                                $_ | ForEach-Object {
                                                    If ([System.String]::IsNullOrEmpty($_.FromId))
                                                    {
                                                        $_.FromId = $BackupRecord.id
                                                    }
                                                    # The direct association/"Get-JcSdk*Membership" endpoints return null for FromType. So manually populate them here.
                                                    If ([System.String]::IsNullOrEmpty($_.FromType))
                                                    {
                                                        $_.FromType = $SourceTypeMap.Value.Name
                                                    }
                                                }
                                            }
                                            $AssociationResults += $AssociationResult
                                        }
                                    }
                                    ElseIf (($SourceTypeMap.Value.Name -eq 'system' -and $TargetTypeMap.Value.Name -eq 'SoftwareApp' -and $Global:JCSettings.ROLE -eq 'Read Only') -or ($SourceTypeMap.Value.Name -eq 'system_group' -and $TargetTypeMap.Value.Name -eq 'SoftwareApp' -and $Global:JCSettings.ROLE -eq 'Read Only'))
                                    {
                                        $Command = 'Get-JcSdk{0}Traverse{2} -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id, (Get-Culture).TextInfo.ToTitleCase($TargetTypeMap.Value.Name)
                                        If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                        $AssociationResult = Invoke-Expression -Command:($Command)
                                        If (-not [System.String]::IsNullOrEmpty($AssociationResult))
                                        {
                                            # The direct association/"Get-JcSdk*Membership" endpoints return null for FromId. So manually populate them here.
                                            $AssociationResult.Paths | ForEach-Object {
                                                $_ | ForEach-Object {
                                                    If ([System.String]::IsNullOrEmpty($_.FromId))
                                                    {
                                                        $_.FromId = $BackupRecord.id
                                                    }
                                                    # The direct association/"Get-JcSdk*Membership" endpoints return null for FromType. So manually populate them here.
                                                    If ([System.String]::IsNullOrEmpty($_.FromType))
                                                    {
                                                        $_.FromType = $SourceTypeMap.Value.Name
                                                    }
                                                }
                                            }
                                            $AssociationResults += $AssociationResult
                                        }
                                    }
                                    Else
                                    {
                                        $Command = 'Get-JcSdk{0}Association -{1}Id:("{2}") -Targets:("{3}")' -f $SourceTypeMap.Key, $SourceTypeMap.Key.Replace('UserGroup', 'Group').Replace('SystemGroup', 'Group'), $BackupRecord.id, $TargetTypeMap.Value.Name
                                        If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                        $AssociationResult = Invoke-Expression -Command:($Command)
                                        If (-not [System.String]::IsNullOrEmpty($AssociationResult))
                                        {
                                            $AssociationResult | ForEach-Object {
                                                # The direct association/"Get-JcSdk*Association" endpoints return null for FromId. So manually populate them here.
                                                If ([System.String]::IsNullOrEmpty($_.FromId))
                                                {
                                                    $_.FromId = $BackupRecord.id
                                                }
                                                # The direct association/"Get-JcSdk*Association" endpoints return null for FromType. So manually populate them here.
                                                If ([System.String]::IsNullOrEmpty($_.FromType))
                                                {
                                                    $_.FromType = $SourceTypeMap.Value.Name
                                                }
                                            }
                                            $AssociationResults += $AssociationResult
                                        }
                                    }
                                }
                                If (-not [System.String]::IsNullOrEmpty($AssociationResults))
                                {
                                    If ($Format -eq 'json')
                                    {
                                        $AssociationResults | ConvertTo-Json -Depth:(100) | Out-File -FilePath:($AssociationFullName) -Force
                                    }
                                    ElseIf ($Format -eq 'csv')
                                    {
                                        # Convert object properties of objects to compressed json strings
                                        $AssociationResults | ForEach-Object {
                                            $NewRecord = [PSCustomObject]@{}
                                            $_.PSObject.Properties | ForEach-Object {
                                                If ($_.TypeNameOfValue -like '*.Models.*' -or $_.TypeNameOfValue -like '*Object*' -or $_.TypeNameOfValue -like '*String`[`]*')
                                                {
                                                    Add-Member -InputObject:($NewRecord) -MemberType:('NoteProperty') -Name:($_.Name) -Value:($_.Value | ConvertTo-Json -Depth:(100) -Compress)
                                                }
                                                Else
                                                {
                                                    Add-Member -InputObject:($NewRecord) -MemberType:('NoteProperty') -Name:($_.Name) -Value:($_.Value)
                                                }
                                            }
                                            Return $NewRecord
                                        } | Export-Csv -NoTypeInformation -Path:($AssociationFullName) -Force
                                    }
                                    Else
                                    {
                                        Write-Error ("Unknown format: $Format")
                                    }
                                    # Build hash to return data
                                    Return @{$AssociationBaseName = $AssociationResults }
                                }
                            }) -ArgumentList:($SourceTypeMap, $TargetTypeMap, $BackupFile, $AssociationBaseName, $AssociationFileName, $AssociationFullName, $Format, $global:JCSettings, $PSBoundParameters.Debug)
                    }
                }
            }
            If ($AssociationJobs)
            {
                $AssociationJobStatus = Wait-Job -Id:($AssociationJobs.Id)
                $AssociationResults = $AssociationJobStatus | Receive-Job
                # Add the results of associations to outputhash results
                $AssociationResults | ForEach-Object {
                    $_.GetEnumerator() | ForEach-Object {
                        $OutputHash.Add($_.Key, $_.Value)
                    }
                }
            }
            $TimerAssociations.Stop()
        }
    }
    End
    {
        # Write Out Manifest
        [ordered]@{
            date           = $Date;
            organizationId = $env:JCOrgId;
            moduleVersion  = @(Get-Module -Name:('JumpCloud*') -ListAvailable | Select-Object Name, Version);
            result         = Get-ChildItem -Path:($TempPath) | Sort-Object -Property BaseName | ForEach-Object {
                [PSCustomObject]@{
                    Type  = $_.BaseName
                    Count = $OutputHash.Item($_.BaseName).Count
                }
            }
        } | ConvertTo-Json -Depth:(100) | Out-File -FilePath:("$($TempPath)/Manifest.json") -Force
        # Zip results
        Compress-Archive -Path:($TempPath) -CompressionLevel:('Fastest') -Destination:($ArchivePath)
        # Clean up temp directory
        If (Test-Path -Path:($ArchivePath))
        {
            Remove-Item -Path:($TempPath) -Force -Recurse
            Write-Host ("Backup Success: $($ArchivePath)") -ForegroundColor:('Green')
            Write-Host("Backup-JCOrganization Results:") -ForegroundColor:('Green')
            $OutputHash.GetEnumerator() | Sort-Object -Property Name | Select-Object -Skip 1 | ForEach-Object {
                If ($_.Key)
                {
                    Write-Host ("$($_.Key): $($_.Value.Count)") -ForegroundColor:('Magenta')
                }
            }
        }
        $TimerTotal.Stop()
        If ($TimerObject) { Write-Debug ("Object Run Time: $($TimerObject.Elapsed)") }
        If ($TimerAssociations) { Write-Debug ("Association Run Time: $($TimerAssociations.Elapsed)") }
        If ($TimerTotal) { Write-Debug ("Total Run Time: $($TimerTotal.Elapsed)") }
        If ($PassThru)
        {
            Return $OutputHash
        }
        Else
        {
            Return $OutputHash.BackupLocation
        }
    }
}