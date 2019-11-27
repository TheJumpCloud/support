###################### Auto Generate Employee IDs  ##########################
# This script will check each user's employeeIdentifier (Employee ID)
#
# First, the script will take the first two characters of an employee's first
# and last name and save those characters to a variable. It will then append 
# four random numbers to the end of that variable. If that variable exists
# in JumpCloud as an existing Employee ID, the numbers will be regenerated 
# until the Employee ID variable is unique.
#
# If the user does not have an Employee ID and the generated Employee ID
# is unique, the script will assign that generated Employee ID to the user.
#
# If a user already has an Employee ID, the script will not update that
# employee's ID and will print the output
#
# Author: Joe Workman | joe.workman@jumpcloud.com 
# Version: 1.0
############################################################################

# To check and set every user in an org:
Get-JCUser | ForEach-Object {
    Write-Host "CHECKING username:" $_.username
    # take first two letters from first and last name, convert to lowercase 
    $eid = ($_.firstname.Substring(0, [Math]::Min($_.firstname.Length, 2)) + $_.lastname.Substring(0, [Math]::Min($_.lastname.Length, 2))).toLower() 
    # then add random 4 digit number
    $eid += Get-Random -minimum 1000 -maximum 9999
    # if this employeeID belongs to another user delete last four characters and pick new random numbers
    while ( Get-JCUser -employeeIdentifier $eid ){
        Write-Host "Found existing Employee ID, generate random numbers again"
        # remove the last four characters off the variable by selecting only the first four
        $eid = $eid.Substring(0, [Math]::Min($eid.Length, 4))
        # append random four digits to the end of the variable
        $eid += Get-Random -minimum 1000 -maximum 9999
        # print the variable
        Write-Host "New Employee ID:" $eid
    }
    # if the current user does not have a eid, set the eid
    if ( !$_.employeeIdentifier ) {
        Write-Host "UPDATING username:" $_.username " with Employee ID:" $eid
        # Set-JCUser will update the currently checked username with the new Employee ID
        Set-JCUser -Username $_.username -employeeIdentifier $eid
    }
    else {
        # Username is already set
        Write-Host "Username:" $_.username "already has Employee ID:" $_.employeeIdentifier
    }
    # print a line to visualize end of loop
    Write-Host "______________________"
} 
