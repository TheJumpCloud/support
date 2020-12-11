# <#
# .Synopsis
# The function exports objects from your JumpCloud organization to local json files
# .Description
# The function exports objects from your JumpCloud organization to local json files
# .Example
# PS C:\> {{ Add code here }}

# {{ Add output here }}
# .Example
# PS C:\> {{ Add code here }}

# {{ Add output here }}

# .Notes

# .Link
# https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V1/docs/exports/Backup-JcSdkOrganization.md
# #>
# Function Backup-JcSdkOrganization
# {
#     [CmdletBinding(DefaultParameterSetName = 'Backup', PositionalBinding = $false)]
#     Param(
#         [Parameter(ParameterSetName = 'Backup', Mandatory)]
#         [System.String]
#         # Specify output file path for backup files
#         ${Path},

#         # Add validate path
#         # [-All] [-Applications] [-Commands] [-Directories] [-LdapServers] [-Policies] [-RadiusServers] [-SoftwareApps] [-System] [-SystemGroup] [-SystemUser] [-UserGroup] [-Settings]

#         [Parameter(DontShow)]
#         [JumpCloud.SDK.V1.Category('Runtime')]
#         [System.Management.Automation.SwitchParameter]
#         # Wait for .NET debugger to attach
#         ${Break},

#         [Parameter(DontShow)]
#         [ValidateNotNull()]
#         [JumpCloud.SDK.V1.Category('Runtime')]
#         [JumpCloud.SDK.V1.Runtime.SendAsyncStep[]]
#         # SendAsync Pipeline Steps to be appended to the front of the pipeline
#         ${HttpPipelineAppend},

#         [Parameter(DontShow)]
#         [ValidateNotNull()]
#         [JumpCloud.SDK.V1.Category('Runtime')]
#         [JumpCloud.SDK.V1.Runtime.SendAsyncStep[]]
#         # SendAsync Pipeline Steps to be prepended to the front of the pipeline
#         ${HttpPipelinePrepend},

#         [Parameter(DontShow)]
#         [JumpCloud.SDK.V1.Category('Runtime')]
#         [System.Uri]
#         # The URI for the proxy server to use
#         ${Proxy},

#         [Parameter(DontShow)]
#         [ValidateNotNull()]
#         [JumpCloud.SDK.V1.Category('Runtime')]
#         [System.Management.Automation.PSCredential]
#         # Credentials for a proxy server to use for the remote call
#         ${ProxyCredential},

#         [Parameter(DontShow)]
#         [JumpCloud.SDK.V1.Category('Runtime')]
#         [System.Management.Automation.SwitchParameter]
#         # Use the default credentials for the proxy
#         ${ProxyUseDefaultCredentials}
#     )
#     Begin
#     {
#         $Results = @()
#         $PSBoundParameters.Add('HttpPipelineAppend', {
#                 param($req, $callback, $next)
#                 # call the next step in the Pipeline
#                 $ResponseTask = $next.SendAsync($req, $callback)
#                 $global:JCHttpRequest = $req
#                 $global:JCHttpRequestContent = If (-not [System.String]::IsNullOrEmpty($req.Content)) { $req.Content.ReadAsStringAsync() }
#                 $global:JCHttpResponse = $ResponseTask
#                 # $global:JCHttpResponseContent = If (-not [System.String]::IsNullOrEmpty($ResponseTask.Result.Content)) { $ResponseTask.Result.Content.ReadAsStringAsync() }
#                 Return $ResponseTask
#             }
#         )
#     }
#     Process
#     {

$Path = 'C:\Temp\jcorgbackup'
$Types = ('SystemUser', 'UserGroup', 'LdapServer')#, 'LdapServer', 'RadiusServer', 'Application', 'System', 'SystemGroup', 'Policy', 'Command', 'SoftwareApp', 'Directory')
# Map to define how jcassoc & jcsdk types relate
$map = @{
    Application  = 'application';
    Command      = 'command';
    aaa          = 'g_suite';
    LdapServer   = 'ldap_server';
    bbb          = 'office_365';
    Policy       = 'policy';
    RadiusServer = 'radius_server';
    System       = 'system';
    SystemGroup  = 'system_group';
    SystemUser   = 'user';
    UserGroup    = 'user_group';
}

$Jobs = $Types | ForEach-Object {
    $JumpCloudType = $_
    Start-Job -ScriptBlock:( {
            param ($Path, $JumpCloudType);
            $CommandTemplate = "Get-JcSdk{0}"
            $Result = Invoke-Expression -Command:($CommandTemplate -f $JumpCloudType)
            Write-Debug ('HttpRequest: ' + $JCHttpRequest);
            Write-Debug ('HttpRequestContent: ' + $JCHttpRequestContent.Result);
            Write-Debug ('HttpResponse: ' + $JCHttpResponse.Result);
            # Write-Debug ('HttpResponseContent: ' + $JCHttpResponseContent.Result);

            # Write output to file
            $Result `
            | Select-Object @{Name = 'JcSdkType'; Expression = { $JumpCloudType } }, * `
            | ConvertTo-Json -Depth:(100) `
            | Out-File -FilePath:("$($Path)/$($JumpCloudType).json") -Force
        }) -ArgumentList:($Path, $JumpCloudType)
}
$JobStatus = Wait-Job -Id:($Jobs.Id)
$JobStatus | Receive-Job



# Get the backup files we created earlier
$files = Get-ChildItem $Path | Where-Object { $_.BaseName -in $Types }
$JobsAssoc = $files | ForEach-Object {
# Foreach ($file in $files) {
    $file = $_
    Start-Job -ScriptBlock:( {
        param ($Path, $Types, $map, $file);
        $assoc = @()
        # Get content from the file
        $jsonContent = Get-Content $file | ConvertFrom-Json
        foreach ($item in $jsonContent){
            $result = Get-JCAssociation -type $map["$($item.JcSdkType)"] -id $($item.id)
            if ($result) {
                $assoc += $result
            }
        }
        # Write out the results
        $assoc | ConvertTo-Json -Depth: 100 | Out-File -FilePath:("$file-associations.json") -Force
    }) -ArgumentList:($Path, $Types, $map, $file)
}
$JobStatus = Wait-Job -Id:($JobsAssoc.Id)
$JobStatus | Receive-Job

# # Associations
# # Read files
# If (-not [System.String]::IsNullOrEmpty($Associations))
# {
#     Get-JCAssociation -Type: -Id -TargetType
# }


#     }
#     End
#     {
#         # Clean up global variables
#         $GlobalVars = @('JCHttpRequest', 'JCHttpRequestContent', 'JCHttpResponse', 'JCHttpResponseContent')
#         $GlobalVars | ForEach-Object {
#             If ((Get-Variable -Scope:('Global')).Where( { $_.Name -eq $_ })) { Remove-Variable -Name:($_) -Scope:('Global') }
#         }
#         Return $Results
#     }
# }
