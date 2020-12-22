<#
ToDo
Validate Path contains *.zip file

#>

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
        # # Map to define how JCAssociation & JcSdk types relate
        # $JcTypesMap = @{
        #     application   = 'Application'
        #     command       = 'Command'
        #     g_suite       = 'GSuite'
        #     ldap_server   = 'LdapServer'
        #     office_365    = 'Office365'
        #     policy        = 'Policy'
        #     radius_server = 'RadiusServer'
        #     system        = 'System'
        #     system_group  = 'SystemGroup'
        #     user          = 'SystemUser'
        #     user_group    = 'UserGroup'
        # }
    }
    Process
    {
        Write-Host ("Backup Location: $($ZipArchive.FullName)")
        Write-Host ("Backup Time: $($ZipArchive.LastWriteTime)")
        # Get list of files from backup location and split into object and association groups
        $RestoreFiles = $Types | ForEach-Object { Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Exclude:('*Association*') | Where-Object { $_.BaseName -like "*$($Types)*" } }
        # For each backup file restore object
        $Jobs = $RestoreFiles | ForEach-Object {
            $RestoreFileFullName = $_.FullName
            $RestoreFileBaseName = $_.BaseName
            Start-Job -ScriptBlock:( {
                    Param ($RestoreFileFullName, $RestoreFileBaseName)
                    Write-Host ("Restoring: $($RestoreFileBaseName)")
                    # Collect old ids and new ids for mapping
                    $IdMapping = @{}
                    $GetCommandTemplate = "Get-JcSdk{0} -Fields id"
                    $NewCommandTemplate = "New-JcSdk{0}"
                    $SetCommandTemplate = "Set-JcSdk{0}"
                    $ExistingIds = (Invoke-Expression -Command:($GetCommandTemplate -f $RestoreFileBaseName)).id
                    $RestoreFileContent = Get-Content -Path:($RestoreFileFullName) | ConvertFrom-Json
                    $RestoreFileContent | ForEach-Object {
                        $RestoreFileRecord = $_
                        $CommandType = Invoke-Expression -Command:("[$($RestoreFileRecord.JcSdkType)]")
                        $RestoreFileRecord = $CommandType::DeserializeFromPSObject($RestoreFileRecord)
                        $CommandResults = If ( ($_.id -notin $ExistingIds) )
                        {
                            If (-not $RestoreFileRecord.ExternallyManaged)
                            {
                                Invoke-Expression -Command:("`$RestoreFileRecord | $($NewCommandTemplate -f $RestoreFileBaseName)")
                                # Invoke-Expression -Command:("$($NewCommandTemplate -f $RestoreFileBaseName) -Body:(`$RestoreFileRecord)")
                            }
                        }
                        Else
                        {
                            Write-Host ($RestoreFileRecord | ConvertTo-Json -Compress)
                            # Invoke command to update existing resource
                            Invoke-Expression -Command:("`$RestoreFileRecord | $($SetCommandTemplate -f $RestoreFileBaseName)")
                            # Invoke-Expression -Command:("$($SetCommandTemplate -f $RestoreFileBaseName) -Body:(`$RestoreFileRecord)")
                        }
                        If (-not [System.String]::IsNullOrEmpty($CommandResults))
                        {
                            $IdMapping.Add($RestoreFileRecord.id, $CommandResults.Id)
                        }
                    }
                    Return $IdMapping
                }) -ArgumentList:($RestoreFileFullName, $RestoreFileBaseName)
        }
        $JobStatus = Wait-Job -Id:($Jobs.Id)
        $IdMap += $JobStatus | Receive-Job

        # Foreach type start a new job and restore object association records
        # If ($PSBoundParameters.Association)
        # {

        # # flatten $IdMap to single table
        # $flattenedMap = @{}
        # ForEach ($hash In $$IdMap)
        # {
        #     ForEach ($key In $hash.Keys)
        #     {
        #         # write-host "OldID: $key maps to NewID: $($hash[$key])"
        #         $flattenedMap.Add($key, $($hash[$key]))
        #     }
        # }
        # Write-Host "$($flattenedMap.count) Items were restored"

        # $RestoreAssociationFiles = Get-ChildItem -Path:($ExpandedArchivePath.FullName) -Filter:('*Association*')
        # $Jobs = ForEach ($file In $RestoreAssociationFiles)
        # {
        #     Start-Job -ScriptBlock:( {
        #             Param ($file, $flattenedMap)
        #             $file = Get-Item $file
        #             Write-Host "checking $file"
        #             $functionName = "Get-JcSdk$($file.BaseName)".replace("-Association", "")
        #             $ExistingIds = (& $functionName -Fields id).id
        #             $Association = ConvertFrom-Json -InputObject (Get-Content $file -Raw)
        #             # for each association
        #             # TODO: quickly loop through and find possible target types, get existingTargetIds
        #             $targetTypes = $Association.Paths.ToType | Get-Unique
        #             $existingTargetIds = @()
        #             ForEach ($item In $targetTypes)
        #             {
        #                 $functionName = "Get-JcSdk$($JcTypesMap[$item])"
        #                 $existingTargetIds += (& $functionName -Fields id).id
        #             }
        #             ForEach ($item In $Association)
        #             {
        #                 if ($($flattenedMap[$($item.id)]) -And $($flattenedMap[$($item.targetId)]) -And ($($item.associationType) -eq "direct"))
        #                 {
        #                     # If the NewID maps back to a valid OldID, for both the source and target, create the Association
        #                     # Write-Host "Association Restore Type: New Source & Target"
        #                     New-JCAssociation -Type $($item.type) -Id $($flattenedMap[$($item.id)]) -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
        #                 }
        #                 if (($($flattenedMap[$($item.id)])) -And ($item.targetId -in $existingTargetIds) -And ($($item.associationType) -eq "direct"))
        #                 {
        #                     # NewID Maps to Old ID for source, associated w/ existingTargetID
        #                     # Write-Host "Association Restore Type: New Source, Existing Target"
        #                     New-JCAssociation -Type $($item.type) -Id $($flattenedMap[$($item.id)]) -TargetId $item.targetId -TargetType $($item.Paths.ToType) -Force
        #                 }
        #                 if (($item.id -in $ExistingIds) -And $($flattenedMap[$($item.targetId)]) -And ($($item.associationType) -eq "direct"))
        #                 {
        #                     # Source Old ID exists and Target NewID maps to Old ID
        #                     # Write-Host "Association Restore Type: Existing Source, New Target"
        #                     New-JCAssociation -Type $($item.type) -Id $item.id -TargetId $($flattenedMap[$($item.targetId)]) -TargetType $($item.Paths.ToType) -Force
        #                 }
        #                 if (($item.id -in $ExistingIds) -And ($item.targetId -in $existingTargetIds) -And ($($item.associationType) -eq "direct"))
        #                 {
        #                     # Source & Target exist, update association
        #                     if ($item.targetId -notin (Get-JCAssociation -Id $item.id -Type $item.type -TargetType $($item.Paths.ToType)).targetId)
        #                     {
        #                         Write-Host "Assocation Restored!"
        #                         New-JCAssociation -Type $($item.type) -Id $item.id -TargetId $item.targetId -TargetType $($item.Paths.ToType) -Force
        #                     }

        #                 }
        #             }
        #         }) -ArgumentList:($file, $flattenedMap)
        # }
        # $JobStatus = Wait-Job -Id:($Jobs.Id)
        # $JobStatus | Receive-Job
        # $finalCount = 0
        # ForEach ($item In $AssociationResults) {
        #     write-host "value $item"
        #     $finalCount += $item
        # }
        # write-host "$($finalCount) Association were restored"

        # TODO: for testing:
        # remove-jcusergroup PesterTest_UserGroup -Force; remove-jcusergroup ybelgqoz -Force; remove-jcsystemgroup PesterTest_SystemGroup -Force; $users = Get-JCUser | Where-Object { $_.email -Match "@pestertest" }; $users | Remove-JCUser -force; $users = Get-JCUser | Where-Object { $_.email -Match "@deleteme" }; $users | Remove-JCUser -force; $users = Get-JCUser | Where-Object { $_.email -Match "@fhpomlyu" }; $users | Remove-JCUser -force;
        # }
    }
    End
    {

    }
}

