#!/bin/bash

# should be run as root
# Install AutoPkg
curl -L -o /tmp/autopkg-1.2.pkg "https://github.com/autopkg/autopkg/releases/download/v1.2/autopkg-1.2.pkg" >/dev/null
installer -pkg /tmp/autopkg-1.2.pkg -target /

exit 0