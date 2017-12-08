package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/TheJumpCloud/jcapi"
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

func main() {
	var apiKey string
	var apiUrl string
	// Obtain the input parameters
	flag.StringVar(&apiKey, "key", "", "-key=<API-key-value>")
	flag.StringVar(&apiUrl, "url", apiUrlDefault, "-url=<jumpcloud-api-url>")
	flag.Parse()

	// if the api key isn't specified, try to obtain it through environment variable:
	if apiKey == "" {
		apiKey = os.Getenv(apiKeyEnvVariable)
	}

	if apiKey == "" {
		fmt.Println("Usage:")
		fmt.Println("  -key=\"\": -key=<API-key-value>")
		fmt.Println("  -url=\"\": -url=<jumpcloud-api-url> (optional)")
		fmt.Println("You can also set the API key via the JUMPCLOUD_APIKEY environment variable:")
		fmt.Println("Run: export JUMPCLOUD_APIKEY=<your-JumpCloud-API-key>")
		return
	}

	// check if the org is on tags or groups:
	isGroups, err := isGroupsOrg(apiUrl, apiKey)
	if err != nil {
		log.Fatalf("Could not determine your org type, err='%s'\n", err)
	}

	// if we're on a groups org, instantiate API client v2:
	var apiClientV2 *jcapiv2.APIClient
	var auth context.Context
	if isGroups {
		apiClientV2 = jcapiv2.NewAPIClient(jcapiv2.NewConfiguration())
		apiClientV2.ChangeBasePath(apiUrl + "/v2")
		// set up the API key via context:
		auth = context.WithValue(context.TODO(), jcapiv2.ContextAPIKey, jcapiv2.APIKey{
			Key: apiKey,
		})
	}

	// instantiate the API client v1:
	apiClientV1 := jcapi.NewJCAPI(apiKey, apiUrl)

	// Grab all system users (with their tags if this is a Tags org):
	userList, err := apiClientV1.GetSystemUsers(!isGroups)
	if err != nil {
		log.Fatalf("Could not read system users, err='%s'\n", err)
	}

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

	for _, user := range userList {
		outFirst(user.UserName)
		out(user.FirstName)
		out(user.LastName)
		out(user.Email)
		out(user.Uid)
		out(user.Gid)
		out(fmt.Sprintf("%t", user.Activated))
		out(fmt.Sprintf("%t", user.PasswordExpired))
		out(fmt.Sprintf("%t", user.Sudo))

		if isGroups {
			// For now, just list the User Groups this user is a member of.
			// NOTE: there are many more associations for a user in a Groups org we may want to list here as well:
			// Applications, Directories, GSuite, LDAP, O365, Systems, Radius Servers

			var graphs []jcapiv2.GraphObjectWithPaths
			for skip := 0; skip == 0 || len(graphs) == searchLimit; skip += searchSkipInterval {
				// set up optional parameters:
				optionals := map[string]interface{}{
					"limit": int32(searchLimit),
					"skip":  int32(skip),
				}
				graphs, _, err := apiClientV2.UsersApi.GraphUserMemberOf(auth, user.Id, contentType, accept, optionals)

				if err != nil {
					log.Printf("Could not read groups for user %s, err='%s'\n", user.Id, err)
					continue
				}
				// output the ids for each user group we retrieved:
				for _, graph := range graphs {
					out(graph.Id)
				}
			}
		} else {
			// this is a Tags org, just list the Tags we've already retrieved:
			for _, tag := range user.Tags {
				out(tag.Name)
			}
		}

		endLine()
	}
}
