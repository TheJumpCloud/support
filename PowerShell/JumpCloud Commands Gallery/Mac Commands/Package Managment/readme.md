# Update/ Patching using JumpCloud

There are a few methods for patching mac systems. [AutoPkg](https://github.com/autopkg/autopkg) is a well supported, community backed project which uses "recipe" based code to process package installs and deployment. [Homebrew](https://brew.sh/) is another popular package manager for macOS. Either tool can be used in conjunction with JumpCloud to push and update packages on macOS systems. The scripts provided in this repository and within each package manager should be vetted by each admin before use in a production environment.

Prerequisites: Install Xcode command line tools (recommended for git). Install via a JumpCloud Command. [Rich Trouton's silent Xcode install script](https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/install_xcode_command_line_tools) is a valid way to do this. Add as a new command with a 5-10min timeout depending on network speed.

## AutoPKG

Requirements: Admin user across all systems.

Deploy the [Install AutoPkg command](./Mac&#32;-&#32;Install&#32;AutoPkg&#32;Package&#32;Manager.md) across your mac fleet.



## Homebrew

Requirements: Manually install [homebrew](https://brew.sh/) or [homebrew-install.sh](./homebrew-install.sh) script variant, Admin user has installed homebrew and is on every system you wish to run homebrew on.
