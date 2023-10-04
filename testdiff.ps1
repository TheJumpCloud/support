$list = @("/PowerShell/Deploy/*", "/PowerShell/JumpCloud Module/*", "/PowerShell/ModuleChangelog.md")

# Loop through each file in the list then do git diff
$difCount = 0 # Diff Counter
$gitDiff = git diff origin/$GITHUB_BASE_REF..HEAD
foreach ($path in $list) {
    # Check if the path exists in the Git diff
    if ($gitDiff -match [regex]::Escape($path)) {
        Write-Host "Path found in Git diff: $path"
        $difCount++
    }
}
# If difcount = 0 then no changes were made to the files in the list, throw exit 1
if ($difCount -eq 0) {
    Write-Host "No changes were made to the files in the list, exiting with code 1"
    exit 1
}