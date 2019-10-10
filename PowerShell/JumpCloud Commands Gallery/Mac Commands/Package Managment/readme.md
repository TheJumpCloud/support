# Update/ Patching using JumpCloud

There are a few methods for patching mac systems. [AutoPkg](https://github.com/autopkg/autopkg) is a well supported, community backed project which uses "recipe" based code to process package installs and deployment. [Homebrew](https://brew.sh/) is another popular package manager for macOS. Either tool can be used in conjunction with JumpCloud to push and update packages on macOS systems. The scripts provided in this repository and within each package manager should be vetted by each admin before use in a production environment.

Prerequisites: Install Xcode command line tools (recommended for git). Install via a JumpCloud Command. [Rich Trouton's silent Xcode install script](https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/install_xcode_command_line_tools) is a valid way to do this. Add as a new command with a 5-10min timeout depending on network speed.

## AutoPKG

Although AutoPkg is commonly used to source packages for deployment en masse, it has the ability to install packages locally. Many members in the Mac Admin community have built their own [AutoPkg repositories](https://github.com/autopkg) of software packages and published those on github. AutPkg is typically used with various processors to upload compiled packages directly to Munki, Jamf Pro, Filewave or other distribution points.

AutoPkg can be installed locally on systems and directed to install ".download" recipes. Included within AutoPkg are several core processors which admins can leverage to take various action on package sources. The ".install" recipe extension takes the output of a .download recipe and installs it on a local system. The AutoPkg recipe system is very modular. An admin can build their own "exampleApplication.install" recipe based on "macAdminCommunityMember's-exampleApplication.download" recipe. Thus, an admin can install any community built recipe on local machines. Similarly, the .jss and .munki extensions build upon .download recipes to take additional action like uploading packages to Jamf Distribution points, creating smart groups and automating the package deployment process.

The recipe system of AutoPkg allows admins to have granular control of their packaging workflow. At the most basic level, AutoPkg can be used to install packages. Advanced workflows can be developed to check sources for viruses and distribute packages to testing endpoints before general distribution. In this example, we'll leverage AutoPkg's ability to source and install packages on a local system.

Requirements: Admin user across all systems. Xcode Command Line Tools installed for the management of .git sources, namely the community maintained package sources which contain the apps to install.

Deploy the [Install AutoPkg command](./Mac&#32;-&#32;Install&#32;AutoPkg&#32;Package&#32;Manager.md) across your mac fleet.

### Example deployment of Spotify across your org

After installing AutoPkg on a system, the autopkg binary should have been made available in your system path. Running the command: `autopkg --help` with produce help documentation on a per-verb basis.

On a system with AutoPkg installed, run: `autopkg search spotify`.
![spotify example](./images/spotify.png)

The result .recipe files in the example above are results pulled from the community built [AutoPkg github](https://github.com/autopkg) organization. The "Spotify.download.recipe" in the "recipes" repo is the base recipe we'll use to install Spotify on our example machine. [Elliot Jordan's homebysix-recipes repo](https://github.com/homebysix) contains a Spotify.install.recipe which we can use to install Spotify on our systems. If both repos are trusted, and the contents of each recipe have been vetted, add both repos using the `autopkg repo-add` command to add the repos by their respective urls.

For example:
```
autopkg repo-add https://github.com/autopkg/recipes
autopkg repo-add https://github.com/autopkg/homebysix-recipes
```

Both recipe repos should be available for the user context. Running `autopkg repo-list` should display the currently installed recipe repositories. After adding both repos the .recipe file is available for the autopkg binary. Run `AutoPkg info Spotify.install` to verify information about the recipe before executing the run command:

```
autopkg run Spotify.install
```
Spotify should be installed on the current system. JumpCloud commands can automate this process across multiple systems. 

## Homebrew

Homebrew predates AutoPkg by a few years. Like AutoPkg, Homebrew enables users to build their own "Formulas" and package their own apps. In addition to the installing unix applications Homebrew was extended to install native macOS apps. Homebrew can be installed in multiple locations for multiple users. The purpose of this documentation is to provide administrators examples with Homebrew installed using a single admin.

Homebrew Cask (brew-cask) formulas often require some user input making the remote administration of those applications somewhat difficult. Depending on the use case, AutoPkg may be the better package manage for GUI macOS apps. Make no mistake, The Homebrew library of unix command line applications is incredibly well-maintained and a valuable resource for administrators.

Requirements: Manually install [homebrew](https://brew.sh/) or [homebrew-install.sh](./homebrew-install.sh) script variant, Admin user has installed homebrew and is on every system you wish to run homebrew on.
