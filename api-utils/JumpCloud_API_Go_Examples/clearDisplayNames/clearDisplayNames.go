package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	jcapiv1 "github.com/TheJumpCloud/jcapi-go/v1"
)

const (
	JUMPCLOUD_APIKEY_VAR string = "JUMPCLOUD_APIKEY"
	JUMPCLOUD_ORGID_VAR  string = "JUMPCLOUD_ORGID"
	JUMPCLOUD_URL_VAR    string = "JUMPCLOUD_URL"  // in case want to do it locally.
	URLBASE              string = "https://console.jumpcloud.com/api"
	CONTENT_TYPE		 string = "application/json"
	ACCEPT				 string = "application/json"
)

func main() {
	apiKey := os.Getenv(JUMPCLOUD_APIKEY_VAR)
	if apiKey == "" {
		fmt.Printf("Environment variable %s not set, please set it to your API key with\n\texport %s=<your-api-key>\n", JUMPCLOUD_APIKEY_VAR, JUMPCLOUD_APIKEY_VAR)
		os.Exit(1)
	}
	orgId := os.Getenv(JUMPCLOUD_ORGID_VAR)
	if orgId == "" {
		fmt.Printf("Environment variable %s not set. If this is a multi-tenant admin you must set the OrgID with\n\texport %s=<your-orgid>\n", JUMPCLOUD_ORGID_VAR, JUMPCLOUD_ORGID_VAR)
		// ^^^^ not an error, just informational; don't exit
	}
	url := os.Getenv(JUMPCLOUD_URL_VAR)
	if url == "" {
		url = URLBASE
	} else {
		fmt.Printf("URL overridden (by environment variable %s) from: %s to: %s\n", JUMPCLOUD_URL_VAR, URLBASE, url)
	}

	config := jcapiv1.NewConfiguration()
	apiClientV1 := jcapiv1.NewAPIClient(config)
	apiClientV1.ChangeBasePath(url)

	auth := context.WithValue(context.TODO(), jcapiv1.ContextAPIKey, jcapiv1.APIKey{
		Key: apiKey,
	})

	optionals := map[string]interface{}{
		"xOrgId": orgId,
	}

	results, res, err := apiClientV1.SystemsApi.SystemsList(auth, CONTENT_TYPE, ACCEPT, optionals)
	if err != nil {
		fmt.Printf("ERROR: Could not get systems list, err='%s'\n", err.Error())
		os.Exit(1)
	}
	if res.StatusCode != 200 {
		fmt.Printf("ERROR: status code returned: %d\n", res.StatusCode)
		os.Exit(1)
	}

	systemsList := results.Results
	for idx, _ := range systemsList {
		if systemsList[idx].DisplayName != systemsList[idx].Hostname {
			fmt.Printf("Resetting display name (%s) to '%s'\n", systemsList[idx].DisplayName, systemsList[idx].Hostname)

			systemsList[idx].DisplayName = systemsList[idx].Hostname
			optionals["body"], err = json.Marshal(systemsList[idx])
			if err != nil {
				fmt.Printf("ERROR: failed converting system object to json: %+v - SKIPPING\n", systemsList[idx])
			}
			res, err := apiClientV1.SystemsApi.SystemsPut(auth, systemsList[idx].Id, CONTENT_TYPE, ACCEPT, optionals)
			if err != nil {
				fmt.Printf("ERROR: Could not update system '%s', err='%s' - SKIPPING\n", err.Error())
			}
			if res.StatusCode != http.StatusOK {
				fmt.Printf("ERROR: status code returned: %d - SKIPPING\n", res.StatusCode)
			}
		}
	}

	os.Exit(0)
}
