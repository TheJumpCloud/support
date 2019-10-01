function Get-JCBackup
{
    [CmdletBinding(DefaultParameterSetName = 'None')]
    param (

        [Parameter(HelpMessage = 'A switch parameter that when called tells the command to back up JumpCloud user, system user, system, user group, and system group information to CSV files.')][switch] $All,
        [Parameter(HelpMessage = 'A switch parameter that when called backs up JumpCloud user information to CSV.')][switch] $Users,
        [Parameter(HelpMessage = 'A switch parameter that when called backs up JumpCloud system user information to CSV.')][switch] $SystemUsers,
        [Parameter(HelpMessage = 'A switch parameter that when called backs up JumpCloud system information to CSV.')][switch] $Systems,
        [Parameter(HelpMessage = 'A switch parameter that when called backs up JumpCloud user group membership to CSV.')][switch] $UserGroups,
        [Parameter(HelpMessage = 'A switch parameter that when called backs up JumpCloud system group membership to CSV.')][switch] $SystemGroups

    )

    begin
    {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JCOnline }

        if ($All)
        {

            $Users = $true
            $SystemUsers = $true
            $Systems = $true
            $UserGroups = $true
            $SystemGroups = $true

        }



        if ((-not $All) -and (-not $Users) -and (-not $SystemUsers) -and (-not $Systems -and (-not $UserGroups) -and (-not $SystemGroups)))
        {
            Write-Error "You must select item(s) to backup to CSV by setting parameter(s). Options include '-Users', '-SystemUsers', '-Systems','-UserGroups', '-SystemGroups', or '-All' to backup all items" -ErrorAction Stop
        }


        $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  /
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/
                       /_/
                                               CSV Backup
"@

    }


    process
    {

        If (!(Get-PSCallStack | Where-Object { $_.Command -match 'Pester' })) { Clear-Host }

        Write-Host $Banner -ForegroundColor Green

        Write-Host "`n============= Backup Status ============`n"

        if ($Users)
        {

            Write-Host -nonewline "Backing up JumpCloud user information..."

            try
            {
                Get-JCUser | Select-Object * , `
                @{Name = 'attributes'; Expression = { $_.attributes | ConvertTo-Json } }, `
                @{Name = 'addresses'; Expression = { $_.addresses | ConvertTo-Json } }, `
                @{Name = 'phonenumbers'; Expression = { $_.phonenumbers | ConvertTo-Json } }, `
                @{Name = 'ssh_keys'; Expression = { $_.ssh_keys | ConvertTo-Json } } `
                    -ExcludeProperty attributes, addresses, phonenumbers, ssh_keys | Export-Csv -Path "JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force

            Write-Host "JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV created.`n" -ForegroundColor Green

        }
        catch
        {
            Write-Host "$($_.ErrorDetails)"
        }

    }

    if ($SystemUsers)
    {

        Write-Host -nonewline "Backing up JumpCloud system user information..."

        try
        {
            Get-JCSystem -returnProperties hostname | % { Get-JCSystemUser -SystemID $_._id | Select-Object -Property * , @{Name = 'BindGroups'; Expression = { $_.BindGroups | ConvertTo-Json } } -ExcludeProperty BindGroups | Export-Csv -Path "JumpCloudSystemUsers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force -Append }

            Write-Host "JumpCloudSystemUsers_$(Get-Date -Format MMddyyyy).CSV created.`n" -ForegroundColor Green

        }
        catch
        {
            Write-Host "$($_.ErrorDetails)"

        }

    }

    if ($Systems)
    {

        Write-Host -nonewline "Backing up JumpCloud system information..."

        try
        {
            Get-JCSystem | Select-Object *, `
            @{Name = 'networkInterfaces'; Expression = { $_.networkInterfaces | ConvertTo-Json } }, `
            @{Name = 'sshdParams'; Expression = { $_.sshdParams | ConvertTo-Json } } `
                -ExcludeProperty networkInterfaces, sshdParams, connectionHistory | Export-Csv -Path "JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force

        Write-Host "JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV created.`n" -ForegroundColor Green

    }
    catch
    {
        Write-Host "$($_.ErrorDetails)"

    }



}

if ($UserGroups)
{

    Write-Host -nonewline "Backing up JumpCloud user group membership..."

    try
    {
        Get-JCGroup -Type User | % { Get-JCUserGroupMember  -GroupName $_.name | Export-Csv -Path "JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force -Append }

        Write-Host "JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV created.`n" -ForegroundColor Green

    }
    catch
    {
        Write-Host "$($_.ErrorDetails)"

    }

}

if ($SystemGroups)
{

    Write-Host -nonewline "Backing up JumpCloud system group membership..."

    try
    {
        Get-JCGroup -Type System | % { Get-JCSystemGroupMember  -GroupName $_.name | Export-Csv -Path "JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force -Append }

        Write-Host "JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV created.`n" -ForegroundColor Green
    }
    catch
    {
        Write-Host "$($_.ErrorDetails)"

    }

}

}

end
{


}

}