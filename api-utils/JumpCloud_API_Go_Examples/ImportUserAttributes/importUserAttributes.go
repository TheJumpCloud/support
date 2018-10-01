package main

import (
	"bufio"
	"encoding/csv"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"os"
	"regexp"
	"time"

	"github.com/TheJumpCloud/jcapi"
)

const (
	defaultURLBase = "https://console.jumpcloud.com/api"
	defaultOutFile = "results.log"
)

type userAttributes struct {
	Attributes []jcapi.JCUserAttribute `json:"attributes"`
}

func getUserByEmail(jc jcapi.JCAPI, email string) ([]jcapi.JCUser, error) {
	jcUsers, jcErr := jc.GetSystemUserByEmail(email, false)

	if jcErr != nil {
		return nil, fmt.Errorf("Error retrieving user for email %s: %s", email, jcErr)
	}
	return jcUsers, nil
}

func buildAttributes(user jcapi.JCUser, userRecord []string, attributeNames []string) userAttributes {

	// build map of existing user attributes
	attributeMap := make(map[string]jcapi.JCUserAttribute)
	for _, attribute := range user.Attributes {
		attributeMap[attribute.Name] = attribute
	}

	// add or overwrite attributes from file record
	recordLen := len(userRecord)
	for i, attributeName := range attributeNames {
		attribute := jcapi.JCUserAttribute{Name: attributeName}
		// acount for empty attributes at end of record
		if recordLen > (i + 1) {
			attribute.Value = userRecord[i+1]
		}
		attributeMap[attributeName] = attribute
	}

	attributeArray := make([]jcapi.JCUserAttribute, 0, len(attributeMap))
	for _, attribute := range attributeMap {
		attributeArray = append(attributeArray, attribute)
	}

	return userAttributes{attributeArray}
}

func importUserAttributes(jc jcapi.JCAPI, user jcapi.JCUser, attributes userAttributes) error {

	b, err := json.Marshal(attributes)
	if err != nil {
		return fmt.Errorf("Error converting attributes to JSON: %s", err.Error())
	}

	url := "/systemusers/" + user.Id
	_, jcErr := jc.Put(url, b)
	if jcErr != nil {
		return fmt.Errorf("Error setting attribute(s) on user %s: %s", user.Email, jcErr.Error())
	}
	return nil

}

func validateAttributeNames(attributeNames []string) error {

	// 0 < length < 32
	// Alphanumeric, no spaces
	isAlphaNumeric := regexp.MustCompile(`^[0-9A-Za-z]+$`).MatchString
	for _, attributeName := range attributeNames {
		nameLen := len(attributeName)
		if nameLen == 0 {
			return fmt.Errorf("Attribute name is empty")
		}
		if nameLen > 32 {
			return fmt.Errorf("Attribute name exceeds 32 characters [%s]", attributeName)
		}
		if !isAlphaNumeric(attributeName) {
			return fmt.Errorf("Attribute name contains non-alphanumeric characters or spaces [%s]", attributeName)
		}
	}

	return nil

}

func outputResultsToFile(outputFilePath string, attributeCount int, userCount int, importedUserCount int, unknownUsers []string, errorsByUser map[string]error) {

	// Write to results file
	outputFile, err := os.Create(outputFilePath)
	if err != nil {
		fmt.Printf("Error creating output file: %s\n", err.Error())
		return
	}

	defer outputFile.Close()

	writer := bufio.NewWriter(outputFile)

	writer.WriteString("User Attribute Import Results\n")
	writer.WriteString(fmt.Sprintf("  %d attributes processed\n", attributeCount))
	writer.WriteString(fmt.Sprintf("  %d users processed\n", userCount))
	writer.WriteString(fmt.Sprintf("  %d users had attributes imported\n", importedUserCount))
	writer.WriteString(fmt.Sprintf("  %d users not found\n", len(unknownUsers)))
	writer.WriteString(fmt.Sprintf("  %d errors processing users\n", len(errorsByUser)))

	if len(unknownUsers) > 0 {
		writer.WriteString("\nUnknown Users:\n")
		for _, userEmail := range unknownUsers {
			writer.WriteString(fmt.Sprintf("  %s\n", userEmail))
		}
	}

	if len(errorsByUser) > 0 {
		fmt.Println("\nUser Errors:")
		for email, err := range errorsByUser {
			writer.WriteString(fmt.Sprintf("  %s: %s\n", email, err.Error()))
		}
	}

	writer.Flush()

}

func main() {

	// input parameters
	apiKey := flag.String("api-key", "", "Your JumpCloud Administrator API Key")
	inputFilePath := flag.String("input", "", "CSV file containing user identifier and attributes")
	outputFilePath := flag.String("output", defaultOutFile, "Results file")
	baseURL := flag.String("url", defaultURLBase, "Base API Url override")
	orgId := flag.String("org", "", "Your multi-tenant administrator's organization ID (optional)")

	flag.Parse()

	if *apiKey == "" || *inputFilePath == "" {
		flag.Usage()
		return
	}

	if *baseURL != defaultURLBase {
		fmt.Printf("URL overridden from: %s to: %s", defaultURLBase, baseURL)
	}

	// Attach to JumpCloud API
	jc := jcapi.NewJCAPI(*apiKey, *baseURL)
	if *orgId != "" {
		jc.OrgId = *orgId
	} else {
		fmt.Println("You may specify an orgID for multi-tenant administrators.")
	}

	// Setup access to input/output files
	inputFile, err := os.Open(*inputFilePath)
	if err != nil {
		fmt.Printf("Error opening input file %s: %s\n", *inputFilePath, err)
		return
	}
	defer inputFile.Close()

	// Read input file and process users one at a time
	reader := csv.NewReader(inputFile)
	reader.FieldsPerRecord = -1 // indicates records have optional fields

	// Read header row (email, attributeName(s)...)
	headerRecord, err := reader.Read()
	if err != nil {
		fmt.Printf("Error reading header row: %s\n", err)
		return
	}

	if len(headerRecord) < 2 {
		fmt.Printf("Invalid header row: File must contain at least 2 columns\n")
		return
	}

	attributeNames := headerRecord[1:]
	err = validateAttributeNames(attributeNames)
	if err != nil {
		fmt.Printf("Invalid attribute name: %s\n", err)
		return
	}

	// Result tracking
	userCount := 0
	importedUserCount := 0
	var unknownUsers []string
	var errorsByUser = make(map[string]error)

	// Read each row (email + attribute values)
	for {

		record, err := reader.Read()
		if err == io.EOF {
			break
		}

		userCount++
		if err != nil {
			fmt.Printf("Error reading record on line %d: %s\n", userCount+1, err)
			return
		}

		// sleep every 50 users to not overload API server
		if userCount%50 == 0 {
			fmt.Printf("%d users processed. Sleeping 5 seconds...\n", userCount)
			time.Sleep(time.Second * 5)
		}

		// Fetch user by email
		email := record[0]
		users, err := getUserByEmail(jc, email)
		if err != nil {
			errorsByUser[email] = err
			continue
		}
		if len(users) == 0 {
			unknownUsers = append(unknownUsers, email)
			continue
		}

		// Build attribute list and import
		user := users[0]
		attributes := buildAttributes(user, record, attributeNames)
		err = importUserAttributes(jc, user, attributes)
		if err != nil {
			errorsByUser[email] = err
		} else {
			importedUserCount++
		}

	}

	outputResultsToFile(*outputFilePath, len(attributeNames), userCount, importedUserCount, unknownUsers, errorsByUser)

	fmt.Println("\nImport complete:")
	fmt.Printf("  %d attributes processed\n", len(attributeNames))
	fmt.Printf("  %d users processed\n", userCount)
	fmt.Printf("  %d users has attributes imported\n", importedUserCount)
	fmt.Printf("  %d users not found\n", len(unknownUsers))
	fmt.Printf("  %d errors processing users\n", len(errorsByUser))
	fmt.Printf("\nResults output to file %s\n\n", *outputFilePath)

	return

}
