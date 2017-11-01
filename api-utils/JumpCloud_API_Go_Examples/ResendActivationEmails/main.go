package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/TheJumpCloud/jcapi"
)

const (
	URL_BASE string = "https://console.jumpcloud.com/api"
)

func yOrN(question string) (yes bool) {
	var line string

	for line != "y" && line != "n" {
		fmt.Printf("%s? [y/n]: ", question)
		fmt.Scanln(&line)

		if line != "y" && line != "n" {
			fmt.Printf("You must enter 'y' or 'n'. Please try again.\n\n")
		}
	}

	yes = line == "y"

	return
}

func main() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage of %s:\n", os.Args[0])
		flag.PrintDefaults()
	}

	apiKey := flag.String("api-key", "", "Your JumpCloud Administrator API Key.")
	activationFlag := flag.Bool("activation", false, "Set this flag to true to resend emails only to users who have not activated their system user account.")
	pendingProvisioningFlag := flag.Bool("pendingProvisioning", false, "Set this flag to true to resend emails only to users who have not yet set their password as part of Google Apps provisioning.")

	flag.Parse()

	if *apiKey == "" {
		flag.Usage()
		log.Fatalf("api-key is required, please set it to the API key of a JumpCloud administrator on your JumpCloud account.")
	}

	if *activationFlag == false && *pendingProvisioningFlag == false {
		flag.Usage()
		log.Fatalf("Neither 'activation' nor 'pendingProvisioning' flags are set to true, no work to do.")
	}

	jc := jcapi.NewJCAPI(*apiKey, URL_BASE)

	users, err := jc.GetSystemUsers(false)

	var emailList []jcapi.JCUser

	activationCount := 0
	pendingProvisioningCount := 0

	// Find all the users and add them to the email resend list
	for _, user := range users {
		if *activationFlag && !user.Activated {
			emailList = append(emailList, user)
			activationCount++
		} else if *pendingProvisioningFlag && user.PendingProvisioning {
			emailList = append(emailList, user)
			pendingProvisioningCount++
		}
	}

	fmt.Printf("Emailing %d users who have not activated, and %d who have not yet been provisioned in Google Apps\n\n",
		activationCount, pendingProvisioningCount)

	yes := yOrN("Continue")

	if yes {
		err = jc.SendUserActivationEmail(emailList)
		if err != nil {
			log.Fatalf("Failed to send emails, err='%s'", err)
		}

		fmt.Printf("%d emails sent successfully\n", activationCount+pendingProvisioningCount)
	}
}
