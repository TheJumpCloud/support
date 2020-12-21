<#
TODO
    1. Make "All" a switch parameter
    2. Through parameter sets if "All" is used then you cant use "Type" and vice versa
    3. Should association back up all associations for item or just the associations possible within the type parameter?
    4. Make this a class in psm1 file: [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
    5. Remove unzip folder
    6. Add manifest file
    7. Only "Direct" associations
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
https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Backup-JCOrganization.md
#>
Function Backup-JCOrganization
{
    [CmdletBinding(DefaultParameterSetName = 'Backup', PositionalBinding = $false)]
    Param(
        [Parameter(ParameterSetName = 'Backup', Mandatory)]
        [System.String]
        # Specify output file path for backup files
        ${Path},

        [Parameter()]
        [ValidateSet('All', 'SystemGroup', 'UserGroup', 'System', 'SystemUser')]
        [System.String[]]
        # Specify the type of JumpCloud objects you want to backup.
        ${Type},

        [Parameter()]
        [switch]
        # Include to backup object type associations
        ${Associations}
    )
    Begin
    {
        $Date = Get-Date -Format:("yyyyMMddTHHmmssffff")
        $ChildPath = "JumpCloud_$($Date)"
        $PSBoundParameters.Path = Join-Path -Path:($PSBoundParameters.Path) -ChildPath:($ChildPath)
        $OutputPath = Join-Path -Path:($PSBoundParameters.Path) -ChildPath:("$($ChildPath).zip")
        # If the path does not exist, create it
        If (-not (Test-Path $PSBoundParameters.Path))
        {
            New-Item -Path:($PSBoundParameters.Path) -Name:$($PSBoundParameters.Path.BaseName) -ItemType:('directory')
        }
        # When Type = All use the rest of the existing options
        $Types = If ($PSBoundParameters.Type -eq 'All')
        {

            $Command = Get-Command $MyInvocation.MyCommand
            $Command.Parameters.Type.Attributes.ValidValues | Where-Object { $_ -ne 'All' }
        }
        Else
        {
            $PSBoundParameters.Type
        }
    }
    Process
    {
        # Foreach type start a new job and retreive object records
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
                }) -ArgumentList:($PSBoundParameters.Path, $JumpCloudType)
        }
        $JobStatus = Wait-Job -Id:($Jobs.Id)
        $JobStatus | Receive-Job
        # # Foreach type start a new job and retreive object association records
        # If ($PSBoundParameters.Associations)
        # {
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
        #     # Get the backup files we created earlier
        #     $BackupFiles = Get-ChildItem $PSBoundParameters.Path | Where-Object { $_.BaseName -in $Types }
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
        #             }) -ArgumentList:($PSBoundParameters.Path, $Types, $JcTypesMap, $BackupFileFullName, $BackupFileBaseName, $BackupFilesBaseName)
        #     }
        #     $JobsAssociationsStatus = Wait-Job -Id:($JobsAssociations.Id)
        #     $JobsAssociationsStatus | Receive-Job
        # }
        # Zip results
        If (Compress-Archive -Path:($PSBoundParameters.Path) -CompressionLevel:('Fastest') -Destination:($OutputPath))
        {
            Remove-Item -Path:($PSBoundParameters.Path)
        }
    }
    End
    {
        If (Test-Path -Path:($OutputPath))
        {
            Write-Host ("Backup Success: $($OutputPath)") -ForegroundColor:('Green')
        }
    }
}
