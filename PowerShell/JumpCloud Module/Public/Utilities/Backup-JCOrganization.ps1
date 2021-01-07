<#
TODO
    . Should association back up all Association for item or just the Association possible within the type parameter?
    . Make this a class in psm1 file: [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
    . Roll back x-ms-enum
    . Change `-direct` switch to where filter
#>
<#
.Synopsis
The function exports objects from your JumpCloud organization to local json files

.Description
The function exports objects from your JumpCloud organization to local json files

.Example
Backup UserGroups and SystemUsers with their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers') -Association

.Example
Backup UserGroups and SystemUsers without their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers')

.Example
Backup all avalible JumpCloud objects and their Association
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -All

.Link
https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Backup-JCOrganization.md
#>

Function Backup-JCOrganization
{
    [CmdletBinding(DefaultParameterSetName = 'All', PositionalBinding = $false)]
    Param(
        [Parameter(Mandatory)]
        [System.String]
        # Specify output file path for backup files
        ${Path},

        [Parameter(ParameterSetName = 'All')]
        [switch]
        # The Username of the JumpCloud user you wish to search for
        ${All},

        [Parameter(ParameterSetName = 'Type')]
        # [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
        [ValidateSet('ActiveDirectory', 'Application', 'Command', 'GSuite', 'LdapServer', 'Office365', 'Policy', 'RadiusServer', 'SoftwareApp', 'System', 'SystemGroup', 'SystemUser', 'UserGroup')]
        [System.String[]]
        # Specify the type of JumpCloud objects you want to backup
        ${Type},

        [Parameter(ParameterSetName = 'Type')]
        [switch]
        # Include to backup object type Association
        ${Association}
    )
    Begin
    {
        $swTotal = [Diagnostics.Stopwatch]::StartNew()
        $Date = Get-Date -Format:("yyyyMMddTHHmmssffff")
        $ChildPath = "JumpCloud_$($Date)"
        $TempPath = Join-Path -Path:($PSBoundParameters.Path) -ChildPath:($ChildPath)
        $ArchivePath = Join-Path -Path:($PSBoundParameters.Path) -ChildPath:("$($ChildPath).zip")
        $Manifest = @{
            name             = "JumpCloudBackup";
            date             = "$Date";
            organizationID   = "$env:JCOrgId"
            backupFiles      = @()
            associationFiles = @()
        }
        # If the path does not exist, create it
        If (-not (Test-Path $TempPath))
        {
            New-Item -Path:($TempPath) -Name:$($TempPath.BaseName) -ItemType:('directory')
        }
        # When -All is provided use all type options and Association
        $Types = If ($PSCmdlet.ParameterSetName -eq 'All')
        {
            $PSBoundParameters.Add('Association', $true)
            (Get-Command $MyInvocation.MyCommand).Parameters.Type.Attributes.ValidValues
        }
        Else
        {
            $PSBoundParameters.Type
        }
        # Map to define how JCAssociation & JcSdk types relate
        $JcTypesMap = @{
            ActiveDirectory = [PSCustomObject]@{Name = 'active_directory'; ApprovedAssociations = @(); FullAssociations = @('user', 'user_group'); }; # Swagger says this works but it doesnt: 'active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365','policy', 'radius_server','system', 'system_group',
            Application     = [PSCustomObject]@{Name = 'application'; ApprovedAssociations = @('user_group'); FullAssociations = @('user', 'user_group'); }; # Swagger says this works but it doesnt:  'active_directory', 'application', 'command', 'g_suite', 'ldap_server','office_365', 'policy', 'radius_server', 'system', 'system_group',
            Command         = [PSCustomObject]@{Name = 'command'; ApprovedAssociations = @('system', 'system_group'); FullAssociations = @('system', 'system_group'); }; # Swagger says this works but it doesnt: 'active_directory', 'application','command','g_suite', 'ldap_server','office_365','policy','radius_server', 'user', 'user_group'
            GSuite          = [PSCustomObject]@{Name = 'g_suite'; ApprovedAssociations = @('user', 'user_group'); FullAssociations = @( 'user', 'user_group'); }; # Swagger says this works but it doesnt: 'active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'software_app', 'system', 'system_group',
            LdapServer      = [PSCustomObject]@{Name = 'ldap_server'; ApprovedAssociations = @('user', 'user_group'); FullAssociations = @('user', 'user_group'); }; # Swagger says this works but it doesnt:'active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group',
            Office365       = [PSCustomObject]@{Name = 'office_365'; ApprovedAssociations = @('user', 'user_group'); FullAssociations = @('user', 'user_group'); }; # Swagger says this works but it doesnt: 'active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'software_app', 'system', 'system_group',
            Policy          = [PSCustomObject]@{Name = 'policy'; ApprovedAssociations = @('system', 'system_group'); FullAssociations = @( 'system', 'system_group'); }; # Swagger says this works but it doesnt:'active_directory', 'application', 'command','g_suite', 'ldap_server','office_365','policy', 'radius_server', 'user', 'user_group'
            RadiusServer    = [PSCustomObject]@{Name = 'radius_server'; ApprovedAssociations = @('user_group'); FullAssociations = @('user', 'user_group'); }; # Swagger says this works but it doesnt:'active_directory', 'application', 'command','g_suite', 'ldap_server','office_365','policy', 'radius_server', 'system', 'system_group',
            SoftwareApp     = [PSCustomObject]@{Name = 'software_app'; ApprovedAssociations = @('system_group', 'system'); FullAssociations = @( 'system', 'system_group'); }; # Swagger says this works but it doesnt:'active_directory','application', 'command','g_suite', 'ldap_server','office_365','policy', 'radius_server', 'user', 'user_group'
            System          = [PSCustomObject]@{Name = 'system'; ApprovedAssociations = @('command', 'policy', 'system_group', 'user'); FullAssociations = @( 'command', 'policy', 'user', 'user_group'); }; # Swagger says this works but it doesnt: 'active_directory','application','g_suite', 'ldap_server','office_365','radius_server'
            SystemGroup     = [PSCustomObject]@{Name = 'system_group'; ApprovedAssociations = @('command', 'policy', 'system', 'user_group'); FullAssociations = @( 'command', 'policy', 'user', 'user_group'); }; # Swagger says this works but it doesnt:'active_directory','application','g_suite', 'ldap_server','office_365','radius_server',
            SystemUser      = [PSCustomObject]@{Name = 'user'; ApprovedAssociations = @('g_suite', 'ldap_server', 'office_365', 'system', 'user_group'); FullAssociations = @('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system', 'system_group'); }; # Swagger says this works but it doesnt: 'command','policy',
            UserGroup       = [PSCustomObject]@{Name = 'user_group'; ApprovedAssociations = @('application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system_group', 'user'); FullAssociations = @('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system', 'system_group'); }; # Swagger says this works but it doesnt: 'command','policy',
        }
    }
    Process
    {
        $sw = [Diagnostics.Stopwatch]::StartNew()
        # Foreach type start a new job and retrieve object records
        $ObjectJobs = @()
        ForEach ($JumpCloudType In $Types)
        {
            $SourceTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Key -eq $JumpCloudType }
            $ObjectJobs += Start-Job -ScriptBlock:( { Param ($TempPath, $SourceTypeMap);
                    # Logic to handle directories
                    $Command = If ($SourceTypeMap.Key -eq 'GSuite')
                    {
                        $DirectoryId = (Get-JcSdkDirectory | Where-Object { $_.Type -eq $SourceTypeMap.Value.Name }).Id
                        "Get-JcSdk{0} -Id:('{1}')" -f $SourceTypeMap.Key, $DirectoryId
                    }
                    ElseIf ($SourceTypeMap.Key -eq 'Office365')
                    {
                        $DirectoryId = (Get-JcSdkDirectory | Where-Object { $_.Type -eq $SourceTypeMap.Value.Name }).Id
                        "Get-JcSdk{0} -{0}Id:('{1}')" -f $SourceTypeMap.Key, $DirectoryId
                    }
                    Else
                    {
                        "Get-JcSdk{0}" -f $SourceTypeMap.Key
                    }
                    Write-Debug ("Running: $Command")
                    $Result = Invoke-Expression -Command:($Command)
                    # Write output to file
                    $Result `
                    | ConvertTo-Json -Depth:(100) `
                    | Out-File -FilePath:("{0}/{1}.json" -f $TempPath, $SourceTypeMap.Key) -Force
                    # TODO: Potential use for restore function
                    #| ForEach-Object { $_ | Select-Object *, @{Name = 'JcSdkModel'; Expression = { $_.GetType().FullName } } } `
                    # Manifest: Populate backupFiles value
                    $backupFiles = @{
                        backupType     = $SourceTypeMap.Key
                        backupLocation = "./$($SourceTypeMap.Key).json"
                    }
                    Return $backupFiles
                }) -ArgumentList:($TempPath, $SourceTypeMap)
        }
        $ObjectJobStatus = Wait-Job -Id:($ObjectJobs.Id)
        # Manifest: Populate backupFiles value
        $manifest.backupFiles += $ObjectJobStatus | Receive-Job
        $sw.Stop()
        Write-Host ("Object Run Time: $($sw.Elapsed)") -BackgroundColor Cyan -ForegroundColor Black

        # Foreach type start a new job and retreive object association records
        If ($PSBoundParameters.Association)
        {
            $AssociationJobs = @()
            $sw = [Diagnostics.Stopwatch]::StartNew()
            # Get the backup files we created earlier
            $BackupFiles = Get-ChildItem -Path:($TempPath) | Where-Object { $_.BaseName -in $Types }
            ForEach ($BackupFile In $BackupFiles)
            {
                # Type mapping lookup
                $SourceTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Key -eq $BackupFile.BaseName }
                # TODO: Figure out how to make this work with x-ms-enum.
                # $ValidTargetTypes = (Get-Command Get-JcSdk$($SourceTypeMap.Key)Association).Parameters.Targets.Attributes.ValidValues
                # Get list of valid target types from Get-JCAssociation
                # $ValidTargetTypes = $SourceTypeMap.Value.ApprovedAssociations
                $ValidTargetTypes = $SourceTypeMap.Value.FullAssociations
                # Lookup file names in $JcTypesMap
                ForEach ($ValidTargetType In $ValidTargetTypes)
                {
                    $TargetTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Value.Name -eq $ValidTargetType }
                    # If the valid target type matches a file name look up the associations for the SourceType and TargetType
                    If ($TargetTypeMap.Key -in $BackupFiles.BaseName)
                    {
                        $AssociationJobs += Start-Job -ScriptBlock:( { Param ($SourceTypeMap, $TargetTypeMap, $TempPath, $BackupFile);
                                $AssociationResults = @()
                                # Get content from the file
                                $BackupRecords = Get-Content -Path:($BackupFile.FullName) | ConvertFrom-Json
                                ForEach ($BackupRecord In $BackupRecords)
                                {
                                    # Build Command based upon source and target combinations
                                    $Command = If (($SourceTypeMap.Value.Name -eq 'system' -and $TargetTypeMap.Value.Name -eq 'system_group') -or ($SourceTypeMap.Value.Name -eq 'user' -and $TargetTypeMap.Value.Name -eq 'user_group'))
                                    {
                                        'Get-JcSdk{0}Member -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id
                                    }
                                    ElseIf (($SourceTypeMap.Value.Name -eq 'system_group' -and $TargetTypeMap.Value.Name -eq 'system') -or ($SourceTypeMap.Value.Name -eq 'user_group' -and $TargetTypeMap.Value.Name -eq 'user'))
                                    {
                                        'Get-JcSdk{0}Membership -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id
                                    }
                                    Else
                                    {
                                        'Get-JcSdk{0}Association -{0}Id:("{1}") -Targets:("{2}")' -f $SourceTypeMap.Key, $BackupRecord.id, $TargetTypeMap.Value.Name
                                    }
                                    # *Group commands take "GroupId" as a parameter vs "{Type}Id"
                                    $Command = $Command.Replace('UserGroupId', 'GroupId').Replace('SystemGroupId', 'GroupId').Replace('SystemUser', 'User')
                                    Write-Debug ("Running: $Command")
                                    $AssociationResults += Invoke-Expression -Command:($Command) | ConvertTo-Json -Depth:(100)
                                }
                                $AssociationResults | Out-File -FilePath:("{0}/Association-{1}-{2}.json" -f $TempPath, $SourceTypeMap.Key, $TargetTypeMap.Key) -Force
                            }) -ArgumentList:($SourceTypeMap, $TargetTypeMap, $TempPath, $BackupFile)
                    }
                }
                # # Write out the results
                # If (-not [System.String]::IsNullOrEmpty($AssociationResults))
                # {
                #     # Manifest: Populate backupFiles value
                #     $backupFiles = @{
                #         backupType     = "$($BackupFile.BaseName)"
                #         backupLocation = "./$($BackupFile.BaseName)-Association.json"
                #     }
                #     Return $backupFiles
                # }
            }
            $AssociationJobsStatus = Wait-Job -Id:($AssociationJobs.Id)
            $AssociationResults = $AssociationJobsStatus | Receive-Job
            # Manifest: Populate backupFiles value
            $manifest.associationFiles += $AssociationResults
            $sw.Stop()
            Write-Host ("Association Run Time: $($sw.Elapsed)") -BackgroundColor Cyan -ForegroundColor Black
        }
    }
    End
    {
        # Write Out Manifest
        $Manifest | ConvertTo-Json -Depth:(100) | Out-File -FilePath:("$($TempPath)/BackupManifest.json") -Force
        # Zip results
        Compress-Archive -Path:($TempPath) -CompressionLevel:('Fastest') -Destination:($ArchivePath)
        # Clean up temp directory
        If (Test-Path -Path:($ArchivePath))
        {
            Remove-Item -Path:($TempPath) -Force -Recurse
            Write-Host ("Backup Success: $($ArchivePath)") -ForegroundColor:('Green')
        }
        $swTotal.Stop()
        Write-Host ("Total Run Time: $($swTotal.Elapsed)") -BackgroundColor Cyan -ForegroundColor Black
    }
}
