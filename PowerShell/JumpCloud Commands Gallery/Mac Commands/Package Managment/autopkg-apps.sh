#!/bin/bash

# assuming autopkg is installed && ample timeout for JC command is set

# Add default repos
/usr/local/bin/autopkg repo-add https://github.com/autopkg/recipes # add https://github.com/autopkg/recipes
/usr/local/bin/autopkg repo-add https://github.com/autopkg/homebysix-recipes 

# Download and install application set
/usr/local/bin/autopkg install Firefox.install --verbose
/usr/local/bin/autopkg install GoogleChrome.install --verbose
/usr/local/bin/autopkg install VLC.install --verbose

exit 0