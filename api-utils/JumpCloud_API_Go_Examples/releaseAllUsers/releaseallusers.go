package main

import (
	"flag"
	"fmt"

	"github.com/TheJumpCloud/jcapi"
)

//
// This program will "release" all AD-owned user accounts that have been
// imported by the JumpCloud AD Bridge agent. This is useful if you'd like to
// use the AD Bridge agent to bring all your user accounts and their group memberships
// into JumpCloud, and then disable your AD server, and manage users from JumpCloud.
//
// This script will have no effect on your JumpCloud account if you have no AD-managed
// users in your account.
//
// Multi-tenant administrators (administrators associated to more than one
// organization) cannot use this script because it does not support the
// `x-org-id` HTTP header, which is required to specify which organization
// users should be released from.
//
func main() {
	var apiKey string
	var urlBase string
	var orgId string

	// Obtain the input parameters
	flag.StringVar(&apiKey, "key", "", "-key=<API-key-value>")
	flag.StringVar(&urlBase, "url", jcapi.StdUrlBase, "-url=<jumpcloud-api-url>")
	flag.StringVar(&orgId, "org", "", "-org=<organizationID (optional for multi-tenant administrators)")
	flag.Parse()

	if apiKey == "" {
		fmt.Println("Usage of ./releaseAllUsers:")
		fmt.Println("  -key=\"\": -key=<API-key-value>")
		fmt.Println("  -url=\"\": -url=<jumpcloud-api-url> (optional)")
		fmt.Println("  -org=\"\": -org=<organizationID> (optional for multi-tenant administrators>")
		return
	}

	if urlBase != jcapi.StdUrlBase {
		fmt.Printf("URL overridden from: %s to: %s", jcapi.StdUrlBase, urlBase)
	}

	jc := jcapi.NewJCAPI(apiKey, urlBase)
	if orgId != "" {
		jc.OrgId = orgId
	} else {
		fmt.Println("You may specify an orgID for multi-tenant administrators.")
	}

	userList, err := jc.GetSystemUsers(false)
	if err != nil {
		fmt.Printf("Could not read system users, err='%s'\n", err)
		return
	}

	var updateCount = 0

	for i, _ := range userList {
		if userList[i].ExternallyManaged == true {
			userList[i].ExternallyManaged = false
			userList[i].ExternalDN = ""
			userList[i].ExternalSourceType = ""

			userId, err := jc.AddUpdateUser(3, userList[i])
			if err != nil {
				fmt.Printf("Could not update user '%s', err='%s'", userList[i].ToString(), err)
				return
			} else {
				fmt.Printf("Updated user ID '%s'\n", userId)
			}

			updateCount++
		}
	}

	fmt.Printf("%d users released\n", updateCount)

	return
}
