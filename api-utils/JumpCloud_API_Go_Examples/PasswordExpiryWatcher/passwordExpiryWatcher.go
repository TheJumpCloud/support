package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/TheJumpCloud/jcapi"
)

func main() {
	// Input parameters
	var apiKey string
	var csvFile string
	var url string

	// Obtain the input parameters
	flag.StringVar(&csvFile, "output", "", "-output=<filename>")
	flag.StringVar(&apiKey, "key", "", "-key=<API-key-value>")
	flag.StringVar(&url, "url", jcapi.StdUrlBase, "-url=<jumpcloud-api-url> (optional for use outside production")
	flag.Parse()

	if csvFile == "" || apiKey == "" {
		fmt.Println("Usage of ./CSVImporter:")
		fmt.Println("  -output=\"\": -output=<filename>")
		fmt.Println("  -key=\"\": -key=<API-key-value>")
		fmt.Println("  -url=\"\": -url=<jumpcloud-api-url>")
		return
	}

	if url != jcapi.StdUrlBase {
		fmt.Printf("URL overridden from: %s to: %s", jcapi.StdUrlBase, url)
	}

	// Attach to JumpCloud
	jc := jcapi.NewJCAPI(apiKey, url)

	// Fetch all users who's password expires between given dates in
	userList, err := jc.GetSystemUsers(false)

	if err != nil {
		fmt.Printf("Could not read system users, err='%s'\n", err)
		return
	}

	// Setup access the CSV file specified
	path, err := filepath.Abs(csvFile)
	if err != nil {
		log.Fatal("Entered an incorrect file path for CSV output")
	}
	file, err := os.Create(path)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	w := csv.NewWriter(file)

	if err := w.Write([]string{"FIRSTNAME", "LASTNAME", "EMAIL", "PASSWORD EXPIRY DATE", "PASSWORD EXPIRED", "MFA ENABLED", "MFA VERIFIED"}); err != nil {
		log.Fatalln("error writing record to csv:", err)
	}

	for _, record := range userList {
		nullTime := time.Time{}
		var expired, passwordExpirationString string
		if record.PasswordExpired {
			expired = "YES"
		} else {
			expired = "NO"
		}
		if record.PasswordExpirationDate == nullTime {
			passwordExpirationString = "No Date Set"
		} else {
			passwordExpirationString = record.PasswordExpirationDate.String()
		}
		if err := w.Write([]string{record.FirstName, record.LastName, record.Email, passwordExpirationString, expired, strconv.FormatBool(record.EnableUserPortalMultifactor), strconv.FormatBool(record.TotpEnabled)}); err != nil {
			log.Fatalln("error writing record to csv:", err)
		}
	}
	w.Flush()

	if err := w.Error(); err != nil {
		log.Fatal(err)
	}

	fmt.Println("Finished")

	return
}
