Describe -Tag:('ModuleValidation') 'Return Properties Checks' {
    It 'Validates that functions with "Return Properties" return up-to-date fields' {
        Import-Module powershell-yaml -force
        $validFunction = @('Get-JCSystem', 'Get-JCUser', 'Get-JCCommand')
        $functionHash = @{
            'Get-JCSystem'  = @{
                'modelDefinition'     = 'definitions.system.properties'
                'customDefinitionMap' = @{

                }
                'ignoreList'          = @(
                    'primarySystemUser._id',
                    'primarySystemUser.account_locked',
                    'primarySystemUser.account_locked_date',
                    'primarySystemUser.activated',
                    'primarySystemUser.addresses',
                    'primarySystemUser.admin',
                    'primarySystemUser.allow_public_key',
                    'primarySystemUser.alternateEmail',
                    'primarySystemUser.attributes',
                    'primarySystemUser.badLoginAttempts',
                    'primarySystemUser.company',
                    'primarySystemUser.costCenter',
                    'primarySystemUser.created',
                    'primarySystemUser.creationSource',
                    'primarySystemUser.department',
                    'primarySystemUser.description',
                    'primarySystemUser.disableDeviceMaxLoginAttempts',
                    'primarySystemUser.displayname',
                    'primarySystemUser.email',
                    'primarySystemUser.employeeIdentifier',
                    'primarySystemUser.employeeType',
                    'primarySystemUser.enable_managed_uid',
                    'primarySystemUser.enable_user_portal_multifactor',
                    'primarySystemUser.external_dn',
                    'primarySystemUser.external_password_expiration_date',
                    'primarySystemUser.external_source_type',
                    'primarySystemUser.externally_managed',
                    'primarySystemUser.firstname',
                    'primarySystemUser.jobTitle',
                    'primarySystemUser.lastname',
                    'primarySystemUser.ldap_binding_user',
                    'primarySystemUser.location',
                    'primarySystemUser.managedAppleId',
                    'primarySystemUser.manager',
                    'primarySystemUser.mfa',
                    'primarySystemUser.mfaEnrollment',
                    'primarySystemUser.middlename',
                    'primarySystemUser.organization',
                    'primarySystemUser.password_date',
                    'primarySystemUser.password_expiration_date',
                    'primarySystemUser.password_expired',
                    'primarySystemUser.password_never_expires',
                    'primarySystemUser.passwordless_sudo',
                    'primarySystemUser.phoneNumbers',
                    'primarySystemUser.public_key',
                    'primarySystemUser.recoveryEmail',
                    'primarySystemUser.relationships',
                    'primarySystemUser.restrictedFields',
                    'primarySystemUser.samba_service_user',
                    'primarySystemUser.ssh_keys',
                    'primarySystemUser.state',
                    'primarySystemUser.sudo',
                    'primarySystemUser.suspended',
                    'primarySystemUser.tags',
                    'primarySystemUser.totp_enabled',
                    'primarySystemUser.unix_guid',
                    'primarySystemUser.unix_uid',
                    'primarySystemUser.username', '_id', 'tags'
                )
            };
            'Get-JCUser'    = @{
                'modelDefinition'     = 'definitions.systemuserput.properties'
                'customDefinitionMap' = @{

                }
                'ignoreList'          = @('_id', 'tags')
            };
            'Get-JCCommand' = @{
                'modelDefinition'     = 'definitions.command.properties'
                'customDefinitionMap' = @{

                }
            };
        }
        $swaggerV1Url = "https://docs.jumpcloud.com/api/1.0/index.yaml"
        $swaggerContent = Invoke-WebRequest -Uri $swaggerV1Url -Method 'Get'
        $swagger = $swaggerContent.content | ConvertFrom-Yaml

        foreach ($item in $functionHash.keys) {
            Write-host "$($item.keys)"
            #get the command file:
            $command = Get-Command -name $item
            $commandRetAttributes = $command.Parameters.returnProperties.attributes.validValues
            $commandList = New-Object System.Collections.ArrayList
            foreach ($collection in $commandRetAttributes) {
                $commandList.Add($collection) | Out-Null
            }
            $swaggerRetAttributes = invoke-Expression ('$swagger.' + $functionHash[$item].modelDefinition)
            $swaggerList = New-Object System.Collections.ArrayList
            foreach ($collection in $swaggerRetAttributes.keys) {
                $swaggerList.Add($collection) | Out-Null
            }

            $diffList = compare-Object -ReferenceObject $commandList -DifferenceObject $swaggerList
            # items in swagger, not module
            $inSwaggerNotFunction = $diffList | where-object { $_.SideIndicator -eq "=>" }
            $missing = $inSwaggerNotFunction | where-object { $_.InputObject -notin $functionHash[$item].ignoreList }
            # there should not be any missing items
            if ($missing.InputObject) {
                Write-Warning "The following properties are defined in swagger for the $item function but not the module, either add them to the function validate set or add them to the ignore list in this test"
                Write-host $missing.InputObject
            }
            $missing.InputObject | should -BeNullOrEmpty
        }
    }
}
