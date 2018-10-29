package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"

	jcapiv1 "github.com/TheJumpCloud/jcapi-go/v1"
	jcapiv2 "github.com/TheJumpCloud/jcapi-go/v2"
)

const (
	apiUrlDefault string = "https://console.jumpcloud.com/api"
)

func outFirst(data string) {
	fmt.Printf("\"%s\"", data)
}

func out(data string) {
	fmt.Printf(",\"%s\"", data)
}

func endLine() {
	fmt.Printf("\n")
}

func header(isGroups bool) {
	outFirst("Username")
	out("FirstName")
	out("LastName")
	out("Email")
	out("UID")
	out("GID")
	out("Activated")
	out("PasswordExpired")
	out("Sudo")
	if isGroups {
		out("User Groups")
	} else {
		out("Tags")
	}
	endLine()
}

func main() {
	var apiKey string
	var apiUrl string
	var orgId string

	// Obtain the input parameters
	flag.StringVar(&apiKey, "key", "", "-key=<API-key-value>")
	flag.StringVar(&apiUrl, "url", apiUrlDefault, "-url=<jumpcloud-api-url>")
	flag.StringVar(&orgId, "org", "", "-org=<organizationID> (optional for multi-tenant administrators)")
	flag.Parse()

	// if the api key isn't specified, try to obtain it through environment variable:
	if apiKey == "" {
		apiKey = os.Getenv(apiKeyEnvVariable)
	}

	if apiKey == "" {
		fmt.Println("Usage:")
		fmt.Println("  -key=\"\": -key=<API-key-value>")
		fmt.Println("  -url=\"\": -url=<jumpcloud-api-url> (optional)")
		fmt.Println("  -org=\"\": -org=<organizationID> (optional for multi-tenant administrators)")
		fmt.Println("You can also set the API key via the JUMPCLOUD_APIKEY environment variable:")
		fmt.Println("Run: export JUMPCLOUD_APIKEY=<your-JumpCloud-API-key>")
		return
	}

	if apiUrl != apiUrlDefault {
		_, _ = fmt.Fprintf(os.Stderr, "URL overridden from: %s to: %s\n", apiUrlDefault, apiUrl)
	}

	// check if the org is on tags or groups:
	isGroups, err := isGroupsOrg(apiUrl, apiKey, orgId)
	if err != nil {
		log.Fatalf("Could not determine your org type, err='%s'\n", err)
	}

	if orgId == "" {
		_, _ = fmt.Fprintln(os.Stderr, "You may specify an orgID for multi-tenant administrators.")
	}

	var apiClientV2 *jcapiv2.APIClient
	var authv2 context.Context
	var authv1 context.Context
	if isGroups {
		// instantiate the API client v2:
		// This is used down below with the User Groups functionality.
		config := jcapiv2.NewConfiguration()
		apiClientV2 = jcapiv2.NewAPIClient(config)
		apiClientV2.ChangeBasePath(apiUrl)

		authv1 = context.WithValue(context.TODO(), jcapiv1.ContextAPIKey, jcapiv1.APIKey{
			Key: apiKey,
		})
		authv2 = context.WithValue(context.TODO(), jcapiv2.ContextAPIKey, jcapiv2.APIKey{
			Key: apiKey,
		})
	}

	optionals := map[string]interface{}{
		"xOrgId": orgId,
	}

	// instantiate the API client v1:
	config := jcapiv1.NewConfiguration()
	apiClientV1 := jcapiv1.NewAPIClient(config)
	apiClientV1.ChangeBasePath(apiUrl)

	// Grab all system users (with their tags if this is a Tags org):
	result, _, err := apiClientV1.SystemusersApi.SystemusersList(authv1, contentType, accept, optionals)
	if err != nil {
		log.Fatalf("Could not read system users, err='%s'\n", err)
	}
	header(isGroups)
	for entryIndex := range result.Results {
		user := result.Results[entryIndex]
		outFirst(user.Username)
		out(user.Firstname)
		out(user.Lastname)
		out(user.Email)
		out(fmt.Sprintf("%v", user.UnixUid))
		out(fmt.Sprintf("%v", user.UnixGuid))
		out(fmt.Sprintf("%t", user.Activated))
		out(fmt.Sprintf("%t", user.PasswordExpired))
		out(fmt.Sprintf("%t", user.Sudo))

		// For now, just list the User Groups this user is a member of.
		// NOTE: there are many more associations for a user in a Groups org we may want to list here as well:
		// Applications, Directories, GSuite, LDAP, O365, Systems, Radius Servers

		var graphs []jcapiv2.GraphObjectWithPaths
		for skip := 0; skip == 0 || len(graphs) == searchLimit; skip += searchSkipInterval {
			// set up optional parameters:
			optionals := map[string]interface{}{
				"limit":  int32(searchLimit),
				"skip":   int32(skip),
				"xOrgId": orgId,
			}
			graphs, _, err := apiClientV2.UsersApi.GraphUserMemberOf(authv2, user.Id, contentType, accept, optionals)

			if err != nil {
				// Not absolutely sure this need to be printed; it isn't an error and just muddles up the output.
				//log.Printf("Could not read groups for user %s, err='%s'\n", user.Id, err)
				out("")
				continue
			}
			// output the ids for each user group we retrieved:
			for _, graph := range graphs {
				out(graph.Id)
			}
		}

		endLine()
	}
}
