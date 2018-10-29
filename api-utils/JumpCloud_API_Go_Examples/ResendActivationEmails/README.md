## ResendActivateEmails

Multi-tenant administrators (administrators associated to more than one
organization) cannot use this tool because it does not support the
`x-org-id` HTTP header, which is required to specify which organization
users should be released from.

Not able to use the jcapi-go API as the user.PendingProvisioning is not exposed in the SystemusersApi.

