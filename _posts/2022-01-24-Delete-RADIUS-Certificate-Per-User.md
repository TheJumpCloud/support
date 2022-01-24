---
layout: post
title: Delete RADIUS Certificates Per User
description: An example of how to delete outdated RADIUS Certificates using JumpCloud commands
tags:
  - commands
  - bash
  - mac
  - RADIUS
---

This is to showcase a possible use case of deleting old/expired RADIUS certificates from user's keychains and allow for the new RADIUS certificates to take their place.

### Basic Usage

* You will need to know the old certificate's HASH value or name
* Create a command similar to the setup shown [here](#Command-Setup)
* The script will use the last logged in user, ensure that the user in question is the correct user

### Additional Information

If the certificate's HASH value is unknown, the delete-certificate command accepts other parameters:
```
Usage: delete-certificate [-c name] [-Z hash] [-t] [keychain...]

-c  Specify certificate to delete by its common name
-Z  Specify certificate to delete by its SHA-1 hash value
-t  Also delete user trust settings for this certificate The certificate to be deleted 

must be uniquely specified either by a string found in its common name, or by its SHA-1 hash. If no keychains are specified to search, the default search list is used.
```

### Script

```bash
# Get last user logged into console and put into variable "lastUser"
lastUser=`stat -f %Su /dev/console`

## Delete SHA-1 for radius.jumpcloud.com certificate which expired 
security delete-certificate -Z <SHA-1 HASH> /Users/$lastUser/Library/Keychains/login.keychain-db
```

### Command Setup
![image](https://user-images.githubusercontent.com/89030113/150854220-e563fc1e-3d69-4222-ad65-ef3435e46a25.png)

