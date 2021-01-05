<#
ToDo
Validate Path contains *.zip file
If object exists compare the existing object against backup object for diffs
#>

<#
.Synopsis
The function exports objects from your JumpCloud organization to local json files
.Description
The function exports objects from your JumpCloud organization to local json files
.Example
Restore UserGroups and SystemUsers with their associations
PS C:\> Restore-JCOrganization -Path:('C:\Temp\JumpCloud_20201222T1324549196.zip') -Type:('UserGroup','SystemUsers') -Association

.Example
Restore UserGroups and SystemUsers without their associations
PS C:\> Restore-JCOrganization -Path:('C:\Temp\JumpCloud_20201222T1324549196.zip') -Type:('UserGroup','SystemUsers')

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
        [ValidateSet('SystemGroup', 'UserGroup', 'SystemUser')]
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

        # Get the manifest file from backup
        $ManifestFile = $ExpandedArchivePath | Get-ChildItem | Where-Object { $_.Name -eq "BackupManifest.json" }
        If (-not (Test-Path -Path:($ManifestFile) -ErrorAction:('SilentlyContinue')))
        {
            Write-Error ("Unable to find manifest file: $($ManifestFile)")
        }
        Else
        {
            $Manifest = Get-Content -Path:($ManifestFile) | ConvertFrom-Json
            Write-Host ("###############################################################")
            Write-Host ("Backup Org: $($Manifest.organizationID)")
            Write-Host ("Backup Date: $($Manifest.date)")
            Write-Host "Contains Object Files:" (-not [system.string]::IsNullOrEmpty(($($Manifest.backupFiles))))
            Write-Host "Contains Associations:" (-not [system.string]::IsNullOrEmpty(($($Manifest.associationFiles))))
            Write-Host ("###############################################################")
        }
    }
    Process
    {
        Write-Host ("Backup Location: $($ZipArchive.FullName)")
        Write-Host ("Backup Time: $($ZipArchive.LastWriteTime)")
        # Get list of files from backup location and split into object and association groups
        $RestoreFiles = Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Exclude:('*Association*') | ForEach-Object { $_ | Where-Object { $_.BaseName -in $Types } }
        # For each backup file restore object
        $JcObjectsJobs = $RestoreFiles | ForEach-Object {
            $RestoreFileFullName = $_.FullName
            $RestoreFileBaseName = $_.BaseName
            Start-Job -ScriptBlock:( {
                    Param ($RestoreFileFullName, $RestoreFileBaseName)
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
                        # If SystemUser is managed by third-party dont create or update
                        If (-not $RestoreFileRecord.ExternallyManaged)
                        {
                            $CommandResult = If ( $RestoreFileRecord.id -notin $ExistingIds )
                            {
                                # Invoke command to create new resource
                                $Command = "`$RestoreFileRecord | $("New-JcSdk{0}" -f $RestoreFileBaseName)"
                                # $Command = "$("New-JcSdk{0}" -f $RestoreFileBaseName) -Body:(`$RestoreFileRecord)"
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
                                # TODO: Why does the other command not work
                                $Command = "$("Set-JcSdk{0}" -f $RestoreFileBaseName) -Id:(`$RestoreFileRecord.id) -Body:(`$RestoreFileRecord)"
                                # $Command = "`$RestoreFileRecord | $("Set-JcSdk{0}" -f $RestoreFileBaseName)"
                                # # $Command = "$("Set-JcSdk{0}" -f $RestoreFileBaseName) -Body:(`$RestoreFileRecord)"
                                Write-Debug ("Running: $Command")
                                $SetJcSdkResult = Invoke-Expression -Command:($Command)
                                If (-not [System.String]::IsNullOrEmpty($SetJcSdkResult))
                                {
                                    $JcObjectResults.Updated += $SetJcSdkResult
                                    $SetJcSdkResult
                                }
                            }
                            $JcObjectResults.IdMap += [PSCustomObject]@{
                                OldId = $RestoreFileRecord.id
                                NewId = $CommandResult.Id
                            }
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
            $RestoreAssociationFiles = Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Filter:('*Association*')
            $AssociationsJobs = ForEach ($RestoreAssociationFile In $RestoreAssociationFiles)
            {
                Start-Job -ScriptBlock:( {
                        Param ($RestoreAssociationFile, $IdMap)
                        $AssociationResults = [PSCustomObject]@{
                            Existing = @();
                            New      = @();
                        }
                        $AssociationContent = Get-Content -Path:($RestoreAssociationFile.FullName) -Raw | ConvertFrom-Json
                        ForEach ($AssociationItem In $AssociationContent)
                        {
                            $Id = ($IdMap | Where-Object { $_.OldId -eq $AssociationItem.Id }).NewId
                            $TargetId = ($IdMap | Where-Object { $_.OldId -eq $AssociationItem.TargetId }).NewId
                            # Only create associations for the ids that were created or updated in the previous step
                            If (-not [System.String]::IsNullOrEmpty($Id) -and -not [System.String]::IsNullOrEmpty($TargetId))
                            {
                                # Check for existing association
                                $ExistingAssociation = Get-JCAssociation -Type:($AssociationItem.Type) -Id:($Id) -TargetType:($AssociationItem.TargetType) | Where-Object { $_.TargetId -eq $TargetId }
                                If ([System.String]::IsNullOrEmpty($ExistingAssociation))
                                {
                                    $NewAssociationCommand = "New-JCAssociation -Type:('$($AssociationItem.Type)') -Id:('$($Id)') -TargetType:('$($AssociationItem.TargetType)') -TargetId:('$($TargetId)') -Force"
                                    Write-Host ("Running: $NewAssociationCommand")
                                    $AssociationResults.New += Invoke-Expression -Command:($NewAssociationCommand)
                                }
                                Else
                                {
                                    $AssociationResults.Existing += $ExistingAssociation
                                }
                            }
                        }
                        Return $AssociationResults
                    }) -ArgumentList:($RestoreAssociationFile, $IdMap)
            }
            $JobStatus = Wait-Job -Id:($AssociationsJobs.Id)
            $AssociationResults = $JobStatus | Receive-Job
        }
    }
    End
    {
        # Output
        # TODO: Add if statement to each write-host
        If (-not [System.String]::IsNullOrEmpty($JcObjectJobResults))
        {
            Write-Host "$($JcObjectJobResults.New.Count) Objects restored"
            Write-Host "$($JcObjectJobResults.Updated.Count) Objects existed and have been updated"
        }
        If (-not [System.String]::IsNullOrEmpty($AssociationResults))
        {
            Write-Host "$($AssociationResults.New.Count) Associations restored"
            Write-Host "$($AssociationResults.Existing.Count) Associations existed and have been skipped"
        }
    }
}
