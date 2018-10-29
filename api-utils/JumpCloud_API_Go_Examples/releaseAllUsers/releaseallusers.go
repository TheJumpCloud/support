package main

import (
	"context"
	"flag"
	"fmt"

	"github.com/TheJumpCloud/jcapi"
	jcapiv1 "github.com/TheJumpCloud/jcapi-go/v1"
)

const (
	CONTENT_TYPE = "application/json"
	ACCEPT       = "application/json"
)

func returnToString(user jcapiv1.Systemuserreturn) string {
	returnVal := fmt.Sprintf("JCUSER: Id=[%s] - FName/LName=[%s/%s] - Email=[%s] - sudo=[%t] - Uid=%d - Gid=%d - enableManagedUid=%t\n",
		user.Id, user.Firstname, user.Lastname, user.Email, user.Sudo, user.UnixUid, user.UnixGuid, user.EnableManagedUid)

	return returnVal
}

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
		fmt.Printf("URL overridden from: %s to: %s\n", jcapi.StdUrlBase, urlBase)
	}

	if orgId != "" {
		fmt.Println("You may specify an orgID for multi-tenant administrators.")
	}

	if orgId == "" {
		fmt.Println("You may specify an orgID for multi-tenant administrators.\n")
	}

	// Attach to JumpCloud
	var apiClientV1 *jcapiv1.APIClient
	apiClientV1 = jcapiv1.NewAPIClient(jcapiv1.NewConfiguration())
	apiClientV1.ChangeBasePath(urlBase)

	var authv1 context.Context
	authv1 = context.WithValue(context.TODO(), jcapiv1.ContextAPIKey, jcapiv1.APIKey{
		Key: apiKey,
	})

	optionals := map[string]interface{}{
		"xOrgId": orgId,
	}

	// Fetch all users who's password expires between given dates in
	userListResult, _, err := apiClientV1.SystemusersApi.SystemusersList(authv1, CONTENT_TYPE, ACCEPT, optionals)

	if err != nil {
		fmt.Printf("Could not read system users, err='%s'\n", err)
		return
	}

	var updateCount = 0

	for i, _ := range userListResult.Results {
		currentUser := userListResult.Results[i]
		if currentUser.ExternallyManaged == true {
			currentUser.ExternallyManaged = false
			currentUser.ExternalDn = ""
			currentUser.ExternalSourceType = ""

			optionals["body"] = userListResult.Results[i]

			resultUser, _, err := apiClientV1.SystemusersApi.SystemusersPut(authv1, currentUser.Id, CONTENT_TYPE, ACCEPT, optionals)

			//userId, err := jc.AddUpdateUser(3, userList[i])
			if err != nil {
				fmt.Printf("Could not update user '%s', err='%s'", returnToString(currentUser), err)
				return
			} else {
				fmt.Printf("Updated user ID '%s'\n", resultUser.Id)
			}

			updateCount++
		}
	}

	fmt.Printf("%d users released\n", updateCount)

	return
}
