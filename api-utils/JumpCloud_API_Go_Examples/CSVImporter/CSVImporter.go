package main

import (
	"context"
	"encoding/csv"
	"flag"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"

	"github.com/TheJumpCloud/jcapi"
	jcapiv1 "github.com/TheJumpCloud/jcapi-go/v1"
)

//
// This program will process each line (record) of a CSV file as a user
// import request into JumpCloud.
//
// The CSV file must have each line formatted as:
//
// first_name, last_name, USER_NAME, EMAIL, uid, gid, SUDO_FLAG, password, host_name, admin1, admin2, ...
//
// Values shown in all lowercase are optional, while those in all uppercase
// are required.  Placeholders (i.e. commas with no value) must be specified
// for all values up to "host_name", but the administrator list may be omitted.
//
// For each line of the CSV file, this program will:
//
// 1 - Insert the USER_NAME specified as a new JumpCloud user, if the name
//     does not already exist, otherwise this line will be treated as an
//     update to an existing user matching USER_NAME.
//
// 2 - If the password was specified, the USER_NAME will have that password
//     assigned to it immediately, otherwise, JumpCloud will automatically
//     generate an email message, delivered to the EMAIL specified, requesting
//     the user to provide an appropriate password for their account.
//
// 3 - The value of the SUDO_FLAG will always be applied to this user.  All
//     other optional values specified will be applied as appropriate.
//
// 4 - When the host_name is specified, a tag will be created or updated for
//     this USER_NAME associated with the host_name provided.
//     (n.b. - if the USER_NAME already exists on the host_name in question,
//     specifying these values here will result in the account on host_name
//     being "taken over" by JumpCloud)
//
// 5 - If a line in the CSV file cannot be processed, the error will be
//     reported to stderr, and processing will continue.
//
// 6 - A summary is printed at the conclusion of processing.
//
// Because the program performs updates on existing values, and inserts
// otherwise, any given CSV file can be run against JumpCloud multiple
// times without creating duplication or similar issues.
//

const (
	urlBase      string = "https://console.jumpcloud.com/api"
	CONTENT_TYPE string = "application/json"
	ACCEPT       string = "application/json"
)

//
// Returns the ID for the username specified if it is contained in the
// list of users provided.  (helper function)
//

func GetUserIdFromUserName(users []jcapiv1.Systemuserreturn, name string) string {
	returnVal := ""

	for _, user := range users {
		if user.Username == name {
			returnVal = user.Id
			break
		}
	}

	return returnVal
}

func returnToString(user jcapiv1.Systemuserreturn) string {
	returnVal := fmt.Sprintf("JCUSER: Id=[%s] - FName/LName=[%s/%s] - Email=[%s] - sudo=[%t] - Uid=%d - Gid=%d - enableManagedUid=%t\n",
		user.Id, user.Firstname, user.Lastname, user.Email, user.Sudo, user.UnixUid, user.UnixGuid, user.EnableManagedUid)

	return returnVal
}

func putToString(user jcapiv1.Systemuserputpost) string {
	returnVal := fmt.Sprintf("JCUSER: FName/LName=[%s/%s] - Email=[%s] - sudo=[%t] - Uid=%d - Gid=%d - enableManagedUid=%t\n",
		user.Firstname, user.Lastname, user.Email, user.Sudo, user.UnixUid, user.UnixGuid, user.EnableManagedUid)

	return returnVal
}

func tagToString(tag jcapiv1.Tag) string {
	return fmt.Sprintf("tag id=%s - name='%s' - groupName='%s' - systems='%s' - systemusers='%s' - externally_managed='%t' (%s)",
		tag.Id, tag.Name, tag.GroupName, strings.Join(tag.Systems, ","),
		strings.Join(tag.Systemusers, ","), tag.ExternallyManaged, tag.ExternalDN)
}

//
// Process the line read from the CSV file into JumpCloud. (helper function)
//
func ProcessCSVRecord(jc jcapiv1.APIClient, systemUsersList *jcapiv1.Systemuserslist, csvRecord []string,
	auth context.Context, outerOptionals map[string]interface{}) (err error) {
	userList := systemUsersList.Results

	// Verify the record is complete enough to process
	if len(csvRecord) < 9 {
		err = fmt.Errorf("Line is improperly formatted (missing fields), skipping line.")
		return
	}

	// Setup work variables
	var currentUser jcapiv1.Systemuserputpost
	var currentHost string

	currentAdmins := make(map[string]string) // "user name", "user id"

	var fieldMap = map[int]*string{
		0: &currentUser.Firstname,
		1: &currentUser.Lastname,
		2: &currentUser.Username,
		3: &currentUser.Email,
		// "UnixUid" int32 handed separately, so no 4
		// "UnixGuid" int32 handled separately, so no 5
		// "Sudo" boolean will be handled separately, so no 6
		// "Password" not available in jcapi-go, so no 7
		8: &currentHost,
	}

	// Parse the record provided into our work vars
	for i, element := range csvRecord {
		// Handle variable fields separately
		if i > 8 {
			break
		}

		// Special cases for the boolean and int32s to be parsed
		if i == 6 {
			currentUser.Sudo = jcapi.GetTrueOrFalse(element)
		} else if i == 3 {
			*fieldMap[i] = strings.ToLower(element)
		} else if i == 4 {
			if element == "" {
				currentUser.UnixUid = 0
			} else {
				parsedInt, convErr := strconv.Atoi(element)
				if convErr != nil {
					err = fmt.Errorf("Value for UnixUid was not valid integer value")
					return
				}
				currentUser.UnixUid = int32(parsedInt)
			}
		} else if i == 5 {
			if element == "" {
				currentUser.UnixGuid = 0
			} else {
				parsedInt, convErr := strconv.Atoi(element)
				if convErr != nil {
					err = fmt.Errorf("Value for UnixGuid was not valid integer value")
					return
				}
				currentUser.UnixGuid = int32(parsedInt)
			}
		} else if i == 7 {
			// In jcapi-go we don't have the password in the user; ignore this field
		} else {
			// Default case is to move the string into the var
			*fieldMap[i] = element
		}
	}

	// The administrators list is optional, and variable.  Using a slice
	// will pick it up if it exists without causing errors otherwise.
	// Map any names found to their ID values for later use.
	adminsSlice := csvRecord[9:]

	for _, tempAdmin := range adminsSlice {
		// If there were no admins to slice, the slice itself will still have
		// a single null element that is returned.  Account for that, but
		// otherwise add-in the values found.
		if tempAdmin != "" {
			currentAdmins[tempAdmin] = GetUserIdFromUserName(userList, tempAdmin)
		}
	}

	// Determine operation to perform based on whether the current user
	// is already in JumpCloud...
	var opCode jcapi.JCOp
	currentUserId := GetUserIdFromUserName(userList, currentUser.Username)

	if currentUserId != "" {
		opCode = jcapi.Update
	} else {
		opCode = jcapi.Insert
	}

	// Sanity-check any UID/GID pair supplied and set management mode accordingly
	if (currentUser.UnixUid == 0 && currentUser.UnixGuid != 0) || (currentUser.UnixUid != 0 && currentUser.UnixGuid == 0) {
		err = fmt.Errorf("Could not process user '%s', err=Invalid UID:GID pair '%d:%d', both must be specified", putToString(currentUser), currentUser.UnixUid, currentUser.UnixGuid)
		return
	}

	if currentUser.UnixUid != 0 || currentUser.UnixGuid != 0 {
		currentUser.EnableManagedUid = true
	}

	// Perform the requested operation on the current user and report results
	var resultUser jcapiv1.Systemuserreturn
	var err2 error

	optionals := map[string]interface{}{
		"xOrgId": outerOptionals["xOrgId"],
		"body":   currentUser,
	}

	if opCode == jcapi.Update {
		resultUser, _, err2 = jc.SystemusersApi.SystemusersPut(auth, currentUserId, CONTENT_TYPE, ACCEPT, optionals)
	} else if opCode == jcapi.Insert {
		resultUser, _, err2 = jc.SystemusersApi.SystemusersPost(auth, CONTENT_TYPE, ACCEPT, optionals)
	}
	if err2 != nil {
		err = fmt.Errorf("Could not %s user '%s', err='%s'", jcapi.MapJCOpToHTTP(opCode), putToString(currentUser), err)
		return
	}

	if opCode == jcapi.Update {
		fmt.Printf("\tUser '%s' (ID '%s') updated from input file\n", currentUser.Username, currentUserId)
	} else {
		fmt.Printf("\tLoaded user '%s' (ID '%s')\n", currentUser.Username, currentUserId)
		// Add this user to our list
		resultUser.Id = currentUserId
		userList = append(userList, resultUser)
	}

	// Create/associate JumpCloud tags for the host and user...
	if currentHost != "" {
		// Determine if the host specified is defined in JumpCloud
		var currentJCSystem jcapiv1.System
		tempSysList, _, err2 := jc.SystemsApi.SystemsList(auth, CONTENT_TYPE, ACCEPT, optionals)

		if err2 != nil {
			err = fmt.Errorf("Look up for host '%s' failed - err='%s'", currentHost, err)
			return
		}

		switch {
		case tempSysList.TotalCount > 1:
			err = fmt.Errorf("Found multiple hostnames for '%s', cannot build a tag for it.", currentHost)
			return
		case tempSysList.TotalCount == 0:
			err = fmt.Errorf("Could not find a system for '%s', cannot build a tag for this user.", currentHost)
			return
		case tempSysList.TotalCount == 1:
			currentJCSystem = tempSysList.Results[0]
		default:
			return
		}

		// Construct the user's tag from the inputs
		var tempTag jcapiv1.Tag

		tempTag.Name = currentHost + " - "

		if currentUser.Firstname != "" && currentUser.Lastname != "" {
			tempTag.Name = tempTag.Name + currentUser.Firstname + " " + currentUser.Lastname + " "
		}

		tempTag.Name = tempTag.Name + "(" + currentUser.Username + ")"

		// Does the tag already exist?
		var tag jcapiv1.Tag

		tag, _, err2 = jc.TagsApi.TagsGet(auth, tempTag.Name, CONTENT_TYPE, ACCEPT, outerOptionals)
		if err2 != nil && !strings.Contains(err.Error(), "unexpected end of JSON input") {
			err = fmt.Errorf("Tag lookup failed for tag '%s', skipping this tag, err='%s'", tempTag.Name, err)
			return
		}

		if tag.Id != "" {
			// Yep, tag exists
			fmt.Printf("\tTag '%s' already exists, not modifying it.\n", tempTag.Name)
			return
		}

		opCode = jcapi.Insert

		// Build a suitable tag from the request's elements
		tempTag.Systems = append(tempTag.Systems, currentJCSystem.Id)
		tempTag.Systemusers = append(tempTag.Systemusers, currentUserId)

		for _, adminId := range currentAdmins {
			tempTag.Systemusers = append(tempTag.Systemusers, adminId)
		}

		// Create or modify the tag in JumpCloud
		optionals := map[string]interface{}{
			"xOrgId": outerOptionals["xOrgId"],
			"body":   tempTag,
		}
		_, _, err2 = jc.TagsApi.TagsPut(auth, tempTag.Name, CONTENT_TYPE, ACCEPT, optionals)
		if err2 != nil {
			err = fmt.Errorf("Could not POST tag '%s', err='%s'", tagToString(tempTag), err)
		} else {
			fmt.Printf("\tCreated tag '%s' (ID '%s')\n", tempTag.Name, tempTag.Id)
		}
	}

	return
}

//
// Main Entry Point...
//

func main() {
	// Input parameters
	var apiKey string
	var csvFile string
	var orgId string
	var url string

	// Obtain the input parameters
	flag.StringVar(&csvFile, "csv", "", "-csv=<filename>")
	flag.StringVar(&apiKey, "key", "", "-key=<API-key-value>")
	flag.StringVar(&orgId, "org", "", "-org=<organizationID> (optional for multi-tenant administrators)")
	flag.StringVar(&url, "url", urlBase, "-url=<jumpcloud-api-url> (optional, use outside of production)")
	flag.Parse()

	if csvFile == "" || apiKey == "" {
		fmt.Println("Usage of ./CSVImporter:")
		fmt.Println("  -csv=\"\": -csv=<filename>")
		fmt.Println("  -key=\"\": -key=<API-key-value>")
		fmt.Println("  -org=\"\": -org=<organizationID> (optional for multi-tenant administrators)")
		fmt.Println("  -url=\"\": -url=<jumpcloud-api-url> (optional, use outside of production)")
		return
	}

	if orgId == "" {
		fmt.Println("You may specify an orgID for multi-tenant administrators")
	}

	if url != urlBase {
		fmt.Printf("URL overridden from: %s to %s\n", urlBase, url)
	}

	config := jcapiv1.NewConfiguration()
	var apiClientV1 *jcapiv1.APIClient
	apiClientV1 = jcapiv1.NewAPIClient(config)
	apiClientV1.ChangeBasePath(url)

	var authv1 context.Context
	authv1 = context.WithValue(context.TODO(), jcapiv1.ContextAPIKey, jcapiv1.APIKey{
		Key: apiKey,
	})

	optionals := map[string]interface{}{
		"xOrgId": orgId,
	}

	// Attach to JumpCloud
	result, _, err := apiClientV1.SystemusersApi.SystemusersList(authv1, CONTENT_TYPE, ACCEPT, optionals)

	if err != nil {
		fmt.Printf("Could not read system users, err='%s'\n", err)
		return
	}

	// Setup access the CSV file specified
	inFile, err := os.Open(csvFile)

	if err != nil {
		fmt.Printf("Error opening CSV file %s, err=%s\n", csvFile, err)
		return
	}

	defer inFile.Close()

	reader := csv.NewReader(inFile)
	reader.FieldsPerRecord = -1 // indicates records have optional fields

	// Process each user/request record found in the CSV file...
	recordCount := 1

	for {
		// Read next record from CSV file
		record, err := reader.Read()

		// Exit loop at the end of file or on error
		if err == io.EOF {
			fmt.Println("<EOF>")
			break
		} else if err != nil {
			fmt.Printf("ERROR: Could not read CSV file %s, line %d, err=%s\n", csvFile, recordCount, err)
			return
		}

		fmt.Printf("Line #%d:\n", recordCount)

		// Process this request record
		err = ProcessCSVRecord(*apiClientV1, &result, record, authv1, optionals)
		if err != nil {
			fmt.Printf("\tERROR: %s\n", err)
		}

		// Indicate that we processed another line of the CSV file
		recordCount = recordCount + 1
	}

	// Print run summary
	fmt.Printf("\n\nProcessed %d records from file %s \n", recordCount-1, csvFile)

	return
}
