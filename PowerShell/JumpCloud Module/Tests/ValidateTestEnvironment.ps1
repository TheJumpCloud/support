$CommandResults = Get-JCCommandResult #Ensure there are command results to test

if ($CommandResults._id.Count -lt 5) #If there are not at least five command results then use the Invoke-JCCommand to populate four command results
{
    Write-Error 'You must have at least 5 Command Results to run the Pester tests'
}

Write-Host "There are $($CommandResults._id.Count) command results"


$Commands = Get-JCCommand

if ($($Commands._id.Count) -le 1)
{ Write-Error 'You must have at least 2 JumpCloud commands to run the Pester tests'; break }

Write-Host "There are $($Commands.Count) commands"

$Triggers = $Commands | Where-Object trigger -ne '' | Measure-Object

if ($Triggers.Count -lt 2 )
{
    Write-Error 'You must have at least 2 JumpCloud commands with command triggers to run the Pester tests'
    break
}

$SystemGroups = Get-JCGroup -Type System
$UserGroups = Get-JCGroup -Type User

if ($UserGroups._id.Count -lt 2)
{
    Write-Error 'You must have at least 2 JumpCloud User Groups to run the Pester tests'; break
}

if ($SystemGroups._id.Count -lt 2)
{
    Write-Error 'You must have at least 2 JumpCloud System Groups to run the Pester tests'; break
}

Write-Host "There are $($UserGroups._id.Count) User Groups and " -NoNewline
Write-Host "there are $($SystemGroups._id.Count) System Groups"