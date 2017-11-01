package main

import (
	"flag"
	"fmt"
	"log"
	"regexp"
	"strings"
	"time"

	"github.com/TheJumpCloud/jcapi"
)

const (
	COMMAND_NAME_RANDOM_PART int = 16

	MAX_COMMAND_LEN int = 16384 // Maximum size of a command to send to JumpCloud

	RESULT_POLL_TIME     int = 5  // Check every RESULT_POLL_TIME seconds for command results
	RESULT_MAX_POLL_TIME int = 70 // Stop checking for results after RESULT_MAX_POLL_TIME_SECONDS (must be a minimum of 60 seconds)

	URL_BASE string = "https://console.jumpcloud.com/api"
)

func makeImmediateCommand(name, command, commandType, shell, user string) jcapi.JCCommand {
	return jcapi.JCCommand{
		Name:        name,
		Command:     command,
		CommandType: commandType,
		User:        user,
		LaunchType:  "manual",
		Schedule:    "immediate",
		Timeout:     "0", // No timeout
		ListensTo:   "",
		Trigger:     "",
		Sudo:        false,
		Shell:       shell,
		Skip:        0,
		Limit:       10,
	}
}

func deleteCommandResultsByName(jc jcapi.JCAPI, commandName string) (err error) {
	results, err := jc.GetCommandResultsByName(commandName)
	if err != nil {
		err = fmt.Errorf("Could not find the command result for '%s', err='%s'", commandName, err.Error())
		return
	}

	errors := make([]string, 0, len(results))

	for _, result := range results {

		err = jc.DeleteCommandResult(result.Id)
		if err != nil {
			errors = append(errors, err.Error())
			err = nil
		}
	}

	if len(errors) > 0 {
		err = fmt.Errorf("One or more deletes failed, err='%s'", strings.Join(errors, "\n"))
		return
	}

	return
}

func findSystemsByOSType(systems []jcapi.JCSystem, osTypeRegEx string) (indices []int, err error) {
	r, err := regexp.Compile(osTypeRegEx)
	if err != nil {
		err = fmt.Errorf("Could not compile regex for '%s', err='%s'", osTypeRegEx, err.Error())
		return
	}

	for idx, system := range systems {
		if r.Match([]byte(system.Os)) && system.Active {
			indices = append(indices, idx)
		}
	}

	return
}

func getSystemNameMap(jc jcapi.JCAPI, idList []string) (systemNameMap map[string]jcapi.JCSystem, err error) {
	systemNameMap = make(map[string]jcapi.JCSystem)

	//
	// Walk the IDs on which we ran the command, and create a map of host name to
	// JCSystem object. This allows us to determine which command results go with
	// which commands.
	//
	for _, id := range idList {
		system, err2 := jc.GetSystemById(id, false)
		if err2 != nil {
			err = fmt.Errorf("Could not get system object for id '%s', err='%s'", id, err.Error())
			return
		}

		systemNameMap[system.Hostname] = system
	}

	return
}

func waitForAndProcessResults(jc jcapi.JCAPI, commandObj jcapi.JCCommand) (outputBuffer string, err error) {
	systemsFound := make(map[string]jcapi.JCResponse)

	systemNameMap, err := getSystemNameMap(jc, commandObj.Systems)
	if err != nil {
		err = fmt.Errorf("Could not map system names to systems, err='%s'", err.Error())
		return
	}

	fmt.Printf("\nWaiting for results...")

	for i := 0; i < RESULT_MAX_POLL_TIME; i += RESULT_POLL_TIME {
		time.Sleep(time.Duration(RESULT_POLL_TIME) * time.Second)

		fmt.Printf(".")

		results, err2 := jc.GetCommandResultsByName(commandObj.Name)
		if err2 != nil {
			err = fmt.Errorf("Could not find the command result for '%s', err='%s'", commandObj.Name, err2.Error())
			return
		}

		// Walk the results and add their exit code to the map (maps system name to the result data)
		for _, result := range results {
			details, err2 := jc.GetCommandResultDetailsById(result.Id)
			if err2 != nil {
				err = fmt.Errorf("Could not get command result details by ID, err='%s'", err.Error())
				return
			}
			systemsFound[result.System] = details.Response
		}

		if len(results) == len(commandObj.Systems) {

			//
			// Note, this isn't guaranteed to get the actual result of the command, as the command
			// may still be running. If the result is important to you, you'll probably want to verify
			// that the result.ResponseTime is set to a valid time before you stop gathering result
			// data.
			//
			break
		}
	}

	fmt.Printf("done.\n\n")

	// Output the results for all systems that were successful
	headerBuffer := fmt.Sprintf("Systems with a zero exit code\n")
	headerBuffer += fmt.Sprintf("=============================\n")

	dataBuffer := ""

	for systemId, result := range systemsFound {
		if result.Data.ExitCode == 0 && result.Error == "" {
			dataBuffer += fmt.Sprintf("ID %s: Completed, exit code=%d, output=[%s]\n", systemId, result.Data.ExitCode, result.Data.Output)
		}
	}

	if dataBuffer != "" {
		outputBuffer = headerBuffer + dataBuffer
	}

	// Output the results for all systems that returned a non-zero exit code
	headerBuffer = fmt.Sprintf("\nSystems with non-zero exit code\n")
	headerBuffer += fmt.Sprintf("===============================\n")

	dataBuffer = ""

	for systemId, result := range systemsFound {
		if result.Data.ExitCode > 0 || result.Error != "" {
			dataBuffer += fmt.Sprintf("ID %s: Failed, exit code=%d, error=[%s]\n", systemId, result.Data.ExitCode, result.Error)
		}
	}

	if dataBuffer != "" {
		outputBuffer = headerBuffer + dataBuffer
	}

	// Output the results for all systems that did not return any result
	headerBuffer = fmt.Sprintf("\nSystems with no command result\n")
	headerBuffer += fmt.Sprintf("===============================\n")

	dataBuffer = ""

	for hostName, _ := range systemNameMap {
		if _, exists := systemsFound[hostName]; !exists {
			dataBuffer += fmt.Sprintf("ID %s (%s): Received no command result\n", systemNameMap[hostName].Id, hostName)
		}
	}

	if dataBuffer != "" {
		outputBuffer += headerBuffer + dataBuffer
	}

	return
}

//
// This example accepts an API key and the name of the file to execute commands against. You can then
// specify a regular expression for the JCSystem.Os value of the systems you want the command to run
// against.
//
// It will write the results of the commands to stdout when exitCode != 0
//
func main() {
	apiKey := flag.String("api-key", "none", "Your JumpCloud Administrator API Key")
	commandFile := flag.String("command-file", "myCommand.txt", "The name of a file containing a command to run")
	commandType := flag.String("command-type", "windows", "OS type of the command, 'linux', 'windows', or 'mac'")
	shell := flag.String("shell", "powershell", "Shell (Windows-only) (powershell/cmd)")
	osType := flag.String("os-type", "Windows.*", "A regular expression to match your systems for OS type")
	deleteFlag := flag.Bool("delete-after-run", false, "When true, delete commands and results at completion.")

	flag.Parse()

	jc := jcapi.NewJCAPI(*apiKey, URL_BASE)

	// Generate a randomized command name
	commandName := "CMD " + makeRandomString(COMMAND_NAME_RANDOM_PART)

	// Read the input file
	commandData, err := readFile(*commandFile, MAX_COMMAND_LEN)
	if err != nil {
		log.Fatalf("Could not read command, err='%s'", err.Error())
	}

	// Make the command object
	commandObj := makeImmediateCommand(commandName, commandData, *commandType, *shell, jcapi.COMMAND_ROOT_USER)

	//
	// Get the list of matching servers and add them to the command
	//
	systems, err := jc.GetSystems(false)
	if err != nil {
		log.Fatalf("Could not get a list of all systems, err='%s'")
	}

	indices, err := findSystemsByOSType(systems, *osType)
	if err != nil {
		log.Fatalf("Could not search a list of systems for OS type matching '%s', err='%s'", *osType, err.Error())
	}

	if len(indices) == 0 {
		log.Fatalf("No systems match '%s' on your JumpCloud account\n", *osType)
	}

	fmt.Printf("Executing Command on the Following Systems\n")
	fmt.Printf("------------------------------------------\n")

	for _, index := range indices {
		fmt.Printf("%s\t%s\n", systems[index].Id, systems[index].Hostname)

		commandObj.Systems = append(commandObj.Systems, systems[index].Id)
	}

	//
	// Add the command object to the JumpCloud account
	//
	commandObj, err = jc.AddUpdateCommand(jcapi.Insert, commandObj)
	if err != nil {
		log.Fatalf("Could not POST a new command, err='%s'", err.Error())
	}
	if *deleteFlag {
		defer jc.DeleteCommand(commandObj)
	}

	//
	// Run the command
	//
	err = jc.RunCommand(commandObj)
	if err != nil {
		log.Fatalf("Could not run the command '%s', err='%s'", commandObj.ToString(), err.Error())
	}
	if *deleteFlag {
		defer deleteCommandResultsByName(jc, commandName)
	}

	//
	// Wait for results to come back from each command executed, but don't wait forever if some of the results
	// don't come back. Write to stdout as results are returned, and after a specified timeout, output the list
	// of failed commands and commands that did not run within the specified timeout.
	//
	outputBuffer, err := waitForAndProcessResults(jc, commandObj)
	if err != nil {
		log.Fatalf("Could not wait for and process results, err='%s'", err.Error())
	}

	fmt.Printf(outputBuffer)

	return
}
