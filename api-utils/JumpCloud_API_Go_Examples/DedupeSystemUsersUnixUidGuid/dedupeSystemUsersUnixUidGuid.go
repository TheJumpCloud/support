package main

import (
	"bufio"
	"flag"
	"fmt"
	"github.com/TheJumpCloud/jcapi"
	"os"
	"sort"
	"strconv"
	"strings"
)

// URLBase is the production api endpoint.
const URLBase string = "https://console.jumpcloud.com/api"

var api jcapi.JCAPI

func main() {
	var apiKey string
	var url string
	var dryRun bool

	flag.StringVar(&apiKey, "key", "", "Your JumpCloud Administrator API Key")
	flag.StringVar(&url, "url", URLBase, "Alternative Jumpcloud API URL (optional)")
	flag.BoolVar(&dryRun, "dryRun", true, "If false, send requests. If true, print out actions")
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

	dupeUsers, uidValues, seenUids, seenGuids := findDupeUsers(userList)

	if len(dupeUsers) == 0 {
		fmt.Println("No users have duplicate values! Nothing to do here")
		return
	}

	reader := bufio.NewReader(os.Stdin)
	fmt.Println("Now we can help you fix your duplicate values")
	fmt.Println("---------------------------------------------")
	fmt.Println("To fix the duplicate values, we are going to iterate through all users with duplicate values")
	fmt.Println("And assign them the next available matching value for unix_uid and unix_guid")
	fmt.Println("To continue with updating user values, type CONTINUE, otherwise type QUIT to stop script")
	if dryRun {
		fmt.Println("DRY RUN IS ON. USERS WILL NOT BE UPDATED. SET --dryRun=false TO UPDATE USER DATA")
	}

Loop:
	for {
		fmt.Print("-> ")
		option, _ := reader.ReadString('\n')
		option = strings.Replace(option, "\n", "", -1)
		switch option {
		case "CONTINUE":
			break Loop
		case "QUIT":
			return
		default:
			fmt.Println("Enter a valid option to continue")
		}
	}
	setValue := uidValues[0]
	for _, user := range dupeUsers {
		fmt.Printf("Updating user: %s\n", user.Id)
		setValue = findNextAvaiableValue(setValue, seenUids, seenGuids)
		if dryRun {
			fmt.Printf("Previous values for user: %s unix_uid: %s unix_guid %s\n", user.Id, user.Uid, user.Gid)
			fmt.Printf("Would update user: %s with unix_uid: %d unix_guid: %d\n", user.Id, setValue, setValue)
		} else {
			user.Uid = strconv.Itoa(setValue)
			user.Gid = strconv.Itoa(setValue)
			_, err := api.AddUpdateUser(jcapi.Update, user)
			if err != nil {
				fmt.Println("Error updating user: %s. Bailing", err)
				return
			}
		}
		fmt.Printf("User: %s updated\n", user.Id)
	}
	fmt.Printf("All users updated!\n")
	return
}

func findDupeUsers(userList []jcapi.JCUser) ([]jcapi.JCUser, []int, map[int]bool, map[int]bool) {
	seenUids := make(map[int]bool)
	seenGuids := make(map[int]bool)
	dupeUsers := make([]jcapi.JCUser, 0)
	uidValues := make([]int, 0)
	guidValues := make([]int, 0)

	dupeUid := false
	dupeGuid := false
	for _, user := range userList {
		var uidInt int
		var guidInt int
		// If unix_uid or unix_guid is null in the database, we do not want to convert to integer
		// Atoi will convert this to 0, and that will give false positive duplicate values
		if user.Uid != "null" {
			uidInt, _ = strconv.Atoi(user.Uid)
		}
		if user.Gid != "null" {
			guidInt, _ = strconv.Atoi(user.Gid)
		}
		if _, ok := seenUids[uidInt]; !ok { // uid not seen before
			uidValues = append(uidValues, uidInt)
			seenUids[uidInt] = true
		} else {
			dupeUid = true
		}
		if _, ok := seenGuids[guidInt]; !ok { // guid not seen before
			guidValues = append(guidValues, guidInt)
			seenGuids[guidInt] = true
		} else {
			dupeGuid = true
		}
		if dupeUid || dupeGuid {
			dupeUsers = append(dupeUsers, user)
		}
		dupeUid = false
		dupeGuid = false
	}
	sort.Ints(uidValues)
	sort.Ints(guidValues)
	return dupeUsers, uidValues, seenUids, seenGuids
}

func findNextAvaiableValue(startValue int, seenUids map[int]bool, seenGuids map[int]bool) int {
	for {
		if !seenUids[startValue] && !seenGuids[startValue] {
			seenUids[startValue] = true
			seenGuids[startValue] = true
			return startValue
		}
		startValue++
	}
}
