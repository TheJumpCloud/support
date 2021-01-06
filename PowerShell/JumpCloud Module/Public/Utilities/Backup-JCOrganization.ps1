<#
TODO
    . Should association back up all Association for item or just the Association possible within the type parameter?
    . Make this a class in psm1 file: [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
    . Roll back x-ms-enum
#>
<#
.Synopsis
The function exports objects and associations from your JumpCloud organization to local json files

.Description
The function exports objects and associations from your JumpCloud organization to local json files

.Example
Backup UserGroups and SystemUsers with their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers') -Association

.Example
Backup UserGroups and SystemUsers without their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers')

.Example
Backup all available JumpCloud objects and their associations
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
        [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
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
            Application  = 'application';
            Command      = 'command';
            GSuite       = 'g_suite';
            LdapServer   = 'ldap_server';
            Office365    = 'office_365';
            Policy       = 'policy';
            RadiusServer = 'radius_server';
            System       = 'system';
            SystemGroup  = 'system_group';
            SystemUser   = 'user';
            UserGroup    = 'user_group';
        }
    }
    Process
    {
        # Foreach type start a new job and retrieve object records
        $Jobs = $Types | ForEach-Object {
            $JumpCloudType = $_
            Start-Job -ScriptBlock:( {
                    Param ($Path, $JumpCloudType);
                    $CommandTemplate = "Get-JcSdk{0}"
                    $Result = Invoke-Expression -Command:($CommandTemplate -f $JumpCloudType)
                    # Write output to file
                    $Result `
                    | ForEach-Object { $_ | Select-Object *, @{Name = 'JcSdkModel'; Expression = { $_.GetType().FullName } } } `
                    | ConvertTo-Json -Depth:(100) `
                    | Out-File -FilePath:("$($Path)/$($JumpCloudType).json") -Force
                    # Manifest: Populate backupFiles value
                    $backupFiles = @{
                        backupType     = $JumpCloudType
                        backupLocation = "./$($JumpCloudType).json"
                    }
                    return $backupFiles
                }) -ArgumentList:($TempPath, $JumpCloudType)
        }
        $JobStatus = Wait-Job -Id:($Jobs.Id)
        # Manifest: Populate backupFiles value
        $manifest.backupFiles += $JobStatus | Receive-Job
        # Foreach type start a new job and retrieve object association records
        If ($PSBoundParameters.Association)
        {
            # Get the backup files we created earlier
            $BackupFiles = Get-ChildItem $TempPath | Where-Object { $_.BaseName -in $Types }
            $BackupFilesBaseName = $BackupFiles.BaseName
            $JobsAssociation = $BackupFiles | ForEach-Object {
                $BackupFileFullName = $_.FullName
                $BackupFileBaseName = $_.BaseName
                Start-Job -ScriptBlock:( {
                        Param ($Path, $Types, $JcTypesMap, $BackupFileFullName, $BackupFileBaseName, $BackupFilesBaseName);
                        $AssociationType = $JcTypesMap["$BackupFileBaseName"]
                        $ValidTargetTypes = (Get-Command Get-JCAssociation -ArgumentList:($AssociationType)).Parameters.TargetType.Attributes.ValidValues
                        $AssociationResults = @()
                        # Get content from the file
                        $jsonContent = Get-Content -Path:($BackupFileFullName) | ConvertFrom-Json
                        ForEach ($Record In $jsonContent)
                        {
                            # Lookup file names in $JcTypesMap
                            $TargetTypes = $ValidTargetTypes | ForEach-Object {
                                $ValidTargetTypes = $_
                                If (($JcTypesMap.GetEnumerator() | Where-Object { $_.Value -eq $ValidTargetTypes }).Key -in $BackupFilesBaseName)
                                {
                                    $ValidTargetTypes
                                }
                            }
                            # If a valid target is found get the Association
                            If (-not [System.String]::IsNullOrEmpty($TargetTypes))
                            {
                                $Command = "Get-JCAssociation -Direct -id:('$($Record.id)') -Type:('$($JcTypesMap["$($BackupFileBaseName)"])') -TargetType:('$($TargetTypes -join "','")')"
                                Write-Debug ("Running: $Command")
                                $Result = Invoke-Expression -Command:($Command)
                                If ($Result)
                                {
                                    $AssociationResults += $Result
                                }
                            }
                        }
                        # Write out the results
                        If (-not [System.String]::IsNullOrEmpty($AssociationResults))
                        {
                            # To multiple files
                            $AssociationResults | ConvertTo-Json -Depth:(100) | Out-File -FilePath:("$($Path)/$($BackupFileBaseName)-Association.json") -Force
                            # Manifest: Populate backupFiles value
                            $backupFiles = @{
                                backupType     = "$($BackupFileBaseName)"
                                backupLocation = "./$($BackupFileBaseName)-Association.json"
                            }
                            Return $backupFiles
                        }
                    }) -ArgumentList:($TempPath, $Types, $JcTypesMap, $BackupFileFullName, $BackupFileBaseName, $BackupFilesBaseName)
            }
            $JobsAssociationStatus = Wait-Job -Id:($JobsAssociation.Id)
            # Manifest: Populate backupFiles value
            $manifest.associationFiles += $JobsAssociationStatus | Receive-Job
        }
    }
    End
    {
        # Write Out Manifest
        $Manifest | ConvertTo-Json -Depth:(100) `
        | Out-File -FilePath:("$($TempPath)/BackupManifest.json") -Force
        # Zip results
        Compress-Archive -Path:($TempPath) -CompressionLevel:('Fastest') -Destination:($ArchivePath)
        # Clean up temp directory
        If (Test-Path -Path:($ArchivePath))
        {
            Remove-Item -Path:($TempPath) -Force -Recurse
            Write-Host ("Backup Success: $($ArchivePath)") -ForegroundColor:('Green')
        }
    }
}