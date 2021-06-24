<#
ToDo
Validate Path contains *.zip file
If object exists compare the existing object against backup object for diffs
. Why is 'pester.tester2_AoCaBLbI' being associated to two groups?
. Running restore twice after objects have been deleted from the org fails
#>

<#
.Synopsis
The function exports objects from your JumpCloud organization to local json files
.Description
The function exports objects from your JumpCloud organization to local json files
.Example
Restore UserGroups and Users with their associations
PS C:\> Restore-JCOrganization -Path:('C:\Temp\JumpCloud_20201222T1324549196.zip') -Type:('UserGroup','User') -Association

.Example
Restore UserGroups and Users without their associations
PS C:\> Restore-JCOrganization -Path:('C:\Temp\JumpCloud_20201222T1324549196.zip') -Type:('UserGroup','User')

.Example
Restore all avalible JumpCloud objects and their Association
PS C:\> Restore-JCOrganization -Path:('C:\Temp\JumpCloud_20201222T1324549196.zip') -All

.Notes

.Link
https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Restore-JCOrganization.md
#>
Function Restore-JCOrganization
{
    [CmdletBinding(DefaultParameterSetName = 'All', PositionalBinding = $false)]
    Param(
        [Parameter(Mandatory)]
        [System.String]
        # Specify input .zip file path for restore files
        ${Path},

        [Parameter(ParameterSetName = 'All')]
        [switch]
        # The Username of the JumpCloud user you wish to search for
        ${All},

        [Parameter(ParameterSetName = 'Type')]
        [ValidateSet('SystemGroup', 'UserGroup', 'User')]
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
        # Unzip folder
        $ZipArchive = Get-Item -Path:($Path)
        Expand-Archive -LiteralPath:($Path) -DestinationPath:($ZipArchive.Directory.FullName) -Force
        $ExpandedArchivePath = Get-Item -Path:(Join-Path -Path:($ZipArchive.Directory) -ChildPath:(($ZipArchive.Name).Replace($ZipArchive.Extension, '')))
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
            User         = 'user';
            UserGroup    = 'user_group';
        }
        # Get the manifest file from backup
        $ManifestFile = $ExpandedArchivePath | Get-ChildItem | Where-Object { $_.Name -eq "BackupManifest.json" }
        Write-Host ("###############################################################")
        If (-not (Test-Path -Path:($ManifestFile) -ErrorAction:('SilentlyContinue')))
        {
            Write-Error ("Unable to find manifest file: $($ManifestFile)")
        }
        Else
        {
            $Manifest = Get-Content -Path:($ManifestFile) | ConvertFrom-Json
            Write-Host ("Backup Org: $($Manifest.organizationID)")
            Write-Host ("Backup Date: $($Manifest.date)")
            Write-Host "Contains Object Files:" (-not [system.string]::IsNullOrEmpty(($($Manifest.backupFiles)))) # TODO should we keep this message or change the logic
            Write-Host "Contains Associations:" (-not [system.string]::IsNullOrEmpty(($($Manifest.associationFiles))))
        }
        Write-Host ("Backup Location: $($ZipArchive.FullName)")
        Write-Host ("Backup Time: $($ZipArchive.LastWriteTime)")
        Write-Host ("###############################################################")
    }
    Process
    {
        # Get list of files from backup location and split into object and association groups
        $RestoreFiles = Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Exclude:('*Association*') | ForEach-Object { $_ | Where-Object { $_.BaseName -in $Types } }
        # For each backup file restore object
        $JcObjectsJobs = $RestoreFiles | ForEach-Object {
            $RestoreFileFullName = $_.FullName
            $RestoreFileBaseName = $_.BaseName
            Start-Job -ScriptBlock:( { Param ($RestoreFileFullName, $RestoreFileBaseName)
                    $JcObjectResults = [PSCustomObject]@{
                        Updated = @();
                        New     = @();
                        IdMap   = @();
                    }
                    # Collect old ids and new ids for mapping
                    $ExistingIds = (Invoke-Expression -Command:("Get-JcSdk{0} -Fields id" -f $RestoreFileBaseName)).id
                    $RestoreFileContent = Get-Content -Path:($RestoreFileFullName) | ConvertFrom-Json
                    $RestoreFileContent | ForEach-Object {
                        $CommandType = Invoke-Expression -Command:("[$($_.JcSdkModel)]")
                        $RestoreFileRecord = $CommandType::DeserializeFromPSObject($_)
                        # If User is managed by third-party dont create or update
                        If (-not $RestoreFileRecord.ExternallyManaged)
                        {
                            $CommandResult = If ( $RestoreFileRecord.id -notin $ExistingIds )
                            {
                                # Invoke command to create new resource
                                $Command = "`$RestoreFileRecord | $("New-JcSdk{0}" -f $RestoreFileBaseName)"
                                Write-Debug ("Running: $Command")
                                $NewJcSdkResult = Invoke-Expression -Command:($Command)
                                If (-not [System.String]::IsNullOrEmpty($NewJcSdkResult))
                                {
                                    $JcObjectResults.New += $NewJcSdkResult
                                    $NewJcSdkResult
                                }
                            }
                            Else
                            {
                                # Invoke command to update existing resource
                                $Command = "$("Set-JcSdk{0}" -f $RestoreFileBaseName) -Id:(`$RestoreFileRecord.id) -Body:(`$RestoreFileRecord)"
                                Write-Debug ("Running: $Command")
                                $SetJcSdkResult = Invoke-Expression -Command:($Command)
                                If (-not [System.String]::IsNullOrEmpty($SetJcSdkResult))
                                {
                                    $JcObjectResults.Updated += $SetJcSdkResult
                                    $SetJcSdkResult
                                }
                            }
                        }
                        $JcObjectResults.IdMap += [PSCustomObject]@{
                            OldId = $RestoreFileRecord.id
                            NewId = $CommandResult.Id
                        }
                    }
                    Return $JcObjectResults
                }) -ArgumentList:($RestoreFileFullName, $RestoreFileBaseName)
        }
        $JcObjectsJobStatus = Wait-Job -Id:($JcObjectsJobs.Id)
        $JcObjectJobResults = $JcObjectsJobStatus | Receive-Job
        # Foreach type start a new job and restore object association records
        If ($PSBoundParameters.Association)
        {
            $IdMap = $JcObjectJobResults.IdMap
            $RestoreAssociationFiles = Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Filter:('*Association*') | ForEach-Object { $_ | Where-Object { $_.BaseName.Replace('-Association', '') -in $Types } }
            $AssociationsJobs = ForEach ($RestoreAssociationFile In $RestoreAssociationFiles)
            {
                Start-Job -ScriptBlock:( { Param ($RestoreAssociationFile, $IdMap, $JcTypesMap)
                        $AssociationResults = [PSCustomObject]@{
                            Existing = @();
                            New      = @();
                            Failed   = @();
                        }
                        $AssociationContent = Get-Content -Path:($RestoreAssociationFile.FullName) -Raw | ConvertFrom-Json
                        ForEach ($AssociationItem In $AssociationContent)
                        {
                            $Id = If ([System.String]::IsNullOrEmpty(($IdMap | Where-Object { $_.OldId -eq $AssociationItem.Id }).NewId))
                            {
                                # Check to see if the Id from the file exists in the console
                                $JcTypeLookup = $JcTypesMap.GetEnumerator() | Where-Object { $_.Value -eq $AssociationItem.type }
                                $GetExistingCommand = "Get-JcSdk$($JcTypeLookup.Key) | Where-Object { `$_.id -eq '$($AssociationItem.id)' }"
                                (Invoke-Expression -Command:($GetExistingCommand)).id
                            }
                            Else
                            {
                                ($IdMap | Where-Object { $_.OldId -eq $AssociationItem.Id }).NewId
                            }
                            # If the targetId does not exist in the IdMap then use the targetId from the file
                            $TargetId = If ([System.String]::IsNullOrEmpty(($IdMap | Where-Object { $_.OldId -eq $AssociationItem.TargetId }).NewId))
                            {
                                # Check to see if the targetId from the file exists in the console
                                $JcTypeLookup = $JcTypesMap.GetEnumerator() | Where-Object { $_.Value -eq $AssociationItem.TargetType }
                                $GetExistingCommand = "Get-JcSdk$($JcTypeLookup.Key) | Where-Object { `$_.id -eq '$($AssociationItem.TargetId)' }"
                                (Invoke-Expression -Command:($GetExistingCommand)).id
                            }
                            Else
                            {
                                ($IdMap | Where-Object { $_.OldId -eq $AssociationItem.TargetId }).NewId
                            }
                            # Only create associations for the ids that were created or updated in the previous step
                            If ([System.String]::IsNullOrEmpty($Id))
                            {
                                $AssociationResults.Failed += $AssociationItem
                                Write-Error ("Unable to create association. Id does not exist in org: $($AssociationItem.Type) $($AssociationItem.Id)")
                            }
                            ElseIf ([System.String]::IsNullOrEmpty($TargetId))
                            {
                                $AssociationResults.Failed += $AssociationItem
                                Write-Error ("Unable to create association. TargetId does not exist in org: $($AssociationItem.TargetType) $($AssociationItem.TargetId)")
                            }
                            Else
                            {
                                # Check for existing association
                                $ExistingAssociation = Get-JCAssociation -Type:($AssociationItem.Type) -Id:($Id) -TargetType:($AssociationItem.TargetType) | Where-Object { $_.TargetId -eq $TargetId }
                                If ([System.String]::IsNullOrEmpty($ExistingAssociation))
                                {
                                    $NewAssociationCommand = "New-JCAssociation -Type:('$($AssociationItem.Type)') -Id:('$($Id)') -TargetType:('$($AssociationItem.TargetType)') -TargetId:('$($TargetId)') -Force"
                                    Write-Debug ("Running: $NewAssociationCommand")
                                    $AssociationResults.New += Invoke-Expression -Command:($NewAssociationCommand)
                                }
                                Else
                                {
                                    $AssociationResults.Existing += $ExistingAssociation
                                }
                            }
                        }
                        Return $AssociationResults
                    }) -ArgumentList:($RestoreAssociationFile, $IdMap, $JcTypesMap)
            }
            $AssociationsJobStatus = Wait-Job -Id:($AssociationsJobs.Id)
            $AssociationResults = $AssociationsJobStatus | Receive-Job
        }
    }
    End
    {
        # Clean up temp directory
        If (Test-Path -Path:($ExpandedArchivePath.FullName))
        {
            Remove-Item -Path:($ExpandedArchivePath.FullName) -Force -Recurse
        }
        # Output
        If (-not [System.String]::IsNullOrEmpty($JcObjectJobResults))
        {
            Write-Host "$($JcObjectJobResults.New.Count) Objects have been restored"
            Write-Host "$($JcObjectJobResults.Updated.Count) Objects existed and have been updated"
        }
        If (-not [System.String]::IsNullOrEmpty($AssociationResults))
        {
            Write-Host "$($AssociationResults.New.Count) Associations have been restored"
            Write-Host "$($AssociationResults.Existing.Count) Associations existed and have been skipped"
            Write-Host "$($AssociationResults.Failed.Count) Associations failed to restore"
        }
    }
}