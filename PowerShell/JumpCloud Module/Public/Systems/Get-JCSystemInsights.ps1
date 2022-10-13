<#
.Synopsis
JumpCloud's System Insights feature provides admins with the ability to easily interrogate their
fleet of systems to find important pieces of information. Using this function you
can easily gather heightened levels of information from your fleet of JumpCloud managed
systems.
.Description
Using Get-JCSystemInsights will allow you to easily query JumpCloud's RESTful API to return information from your fleet of JumpCloud managed
systems.

.Example
PS C:\> Get-JCSystemInsights -Table:('App');

Get all Apps from systems with system insights enabled.

.Example
PS C:\> Get-JCSystemInsights -Table:('App') -SystemId:('5d66e0ac51db1e789bb17c77', '5e0e19831bc893319ae068b6');

Get all Apps from the specific systems.

.Example
PS C:\> Get-JCSystemInsights -Table:('App') -Filter:('system_id:eq:5d66e0ac51db1e789bb17c77', 'bundle_name:eq:storeuid');

Get systems that have a specific App on a specific system where the filter is multiple strings.

.Example
PS C:\> Get-JCSystemInsights -Table:('App') -Filter:('system_id:eq:5d66e0ac51db1e789bb17c77, bundle_name:eq:storeuid');

Get systems that have a specific App on a specific system where the filter is a string.

.Link
https://github.com/TheJumpCloud/support/wiki/Get-JCSystemInsights
#>
Function Get-JCSystemInsights {
    [CmdletBinding(DefaultParameterSetName = 'List', PositionalBinding = $false)]
    Param(
        [Parameter(Mandatory)]
        [System.String]
        # Name of the SystemInsights table to query.
        # See docs.jumpcloud.com for list of available table endpoints.
        # Use TAB to see a list of available tables ex: Get-JCSystemInsights -Table <TAB>
        # Output:
        # Alf                    FirefoxAddon           Shadow
        # AlfException           Group                  SharedFolder
        # AlfExplicitAuth        IeExtension            SharedResource
        # App                    InterfaceAddress       SharingPreference
        # AppCompatShim          InterfaceDetail        SipConfig
        # AuthorizedKey          KernelInfo             StartupItem
        # Battery                Launchd                SystemControl
        # BitlockerInfo          LoggedinUser           SystemInfo
        # BrowserPlugin          LogicalDrive           Uptime
        # Certificate            ManagedPolicy          UsbDevice
        # ChromeExtension        Mount                  User
        # Connectivity           OSVersion              UserGroup
        # Crash                  Patch                  UserSshKey
        # CupDestination         Program                WifiNetwork
        # DiskEncryption         PythonPackage          WifiStatus
        # DiskInfo               SafariExtension        WindowSecurityProduct
        # DnsResolver            ScheduledTask
        # EtcHost                Service
        $Table,

        [Parameter()]
        [System.String[]]
        [Alias('_id', 'id', 'system_id')]
        # Id of system to filter on.
        $SystemId,

        [Parameter()]
        [System.String[]]
        # Supported values and operators are specified for each table.
        # See docs.jumpcloud.com and search for specific table for a list of available filter options.
        # Use tab complete to see available filters.
        $Filter,

        [Parameter(DontShow)]
        [System.Boolean]
        # Set to $true to return all results. This will overwrite any skip and limit parameter.
        $Paginate = $true
    )
    Begin {
        Connect-JCOnline -force | Out-Null
        $CommandTemplate = "JumpCloud.SDK.V2\Get-JcSdkSystemInsight{0} @PSBoundParameters"
        $Results = @()
        If (-not [System.String]::IsNullOrEmpty($PSBoundParameters.Filter)) {
            $PSBoundParameters.Filter = $PSBoundParameters.Filter -replace (', ', ',') -join ','
        }
        If (-not [System.String]::IsNullOrEmpty($PSBoundParameters.SystemId)) {
            $SystemIdFilter = $PSBoundParameters.SystemId | ForEach-Object {
                $SystemIdFilterString = "system_id:eq:$($_)"
                If (-not [System.String]::IsNullOrEmpty($PSBoundParameters.Filter)) {
                    "$($SystemIdFilterString),$($PSBoundParameters.Filter)"
                } Else {
                    $SystemIdFilterString
                }
            }
        }
        $PSBoundParameters.Remove('Table') | Out-Null
        $PSBoundParameters.Remove('SystemId') | Out-Null
    }
    Process {
        $Results = If (-not [System.String]::IsNullOrEmpty($SystemIdFilter)) {
            $SystemIdFilter | ForEach-Object {
                $PSBoundParameters.Filter = $_
                Invoke-Expression -Command:($CommandTemplate -f $Table)
            }
        } Else {
            Invoke-Expression -Command:($CommandTemplate -f $Table)
        }
    }
    End {
        Return $Results
    }
}