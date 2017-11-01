package main_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"testing"
)

func TestBackupRestoreTags(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "BackupRestoreTags Suite")
}
