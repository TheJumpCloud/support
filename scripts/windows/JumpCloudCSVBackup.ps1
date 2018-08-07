function Invoke-JCBackup
{
    [CmdletBinding()]
    param (

        [switch] $Users,
        [switch] $SystemUsers,
        [switch] $Systems,
        [switch] $UserGroups,
        [switch] $SystemGroups
       
    )
    
    begin
    {
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
        
        [System.Console]::Clear();

        Write-Host $Banner -ForegroundColor Green

        Write-Host "`n============= Backup Status ============`n"

        if ($Users)
        {

            Write-Host -nonewline "Backing up JumpCloud user information..."

            try
            {
                Get-JCUser | Select-Object * , `
                @{Name = 'attributes'; Expression = {$_.attributes | ConvertTo-Json}}, `
                @{Name = 'addresses'; Expression = {$_.addresses | ConvertTo-Json}}, `
                @{Name = 'phonenumbers'; Expression = {$_.phonenumbers | ConvertTo-Json}}, `
                @{Name = 'ssh_keys'; Expression = {$_.ssh_keys | ConvertTo-Json}} `
                    -ExcludeProperty attributes, addresses, phonenumbers, ssh_keys | Export-CSV -Path "JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force

                Write-Host "JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV created."
                    
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
                Get-JCSystem | Get-JCSystemUser | Select-Object -Property * , @{Name = 'BindGroups'; Expression = {$_.BindGroups | ConvertTo-Json}} -ExcludeProperty BindGroups | Export-CSV -Path "JumpCloudSystemUsers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force 

                Write-Host "JumpCloudSystemUsers_$(Get-Date -Format MMddyyyy).CSV created."
                    
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
                @{Name = 'networkInterfaces'; Expression = {$_.networkInterfaces | ConvertTo-Json}}, `
                @{Name = 'sshdParams'; Expression = {$_.sshdParams | ConvertTo-Json}} `
                    -ExcludeProperty networkInterfaces, sshdParams, connectionHistory | Export-CSV -Path "JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force

                Write-Host "JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV created."

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
                Get-JCGroup -Type User | Get-JCUserGroupMember | Export-CSV -Path "JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force

                Write-Host "JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV created."

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
                Get-JCGroup -Type System | Get-JCSystemGroupMember | Export-CSV -Path "JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation -Force

                Write-Host "JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV created."

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


Invoke-JCBackup -Users -SystemUsers -Systems -UserGroups -SystemGroups
