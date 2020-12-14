<#
TODO
    1. Make "All" a switch parameter
    2. Through parameter sets if "All" is used then you cant use "Type" and vice versa
    3. Should association back up all associations for item or just the associations possible within the type parameter?
    4. Make this a class in psm1 file: [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
    5. Remove unzip folder
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
        $PSBoundParameters.Path = "$($PSBoundParameters.Path)/JumpCloud"
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
        # Foreach type start a new job and retreive object association records
        If ($PSBoundParameters.Associations)
        {
            # Map to define how jcassoc & jcsdk types relate
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
            # Get the backup files we created earlier
            $BackupFiles = Get-ChildItem $PSBoundParameters.Path | Where-Object { $_.BaseName -in $Types }
            $JobsAssociations = $BackupFiles | ForEach-Object {
                $BackupFile = $_
                Start-Job -ScriptBlock:( {
                        Param ($Path, $Types, $JcTypesMap, $BackupFile);
                        $AssociationResults = @()
                        # Get content from the file
                        $jsonContent = Get-Content $BackupFile | ConvertFrom-Json -Depth:(100)
                        ForEach ($item In $jsonContent)
                        {
                            Write-Host ("Get-JCAssociation -Type:($($JcTypesMap["$($item.JcSdkType)"])) -id:($($item.id))") -BackgroundColor cyan
                            $Result = Get-JCAssociation -Type:($JcTypesMap["$($item.JcSdkType)"]) -id:($item.id)
                            If ($Result)
                            {
                                $AssociationResults += $Result
                            }
                        }
                        # Write out the results
                        If (-not [System.String]::IsNullOrEmpty($AssociationResults))
                        {
                            # To multiple files
                            # $AssociationResults | ConvertTo-Json -Depth:(100) | Out-File -FilePath:("$BackupFile-associations.json") -Force
                            # To single file
                            $AssociationResults | ConvertTo-Json -Depth:(100) | Out-File -FilePath:("Associations.json") -Force -Append
                        }
                    }) -ArgumentList:($PSBoundParameters.Path, $Types, $JcTypesMap, $BackupFile)
            }
            $JobsAssociationsStatus = Wait-Job -Id:($JobsAssociations.Id)
            $JobsAssociationsStatus | Receive-Job
        }
        # Zip results
        $OutputPath = "$($PSBoundParameters.Path)_$(Get-Date -Format:("yyyyMMddTHHmmssffff")).zip"
        Compress-Archive -Path:($PSBoundParameters.Path) -CompressionLevel:('Fastest') -Destination:($OutputPath)
    }
    End
    {
        If (Test-Path -Path:($OutputPath))
        {
            Write-Host ("Backup Success: $($OutputPath)") -ForegroundColor:('Green')
        }
    }
}
