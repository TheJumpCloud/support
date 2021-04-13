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
        [System.IO.FileInfo]
        [ValidateScript( {
                If (-Not ($_ | Test-Path) )
                {
                    Throw "File or folder does not exist: '$_'"
                }
                If (-Not ($_ | Test-Path -PathType Leaf) )
                {
                    Throw "The Path argument must be a file. Folder paths are not allowed: $_"
                }
                If ($_ -notmatch "(\.zip)")
                {
                    Throw "The file specified in the path argument must be either of type zip: $_"
                }
                Return $true
            })]
        # Specify input .zip file path for restore files
        ${Path},

        [Parameter(ParameterSetName = 'All')]
        [switch]
        # The Username of the JumpCloud user you wish to search for
        ${All},

        [Parameter(ParameterSetName = 'Type')]
        [ValidateSet('Application', 'Command', 'DuoApplication', 'IPList', 'LdapServerSambaDomain', 'Policy', 'RadiusServer', 'SoftwareApp', 'SystemGroup', 'User', 'UserGroup')]
        [System.String[]]
        # Specify the type of JumpCloud objects you want to backup. Restore of "System" is unavailable.
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
        # Test and convert CSVs back to JSON
        $csvFiles = $ExpandedArchivePath | Get-ChildItem | Where-Object { $_.Name -match ".csv" }
        if ($csvFiles){
            foreach ($csvFile in $csvFiles) {
                # Convert the CSV file to JSON
                Get-Content -path $csvFile.FullName | ConvertFrom-Csv -Delimiter ',' | ConvertTo-Json -Depth 100 | Out-File "$($csvFile.DirectoryName)\$($csvFile.BaseName).json"
                # Remove the CSV File
                Remove-Item $csvFile.FullName
            }
        }
        # Get the manifest file from backup
        $ManifestFile = $ExpandedArchivePath | Get-ChildItem | Where-Object { $_.Name -eq "Manifest.json" }
        # ToDo: Should we install the versions of the modules listed in the Manifest file if they are not installed on the machine already?
        Write-Host ("###############################################################") -ForegroundColor:('Green')
        If (-not (Test-Path -Path:($ManifestFile) -ErrorAction:('SilentlyContinue')))
        {
            Write-Error ("Unable to find manifest file: $($ManifestFile)")
        }
        Else
        {
            $Manifest = Get-Content -Path:($ManifestFile) | ConvertFrom-Json
            Write-Host ("Backup Org: $($Manifest.organizationID)") -ForegroundColor:('Green')
            Write-Host ("Backup Date: $($Manifest.date)") -ForegroundColor:('Green')
        }
        Write-Host ("Backup Location: $($ZipArchive.FullName)") -ForegroundColor:('Green')
        Write-Host ("Backup Time: $($ZipArchive.LastWriteTime)") -ForegroundColor:('Green')
        Write-Host ("###############################################################") -ForegroundColor:('Green')
    }
    Process
    {
        # Get list of files from backup location and split into object and association groups
        $RestoreFiles = Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Exclude:('*Association*') | ForEach-Object { $_ | Where-Object { $_.BaseName -in $Types } }
        # For each backup file restore object
        $JcObjectsJobs = $RestoreFiles | ForEach-Object {
            $RestoreFileFullName = $_.FullName
            $RestoreFileBaseName = $_.BaseName
            $SourceTypeMap = $global:JcTypesMap.GetEnumerator() | Where-Object { $_.Key -eq $RestoreFileBaseName }
            $ModelName = ($Manifest.result | Where-Object { $_.Type -eq $SourceTypeMap.Key }).ModelName
            $RequiredModules = $Manifest.moduleVersion.name
            Start-Job -ScriptBlock:( { Param ($RestoreFileFullName, $SourceTypeMap, $ModelName, $RequiredModules)
                    $JcObjectResults = [PSCustomObject]@{
                        Updated = @();
                        New     = @();
                        IdMap   = @();
                    }
                    Import-Module -Name:($RequiredModules) -Force
                    $CommandType = Invoke-Expression -Command:("[$($ModelName)]")
                    # Collect old ids and new ids for mapping
                    $Command = "Get-JcSdk{0} -Fields:('{1}')" -f $SourceTypeMap.Key, (@($SourceTypeMap.Value.Identifier_Id, $SourceTypeMap.Value.Identifier_Name) -join (','))
                    If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                    $ExistingObjects = Invoke-Expression -Command:($Command)
                    $RestoreFileContent = Get-Content -Path:($RestoreFileFullName) | ConvertFrom-Json
                    $RestoreFileContent | ForEach-Object {
                        $RestoreFileRecord = $CommandType::DeserializeFromPSObject($_)
                        # If User is managed by third-party dont create or update
                        If (-not $RestoreFileRecord.ExternallyManaged)
                        {
                            # Lookup by "Identifier_Id" to see if item already exists and if it does then update the existing resource
                            $CommandResult = If ( $RestoreFileRecord.($SourceTypeMap.Value.Identifier_Id) -in $ExistingObjects.($SourceTypeMap.Value.Identifier_Id) )
                            {
                                # Invoke command to update existing resource
                                $Command = "Set-JcSdk{0} -Id:({1}) -Body:(`$RestoreFileRecord)" -f $SourceTypeMap.Key, $RestoreFileRecord.id
                                If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                $SetJcSdkResult = Invoke-Expression -Command:($Command)
                                If (-not [System.String]::IsNullOrEmpty($SetJcSdkResult))
                                {
                                    $JcObjectResults.Updated += $SetJcSdkResult
                                    $SetJcSdkResult
                                }
                            }
                            # Lookup by "Identifier_Name" to see if item already exists and if it does then update the existing resource
                            ElseIf ( $RestoreFileRecord.($SourceTypeMap.Value.Identifier_Name) -in $ExistingObjects.($SourceTypeMap.Value.Identifier_Name) )
                            {
                                $ResourceId = $ExistingObjects | Where-Object { $RestoreFileRecord.($SourceTypeMap.Value.Identifier_Name) -in $_.($SourceTypeMap.Value.Identifier_Name) }
                                # Invoke command to update existing resource
                                $Command = "Set-JcSdk{0} -Id:({1}) -Body:(`$RestoreFileRecord)" -f $SourceTypeMap.Key, $ResourceId.id
                                If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                $SetJcSdkResult = Invoke-Expression -Command:($Command)
                                If (-not [System.String]::IsNullOrEmpty($SetJcSdkResult))
                                {
                                    $JcObjectResults.Updated += $SetJcSdkResult
                                    $SetJcSdkResult
                                }
                            }
                            Else
                            {
                                # Invoke command to create new resource
                                $Command = "`$RestoreFileRecord | $("New-JcSdk{0}" -f $SourceTypeMap.Key)"
                                If ($PSBoundParameters.Debug) { Write-Host ("DEBUG: Running: $Command") -ForegroundColor:('Yellow') }
                                $NewJcSdkResult = Invoke-Expression -Command:($Command)
                                If (-not [System.String]::IsNullOrEmpty($NewJcSdkResult))
                                {
                                    $JcObjectResults.New += $NewJcSdkResult
                                    $NewJcSdkResult
                                }
                            }
                        }
                        $JcObjectResults.IdMap += [PSCustomObject]@{
                            OldId = $RestoreFileRecord.id
                            NewId = $CommandResult.Id
                        }
                    }
                    Return $JcObjectResults
                }) -ArgumentList:($RestoreFileFullName, $SourceTypeMap, $ModelName, $RequiredModules)
        }
        $JcObjectsJobStatus = Wait-Job -Id:($JcObjectsJobs.Id)
        $JcObjectJobResults = $JcObjectsJobStatus | Receive-Job
        # Foreach type start a new job and restore object association records
        If ($PSBoundParameters.Association)
        {
            $IdMap = $JcObjectJobResults.IdMap
            $RestoreAssociationFiles = Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Filter:('*Association*') | ForEach-Object { $_ | Where-Object { $_.BaseName.Replace('-Association', '') -in $Types } }
            If ($RestoreAssociationFiles)
            {
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
                        }) -ArgumentList:($RestoreAssociationFile, $IdMap, $global:JcTypesMap)
                }
                $AssociationsJobStatus = Wait-Job -Id:($AssociationsJobs.Id)
                $AssociationResults = $AssociationsJobStatus | Receive-Job
            }
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
            Write-Host "$($JcObjectJobResults.New.Count) Objects have been restored" -ForegroundColor:('Magenta')
            Write-Host "$($JcObjectJobResults.Updated.Count) Objects existed and have been updated" -ForegroundColor:('Magenta')
        }
        If (-not [System.String]::IsNullOrEmpty($AssociationResults))
        {
            Write-Host "$($AssociationResults.New.Count) Associations have been restored" -ForegroundColor:('Magenta')
            Write-Host "$($AssociationResults.Existing.Count) Associations existed and have been skipped" -ForegroundColor:('Magenta')
            Write-Host "$($AssociationResults.Failed.Count) Associations failed to restore" -ForegroundColor:('Magenta')
        }
    }
}
