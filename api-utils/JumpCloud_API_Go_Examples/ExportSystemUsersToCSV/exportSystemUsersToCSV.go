package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/TheJumpCloud/jcapi"
)

// URLBase is the production api endpoint.
const URLBase string = "https://console.jumpcloud.com/api"

var api jcapi.JCAPI

func main() {
	var apiKey string
	var commandID string
	var url string
	var outfile string

	flag.StringVar(&apiKey, "key", "", "Your JumpCloud Administrator API Key")
	flag.StringVar(&commandID, "commandid", "", "The id of the command to run")
	flag.StringVar(&outfile, "out", "", "File path for CSV output")
	flag.StringVar(&url, "url", URLBase, "Alternative Jumpcloud API URL (optional)")
	flag.Parse()

	if apiKey == "" {
		log.Fatalln("API key must be provided.")
	}

	if commandID == "" {
		log.Fatalln("Command id must be provided")
	}

	if url != URLBase {
		fmt.Printf("URL overridden from: %s to: %s", URLBase, url)
	}

	api = jcapi.NewJCAPI(apiKey, url)

	results, err := api.GetCommandResultsBySavedCommandID(commandID)
	if err != nil {
		log.Fatalln(err)
	}

	hostnameMap := createSystemIDToHostnameMap(results)

	var output *os.File
	if outfile != "" {
		path, err := filepath.Abs(outfile)
		if err != nil {
			log.Fatalln("Entered an incorrect file path for CSV output")
		}
		output, err = getFileWriter(path)
		if err != nil {
			log.Fatalln("Problem with the outfile: %s", err.Error)
		}
	} else {
		output = os.Stdout
	}

	defer output.Close()

	if err := writeResultsToCSV(results, hostnameMap, output); err != nil {
		log.Fatalln("Error writing to csv: %s", err.Error())
	}
}

func getFileWriter(absPath string) (*os.File, error) {
	if _, err := os.Stat(absPath); !os.IsNotExist(err) {
		return nil, fmt.Errorf("Output already exists")
	}

	return os.Create(absPath)
}

func writeResultsToCSV(results []jcapi.JCCommandResult, hostnameMap map[string]string, writer io.Writer) error {
	w := csv.NewWriter(writer)

	if err := w.Write([]string{"SYSTEM ID", "HOSTNAME", "USERNAME", "JUMPCLOUD USERNAME", "COMMAND REQUEST TIME"}); err != nil {
		return err
	}
	w.Flush()

	for _, result := range results {
		lines := strings.Split(result.Response.Data.Output, "\n")
		for _, line := range lines {
			line = strings.TrimSpace(line)
			if line != "" {
				if err := w.Write([]string{result.System, hostnameMap[result.System], line, "", result.RequestTime}); err != nil {
					return err
				}

			}
		}
		w.Flush()
	}
	return nil
}

func getHostnameForID(systemID string) (string, error) {
	system, err := api.GetSystemById(systemID, false)
	if err != nil {
		return "", err
	}
	return system.Hostname, nil
}

func createSystemIDToHostnameMap(results []jcapi.JCCommandResult) map[string]string {
	hostnameMap := make(map[string]string)

	for _, result := range results {
		if hostnameMap[result.System] == "" {
			hostname, err := getHostnameForID(result.System)
			if err != nil {
				log.Printf("Error fetching hostname for %s: %s", result.System, err.Error())
			}
			hostnameMap[result.System] = hostname
		}
	}
	return hostnameMap
}
