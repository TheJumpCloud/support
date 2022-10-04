---
layout: post
title: Deploy Fonts via Commands
description: These Windows and MacOS commands will download a zipped folder of fonts & install those fonts on their respective systems
tags:
  - mac
  - windows
  - commands
  - fonts
---

If you've needed to deploy a number of fonts to Windows or MacOS systems, you've likely been frustrated with the numerous solutions online. Using JumpCloud commands and an accessible storage location like AWS S3, this task can be accomplished with relatively few lines of code.

### Basic Usage

- Copy all your fonts to a zipped directory and store the zipped directory in AWS S3
  - Copy the object URL for use in the Windows/ Mac script
- Create A Windows/ Mac Command in JumpCloud
- Copy the contents of the Windows/ Mac command to the command body in JumpCloud
  - Replace the `url` variable in either script with the Object URL from the S3 object.
- Scope the command to systems and run the script
- The fonts from the zipped directory will be downloaded to the selected systems and installed.

### Detailed Instructions

1. Copy Fonts to a zipped directory. In this example I'm using the Google Font: Roboto.

   ![Zip Files](./../../../images/fontsInstall/zipFiles.png)

2. Upload the .zip File to AWS S3 & copy the Object URL

   ![Zip Files](./../../../images/fontsInstall/awss3.png)

3. Create Command in JumpCloud. Replace URL with Object URL from S3

   ![Zip Files](./../../../images/fontsInstall/commandMac.png)

4. Run command on systems, the font will be installed on systems. In this mac example, fonts are installed to `/Library/Fonts`

   ![Zip Files](./../../../images/fontsInstall/installedFont.png)

### Scripts

MacOS Script:

```bash
#!/bin/bash
url="yourPublicURLHere"

##########
# download files
curl -o "/tmp/fonts.zip" $url
# unzip fils to temp location
unzip -o /tmp/fonts.zip -d /tmp/fonts
# copy files to System Fonts Directory
cp /tmp/fonts/* /Library/Fonts/
```

Windows PowerShell Script:

```powershell
# Set the URL
$url = "yourPublicURLHere"

##########
# Download the Font to a Temp Location in C:
Invoke-WebRequest -Uri $url -OutFile "C:\Windows\Temp\Fonts.zip"
# Unzip
Expand-Archive "C:\Windows\Temp\Fonts.zip" -DestinationPath "C:\Windows\Temp\Fonts" -Force

Get-ChildItem -Path "C:\Windows\Temp\Fonts" -Include '*.ttf', '*.ttc', '*.otf' -Recurse | ForEach-Object {
    If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {

        $fileName = $_.Name
        $filePath = $_.Fullname
        if ( -not (Test-Path -Path "C:\Windows\Fonts\$fileName") ) {
            Write-Host "Installing Font: $fileName"
            # Copy Font
            Copy-Item -Path $filePath -Destination ("C:\Windows\Fonts\" + $fileName) -Force
            # Register Font
            New-ItemProperty -Name $fileName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $filePath -Force | Out-Null
        }
    }
}
```
