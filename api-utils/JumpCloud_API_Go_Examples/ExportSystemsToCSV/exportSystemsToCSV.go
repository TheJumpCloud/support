package main

import (
	"context"
	"encoding/csv"
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

// getSystemGroupsforSystem retrieves the system groups the given system is a member of:
func getSystemGroupsforSystem(apiClientV2 *jcapiv2.APIClient, auth context.Context, systemId string) (systemGroups []string, err error) {

	var graphs []jcapiv2.GraphObjectWithPaths
	for skip := 0; skip == 0 || len(graphs) == searchLimit; skip += searchSkipInterval {
		// set up optional parameters:
		optionals := map[string]interface{}{
			"limit": int32(searchLimit),
			"skip":  int32(skip),
		}
		graphs, _, err := apiClientV2.SystemsApi.GraphSystemMemberOf(auth, systemId, contentType, accept, optionals)
		if err != nil {
			return systemGroups, fmt.Errorf("Could not retrieve parent groups for system %s, err='%s'", systemId, err)
		}

		// add the retrieved system groups names to the list for the current system:
		for _, graph := range graphs {
			// get the details of the current system group:
			systemGroup, _, err := apiClientV2.SystemGroupsApi.GroupsSystemGet(auth, graph.Id, contentType, accept, nil)
			if err != nil {
				// just log a message and skip the system group if there's an error retrieving details:
				log.Printf("Could not retrieve info for system group ID %s, err='%s'\n", graph.Id, err)
				continue
			}
			systemGroups = append(systemGroups, systemGroup.Name)
		}
	}

	return
}

func main() {
	var apiKey string
	var apiUrl string
	var orgId string

	// Obtain the input parameters: api key and url (if we want to override the default url)
	flag.StringVar(&apiKey, "key", "", "-key=<API-key-value>")
	flag.StringVar(&apiUrl, "url", apiUrlDefault, "-url=<jumpcloud-api-url>")
	flag.StringVar(&orgId, "org", "", "-org=<organizationID> (optional for multi-tenant administrators)")
	flag.Parse()

	// if the api key isn't specified, try to obtain it through environment variable:
	if apiKey == "" {
		apiKey = os.Getenv("JUMPCLOUD_APIKEY")
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
		fmt.Printf("URL overridden from: %s to %s", apiUrlDefault, apiUrl)
	}

	// check if this org is on Groups or Tags:
	isGroups, err := isGroupsOrg(apiUrl, apiKey, orgId)
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

	// instantiate an API client v1 for all v1 endpoints:
	apiClientV1 := jcapi.NewJCAPI(apiKey, apiUrl)
	if orgId != "" {
		apiClientV1.OrgId = orgId
	} else {
		fmt.Printf("You may specify an orgID for multi-tenant administrators")
	}

	// Grab all systems (with their tags for a Tags)
	systems, err := apiClientV1.GetSystems(!isGroups)
	if err != nil {
		log.Fatalf("Could not read systems, err='%s'\n", err)
	}

	csvWriter := csv.NewWriter(os.Stdout)
	defer csvWriter.Flush()

	headers := []string{"Id", "DisplayName", "HostName", "Active", "Instance ID", "OS", "OSVersion",
		"AgentVersion", "CreatedDate", "LastContactDate"}

	if isGroups {
		headers = append(headers, "SystemGroups")
	} else {
		headers = append(headers, "Tags")
	}

	csvWriter.Write(headers)

	for _, system := range systems {
		outLine := []string{system.Id, system.DisplayName, system.Hostname, fmt.Sprintf("%t", system.Active),
			system.AmazonInstanceID, system.Os, system.Version, system.AgentVersion, system.Created,
			system.LastContact}

		if isGroups {
			// for a Groups org, let's retrieve the system groups this system is a member of:
			systemGroups, err := getSystemGroupsforSystem(apiClientV2, auth, system.Id)
			if err != nil {
				// if we failed to retrieve the system groups for this system, jsut log a msg and skip system groups:
				log.Printf("getSystemGroupsForSystem failed: %s", err)
				// don't call continue here since we still want to print the current system's details...
			} else {
				outLine = append(outLine, systemGroups...)
			}
			// NOTE: there are more associations for a system in a Groups org we may want to list here as well:
			// Policies, direct Users associations, etc
		} else {
			// for Tags orgs, we've already retrieved the list of tags in GetSystems:
			for _, tag := range system.Tags {
				outLine = append(outLine, tag.Name)
			}
		}

		csvWriter.Write(outLine)
	}
}
