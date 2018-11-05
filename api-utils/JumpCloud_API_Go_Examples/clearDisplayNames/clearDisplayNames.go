package main

import (
	"fmt"
	"github.com/TheJumpCloud/jcapi"
	"os"
)

const (
	JUMPCLOUD_APIKEY_VAR string = "JUMPCLOUD_APIKEY"
	URLBASE              string = "https://console.jumpcloud.com/api"
)

func main() {
	apiKey := os.Getenv(JUMPCLOUD_APIKEY_VAR)
	if apiKey == "" {
		fmt.Printf("Environment variable %s not set, please set it to your API key with\n\texport %s=<your-api-key>\n", JUMPCLOUD_APIKEY_VAR, JUMPCLOUD_APIKEY_VAR)
		os.Exit(1)
	}

	jc := jcapi.NewJCAPI(apiKey, URLBASE)

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
