# Step 1 create/update markdown help files using platyPS

Import-Module '~/Git/support/PowerShell/JumpCloud Module/JumpCloud.psd1'
Update-MarkdownHelpModule -Path '~/Git/support/PowerShell/JumpCloud Module/Docs' 

# Step 2 update the new files or the existing files
# Create online versions of the help files in the support.wiki
# Update docs with links to the online docs for 'Get-Help -online' commands

#Step 3 create new external help with updated markdown help

New-ExternalHelp -path '~/Git/support/PowerShell/JumpCloud Module/Docs'  -OutputPath '~/Git/support/PowerShell/JumpCloud Module/en-US'  -Force