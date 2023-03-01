function Show-RadiusMainMenu {
    param (
        [string]$Title = 'JumpCloud Radius Cert Deployment'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "$([char]0x1b)[96mEdit the variables in Config.ps1 before continuing this script"

    Write-Host "1: Press '1' to generate or import your Root Certificate."
    Write-Host "2: Press '2' to generate/update your User Certificate(s)."
    Write-Host "3: Press '3' to distribute your User Certificate(s)."
    Write-Host "4: Press '4' to monitor your User Certification Distribution."
    Write-Host "Q: Press 'Q' to quit."
}