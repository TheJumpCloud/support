package main

import (
	"fmt"
	"math/rand"
	"os"
)

func makeRandomString(size int) (result string) {
	// This is missing any chars that could misconstrued for 0 or 1, by
	// design...
	var alpha = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	buf := make([]byte, size)

	for i := 0; i < size; i++ {
		buf[i] = alpha[rand.Intn(len(alpha))]
	}

	result = string(buf)
	return
}

func readFile(fileName string, maxLen int) (contents string, err error) {
	buffer := make([]byte, maxLen)

	file, err := os.Open(fileName)
	if err != nil {
		err = fmt.Errorf("Could not open file '%s', err='%s'", fileName, err.Error())
		return
	}
	defer file.Close()

	n, err := file.Read(buffer)
	if err != nil {
		err = fmt.Errorf("Could not read file '%s', err='%s'", fileName, err.Error())
		return
	}

	contents = string(buffer[:n])

	return
}
