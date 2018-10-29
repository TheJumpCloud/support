package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	jcapiv1 "github.com/TheJumpCloud/jcapi-go/v1"
)

const (
	URL_BASE string = "https://console.jumpcloud.com/api"
	CONTENT_TYPE = "application/json"
	ACCEPT = "application/json"
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

func systemToString(jcsystem *jcapiv1.System) string {
	returnVal := fmt.Sprintf("JCSystem: OS=[%s] - TemplateName=[%s] - ID=[%s] - RemoteIP=[%s] - LastContact=[%v] - Version=%s - DisplayName=%s - Hostname=%s - Arch=%s\n",
		jcsystem.Os, jcsystem.TemplateName, jcsystem.Id, jcsystem.RemoteIP, jcsystem.LastContact,
		jcsystem.Version, jcsystem.DisplayName, jcsystem.Hostname, jcsystem.Arch)

	for _, tag := range jcsystem.Tags {
		returnVal += fmt.Sprintf("\t%s\n", tag)
	}

	return returnVal
}

func tagToString(tag jcapiv1.Tag) string {
	return fmt.Sprintf("tag id=%s - name='%s' - groupName='%s' - systems='%s' - systemusers='%s' - externally_managed='%t' (%s)",
		tag.Id, tag.Name, tag.GroupName, strings.Join(tag.Systems, ","),
		strings.Join(tag.Systemusers, ","), tag.ExternallyManaged, tag.ExternalDN)
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
		fmt.Printf("URL overridden from: %s to %s\n", URL_BASE, *url)
	}

	config := jcapiv1.NewConfiguration()
	apiClientV1 := jcapiv1.NewAPIClient(config)
	apiClientV1.ChangeBasePath(*url)

	var authv1 context.Context
	authv1 = context.WithValue(context.TODO(), jcapiv1.ContextAPIKey, jcapiv1.APIKey{
		Key: *apiKey,
	})

	optionals := map[string]interface{}{
		"xOrgId": *orgId,
	}

	// Get all the systems in the account
	systems, _, err := apiClientV1.SystemsApi.SystemsList(authv1, CONTENT_TYPE, ACCEPT, optionals)
	if err != nil {
		log.Fatalf("Could not get all systems in the account, err='%s'", err.Error())
	}

	for _, system := range systems.Results {
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
				fmt.Printf("Deleting [%s] - ", systemToString(&system))

				if *enableDelete {
					_, _, err2 := apiClientV1.SystemsApi.SystemsDelete(authv1, system.Id, CONTENT_TYPE, ACCEPT, optionals)
					if err2 != nil {
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
