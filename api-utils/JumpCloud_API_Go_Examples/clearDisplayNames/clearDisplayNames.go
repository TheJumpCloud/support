package main

import (
	"fmt"
	"github.com/TheJumpCloud/jcapi"
	"os"
)

const (
	JUMPCLOUD_APIKEY_VAR string = "JUMPCLOUD_APIKEY"
	JUMPCLOUD_ORGID_VAR  string = "JUMPCLOUD_ORGID"
	JUMPCLOUD_URL_VAR    string = "JUMPCLOUD_URL"  // in case want to do it locally.
	URLBASE              string = "https://console.jumpcloud.com/api"
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
		fmt.Printf("URL overridden (by environment variable %s) from: %s to: %s", JUMPCLOUD_URL_VAR, URLBASE, url)
	}

	jc := jcapi.NewJCAPI(apiKey, url)
	if orgId != "" {
		jc.OrgId = orgId
	}

	systemsList, err := jc.GetSystems(false)
	if err != nil {
		fmt.Printf("ERROR: Could not get systems list, err='%s'\n", err.Error())
		os.Exit(1)
	}

	for idx, _ := range systemsList {
		if systemsList[idx].DisplayName != systemsList[idx].Hostname {
			fmt.Printf("Resetting display name (%s) to '%s'\n", systemsList[idx].DisplayName, systemsList[idx].Hostname)

			systemsList[idx].DisplayName = systemsList[idx].Hostname

			_, err := jc.UpdateSystem(systemsList[idx])
			if err != nil {
				fmt.Printf("ERROR: Could not update system '%s', err='%s' - SKIPPING\n", err.Error())
			}
		}
	}

	os.Exit(0)
}
