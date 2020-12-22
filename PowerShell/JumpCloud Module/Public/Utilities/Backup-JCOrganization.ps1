<#
TODO
    . Should association back up all associations for item or just the associations possible within the type parameter?
    . Only "Direct" associations
    . Make this a class in psm1 file: [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
    . Add manifest file
    . Roll back x-ms-enum
#>

<#
.Synopsis
The function exports objects from your JumpCloud organization to local json files

.Description
The function exports objects from your JumpCloud organization to local json files

.Example
Back up UserGroups and SystemUsers with their assoications
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers') -Associations

.Example
Back up UserGroups and SystemUsers without their assoications
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers')

.Example
Backup all avalible JumpCloud objects and their associations
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
        # Include to backup object type associations
        ${Associations}
    )
    Begin
    {
        $Date = Get-Date -Format:("yyyyMMddTHHmmssffff")
        $ChildPath = "JumpCloud_$($Date)"
        $TempPath = Join-Path -Path:($PSBoundParameters.Path) -ChildPath:($ChildPath)
        $ZipPath = Join-Path -Path:($PSBoundParameters.Path) -ChildPath:("$($ChildPath).zip")
        # If the path does not exist, create it
        If (-not (Test-Path $TempPath))
        {
            New-Item -Path:($TempPath) -Name:$($TempPath.BaseName) -ItemType:('directory')
        }
        # When -All is provided use all type options and associations
        $Types = If ($PSCmdlet.ParameterSetName -eq 'All')
        {
            $Associations = $true
            (Get-Command $MyInvocation.MyCommand).Parameters.Type.Attributes.ValidValues
        }
        Else
        {
            $PSBoundParameters.Type
        }
        #     # Map to define how jcassoc & jcsdk types relate
        #     $JcTypesMap = @{
        #         Application  = 'application';
        #         Command      = 'command';
        #         GSuite       = 'g_suite';
        #         LdapServer   = 'ldap_server';
        #         Office365    = 'office_365';
        #         Policy       = 'policy';
        #         RadiusServer = 'radius_server';
        #         System       = 'system';
        #         SystemGroup  = 'system_group';
        #         SystemUser   = 'user';
        #         UserGroup    = 'user_group';
        #     }
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
                    | Select-Object @{Name = 'JcSdkType'; Expression = { $JumpCloudType } }, * `
                    | ConvertTo-Json -Depth:(100) `
                    | Out-File -FilePath:("$($Path)/$($JumpCloudType).json") -Force
                }) -ArgumentList:($TempPath, $JumpCloudType)
        }
        $JobStatus = Wait-Job -Id:($Jobs.Id)
        $JobStatus | Receive-Job
        # # Foreach type start a new job and retreive object association records
        # If ($PSBoundParameters.Associations)
        # {
        #     # Get the backup files we created earlier
        #     $BackupFiles = Get-ChildItem $TempPath | Where-Object { $_.BaseName -in $Types }
        #     $BackupFilesBaseName = $BackupFiles.BaseName
        #     $JobsAssociations = $BackupFiles | ForEach-Object {
        #         $BackupFileFullName = $_.FullName
        #         $BackupFileBaseName = $_.BaseName
        #         Start-Job -ScriptBlock:( {
        #                 Param ($Path, $Types, $JcTypesMap, $BackupFileFullName, $BackupFileBaseName, $BackupFilesBaseName);
        #                 $AssociationType = $JcTypesMap["$($_.Key)"]
        #                 $ValidTargetTypes = (Get-Command Get-JCAssociation -ArgumentList:($AssociationType)).Parameters.TargetType.Attributes.ValidValues
        #                 $AssociationResults = @()
        #                 # Get content from the file
        #                 $jsonContent = Get-Content -Path:($BackupFileFullName) | ConvertFrom-Json
        #                 ForEach ($Record In $jsonContent)
        #                 {
        #                     Write-Host $Record
        #                     # Lookup file names in $JcTypesMap
        #                     $TargetTypes = $JcTypesMap.GetEnumerator() | ForEach-Object {
        #                         If ($_.Key -ne $BackupFileBaseName -and $_.Key -in $BackupFilesBaseName -and $_.Values -in $ValidTargetTypes)
        #                         {
        #                             $AssociationType
        #                         }
        #                     }
        #                     # If a valid target is found get the associations
        #                     If (-not [System.String]::IsNullOrEmpty($TargetTypes))
        #                     {
        #                         $Command = "Get-JCAssociation -Type:('$($JcTypesMap["$($Record.JcSdkType)"])') -id:('$($Record.id)') -TargetType:('$($TargetTypes -join "','")')"
        #                         # Write-Host ($Command) -BackgroundColor cyan
        #                         $Result = Invoke-Expression -Command:($Command)
        #                         If ($Result)
        #                         {
        #                             $AssociationResults += $Result
        #                         }
        #                     }
        #                 }
        #                 # Write out the results
        #                 If (-not [System.String]::IsNullOrEmpty($AssociationResults))
        #                 {
        #                     # To single file
        #                     # $AssociationResults | ConvertTo-Json -Depth:(100) | Out-File -FilePath:("$($BackupFileFullName)-associations.json") -Force
        #                     # To multiple files
        #                     $AssociationResults | ConvertTo-Json -Depth:(100) | Out-File -FilePath:("$($Path)/$($Record.JcSdkType)-Associations.json") -Force
        #                 }
        #             }) -ArgumentList:($TempPath, $Types, $JcTypesMap, $BackupFileFullName, $BackupFileBaseName, $BackupFilesBaseName)
        #     }
        #     $JobsAssociationsStatus = Wait-Job -Id:($JobsAssociations.Id)
        #     $JobsAssociationsStatus | Receive-Job
        # }
    }
    End
    {
        # Zip results
        Compress-Archive -Path:($TempPath) -CompressionLevel:('Fastest') -Destination:($ZipPath)
        # Clean up temp directory
        If (Test-Path -Path:($ZipPath))
        {
            Remove-Item -Path:($TempPath) -Force -Recurse
            Write-Host ("Backup Success: $($ZipPath)") -ForegroundColor:('Green')
        }
    }
}
