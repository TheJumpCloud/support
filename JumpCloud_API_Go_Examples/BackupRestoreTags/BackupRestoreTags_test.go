package main

import (
	"os"
	"path/filepath"

	"github.com/TheJumpCloud/jcapi"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("BackupRestoreTags", func() {
	Describe("jcback files", func() {
		const (
			TESTFILE_1 = "testfile1.jcback"
		)

		var (
			testTag1 jcapi.JCTag
		)

		BeforeEach(func() {
			testTag1 = jcapi.JCTag{
				Id:          "testId",
				Name:        "testName",
				Systems:     []string{"system1", "system2"},
				SystemUsers: []string{"user1", "user2"},
			}
		})

		It("should write a file and read it back with the same contents", func() {
			err := writeTagFile(TESTFILE_1, testTag1)
			Expect(err).To(BeNil())
			defer os.Remove(TESTFILE_1)

			exists := fileExists(TESTFILE_1)
			Expect(exists).To(BeTrue())

			newTag, err := readTagFile(TESTFILE_1)
			Expect(err).To(BeNil())

			Expect(newTag.Id).To(Equal("testId"))
			Expect(newTag.Name).To(Equal("testName"))
			Expect(newTag.Systems[0]).To(Equal("system1"))
			Expect(newTag.Systems[1]).To(Equal("system2"))
			Expect(newTag.SystemUsers[0]).To(Equal("user1"))
			Expect(newTag.SystemUsers[1]).To(Equal("user2"))
		})

		It("should return false if a file does not exist", func() {
			exists := fileExists("missing.file")
			Expect(exists).To(BeFalse())
		})

		It("should return true if a file exists", func() {
			file, err := os.Create(TESTFILE_1)
			Expect(err).To(BeNil())
			defer func() {
				file.Close()
				os.Remove(TESTFILE_1)
			}()

			exists := fileExists(TESTFILE_1)
			Expect(exists).To(BeTrue())
		})
	})

	Describe("JC server", func() {
		var (
			tagsOnAccount []jcapi.JCTag
		)

		BeforeEach(func() {
			tagsOnAccount = []jcapi.JCTag{
				jcapi.JCTag{
					Id:          "1",
					Name:        "tag1",
					Systems:     []string{"system1", "system2"},
					SystemUsers: []string{"user1", "user2"},
				},
				jcapi.JCTag{
					Id:          "2",
					Name:        "tag2",
					Systems:     []string{"system2", "system3"},
					SystemUsers: []string{"user3", "user4"},
				},
				jcapi.JCTag{
					Id:          "3",
					Name:        "tag3",
					Systems:     []string{"system4", "system5"},
					SystemUsers: []string{"user5", "user6"},
				},
			}
		})

		Context("backup and restore", func() {
			It("should only back up zero tags when the regex matches none of them", func() {
				backedUpCount, tagCount, backupPath, err := backupTags(tagsOnAccount, "myTagNameRegex")
				Expect(err).To(BeNil())
				defer os.RemoveAll(backupPath)

				Expect(backedUpCount).To(Equal(0))
				Expect(tagCount).To(Equal(3))
			})

			It("should only back up one tag when the regex matches one", func() {
				backedUpCount, tagCount, backupPath, err := backupTags(tagsOnAccount, "tag1")
				Expect(err).To(BeNil())
				defer os.RemoveAll(backupPath)

				Expect(backedUpCount).To(Equal(1))
				Expect(tagCount).To(Equal(3))
			})

			It("should only back up two tags when the regex matches tw", func() {
				backedUpCount, tagCount, backupPath, err := backupTags(tagsOnAccount, "tag[12]")
				Expect(err).To(BeNil())
				defer os.RemoveAll(backupPath)

				Expect(backedUpCount).To(Equal(2))
				Expect(tagCount).To(Equal(3))

				exists := fileExists(filepath.Join(backupPath, "tag1.jcback"))
				Expect(exists).To(BeTrue())

				exists = fileExists(filepath.Join(backupPath, "tag2.jcback"))
				Expect(exists).To(BeTrue())
			})

			It("should read a backed up tag", func() {
				backedUpCount, tagCount, backupPath, err := backupTags(tagsOnAccount, "tag1")
				Expect(err).To(BeNil())
				defer os.RemoveAll(backupPath)

				Expect(backedUpCount).To(Equal(1))
				Expect(tagCount).To(Equal(3))

				tagFileName := filepath.Join(backupPath, "tag1.jcback")

				exists := fileExists(tagFileName)
				Expect(exists).To(BeTrue())

				newTag, err := readTagFile(tagFileName)
				Expect(err).To(BeNil())

				Expect(newTag.Id).To(Equal("1"))
				Expect(newTag.Name).To(Equal("tag1"))
				Expect(newTag.Systems[0]).To(Equal("system1"))
				Expect(newTag.Systems[1]).To(Equal("system2"))
				Expect(newTag.SystemUsers[0]).To(Equal("user1"))
				Expect(newTag.SystemUsers[1]).To(Equal("user2"))
			})
		})
	})
})
