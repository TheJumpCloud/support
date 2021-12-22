#!/bin/bash

VERSION=$(grep -o '\d\+\.\d\+\.\d\+' ./PowerShell/JumpCloud\ Module/JumpCloud.psd1)
TITLE="JumpCloud PowerShell Module v$VERSION"
CHANGELOG=$(cat ./PowerShell/ModuleChangelog.md |awk "/^## $VERSION/{ f = 1; next } /## [0-9]+.[0-9]+.[0-9]+/{ f = 0 } f")
BODY="$TITLE $CHANGELOG"
# Get Merge # From CircleCI
TAG="v$VERSION"
ghr -t ${GITHUB_TOKEN} -u ${CIRCLE_PROJECT_USERNAME} -r ${CIRCLE_PROJECT_REPONAME} -c ${CIRCLE_SHA1} -n "$TITLE" -b "$BODY" -delete -draft "$TAG" /root/project/PowerShell/


# Build string to match 
# Get the matching module release version, cut that line out - we'll format it correctly
# Match the current release up to the next time a semantic version string match is found save to variable
cat ./PowerShell/ModuleChangelog.md |awk "/^## $VERSION/{ f = 1; next } /## [0-9]+.[0-9]+.[0-9]+/{ f = 0 } f"

cat .Path/To/PowerShell/ModuleChangelog.md |awk '/^## 1.18.12/{ f = 1; next } /## [0-9]+.[0-9]+.[0-9]+/{ f = 0 } f'
cat ./PowerShell/ModuleChangelog.md |awk -v pat="$VERSION" '$0~pat'
cat ./PowerShell/ModuleChangelog.md |awk -v pat="$VERSION" '$0 ~ pat, /## [0-9]+.[0-9]+.[0-9]+/{ f = 0 } f'


# Get latest version, save to variable
VERSION=$(grep -o '\d\+\.\d\+\.\d\+' ../Path/To/PowerShell/JumpCloud\ Module/JumpCloud.psd1)

# This works
cat ./Path/To/PowerShell/ModuleChangelog.md |awk '/^## 1.18.12/{ f = 1; next } /## [0-9]+.[0-9]+.[0-9]+/{ f = 0 } f'
# This returns the line
cat ./PowerShell/ModuleChangelog.md |awk -v pat="$VERSION" '$0~pat'

cat ./PowerShell/ModuleChangelog.md |awk -v pat="$VERSION" '/$0~pat/,/1.18.11/'
grep -a volume somefile | awk -v t1="$time1" -v t2="$time2" '($0~"^"t1),($0~"^"t2)'

# I need to get the contents of the changelog file between 1.18.12 and whenever ther'es a sementic version match

cat ./PowerShell/ModuleChangelog.md |awk "/^## $VERSION/{ f = 1; next } /## [0-9]+.[0-9]+.[0-9]+/{ f = 0 } f"
cat ./PowerShell/ModuleChangelog.md |awk "/^## $VERSION/, /## [0-9]+.[0-9]+.[0-9]+/"

# Heres the thing I want!
changelog=$(cat ./PowerShell/ModuleChangelog.md |awk "/^## $VERSION/{ f = 1; next } /## [0-9]+.[0-9]+.[0-9]+/{ f = 0 } f")