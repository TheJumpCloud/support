# Managing AutoPkg packages using JumpCloud

[AutoPkg](https://github.com/autopkg/autopkg) is a well supported, community backed project which uses "recipe" based code to process application installs and deployment. AutoPkg can be used in conjunction with JumpCloud to install and update applications on macOS systems. Scripts provided in this repository should be vetted by each admin before use in a production environment. The [AutoPkg wiki](https://github.com/autopkg/autopkg/wik) should be referenced for additional information.

**Prerequisites**: Install Xcode command line tools. Xcode can be installed via a JumpCloud Command. [Rich Trouton's silent Xcode install script](https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/install_xcode_command_line_tools) is just one of many ways to automate this process. Copy that script into a new JumpCloud command with a 5-10min timeout, depending on network speed and deploy to desired systems.

## AutoPkg

Although AutoPkg is commonly used to source packages for deployment en masse, it has the ability to install packages locally. Members in the Mac Admin community have built their own [AutoPkg repositories](https://github.com/autopkg) of software packages and published those on github. AutoPkg is typically used with various processors to upload compiled packages directly to Munki, Jamf Pro, Filewave or other distribution points.

AutoPkg can be installed locally on systems and directed to install ".download" recipes. Included within AutoPkg are several core processors which admins can leverage to take various action on package sources. The ".install" recipe extension takes the processed package or .dmg from a ".download" recipe and installs it on a local system. The AutoPkg recipe system is modular. An admin can build their own "exampleApplication.install" recipe based on "exampleApplication.download" recipe. Thus, an admin can install any community built recipe on local systems. Similarly, the .jss and .munki extensions build upon .download or .pkg recipes to take additional action like uploading packages to distribution points, creating computer groups and further automating the package deployment process.

The recipe model of AutoPkg allows admins to have granular control of their packaging workflow. Without much configuration, AutoPkg can be used to install applications on local systems.

Requirements:

* JumpCloud managed admin user on all systems
* Xcode Command Line Tools installed for the management of .git sources
* At least one repository to search, download and install applications
  
### Install AutoPkg on JumpCloud systems

Deploy the [Mac - Install AutoPkg Package Manager](./Mac&#32;-&#32;Install&#32;AutoPkg&#32;Package&#32;Manager.md) command to the desires system endpoints. Note, this command should run as root. The Xcode command line tools application must be installed before AutoPkg

### Deployment of Chrome, Firefox and VLC with AutoPKG Example

The [Mac - Install AutoPkg Apps](Mac&#32;-&#32;Install&#32;Homebrew&#32;Apps.md) command is included to provide admins with a one click example script to deploy Chrome, Firefox and VLC player. After the AutoPkg binary has been installed on a set of systems, deploy the [Mac - Install AutoPkg Apps](Mac&#32;-&#32;Install&#32;Homebrew&#32;Apps.md) command to the same set of systems, running the command as a local admin. AutoPkg will download and install Chrome, Firefox and VLC. Note, this command is run as a local admin, subsequent AutoPkg commands should be run on the same administrator account.

### Updating AutoPkg Managed Applications

Well-maintained AutoPkg recipes point to the latest version of an application unless otherwise specified. Running `autopkg install firefox.install` on a system with Firefox installed will compare versions the installed application and the downloaded application and evaluate whether or not an update is necessary. If the AutoPkg source application is greater than the installed version on a given system, AutoPkg will attempt to install over the existing version of an application.

Changes to recipe repositories require administrators to pull those changes from github. If a change has been committed to a repository, that repository must be updated for AutoPkg to recognize those changes. An admin can update repositories using the `autopkg repo-update example-repository-url` syntax. An example of this update process is provided in the [Mac - Install AutoPkg Apps](Mac&#32;-&#32;Install&#32;Homebrew&#32;Apps.md) command.

If a specific version of an application is required, chances are that AutoPkg can download an install that package. Rich Trouton's Der Flounder blog posted a short  article on [AutoPkg's ability to package versioned apps](https://derflounder.wordpress.com/2013/11/10/using-autopkg-to-download-and-create-installers-for-firefox/).

### Example deployment of Spotify and adding a new repository

After installing AutoPkg on a system, the binary application should be available in the system path. Running the command: `autopkg --help` will return help documentation on a per-verb basis.

On a system with AutoPkg installed, run: `autopkg search spotify`.

![Spotify example](./images/spotify.png)

The result .recipe files in the example above are recipe results pulled from the community built [AutoPkg github](https://github.com/autopkg) organization. The "Spotify.download.recipe" in the "recipes" repo is the parent recipe to install Spotify on the example system. [Elliot Jordan's homebysix-recipes repo](https://github.com/homebysix) contains a Spotify.install.recipe which can use to install Spotify on a system. Inspecting this recipe file reveals that the parent recipe exists in the [AutoPkg Recipes repository](https://github.com/autopkg/recipes) If both repositories are trusted and the contents of each recipe have been vetted for accuracy, add both repositories using the `autopkg repo-add` command to add the repositories by their respective urls.

For example:

```bash
autopkg repo-add https://github.com/autopkg/recipes
autopkg repo-add https://github.com/autopkg/homebysix-recipes
```

Both recipe repositories should be available for the user context. Running `autopkg repo-list` should display the currently installed recipe repositories. After adding both repositories the spotify.install.recipe file is available for the autopkg binary to reference. Run `autopkg info Spotify.install` to verify information about the recipe before executing the run command:

```bash
autopkg run Spotify.install
```

Spotify will be installed on the current system. JumpCloud commands can automate this process across multiple systems.

#### Other Considerations

AutoPkg recipes can be extended or customized with overrides. The AutoPkg wiki provides more information on [recipe overrides](https://github.com/autopkg/autopkg/wiki/Recipe-Overrides) and [trust-info](https://github.com/autopkg/autopkg/wiki/AutoPkg-and-recipe-parent-trust-info) which can be used to securely monitor the package making process.

Running parent recipes without overrides will produce a similar warning message: `WARNING: example.jumpcloud.recipe is missing trust info and FAIL_RECIPES_WITHOUT_TRUST_INFO is not set. Proceeding...` unless recipe overrides are built and trusted on each system.
