package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"time"

	"github.com/TheJumpCloud/jcapi"
)

const (
	URL_BASE string = "https://console.jumpcloud.com/api"
)

func fileExists(fileName string) (exists bool) {
	if _, err := os.Stat(fileName); err == nil {
		exists = true
	}

	return
}

func readTagFile(backupFileName string) (tagData jcapi.JCTag, err error) {
	fileData, err := ioutil.ReadFile(backupFileName)
	if err != nil {
		return tagData, fmt.Errorf("Could not read file '%s', err='%s'", backupFileName, err)
	}

	err = json.Unmarshal(fileData, &tagData)
	if err != nil {
		return tagData, fmt.Errorf("Could not unmarshal tag data from file '%s', err='%s'", backupFileName, err)
	}

	return
}

func writeTagFile(tagFileName string, tag jcapi.JCTag) (err error) {
	tagData, err := json.Marshal(&tag)
	if err != nil {
		return fmt.Errorf("Cannot marshal tag data for tag '%s', err='%s'", tag.Name, err)
	}

	if fileExists(tagFileName) {
		return fmt.Errorf("Tag backup file '%s' exists in the current working directory, please move it before backing up.", tagFileName)
	}

	err = ioutil.WriteFile(tagFileName, tagData, 0600)
	if err != nil {
		return fmt.Errorf("Could not write tag data for tag '%s' to file '%s', err='%s'", tag.Name, tagFileName, err)
	}

	return
}

func getBackupDirName() (backupDirName string) {
	t := time.Now()
	tz, _ := t.Zone()

	backupDirName = "tagBackup-" + fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d_%s", t.Year(), t.Month(), t.Day(),
		t.Hour(), t.Minute(), t.Second(), tz)

	return
}

func backupTags(tags []jcapi.JCTag, tagRegex string) (backedUpCount, tagCount int, backupDirName string, err error) {
	regex, err := regexp.Compile(tagRegex)
	if err != nil {
		return 0, 0, "", fmt.Errorf("Could not compile regex, err='%s'", err)
	}

	backupDirName = getBackupDirName()

	err = os.MkdirAll(backupDirName, 0700)
	if err != nil {
		return 0, 0, "", fmt.Errorf("Could not create backup directory '%s', err='%s'", backupDirName, err)
	}

	for _, value := range tags {
		if regex.FindString(value.Name) != "" {
			err := writeTagFile(filepath.Join(backupDirName, value.Name+".jcback"), value)
			if err != nil {
				return 0, 0, "", fmt.Errorf("Could not write tag '%s', err='%s'", value.Name, err)
			}

			backedUpCount++
		}
	}

	tagCount = len(tags)

	return
}

func findTagByName(tags []jcapi.JCTag, tagName string) (idx int) {
	for idx, value := range tags {
		if value.Name == tagName {
			return idx
		}
	}

	return -1
}

func restoreTags(jc jcapi.JCAPI, tags []jcapi.JCTag, backupFileName string) (tagId, tagName string, err error) {
	tagData, err := readTagFile(backupFileName)
	if err != nil {
		return "", "", fmt.Errorf("Could not read tag file '%s', err='%s'", backupFileName, err)
	}

	// Does the tag already exist on the JumpCloud account?
	if findTagByName(tags, tagData.Name) > -1 {
		// So we can't touch the tag...
		return "", "", fmt.Errorf("Cannot restore tag: a tag named '%s' already exists on your account.\n\nEither delete or rename the tag on your JumpCloud account to restore from a backup file.", tagData.Name)
	}

	// Add the tag to the account
	tagId, err = jc.AddUpdateTag(jcapi.Insert, tagData)
	if err != nil {
		return "", "", fmt.Errorf("Could not POST tag '%s' from file '%s' to your JumpCloud account, err='%s'", tagData.Name, backupFileName, err)
	}

	tagName = tagData.Name

	return
}

func main() {
	apiKey := flag.String("api-key", "", "Your JumpCloud Administrator API Key.")
	backupTagRegex := flag.String("backup", "", "Set this flag to a regular expression that matches the tag names you want to backup to your local file system.")
	restoreFile := flag.String("restore", "", "Set this flag to a filename that contains a tag you want to restore back to JumpCloud.")

	flag.Parse()

	if *apiKey == "" {
		log.Fatalf("api-key is required, please set it to the API key of a JumpCloud administrator on your JumpCloud account.")
	}

	if *backupTagRegex == "" && *restoreFile == "" {
		log.Fatalf("You must specify one of '-backup=<regexp-matching-your-tags>' or 'restore=<file-name-to-restore-to-jumpcloud>'")
	}

	if *backupTagRegex != "" && *restoreFile != "" {
		log.Fatalf("You may specific only one of 'backup' or 'restore'.")
	}

	jc := jcapi.NewJCAPI(*apiKey, URL_BASE)

	tags, err := jc.GetAllTags()
	if err != nil {
		log.Fatalf("Could not extract tags from your JumpCloud account, err='%s'", err)
	}

	if *backupTagRegex != "" {
		backedUpCount, tagCount, backupDirName, err := backupTags(tags, *backupTagRegex)
		if err != nil {
			log.Fatalf("Could not backup tags matching regex '%s', err='%s'", *backupTagRegex, err)
		}

		log.Printf("Backup complete, %d tags written out of %d tags total to '%s'", backedUpCount, tagCount, backupDirName)
	}

	if *restoreFile != "" {
		tagId, tagName, err := restoreTags(jc, tags, *restoreFile)
		if err != nil {
			log.Fatalf("Could not restore tag from file '%s', err='%s'", *restoreFile, err)
		}

		log.Printf("Tag '%s' restored from file '%s' as ID [%s]", tagName, *restoreFile, tagId)
	}
}
