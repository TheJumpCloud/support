package main

import (
	"github.com/TheJumpCloud/jcapi"
	"os"
	"testing"
)

const (
	testUrlBase string = "https://console.jumpcloud.com/api"
	authUrlBase string = "https://auth.jumpcloud.com"
)

var testAPIKey string = os.Getenv("JUMPCLOUD_APIKEY")
var testSystemID string = os.Getenv("JUMPCLOUD_SYSTEMID")

func checkEnv(t *testing.T) {
	if testAPIKey == "" || testSystemID == "" {
		t.Fatalf("Environment not set, you need to:\n\texport JUMPCLOUD_APIKEY=<your-API-key>\n\texport JUMPCLOUD_SYSTEMID=<some-system-ID-on-your-acct>\n")
	}
}

func TestCSVImportNoTag(t *testing.T) {
	checkEnv(t)

	// Attach to JumpCloud
	jc := jcapi.NewJCAPI(testAPIKey, testUrlBase)

	// Fetch all users in JumpCloud
	userList, err := jc.GetSystemUsers(false)

	if err != nil {
		t.Fatalf("Could not read system users, err='%s'\n", err)
		return
	}

	// Fetch our system from JumpCloud
	system, err := jc.GetSystemById(testSystemID, true)

	if err != nil {
		t.Fatalf("Could not read system info for ID='%s', err='%s'\n", testSystemID, err)
		return
	}

	if system.Hostname == "" {
		t.Fatalf("Could not read system info for ID='%s', err='%s'\n", testSystemID, err)
		return
	}

	// Create a CSV record to add a test user without a tag request
	csvrec := []string{"Frank", "Wilson", "fw", "test+1@jumpcloud.com", "", "", "T", "", ""}

	// Process this request record
	err = ProcessCSVRecord(jc, &userList, csvrec)
	if err != nil {
		t.Fatalf("\tERROR: %s\n", err)
	}

	// Fetch our freshly minted user
	ourUserList, err := jc.GetSystemUserByEmail("test+1@jumpcloud.com", true)

	if err != nil {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	tempUserId := GetUserIdFromUserName(ourUserList, "fw")

	if tempUserId == "" {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	tempUser, err := jc.GetSystemUserById(tempUserId, true)

	if err != nil {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	// Ensure the user has no associated tags
	if len(tempUser.Tags) > 0 {
		t.Fatalf("Unexpectedly found tags associated with user\n")
		return
	}

	return
}

func TestCSVUpdate(t *testing.T) {
	checkEnv(t)

	// Attach to JumpCloud
	jc := jcapi.NewJCAPI(testAPIKey, testUrlBase)

	// Fetch all users in JumpCloud
	userList, err := jc.GetSystemUsers(false)

	if err != nil {
		t.Fatalf("Could not read system users, err='%s'\n", err)
		return
	}

	// Fetch our system from JumpCloud
	system, err := jc.GetSystemById(testSystemID, true)

	if err != nil {
		t.Fatalf("Could not read system info for ID='%s', err='%s'\n", testSystemID, err)
		return
	}

	if system.Hostname == "" {
		t.Fatalf("Could not read system info for ID='%s', err='%s'\n", testSystemID, err)
		return
	}

	// Create a CSV record to add a test user
	csvrec := []string{"Joe", "Smith", "js", "test+2@jumpcloud.com", "", "", "T", "", ""}

	// Process this request record
	err = ProcessCSVRecord(jc, &userList, csvrec)
	if err != nil {
		t.Fatalf("\tERROR: %s\n", err)
	}

	// Fetch our freshly minted user
	ourUserList, err := jc.GetSystemUserByEmail("test+2@jumpcloud.com", true)

	if err != nil {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	tempUserId := GetUserIdFromUserName(ourUserList, "js")

	if tempUserId == "" {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	tempUser, err := jc.GetSystemUserById(tempUserId, true)

	if err != nil {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	if !tempUser.Sudo {
		t.Fatalf("System user does not have expected sudo rights\n")
		return
	}

	// Re-fetch all users in JumpCloud
	userList, err = jc.GetSystemUsers(false)

	if err != nil {
		t.Fatalf("Could not re-read system users, err='%s'\n", err)
		return
	}

	// Update our user to remove sudo righs
	csvrec = []string{"Joe", "Smith", "js", "test+2@jumpcloud.com", "", "", "F", "", ""}

	err = ProcessCSVRecord(jc, &userList, csvrec)
	if err != nil {
		t.Fatalf("\tERROR: %s\n", err)
	}

	// Refetch our user...they should not have sudo
	tempUser, err = jc.GetSystemUserById(tempUserId, true)

	if err != nil {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	if tempUser.Sudo {
		t.Fatalf("Sudo rights unexpectedly found for user\n")
		return
	}

	return
}

func TestCSVImportAndTag(t *testing.T) {
	checkEnv(t)

	// Attach to JumpCloud
	jc := jcapi.NewJCAPI(testAPIKey, testUrlBase)

	// Fetch all users in JumpCloud
	userList, err := jc.GetSystemUsers(false)

	if err != nil {
		t.Fatalf("Could not read system users, err='%s'\n", err)
		return
	}

	// Fetch our system from JumpCloud
	system, err := jc.GetSystemById(testSystemID, true)

	if err != nil {
		t.Fatalf("Could not read system info for ID='%s', err='%s'\n", testSystemID, err)
		return
	}

	if system.Hostname == "" {
		t.Fatalf("Could not read system info for ID='%s', err='%s'\n", testSystemID, err)
		return
	}

	// Create our user along with a tag on our test system
	csvrec := []string{"Bob", "Jones", "bobby", "test+3@jumpcloud.com", "", "", "FALSE", "", system.Hostname}

	err = ProcessCSVRecord(jc, &userList, csvrec)
	if err != nil {
		t.Fatalf("\tERROR: %s\n", err)
	}

	// Refetch our user...they should now have a tag associated with the host and tag name we provided
	tempUserId := GetUserIdFromUserName(userList, "bobby")

	if tempUserId == "" {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	tempUser, err := jc.GetSystemUserById(tempUserId, true)

	if err != nil {
		t.Fatalf("Could not read system user, err='%s'\n", err)
		return
	}

	if len(tempUser.Tags) <= 0 {
		t.Fatalf("No tags associated with user\n")
		return
	}

	foundIt := false
	testTagName := system.Hostname + " - Bob Jones (bobby)"

	for _, checkTag := range tempUser.Tags {
		if checkTag.Name == testTagName {
			for _, checkTagHost := range checkTag.Systems {
				if checkTagHost == testSystemID {
					foundIt = true
				}
			}
		}
	}

	if !foundIt {
		t.Fatalf("Did not find expected tag associated with user\n")
		return
	}

	return
}

func TestCSVBadRecord(t *testing.T) {
	checkEnv(t)

	// Attach to JumpCloud
	jc := jcapi.NewJCAPI(testAPIKey, testUrlBase)

	// Create an empty user list
	userList := []jcapi.JCUser{}

	// Create a CSV record which is incomplete (not enough fields)
	csvrec := []string{"Rob", "Robertson", "rr", "test+4@jumpcloud.com", "T"}

	// Process this request record...we expect an error here
	err := ProcessCSVRecord(jc, &userList, csvrec)
	if err == nil {
		t.Fatalf("Expected error about too few fields in record\n")
	}

	return
}
