Execution Commands
Run the build script from the root of the repository using pwsh to generate a new version (Patch, Minor, or Major):

On Windows:

PowerShell
pwsh ./PowerShell/Deploy/Build-Module.ps1 -ReleaseType Patch
On macOS / Linux:

Bash
pwsh ./PowerShell/Deploy/Build-Module.ps1 -ReleaseType Patch
🛠️ Script Architecture
Get-Config.ps1: The configuration engine. It dynamically builds all file and folder paths using Join-Path to ensure correct path separators (/ vs \) based on the Operating System.

Build-Module.ps1: The orchestrator. It manages the build workflow, updates the module manifest (.psd1), and handles the changelog.

Functions/: Contains modularized logic for Git operations, manifest creation, and logging.

Cross-Platform Compatibility
The build system has been modernized to eliminate hardcoded path strings:

Windows (PS 5.1 & 7): Paths resolve using backslashes (e.g., C:\\Workspace\\...).

macOS / Linux: Paths resolve using forward slashes (e.g., /Users/name/...).

Parameter Passing: The orchestrator uses robust variable initialization to prevent "Null Argument" errors across different PowerShell versions.

Safety Note (ATENTION)
The Invoke-GitCommit.ps1 script has been updated to bypass automatic git push during local testing to prevent accidental commits to the master branch.
