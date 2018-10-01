package main

import (
	"context"

	jcapiv2 "github.com/TheJumpCloud/jcapi-go/v2"
)

// the following constants are used for API v2 calls:
const (
	apiKeyEnvVariable  = "JUMPCLOUD_APIKEY"
	contentType        = "application/json"
	accept             = "application/json"
	searchLimit        = 100
	searchSkipInterval = 100
)

// isGroupsOrg returns true if this org is groups enabled:
func isGroupsOrg(urlBase string, apiKey string, orgId string) (bool, error) {
	// instantiate a new API client object:
	client := jcapiv2.NewAPIClient(jcapiv2.NewConfiguration())
	client.ChangeBasePath(urlBase + "/v2")

	// set up the API key via context:
	auth := context.WithValue(context.TODO(), jcapiv2.ContextAPIKey, jcapiv2.APIKey{
		Key: apiKey,
	})

	// set up optional parameters:
	optionals := map[string]interface{}{
		"limit": int32(1), // limit the query to return 1 item
	}

	if orgId != "" {
		optionals["xOrgId"] = orgId
	}

	// in order to check for groups support, we just query for the list of User groups
	// (we just ask to retrieve 1) and check the response status code:
	_, res, err := client.UserGroupsApi.GroupsUserList(auth, contentType, accept, optionals)

	// check if we're using the API v1:
	// we need to explicitly check for 404, since GroupsUserList will also return a json
	// unmarshalling error (err will not be nil) if we're running this endpoint against
	// a Tags org and we don't want to treat this case as an error:
	if res != nil && res.StatusCode == 404 {
		return false, nil
	}

	// if there was any kind of other error, return that:
	if err != nil {
		return false, err
	}

	// if we're using API v2, we're expecting a 200:
	if res.StatusCode == 200 {
		return true, nil
	}

	return false, nil
}
