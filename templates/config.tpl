package config

import (
	"fmt"
	"github.com/joho/godotenv"
	"log"
	"os"
	"strconv"
)

var (
	PORT      = 0
	SECRETKEY []byte
	DBNAME  = ""
	DBDRIVER  = ""
	DBURL     = ""
	DBDATAURL     = ""
)

// Load the server PORT
func init() {
	var err error
	err = godotenv.Load("config.env")
	if err != nil {
		log.Fatal(err)
	}
	PORT, err = strconv.Atoi(os.Getenv("API_PORT"))
	if err != nil {
		PORT = 9000
	}
	Env:=os.Getenv("Env")

	if Env =="Debug"{
		DBDATAURL=fmt.Sprintf("%s:%s@tcp(127.0.0.1:3306)/?charset=utf8mb4", os.Getenv("DB_USER"), os.Getenv("DB_PASSWORD_Debug"), )
		DBURL = fmt.Sprintf("%s:%s@/%s",
			os.Getenv("DB_USER"),
			os.Getenv("DB_PASSWORD_Debug"),
			os.Getenv("DB_NAME"),
		) + "?charset=utf8mb4&parseTime=true&loc=Asia%2FShanghai"
	}else {
		DBDATAURL=fmt.Sprintf("%s:%s@tcp(mysql-server)/?charset=utf8mb4", os.Getenv("DB_USER"), os.Getenv("DB_PASSWORD_Debug"), )
		DBURL = fmt.Sprintf("%s:%s@tcp(mysql-server)/%s",
			os.Getenv("DB_USER"),
			os.Getenv("DB_PASSWORD_Release"),
			os.Getenv("DB_NAME"),
		) + "?charset=utf8mb4&parseTime=true&loc=Asia%2FShanghai"
	}
	DBNAME = os.Getenv("DB_NAME")
	DBDRIVER = os.Getenv("DB_DRIVER")
	SECRETKEY = []byte(os.Getenv("API_SECRET"))
}

