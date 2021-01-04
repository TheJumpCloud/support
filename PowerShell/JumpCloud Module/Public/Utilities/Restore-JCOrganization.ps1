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
    [CmdletBinding(DefaultParameterSetName = 'Restore', PositionalBinding = $false)]
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
        If (-Not (Test-Path -Path $ManifestFile -ErrorAction SilentlyContinue))
        {
            Write-Host "could not find manifest file"
        }
        Else
        {
            $Manifest = Get-Content -Path:($ManifestFile) | ConvertFrom-Json
            Write-Host "###############################################################"
            Write-Host "Backup Org: $($Manifest.organizationID)"
            Write-Host "Backup Date:" $($Manifest.date)
            Write-Host "Contains Backup Files:" (-Not [system.string]::IsNullOrEmpty(($($Manifest.backupFiles))))
            Write-Host "Contains Associations:" (-Not [system.string]::IsNullOrEmpty(($($Manifest.associationFiles))))
            Write-Host "###############################################################"
        }
        # Map to define how JCAssociation & JcSdk types relate
        $JcTypesMap = @{
            application   = 'Application'
            command       = 'Command'
            g_suite       = 'GSuite'
            ldap_server   = 'LdapServer'
            office_365    = 'Office365'
            policy        = 'Policy'
            radius_server = 'RadiusServer'
            system        = 'System'
            system_group  = 'SystemGroup'
            user          = 'SystemUser'
            user_group    = 'UserGroup'
        }
    }
    Process
    {
        Write-Host ("Backup Location: $($ZipArchive.FullName)")
        Write-Host ("Backup Time: $($ZipArchive.LastWriteTime)")
        # Get list of files from backup location and split into object and association groups
        $RestoreFiles = $Types | ForEach-Object { Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Exclude:('*Association*') | Where-Object { $_.BaseName -like "*$($Types)*" } }
        # $RestoreFiles = @()
        # foreach ($backupFile in $Manifest.BackupFiles)
        # {
        #     # test path and validate types
        #     if ((Test-Path -Path $ExpandedArchivePath/$($backupFile.backupLocation)) -And ($($backupFile.backupType) -in $Types))
        #     {
        #         $fullPath = Get-Item $ExpandedArchivePath/$($backupFile.backupLocation)
        #         $RestoreFiles += Get-Item $fullPath
        #     }
        # }
        # For each backup file restore object
        $Jobs = $RestoreFiles | ForEach-Object {
            $RestoreFileFullName = $_.FullName
            $RestoreFileBaseName = $_.BaseName
            Start-Job -ScriptBlock:( {
                    Param ($RestoreFileFullName, $RestoreFileBaseName)
                    Write-Host ("Restoring: $($RestoreFileBaseName)")
                    # Collect old ids and new ids for mapping
                    $IdMapping = @{}
                    $ExistingIds = (Invoke-Expression -Command:("Get-JcSdk{0} -Fields id" -f $RestoreFileBaseName)).id
                    $RestoreFileContent = Get-Content -Path:($RestoreFileFullName) | ConvertFrom-Json
                    $RestoreFileContent | ForEach-Object {
                        $CommandType = Invoke-Expression -Command:("[$($_.JcSdkModel)]")
                        $RestoreFileRecord = $CommandType::DeserializeFromPSObject($_)
                        # If SystemUser is managed by third-party dont create or update
                        If (-not $RestoreFileRecord.ExternallyManaged)
                        {
                            $CommandResults = If ( $RestoreFileRecord.id -notin $ExistingIds )
                            {
                                # Invoke command to create new resource
                                $Command = "`$RestoreFileRecord | $("New-JcSdk{0}" -f $RestoreFileBaseName)"
                                # $Command = "$("New-JcSdk{0}" -f $RestoreFileBaseName) -Body:(`$RestoreFileRecord)"
                                Write-Debug ("Running: $Command")
                                Invoke-Expression -Command:($Command)
                            }
                            Else
                            {
                                # Invoke command to update existing resource
                                $Command = "$("Set-JcSdk{0}" -f $RestoreFileBaseName) -Id:(`$RestoreFileRecord.id) -Body:(`$RestoreFileRecord)"
                                # $Command = "`$RestoreFileRecord | $("Set-JcSdk{0}" -f $RestoreFileBaseName)"
                                # # $Command = "$("Set-JcSdk{0}" -f $RestoreFileBaseName) -Body:(`$RestoreFileRecord)"
                                Write-Host ("Running: $Command")
                                Invoke-Expression -Command:($Command)
                            }
                            # Add id from file and results into mapping table
                            If (-not [System.String]::IsNullOrEmpty($CommandResults))
                            {
                                $IdMapping.Add($RestoreFileRecord.id, $CommandResults.Id)
                            }
                        }
                    }
                    Return $IdMapping
                }) -ArgumentList:($RestoreFileFullName, $RestoreFileBaseName)
        }
        $JobStatus = Wait-Job -Id:($Jobs.Id)
        $IdMap += $JobStatus | Receive-Job
        # flatten $IdMap to single table
        $flattenedMap = @{}
        ForEach ($hash In $IdMap)
        {
            ForEach ($key In $hash.Keys)
            {
                # write-host "OldID: $key maps to NewID: $($hash[$key])"
                $flattenedMap.Add($key, $($hash[$key]))
            }
        }
        Write-Host "$($flattenedMap.count) Items were restored"
        # Foreach type start a new job and restore object association records
        If ($PSBoundParameters.Association)
        {
            $RestoreAssociationFiles = Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Filter:('*Association*')
            # $RestoreAssociationFiles = @()
            # foreach ($associationBackup in $Manifest.associationFiles)
            # {
            #     # test path and validate types
            #     if ((Test-Path -Path $ExpandedArchivePath/$($associationBackup.backupLocation)) -And ($($associationBackup.backupType) -in $Types))
            #     {
            #         $fullPath = Get-Item $ExpandedArchivePath/$($associationBackup.backupLocation)
            #         $RestoreAssociationFiles += Get-Item $fullPath
            #     }
            # }
            $Jobs = ForEach ($file In $RestoreAssociationFiles)
            {
                # Start-Job -ScriptBlock:( {
                #         Param ($file, $flattenedMap, $JcTypesMap)
                $file = Get-Item $file
                Write-Host "checking $file"
                $functionName = "Get-JcSdk$($file.BaseName)".replace("-Association", "")
                $ExistingIds = (& $functionName -Fields id).id
                $AssociationContent = Get-Content -Path:($file.FullName) -Raw | ConvertFrom-Json
                # for each association
                # TODO: quickly loop through and find possible target types, get existingTargetIds
                $targetTypes = $AssociationContent.Paths.ToType | Get-Unique
                $existingTargetIds = @()
                ForEach ($item In $targetTypes)
                {
                    $functionName = "Get-JcSdk$($JcTypesMap[$item])"
                    $existingTargetIds += (& $functionName -Fields id).id
                }
                $restoreCount = @{}
                ForEach ($item In $AssociationContent)
                {
                    Write-Host ("-Id $($flattenedMap[$($item.id)])") -BackgroundColor Green -ForegroundColor Black
                    Write-Host ("-Id $($item.id)") -BackgroundColor Red -ForegroundColor Black
                    if ($($flattenedMap[$($item.id)]) -And $($flattenedMap[$($item.targetId)]))
                    {
                        # If the NewID maps back to a valid OldID, for both the source and target, create the Association
                        # Write-Host "Association Restore Type: New Source & Target"
                        $result = New-JCAssociation -Type $($item.type) -Id $($flattenedMap[$($item.id)]) -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
                        $restoreCount.Add($result.id, $tesult.targetId)
                    }
                    if (($($flattenedMap[$($item.id)])) -And ($item.targetId -in $existingTargetIds))
                    {
                        # NewID Maps to Old ID for source, associated w/ existingTargetID
                        # Write-Host "Association Restore Type: New Source, Existing Target"
                        $result = New-JCAssociation -Type $($item.type) -Id $($flattenedMap[$($item.id)]) -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
                        $restoreCount.Add($result.id, $tesult.targetId)
                    }
                    if (($item.id -in $ExistingIds) -And $($flattenedMap[$($item.targetId)]))
                    {
                        # Source Old ID exists and Target NewID maps to Old ID
                        # Write-Host "Association Restore Type: Existing Source, New Target"
                        $result = New-JCAssociation -Type $($item.type) -Id $item.id -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
                        $restoreCount.Add($result.id, $tesult.targetId)
                    }
                    if (($item.id -in $ExistingIds) -And ($item.targetId -in $existingTargetIds))
                    {
                        # Source & Target exist, update association
                        if ($item.targetId -notin (Get-JCAssociation -Id $item.id -Type $item.type -TargetType $($item.Paths.ToType)).targetId)
                        {
                            # Write-Host "Assocation Restored!"
                            $result = New-JCAssociation -Type $($item.type) -Id $item.id -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
                            $restoreCount.Add($result.id, $tesult.targetId)
                        }
                    }
                }
                return $restoreCount
                # }) -ArgumentList:($file, $flattenedMap, $JcTypesMap)
            }
            $JobStatus = Wait-Job -Id:($Jobs.Id)
            $AssociationResults += $JobStatus | Receive-Job
            $finalCount = @{}
            ForEach ($item In $AssociationResults)
            {
                ForEach ($key In $item.Keys)
                {
                    $finalCount.Add($key, $($item[$key]))
                }
            }
            Write-Host "$($finalCount.count) Associations were restored"
        }
    }
    End
    {
    }
}
