package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"github.com/TheJumpCloud/jcapi"
	"os"
	"strconv"
	"strings"
)

// URLBase is the production api endpoint.
const URLBase string = "https://console.jumpcloud.com/api"

var api jcapi.JCAPI

func main() {
	var apiKey string
	var url string

	flag.StringVar(&apiKey, "key", "", "Your JumpCloud Administrator API Key")
	flag.StringVar(&url, "url", URLBase, "Alternative Jumpcloud API URL (optional)")
	flag.Parse()

	if apiKey == "" {
		fmt.Printf("API Key must be provided.")
		return
	}

	// Attach to JumpCloud
	api = jcapi.NewJCAPI(apiKey, url)

	// Fetch all users in JumpCloud
	// Send false, because we do not want tags
	fmt.Println("Retreiving users from JumpCloud. Depending on the number of users in your organization this may take awhile")
	userList, err := api.GetSystemUsers(false)

	if err != nil {
		fmt.Printf("Could not read system users, err='%s'\n", err)
		return
	}
	fmt.Println("Users retrieved. Finding users with duplicate unix_uid and unix_guid values")
	dupeUid, dupeGuid := findDupeUidGuids(userList)
	printDupeUserValues(dupeUid, "unix_uid")
	printDupeUserValues(dupeGuid, "unix_guid")

	// Print out options for cleanup
	reader := bufio.NewReader(os.Stdin)
	fmt.Println("Now we can help you fix your duplicate values")
	fmt.Println("---------------------------------------------")
	fmt.Println("Option 1: Start from the duplicate value and increment until all users have unique values")
	fmt.Println("Option 2: Start from an admin specified value and increment until all users have unique values")
	fmt.Println("Option 3: Print all affected user ids and do nothing")

	var updateErr error
	for unixUidValue, userList := range dupeUid {
		updateErr = fixValuesInput(reader, "unix_uid", unixUidValue, userList)
		if updateErr != nil {
			fmt.Printf("Could not update users, err='%s'\n", err)
			return
		}
	}
	for unixGuidValue, userList := range dupeGuid {
		updateErr = fixValuesInput(reader, "unix_guid", unixGuidValue, userList)
		if updateErr != nil {
			fmt.Printf("Could not update users, err='%s'\n", err)
			return
		}
	}
}

func findDupeUidGuids(userList []jcapi.JCUser) (map[string][]jcapi.JCUser, map[string][]jcapi.JCUser) {
	dupeUid := make(map[string][]jcapi.JCUser)
	dupeGuid := make(map[string][]jcapi.JCUser)

	for _, user := range userList {
		dupeUid[user.Uid] = append(dupeUid[user.Uid], user)
		dupeGuid[user.Gid] = append(dupeGuid[user.Gid], user)
	}

	dupeUid = deleteSingleUserValues(dupeUid)
	dupeGuid = deleteSingleUserValues(dupeGuid)

	return dupeUid, dupeGuid
}

func deleteSingleUserValues(userValueMap map[string][]jcapi.JCUser) map[string][]jcapi.JCUser {
	for k, v := range userValueMap {
		if len(v) <= 1 {
			delete(userValueMap, k)
		}
	}
	return userValueMap
}

func printDupeUserValues(userValueMap map[string][]jcapi.JCUser, field string) {
	for k, v := range userValueMap {
		fmt.Printf("%d users have the %s value: %s\n", len(v), field, k)
	}
}

func incrementUnixValuesOnUsers(api jcapi.JCAPI, userList []jcapi.JCUser, field string, startingValue string, dryRun bool) error {
	fmt.Printf("Incrementing values on field: %s for %d systemusers\n", field, len(userList))

	// Update User Values, leaving the first in the list alone
	// Field on the proto is a string, so to make things easier, we convert to int
	// so math is easier
	intValue, _ := strconv.Atoi(startingValue)
	for idx := range userList {
		if field == "unix_uid" {
			userList[idx].Uid = strconv.Itoa(intValue)
		} else { // unix_guid
			userList[idx].Gid = strconv.Itoa(intValue)
		}
		if dryRun {
			fmt.Printf("Updating user: %s field: %s with value: %d\n", userList[idx].Id, field, intValue)
		} else { // Update User
			userId, err := api.AddUpdateUser(3, userList[idx])
			if err != nil {
				fmt.Println("Error updating user. Bailing")
				return err
			}
			fmt.Printf("User: %s successfully updated\n", userId)
		}
		intValue++
	}
	return nil
}

func usersToIdStr(userList []jcapi.JCUser) string {
	var b bytes.Buffer
	for idx := range userList {
		b.WriteString(userList[idx].Id)
		b.WriteString(" ")
	}
	return b.String()
}

func fixValuesInput(reader *bufio.Reader, field string, value string, userList []jcapi.JCUser) error {
	fmt.Printf("How would you like to fix %s value: %s that appears on %d users?\n", field, value, len(userList))
	var err error
	for {
		fmt.Print("-> ")
		option, _ := reader.ReadString('\n')
		option = strings.Replace(option, "\n", "", -1)
		if strings.Compare("1", option) == 0 {
			err = incrementUnixValuesOnUsers(api, userList, field, value, true)
			if err != nil {
				return err
			}
			fmt.Println("Please review the above values. If those values look good, type in EXECUTE. If not, type in BAIL")
			fmt.Print("-> ")
			execute, _ := reader.ReadString('\n')
			execute = strings.Replace(execute, "\n", "", -1)
			if strings.Compare("EXECUTE", execute) == 0 {
				fmt.Println("THIS OPERATION WILL REQUIRE MANUAL CLEANUP IF VALUES ARE INCORRECT.")
				fmt.Print("ARE YOU SURE? y/n? ")
				yes, _ := reader.ReadString('\n')
				yes = strings.Replace(yes, "\n", "", -1)
				if strings.Compare("y", yes) == 0 {
					fmt.Println("Updaing users!")
					err = incrementUnixValuesOnUsers(api, userList, field, value, false)
					if err != nil {
						return err
					}
				} else {
					fmt.Println("Not updating users")
				}
			} else {
				fmt.Println("Not updating users")
			}
			break
		} else if strings.Compare("2", option) == 0 {
			fmt.Print("\nPlease specify which value to start with: ")
			startingValue, _ := reader.ReadString('\n')
			startingValue = strings.Replace(startingValue, "\n", "", -1)
			err = incrementUnixValuesOnUsers(api, userList, field, startingValue, true)
			if err != nil {
				return err
			}
			fmt.Println("Please review the above values. If those values look good, type in EXECUTE. If not, type in BAIL")
			fmt.Print("-> ")
			execute, _ := reader.ReadString('\n')
			execute = strings.Replace(execute, "\n", "", -1)
			if strings.Compare("EXECUTE", execute) == 0 {
				fmt.Println("THIS OPERATION WILL REQUIRE MANUAL CLEANUP IF VALUES ARE INCORRECT.")
				fmt.Print("ARE YOU SURE? y/n? ")
				yes, _ := reader.ReadString('\n')
				yes = strings.Replace(yes, "\n", "", -1)
				if strings.Compare("y", yes) == 0 {
					fmt.Println("Updaing users!")
					err = incrementUnixValuesOnUsers(api, userList, field, startingValue, false)
					if err != nil {
						return err
					}
				} else {
					fmt.Println("Not updating users")
				}
			} else {
				fmt.Println("Not updating users")
			}
			break
		} else if strings.Compare("3", option) == 0 {
			fmt.Printf("You have choosen to manually update your users %s values", field)
			fmt.Printf("The following is a list of users with duplicate %s values", field)
			userIdsStr := usersToIdStr(userList)
			fmt.Printf("The following users have %s value: %s %s", field, value, userIdsStr)
			break
		} else {
			fmt.Println("Please pick a valid option")
		}
	}
	return nil
}
