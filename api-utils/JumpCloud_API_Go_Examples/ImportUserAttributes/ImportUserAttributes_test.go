package main

import (
	"github.com/TheJumpCloud/jcapi"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("ImportUserAttributes", func() {

	Describe("Building attributes struct", func() {

		var attributeNames []string
		var user jcapi.JCUser
		var userRecord []string
		var attributes userAttributes

		buildAttributeMap := func(attributes userAttributes) map[string]string {
			attributeMap := make(map[string]string)
			for _, attribute := range attributes.Attributes {
				attributeMap[attribute.Name] = attribute.Value
			}
			return attributeMap
		}

		addAttributeToUser := func(user *jcapi.JCUser, name string, value string) {
			user.Attributes = append(user.Attributes, jcapi.JCUserAttribute{Name: name, Value: value})
		}

		BeforeEach(func() {
			attributeNames = []string{"Attr1", "Attr2"}
			userRecord = []string{"email", "Value1", "Value2"}
			user = jcapi.JCUser{}
		})

		Context("With no existing attributes", func() {

			BeforeEach(func() {
				attributes = buildAttributes(user, userRecord, attributeNames)
			})
			It("should have only new attributes", func() {
				Expect(len(attributes.Attributes)).To(Equal(2))
			})
			It("should contain the correct attributes", func() {
				attributeMap := buildAttributeMap(attributes)
				Expect(attributeMap["Attr1"]).To(Equal("Value1"))
				Expect(attributeMap["Attr2"]).To(Equal("Value2"))
			})
		})

		Context("With existing attributes not in user record", func() {
			BeforeEach(func() {
				// add two non-matching attributes
				addAttributeToUser(&user, "ExistingAttr1", "ExistingValue1")
				addAttributeToUser(&user, "ExistingAttr2", "ExistingValue2")
				attributes = buildAttributes(user, userRecord, attributeNames)
			})
			It("should have new and existing attributes", func() {
				Expect(len(attributes.Attributes)).To(Equal(4))
			})
			It("should contain the correct attributes", func() {
				attributeMap := buildAttributeMap(attributes)
				Expect(attributeMap["Attr1"]).To(Equal("Value1"))
				Expect(attributeMap["Attr2"]).To(Equal("Value2"))
				Expect(attributeMap["ExistingAttr1"]).To(Equal("ExistingValue1"))
				Expect(attributeMap["ExistingAttr2"]).To(Equal("ExistingValue2"))
			})
		})

		Context("With existing attributes not in user record", func() {
			BeforeEach(func() {
				// add one matching and one non-matching attribute
				addAttributeToUser(&user, "ExistingAttr1", "ExistingValue1")
				addAttributeToUser(&user, "Attr2", "ExistingValue2")
				attributes = buildAttributes(user, userRecord, attributeNames)
			})
			It("should have replaced one attribute", func() {
				Expect(len(attributes.Attributes)).To(Equal(3))
			})
			It("should contain the correct attributes", func() {
				attributeMap := buildAttributeMap(attributes)
				Expect(attributeMap["Attr1"]).To(Equal("Value1"))
				Expect(attributeMap["Attr2"]).To(Equal("Value2"))
				Expect(attributeMap["ExistingAttr1"]).To(Equal("ExistingValue1"))
			})
		})

	})

	Describe("Validating attribute names", func() {

		var attributeNames []string
		var err error

		Context("With valid attributes", func() {
			BeforeEach(func() {
				attributeNames = []string{"ValidAttribute1", "12345678901234567890123456789012"}
				err = validateAttributeNames(attributeNames)
			})
			It("should not error", func() {
				Expect(err).To(BeNil())
			})
		})

		Context("With an empty attribute", func() {
			BeforeEach(func() {
				attributeNames = []string{""}
				err = validateAttributeNames(attributeNames)
			})
			It("should error", func() {
				Expect(err).NotTo(BeNil())
			})
		})

		Context("With an attribute containing spaces", func() {
			BeforeEach(func() {
				attributeNames = []string{"Attri Bute"}
				err = validateAttributeNames(attributeNames)
			})
			It("should error", func() {
				Expect(err).NotTo(BeNil())
			})
		})

		Context("With an attribute containing non-alphanumerics", func() {
			BeforeEach(func() {
				attributeNames = []string{"Attri_Bute"}
				err = validateAttributeNames(attributeNames)
			})
			It("should error", func() {
				Expect(err).NotTo(BeNil())
			})
		})

		Context("With an attribute that exceed 32 characters", func() {
			BeforeEach(func() {
				attributeNames = []string{"123456789012345678901234567890123"}
				err = validateAttributeNames(attributeNames)
			})
			It("should error", func() {
				Expect(err).NotTo(BeNil())
			})
		})

	})

})
