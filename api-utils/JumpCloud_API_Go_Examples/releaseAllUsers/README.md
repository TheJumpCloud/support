## AD Users Release

This tool allows you as a system administrator to remove the AD management flag from your systemusers and move them to be fully managed by JumpCloud's Directory as a Service.

### To Install

##### I do not have the Go toolchain installed
> Most users will want to follow these instructions

1. Go to the "Releases" tab of this github project
	- https://github.com/TheJumpCloud/jcapi/releases
2. We have provided `.zip` files for most operating systems
	- Note that macOS users will want to use the `darwin` binaries
3. Download the zip file of your choice 
	- We always recommend downloading from the latest release if possible
	- Most Windows users will want the `386` zip
4. Extract the files from the zip
	- Right click on the zip file and click `Extract All` on Windows
	- Double click on the zip file on macOS/Linux
5. `releaseAllUsers_myos_myarch` is the relevant binary
	- Some may find this is an unwieldy name to type every time. Feel free to rename to your liking, in fact if this is a tool you plan on running frequently we encourage this for ease of use.

> If you'd like to be able to call this binary from an arbitrary directory you can move it to `/usr/local/bin` on Linux and macOS
>> On macOS the keyboard shortcut `⌘ + Shift + G` with an open Finder window will allow you to directly type in the directory you'd like to access. To move the binary to `/usr/local/bin` with Finder simply use that shortcut and copy/paste `/usr/local/bin` into the dialog box. You can now drag and drop the binary onto the Finder window to easily make it accessible without having to navigate to a specific folder to run it. If you do this we also recommend renaming the binary before moving it to a more memorable name.

##### I have the Go toolchain installed
> If you don't know what "Go" or "Golang" is we have provided pre-made binaries for your convenience. Installation instructions for these binaries is provided in the previous section

1. Clone the `jcapi` repository (it doesn't matter where)
	- `git clone https://github.com/TheJumpCloud/jcapi`
2. Navigate to the `jcapi/examples/releaseAllUsers` directory
	- `cd jcapi/examples/releaseAllUsers`
3. Run go install
	- `go install .`

This will install a binary called `releaseAllUsers` to your `$GOBIN`

> If you'd like to be able to call this binary from an arbitrary directory make sure your `$GOBIN` is in your `$PATH` (linux) or `%PATH%` (windows)

### To Run

To run this tool you will need to use the command line. On Windows you can use PowerShell and on OSX you can use Terminal. 

> While running this tool requires no previous experience with either of those programs some might feel wary or nervous working with a tool they don't understand. The following instructions in this section should provide you with all you need to get up and running, but if you would like to learn about the how and why of the command line we highly recommend the excellent (and free!) [Command Line Crash Course by Zed Shaw](http://cli.learncodethehardway.org/). Zed even provides a direct email hotline for users that get stuck. If problems persist, or you are unsure of where to begin contact JumpCloud support for assistance running this tool.

This tool only takes two arguments:
- `key` is your JumpCloud API key (required)
- `url` is the JumpCloud API URL (optional)

For example:

`./releaseAllUsers -key=82105124f2979e28273d4e8dd32b2355c5012837`

Or:

`./releaseAllUsers -key=82105124f2979e28273d4e8dd32b2355c5012837 -url="https://console.jumpcloud.com/api"`

> If you have renamed your binary simply replace `releaseAllUsers` with the new name

> If you installed the binary with the Go toolchain and your `$GOBIN` is in your `$PATH` or `%PATH%`, or if you moved the binary to `/usr/local/bin` you can run the above command at any time on your command line excluding the "./"

##### Windows Instructions
1. Open `PowerShell`
2. Using the `cd` (stands for "Change Directory") command navigate to where you downloaded your binaries
	- For example, if we downloaded and unzipped the binaries in our `Download` folder we just have to run: `cd Downloads\JumpCloudAPI_Examples_windows_386`. If we downloaded to our desktop the command will probably look something like: `cd Desktop\JumpCloudAPI_Examples_windows_386`
	- If you used the Go install instructions and your `$GOBIN` is in your `%PATH%` you can skip step 2 and go right to 3
3. Grab your API key from the JumpCloud Admin console
	- Click on your email on the top right hand corner to access the API Settings
4. Run the command
	- `./releaseAllUsers.exe -key=YOUR_API_KEY_GOES_HERE`

> To run a command simply type it into the PowerShell window and hit `Enter` or `Return` when finished 

##### macOS/Linux Instructions
1. Open `Terminal` (this can be found in `Applications/Utilities`)
2. Using the `cd` (stands for "Change Directory") command navigate to where you downloaded your binaries
	- For example, if we downloaded and unzipped the binaries in our `Download` folder we just have to run: `cd Downloads/JumpCloudAPI_Examples_darwin_amd64`. If we downloaded to our desktop the command will probably look something like: `cd Desktop/JumpCloudAPI_Examples_darwin_amd64`
	- If you used the Go install instructions and your `$GOBIN` is in your `$PATH`, or if you manually moved the binary to `/usr/local/bin` you can skip step 2 and go right to 3
3. Grab your API key from the JumpCloud Admin console
	- Click on your email on the top right hand corner to access the API Settings
4. Run the command
	- `./releaseAllUsers -key=YOUR_API_KEY_GOES_HERE`

> To run a command simply type it into the Terminal window and hit `Enter` or `Return` when finished 
