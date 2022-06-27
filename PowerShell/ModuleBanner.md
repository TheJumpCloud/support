#### Latest Version

```
2.0.0
```

 #### Banner Current

```
* This release adds parallel processing functionality to potentially alleviate long processing times for large scale operations
    * This release adds the -parallel flag to the following functions:
        * Get-JCUser
        * Get-JCSystem
        * Get-JCSystemUser
        * Get-JCSystemGroupMember
        * Get-JCUserGroupMember
        * Get-JCCommandResult
* Adjusted output for Get-JCSystemGroupMember -ByID and Get-JCUserGroupMember -ByID to match the output of -GroupName
* Added -ByCommandID and -CommandID to Get-JCCommandResult
    * The added functionality will allow admins to search for all command results pertaining to a single command via the commandID or the workflowID
    * When using the pipeline for inputting a command object to Get-JCCommandResult, use the -ByCommandID switch
        * Example: $OrgCommandResults = Get-JCCommand | Get-JCCommandResult -ByCommandID
    * When using the pipeline for inputting a commandResult object to Get-JCCommandResult, use the -ByID switch
        * Example: $OrgCommandResults = Get-JCCommandResult | Get-JCCommandResult -ByID
```

#### Banner Old

```
* Added search endpoint functionality and parameters to Get-jCCommand
```
