Describe -Tag:('DynamicHash') "Get-DynamicHash" {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "User Hash" {
        $UserHash = Get-DynamicHash -Object User -returnProperties 'created', 'account_locked', 'activated', 'addresses', 'allow_public_key', 'attributes', 'email', 'enable_managed_uid', 'enable_user_portal_multifactor', 'externally_managed', 'firstname', 'lastname', 'ldap_binding_user', 'passwordless_sudo', 'password_expired', 'password_never_expires', 'phoneNumbers', 'samba_service_user', 'ssh_keys', 'sudo', 'suspended', 'totp_enabled', 'unix_guid', 'unix_uid', 'username', 'alternateEmail', 'managedAppleId', 'recoveryEmail'

        $UserHash.count | Should -Be (Get-JCUser).count

        $UserHash.values.account_locked | Should -Not -Be $null
        $UserHash.values.activated | Should -Not -Be $null
        $UserHash.values.addresses | Should -Not -Be $null
        $UserHash.values.allow_public_key | Should -Not -Be $null
        $UserHash.values.alternateEmail | Should -Not -Be $null
        $UserHash.values.attributes | Should -Not -Be $null
        $UserHash.values.created | Should -Not -Be $null
        $UserHash.values.email | Should -Not -Be $null
        $UserHash.values.recoveryEmail | Should -Not -Be $null
        $UserHash.values.enable_managed_uid | Should -Not -Be $null
        $UserHash.values.enable_user_portal_multifactor | Should -Not -Be $null
        $UserHash.values.externally_managed | Should -Not -Be $null
        $UserHash.values.firstname | Should -Not -Be $null
        $UserHash.values.lastname | Should -Not -Be $null
        $UserHash.values.ldap_binding_user | Should -Not -Be $null
        $UserHash.values.managedAppleID | Should -Not -Be $null
        $UserHash.values.password_expired | Should -Not -Be $null
        $UserHash.values.password_never_expires | Should -Not -Be $null
        $UserHash.values.passwordless_sudo | Should -Not -Be $null
        $UserHash.values.phoneNumbers | Should -Not -Be $null
        $UserHash.values.samba_service_user | Should -Not -Be $null
        $UserHash.values.sudo | Should -Not -Be $null
        $UserHash.values.suspended | Should -Not -Be $null
        $UserHash.values.totp_enabled | Should -Not -Be $null
        $UserHash.values.unix_guid | Should -Not -Be $null
        $UserHash.values.unix_uid | Should -Not -Be $null
        $UserHash.values.username | Should -Not -Be $null
    }
    It "System Hash" {
        $SystemHash = Get-DynamicHash -Object System -returnProperties 'created', 'active', 'agentVersion', 'allowMultiFactorAuthentication', 'allowPublicKeyAuthentication', 'allowSshPasswordAuthentication', 'allowSshRootLogin', 'arch', 'created', 'displayName', 'hostname', 'lastContact', 'modifySSHDConfig', 'organization', 'os', 'remoteIP', 'serialNumber', 'systemTimezone', 'templateName', 'version'

        $SystemHash.count | Should -Be (Get-JCSystem).count

        $SystemHash.values.created | Should -Not -Be $null
        $SystemHash.values.active | Should -Not -Be $null
        $SystemHash.values.agentVersion | Should -Not -Be $null
        $SystemHash.values.allowMultiFactorAuthentication | Should -Not -Be $null
        $SystemHash.values.allowPublicKeyAuthentication | Should -Not -Be $null
        $SystemHash.values.allowSshPasswordAuthentication | Should -Not -Be $null
        $SystemHash.values.allowSshRootLogin | Should -Not -Be $null
        $SystemHash.values.arch | Should -Not -Be $null
        $SystemHash.values.created | Should -Not -Be $null
        $SystemHash.values.displayName | Should -Not -Be $null
        $SystemHash.values.hostname | Should -Not -Be $null
        $SystemHash.values.lastContact | Should -Not -Be $null
        $SystemHash.values.modifySSHDConfig | Should -Not -Be $null
        $SystemHash.values.organization | Should -Not -Be $null
        $SystemHash.values.os | Should -Not -Be $null
        $SystemHash.values.remoteIP | Should -Not -Be $null
        $SystemHash.values.serialNumber | Should -Not -Be $null
        $SystemHash.values.systemTimezone | Should -Not -Be $null
        $SystemHash.values.templateName | Should -Not -Be $null
        $SystemHash.values.version | Should -Not -Be $null
    }
    It "SystemGroup Hash" {
        $SystemGroupHash = Get-DynamicHash -Object Group -GroupType System -returnProperties 'name', 'type'

        $SystemGroupHash.count | Should -Be (Get-JCGroup -Type System).count

        $SystemGroupHash.values.name | Should -Not -Be $null
        $SystemGroupHash.values.type | Should -Not -Be $null
    }
    It "UserGroup Hash" {
        $UserGroupHash = Get-DynamicHash -Object Group -GroupType User -returnProperties 'name', 'type'

        $UserGroupHash.count | Should -Be (Get-JCGroup -Type User).count

        $UserGroupHash.values.name | Should -Not -Be $null
        $UserGroupHash.values.type | Should -Not -Be $null
    }
    It "Command Hash" {
        $CommandHash = Get-DynamicHash -Object Command -returnProperties 'command', 'name', 'launchType', 'commandType', 'trigger', 'scheduleRepeatType'

        $CommandHash.count | Should -Be (Get-JCCommand).count

        $CommandHash.Values.command | Should -Not -Be $null
        $CommandHash.Values.name | Should -Not -Be $null
        $CommandHash.Values.launchType | Should -Not -Be $null
        $CommandHash.Values.commandType | Should -Not -Be $null
        $CommandHash.Values.trigger | Should -Not -Be $null
        $CommandHash.Values.scheduleRepeatType | Should -Not -Be $null
    }
}