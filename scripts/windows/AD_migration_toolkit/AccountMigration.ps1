# Domain account migration to local account migration workflow using ProfWiz.msi

# Step 1 create new local user account. This is the account that domain account will be migrated to in 'Step 2'.
# **IMPORTANT** the temp password for new local user account is 'Temp123!'. Update the $TempPassword variable if you wish to change this. 

$Username = Read-Host "Enter desired local account username. Users temp password will be 'Temp123!'"
$TempPassword = "Temp123!"
net user /add $Username $TempPassword

# Step 2 download and launch Profwiz 
Function DownloadProfwiz($Link, $Path)
{
    (New-Object System.Net.WebClient).DownloadFile("$Link", "$Path")
}

$Link = "https://www.forensit.com/Downloads/Profwiz.msi"
$Path = "$PWD\Profwiz.msi"

DownloadProfwiz -Link $Link -Path $Path

# Install Profwiz.msi and use the GUI to migrate the domain account to local user account created in 'Step 1'
Invoke-Item $Path
