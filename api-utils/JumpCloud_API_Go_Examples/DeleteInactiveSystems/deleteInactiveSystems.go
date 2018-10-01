package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/TheJumpCloud/jcapi"
)

const (
	URL_BASE string = "https://console.jumpcloud.com/api"
)

func dateBeforeNDays(date string, days int) (before bool, err error) {
	dateField, err := time.Parse(time.RFC3339, date)
	if err != nil {
		err = fmt.Errorf("Could not parse date value '%s', err='%s'", date, err.Error())
		return
	}

	before = dateField.Before(time.Now().Add(time.Duration(-days) * 24 * time.Hour))

	return
}

func main() {
	apiKey := flag.String("api-key", "", "Your JumpCloud Administrator API Key")
	daysSinceLastConnection := flag.Int("days-since-last-connect", 30,
		"Systems that have not connected in this many days or more, will be deleted from JumpCloud.")
	enableDelete := flag.Bool("enable-delete", false, "Enable this flag to actually delete servers.")
	orgId := flag.String("org", "", "Your multi-tenant administrator's organization ID. (optional)")
	url := flag.String("url", URL_BASE, "Your JumpCloud url")

	flag.Parse()

	if apiKey != nil && *apiKey == "" {
		log.Fatalf("%s: You must specify an API key value (--api-key=keyValue)", os.Args[0])
	}

	if *url != URL_BASE {
		fmt.Printf("URL overridden from: %s to %s", URL_BASE, *url)
	}

	jc := jcapi.NewJCAPI(*apiKey, *url)
	if *orgId != "" {
		jc.OrgId = *orgId
	} else {
		fmt.Println("You may specify an orgID for multi-tenant administrators.")
	}

	// Get all the systems in the account
	systems, err := jc.GetSystems(false)
	if err != nil {
		log.Fatalf("Could not get all systems in the account, err='%s'", err.Error())
	}

	for _, system := range systems {
		if system.Active == false {
			var okToDelete bool

			if system.LastContact == "" {
				okToDelete = true
			} else {
				okToDelete, err = dateBeforeNDays(system.LastContact, *daysSinceLastConnection)
				if err != nil {
					log.Fatalf("Could not compare date '%s' for system ID '%s' (%s), err='%s'", system.LastContact, system.Id, system.Hostname, err.Error())
				}
			}

			if okToDelete {
				fmt.Printf("Deleting [%s] - ", system.ToString())

				if *enableDelete {
					err = jc.DeleteSystem(system)
					if err != nil {
						log.Fatalf("Delete failed, err='%s'\n", err.Error())
					} else {
						fmt.Printf("SUCCESS!\n")
					}
				} else {
					fmt.Printf("NO ACTION TAKEN, use --enable-delete to actually delete servers\n")
				}
			}
		}
	}
}
