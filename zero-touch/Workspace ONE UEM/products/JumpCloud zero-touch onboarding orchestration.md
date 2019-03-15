# Add Product

macOS

## General

### Name

Zero-touch JumpCloud onboarding

### Description

Deploys a script that runs post DEP enrollment to install the JumpCloud agent and auto-assign users to systems in JumpCloud

### Managed By

Your Work Space ONE UEM organization

### Smart Groups

Create a smart group which will apply to DEP enrolled machines.

Note once this product is saved and activated the workflow will kick off on all targeted machines.
 
The "Exclusions" section can be used when creating a Smart Group to exclude existing devices from being targeted.
 
## Manifest

ADD

### Add Manifest > Action(s) To Perform

Install Files/Actions

### Add Manifest > Files/Actions

[JumpCloud zero-touch onboarding workflow](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/files%26actions/JumpCloud%20zero-touch%20onboarding%20workflow.md)

## Conditions

### Download Conditions

[JumpCloud zero-touch onboarding prompt](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/conditions/JumpCloud%20zero-touch%20onboarding%20prompt.md)

## Deployment

N/A

## Dependencies

N/A

## Activate

Select the "Activate" button to activate the workflow. **Note this will activate this workflow to run on all scoped devices which have been targeted by the "Smart Group".**