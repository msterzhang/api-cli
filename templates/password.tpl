package security

import (
	"encoding/base64"
	"errors"
	"log"
)

// Hash make a password hash
func Hash(password string) (string, error) {
	encoded := base64.StdEncoding.EncodeToString([]byte(password))
	return encoded, nil
}

// VerifyPassword verify the hashed password
func VerifyPassword(hashedPassword, password string) error {
	e, err := base64.StdEncoding.DecodeString(hashedPassword)
	if err != nil {
		log.Println("解析base64失败！")
	}
	if string(e) != password {
		return errors.New("密码错误！")
	}
	return nil
}
