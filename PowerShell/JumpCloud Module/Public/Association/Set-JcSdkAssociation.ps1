# # $Prefix = 'JcSdk'
# # $AssociationKeyWords = @('Traverse') #'Association', 'Member', 'Membership',
# # $AssociationCommands = $AssociationKeyWords | ForEach-Object {
# #     $AssociationKeyWord = $_
# #     Get-Command -Module:('JumpCloud.SDK.V2') -Noun:("*$AssociationKeyWord*") | Select-Object -Property:*, @{Name = 'JcType'; Expression = { $_.Noun -Replace ($AssociationKeyWord, '') -Replace ($Prefix, '') } }
# # }
# # $AssociationsGet = $AssociationCommands.Where( { $_.Verb -eq 'Get' })
# # $AssociationsGet | ForEach-Object { $_.Name -replace ($_.JcType, '{0}') }

# # $V2Commands = Get-Command -Module:('JumpCloud.SDK.V2')
# # $AssociationCommands = $V2Commands | Where-Object { $_.Name | Select-String -Pattern:('(^.*?JcSdk)(.*?)(Association|Membership|Member|Traverse)(.*?$)') }
# # $AssociationCommands = $AssociationCommands | Select-Object -Property:*, @{Name = 'ParsedName'; Expression = { $_.Name | Select-String -Pattern:('(^.*?JcSdk)(.*?)(Association|Membership|Member|Traverse)(.*?$)') } }
# # $AssociationCommands.ParsedName | ForEach-Object { # [0],[1],[26],[25]
# #     $ParsedName = $_
# #     If ($ParsedName.Matches.Groups[0].Value -like '*Association*')
# #     {
# #         [PSCustomObject]@{
# #             Type    = $ParsedName.Matches.Groups[2].Value
# #             Keyword = $ParsedName.Matches.Groups[3].Value
# #         }
# #     }
# #     ElseIf ($ParsedName.Matches.Groups[0].Value -like '*MemberShip*')
# #     {
# #         [PSCustomObject]@{
# #             Type    = $ParsedName.Matches.Groups[2].Value
# #             Keyword = $ParsedName.Matches.Groups[3].Value
# #         }
# #     }
# #     ElseIf ($ParsedName.Matches.Groups[0].Value -like '*Member*')
# #     {
# #         [PSCustomObject]@{
# #             Type    = $ParsedName.Matches.Groups[2].Value
# #             Keyword = $ParsedName.Matches.Groups[3].Value
# #         }
# #     }
# #     ElseIf ($ParsedName.Matches.Groups[0].Value -like '*Traverse*')
# #     {
# #         [PSCustomObject]@{
# #             Type       = $ParsedName.Matches.Groups[2].Value
# #             Keyword    = $ParsedName.Matches.Groups[3].Value
# #             TargetType = $ParsedName.Matches.Groups[4].Value
# #         }
# #     }
# #     Else
# #     {
# #         Write-Error ("$ParsedName does not match any association key words.")
# #     }
# # }


# $V2Commands = Get-Command -Module:('JumpCloud.SDK.V2')
# $AssociationCommands = $V2Commands | Where-Object { $_.Name | Select-String -Pattern:('(^.*?JcSdk)(.*?)(Association|Membership|Member|Traverse)(.*?$)') }
# $AssociationCommands = $AssociationCommands | Select-Object -Property:*, @{Name = 'ParsedName'; Expression = { $_.Name | Select-String -Pattern:('(^.*?JcSdk)(.*?)(Association|Membership|Member|Traverse)(.*?$)') } }
# $Traverse = $AssociationCommands.Where( { $_.Name -like '*Traverse*' })

# $Type = 'User'
# $TargetType = 'Application'
# # Pull from "internal" module class?
# $Body = '{"op":"' + $Action + '","type":"' + $SourceItemTypeNameSingular + '","id":"' + $SourceItemId + '","attributes":' + $AttributesValue + '}'
# $Command = $Traverse | Where-Object { $_.ParsedName.Matches.Groups[2].Value -eq $Type -and $_.ParsedName.Matches.Groups[4].Value -eq $TargetType }
# Write-Host ("$($Command.Name) -Body:('$($Body)')") -BackgroundColor Cyan -ForegroundColor Black



# # $AssociationsGet = $AssociationCommands.Where( { $_.Verb -eq 'Get' })
# # $AssociationsSet = $AssociationCommands.Where( { $_.Verb -eq 'Set' })
# # $AssociationsGet | Select-Object Name, JcType | Group-Object JcType | Sort-Object Count
# $AssociationCommands | Get-Command -Syntax
# # $AssociationsGet | ForEach-Object { $_.Name -replace ($_.JcType, '{0}') }
# # $Type = 'User'
# # $Target = 'UserGroup'
# # If ($Type -in $AssociationsSet.JcType )
# # {
# #     $AssociationsSetCommand = $AssociationsSet.Where( { ($_.JcType -eq $Type) })

# #     # If (($Type -eq 'system' -and $Target -eq 'systemgroup') -or ($Type -eq 'user' -and $Target -eq 'usergroup'))
# #     # {
# #     #     $Uri_Associations_POST = $URL_Template_Associations_Members -f $TargetItemTypeNamePlural, $TargetItemId
# #     #     $JsonBody = '{"op":"' + $Action + '","type":"' + $SourceItemTypeNameSingular + '","id":"' + $SourceItemId + '","attributes":' + $AttributesValue + '}'
# #     # }
# #     # ElseIf (($Type -eq 'systemgroup' -and $Target -eq 'system') -or ($Type -eq 'usergroup' -and $Target -eq 'user'))
# #     # {
# #     #     $Uri_Associations_POST = $URL_Template_Associations_Members -f $Type, $SourceItemId
# #     #     $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetItemTypeNameSingular + '","id":"' + $TargetItemId + '","attributes":' + $AttributesValue + '}'
# #     # }
# #     # Else
# #     # {
# #     #     $Uri_Associations_POST = $URL_Template_Associations_Targets -f $Type, $SourceItemId, $SourceItemTargetSingular
# #     #     $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetItemTypeNameSingular + '","id":"' + $TargetItemId + '","attributes":' + $AttributesValue + '}'
# #     # }



# # User, UserGroups, System, SystemGroups
# # $URL_Template_Associations_MemberOf = 'Member'
# # $URL_Template_Associations_Membership = 'Membership'

# # $URL_Template_Associations_TargetType = 'Traverse'

# # Activedirectories, Users
# # $URL_Template_Associations_Targets = 'Association'

# # Only for POST
# # $URL_Template_Associations_Members = ''

# # ('Association', , '', 'Traverse')
# #     # # All the bindings, recursive , both direct and indirect
# #     # $URL_Template_Associations_MemberOf = '/api/v2/{0}/{1}/memberof' # $SourcePlural, $SourceId
# #     # $URL_Template_Associations_Membership = '/api/v2/{0}/{1}/membership' # $SourcePlural (systemgroups,usergroups), $SourceId
# #     # $URL_Template_Associations_TargetType = '/api/v2/{0}/{1}/{2}' # $SourcePlural, $SourceId, $TargetPlural
# #     # # Only direct bindings and don’t traverse through groups
# #     # $URL_Template_Associations_Targets = '/api/v2/{0}/{1}/associations?targets={2}' # $SourcePlural, $SourceId, $TargetSingular
# #     # $URL_Template_Associations_Members = '/api/v2/{0}/{1}/members' # $SourcePlural, $SourceId

# #     # Build Url based upon source and target combinations
# #     If (($Type -eq 'system' -and $Target -eq 'systemgroup') -or ($Type -eq 'user' -and $Target -eq 'usergroup'))
# #     {
# #         $URL_Template_Associations_MemberOf
# #     }
# #     ElseIf (($Type -eq 'systemgroup' -and $Target -eq 'system') -or ($Type -eq 'usergroup' -and $Target -eq 'user'))
# #     {
# #         $URL_Template_Associations_Membership
# #     }
# #     # ElseIf (($Type -eq 'activedirectory' -and $Target -eq 'user') -or ($Type -eq 'user' -and $Target -eq 'activedirectory'))
# #     # {
# #     #     $URL_Template_Associations_Targets
# #     # }
# #     Else
# #     {
# #         $URL_Template_Associations_TargetType
# #     }








# #     Write-Host ($Type)
# #     # $CommandTemplate = "JumpCloud.SDK.V2\Get-JcSdkSystemInsight{0} @PSBoundParameters"
# #     # Invoke-Expression -Command:($CommandTemplate -f $Table)

# # }
# # Else
# # {
# #     Write-Error ("$Type is not in $($AssociationsSet.JcType -join ', ')")
# # }
