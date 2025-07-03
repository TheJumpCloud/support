
###
# USAGE NOTES
#
# To run this script the modules MGGraph and JumpCloud must be installed
#
# An active authenticated session to Office 356 must be loaded prior to running the script.
#
# To do this call the 'Connect-MgGraph -Scopes "User.Read.All"' command and enter Office 365 admin credentials
#
# Prior to running populate the variable $JCAPIKey with the orgs JumpCloud API key that you wish to use as a source of truth to update users in Office 365
##

Connect-MgGraph -Scopes "User.Read.All", "User.ManageIdentities.All"

# Populate with JumpCloud API key
$JCAPIKey = ""

Connect-JCOnline -JumpCloudAPIKey $JCAPIKey -force

# Pull all JumpCloud users and add their email and _id to a hash table
$JCUsers = Get-JCUser -returnProperties email

$JCUsersHash = @{}

ForEach ($User in $JCUsers) {
    $JCUsersHash.Add($User.email, $User._id)
}

# Pull all Office 365 users and add their email and immutableID to a hash table
$Office365Users = Get-MgUser -All -Property UserPrincipalName, ImmutableID | Select-Object UserPrincipalName, ImmutableID

# Results variable
$Results = @()


# Iterate through each Office 365 user
ForEach ($Office365User in $Office365Users) {
    # If the Office 365 user is also a JumpCloud user
    if ($JCUsersHash.ContainsKey(($Office365User).UserPrincipalName)) {
        # Check to see if the Office 365 immutableID is equal to the JumpCloud _id
        if ($Office365User.ImmutableID -ne $JCUsersHash.$($Office365User.UserPrincipalName)) {
            try {
                # If these values are not equal update the Office 365 users immutableID to the JumpCloud _id
                Update-MgUser -UserId $Office365User.UserPrincipalName -OnPremisesImmutableId $JCUsersHash.$($Office365User.UserprincipalName)

                # Format the results
                $FormattedResults = [PSCustomObject]@{

                    UserprincipalName     = $Office365User.UserPrincipalName
                    Office365_ImmutableID = ($Office365User.ImmutableID)
                    JCUser_ID             = $JCUsersHash.$($Office365User.UserPrincipalName)
                    Status                = "Office365_ImmutableID updated"

                }

                # Add formatted results to results
                $Results += $FormattedResults

            } catch {
                # Error handling
                $FormattedResults = [PSCustomObject]@{

                    UserprincipalName     = $Office365User.UserPrincipalName
                    Office365_ImmutableID = ($Office365User.ImmutableID)
                    JCUser_ID             = $JCUsersHash.$($Office365User.UserPrincipalName)
                    Status                = $_.ErrorDetails

                }

                $Results += $FormattedResults

            }

        }
    }
}

# Return results to the screen
$Results

# And export results to CSV file in current working directory
$Results | Export-Csv -Path "Office365_ImmutableID_Updates.csv" -NoTypeInformation
