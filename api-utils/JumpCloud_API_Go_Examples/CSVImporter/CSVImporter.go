package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/TheJumpCloud/jcapi"
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
	urlBase string = "https://console.jumpcloud.com/api"
)

//
// Returns the ID for the username specified if it is contained in the
// list of users provided.  (helper function)
//

func GetUserIdFromUserName(users []jcapi.JCUser, name string) string {
	returnVal := ""

	for _, user := range users {
		if user.UserName == name {
			returnVal = user.Id
			break
		}
	}

	return returnVal
}

//
// Process the line read from the CSV file into JumpCloud. (helper function)
//

func ProcessCSVRecord(jc jcapi.JCAPI, userList *[]jcapi.JCUser, csvRecord []string) (err error) {
	// Verify the record is complete enough to process
	if len(csvRecord) < 9 {
		err = fmt.Errorf("Line is improperly formatted (missing fields), skipping line.")
		return
	}

	// Setup work variables
	var currentUser jcapi.JCUser
	var currentHost string

	currentAdmins := make(map[string]string) // "user name", "user id"

	var fieldMap = map[int]*string{
		0: &currentUser.FirstName,
		1: &currentUser.LastName,
		2: &currentUser.UserName,
		3: &currentUser.Email,
		4: &currentUser.Uid,
		5: &currentUser.Gid,
		// "Sudo" boolean will be handled separately, so no 6
		7: &currentUser.Password,
		8: &currentHost,
	}

	// Parse the record provided into our work vars
	for i, element := range csvRecord {
		// Handle variable fields separately
		if i > 8 {
			break
		}

		// Special case for sole boolean to be parsed
		if i == 6 {
			currentUser.Sudo = jcapi.GetTrueOrFalse(element)
		} else if i == 3 {
			*fieldMap[i] = strings.ToLower(element)
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
			currentAdmins[tempAdmin] = GetUserIdFromUserName(*userList, tempAdmin)
		}
	}

	// Determine operation to perform based on whether the current user
	// is already in JumpCloud...
	var opCode jcapi.JCOp
	currentUserId := GetUserIdFromUserName(*userList, currentUser.UserName)

	if currentUserId != "" {
		opCode = jcapi.Update
		currentUser.Id = currentUserId
	} else {
		opCode = jcapi.Insert
	}

	// Sanity-check any UID/GID pair supplied and set management mode accordingly
	if (currentUser.Uid == "" && currentUser.Gid != "") || (currentUser.Uid != "" && currentUser.Gid == "") {
		err = fmt.Errorf("Could not process user '%s', err=Invalid UID:GID pair '%s:%s', both must be specified", currentUser.ToString(), currentUser.Uid, currentUser.Gid)
		return
	}

	if currentUser.Uid != "" || currentUser.Gid != "" {
		currentUser.EnableManagedUid = true
	}

	// Perform the requested operation on the current user and report results
	currentUserId, err = jc.AddUpdateUser(opCode, currentUser)

	if err != nil {
		err = fmt.Errorf("Could not %s user '%s', err='%s'", jcapi.MapJCOpToHTTP(opCode), currentUser.ToString(), err)
		return
	}

	if opCode == jcapi.Update {
		fmt.Printf("\tUser '%s' (ID '%s') updated from input file\n", currentUser.UserName, currentUserId)
	} else {
		fmt.Printf("\tLoaded user '%s' (ID '%s')\n", currentUser.UserName, currentUserId)
		// Add this user to our list
		currentUser.Id = currentUserId
		*userList = append(*userList, currentUser)
	}

	// Create/associate JumpCloud tags for the host and user...
	if currentHost != "" {
		// Determine if the host specified is defined in JumpCloud
		var currentJCSystem jcapi.JCSystem
		var tempSysList []jcapi.JCSystem

		tempSysList, err = jc.GetSystemByHostName(currentHost, true)
		if err != nil {
			err = fmt.Errorf("Look up for host '%s' failed - err='%s'", currentHost, err)
			return
		}

		switch {
		case len(tempSysList) > 1:
			err = fmt.Errorf("Found multiple hostnames for '%s', cannot build a tag for it.", currentHost)
			return
		case len(tempSysList) == 0:
			err = fmt.Errorf("Could not find a system for '%s', cannot build a tag for this user.", currentHost)
			return
		case len(tempSysList) == 1:
			currentJCSystem = tempSysList[0]
		default:
			return
		}

		// Construct the user's tag from the inputs
		var tempTag jcapi.JCTag

		tempTag.Name = currentHost + " - "

		if currentUser.FirstName != "" && currentUser.LastName != "" {
			tempTag.Name = tempTag.Name + currentUser.FirstName + " " + currentUser.LastName + " "
		}

		tempTag.Name = tempTag.Name + "(" + currentUser.UserName + ")"

		// Does the tag already exist?
		var tag jcapi.JCTag

		tag, err = jc.GetTagByName(tempTag.Name)
		if err != nil && !strings.Contains(err.Error(), "unexpected end of JSON input") {
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
		tempTag.ApplyToJumpCloud = true
		tempTag.Systems = append(tempTag.Systems, currentJCSystem.Id)
		tempTag.SystemUsers = append(tempTag.SystemUsers, currentUserId)

		for _, adminId := range currentAdmins {
			tempTag.SystemUsers = append(tempTag.SystemUsers, adminId)
		}

		// Create or modify the tag in JumpCloud
		tempTag.Id, err = jc.AddUpdateTag(opCode, tempTag)
		if err != nil {
			err = fmt.Errorf("Could not POST tag '%s', err='%s'", tempTag.ToString(), err)
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

	// Obtain the input parameters
	flag.StringVar(&csvFile, "csv", "", "-csv=<filename>")
	flag.StringVar(&apiKey, "key", "", "-key=<API-key-value>")
	flag.Parse()

	if csvFile == "" || apiKey == "" {
		fmt.Println("Usage of ./CSVImporter:")
		fmt.Println("  -csv=\"\": -csv=<filename>")
		fmt.Println("  -key=\"\": -key=<API-key-value>")
		return
	}

	// Attach to JumpCloud
	jc := jcapi.NewJCAPI(apiKey, urlBase)

	// Fetch all users in JumpCloud
	userList, err := jc.GetSystemUsers(false)

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
		err = ProcessCSVRecord(jc, &userList, record)
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
