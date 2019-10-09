# Update/ Patching using JumpCloud

There are a few methods for patching mac systems. [AutoPkg](https://github.com/autopkg/autopkg) is a well supported, community backed project which uses "recipe" based code to process package installs and deployment. [Homebrew](https://brew.sh/) is another popular package manager for macOS. Either tool can be used in conjunction with JumpCloud to push and update packages on macOS systems. The scripts provided in this repository and within each package manager should be vetted by each admin before use in a production environment. 

## AutoPKG

Requirements: Admin user across all systems. Xcode-select (for git)

## Homebrew

Requirements: Manually install [homebrew](https://brew.sh/) or [homebrew-install.sh](./homebrew-install.sh) script variant, Admin user has installed homebrew and is on every system you wish to run homebrew on.
